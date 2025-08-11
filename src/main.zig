const rl = @import("raylib");
const std = @import("std");

const Board = []bool;

const cellSize = 15;

const screenWidth = 800;
const screenHeight = 800;

const boardWidth = screenWidth / cellSize;
const boardHeight = screenHeight / cellSize;

pub fn main() anyerror!void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_impl.allocator();
    const board = try init_board(gpa);

    rl.initWindow(screenWidth, screenHeight, "Game of Life - brunobmello25");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        update(board);
        draw(board);
    }
}

fn update(board: Board) void {
    handle_cell_click(board);
}

fn draw(board: Board) void {
    rl.beginDrawing();
    defer rl.endDrawing();

    rl.clearBackground(.dark_gray);

    draw_board(board);
}

fn handle_cell_click(board: Board) void {
    if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();

        const boardCoord = screen_coord_to_board_coord(mouseX, mouseY);
        const x = boardCoord.@"0";
        const y = boardCoord.@"1";

        const index = linearize(x, y);
        if (index >= 0 and index < boardWidth * boardHeight) {
            board[@intCast(index)] = !board[@intCast(index)];
        }
    }
}

fn screen_coord_to_board_coord(x: i32, y: i32) struct { i32, i32 } {
    const boardX = @divTrunc(x, cellSize);
    const boardY = @divTrunc(y, cellSize);

    return .{ boardX, boardY };
}

fn draw_board(board: Board) void {
    for (0..boardHeight) |Y| {
        for (0..boardWidth) |X| {
            const x: i32 = @intCast(X);
            const y: i32 = @intCast(Y);
            if (is_alive(board, x, y)) {
                rl.drawRectangle(x * cellSize, y * cellSize, cellSize, cellSize, .white);
                rl.drawRectangleLines(x * cellSize, y * cellSize, cellSize, cellSize, .dark_gray);
            } else {
                rl.drawRectangle(x * cellSize, y * cellSize, cellSize, cellSize, .black);
                rl.drawRectangleLines(x * cellSize, y * cellSize, cellSize, cellSize, .dark_gray);
            }
        }
    }
}

fn is_alive(board: Board, x: i32, y: i32) bool {
    if (x < 0 or x >= boardWidth or y < 0 or y >= boardHeight) {
        return false;
    }
    const index = linearize(x, y);
    return board[@intCast(index)];
}

fn linearize(x: i32, y: i32) i32 {
    return y * boardWidth + x;
}

fn delinearize(index: i32) struct { i32, i32 } {
    const x = index % boardWidth;
    const y = index / boardWidth;
    return .{ x, y };
}

fn init_board(allocator: std.mem.Allocator) !Board {
    var boardData = try std.ArrayList(bool).initCapacity(allocator, @intCast(boardWidth * boardHeight));

    for (0..@intCast(boardWidth * boardHeight)) |i| {
        try boardData.insert(i, false);
    }

    return try boardData.toOwnedSlice();
}

test "linearization" {
    const x = 5;
    const y = 3;
    const index = linearize(x, y);
    try std.testing.expect(index == 3 * boardWidth + 5);
    const xd, const yd = delinearize(index);
    try std.testing.expect(xd == 5);
    try std.testing.expect(yd == 3);
}

const print = std.debug.print;
