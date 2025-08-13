const rl = @import("raylib");
const std = @import("std");

const Board = []bool;

const cellSize = 10;

const screenWidth = 800;
const screenHeight = 800;

const boardWidth = screenWidth / cellSize;
const boardHeight = screenHeight / cellSize;

const State = enum {
    Drawing,
    Running,
    Finished,
};

const Game = struct {
    board: Board,
    nextBoard: Board,
    boardDrawed: ?Board,
    allocator: std.mem.Allocator,
    state: State = .Drawing,

    pub fn init(allocator: std.mem.Allocator) !*Game {
        const board = try init_board(allocator);
        const nextBoard = try init_board(allocator);
        const game = try allocator.create(Game);
        game.* = Game{
            .board = board,
            .nextBoard = nextBoard,
            .allocator = allocator,
            .boardDrawed = null,
        };
        return game;
    }

    pub fn deinit(self: *Game) void {
        self.allocator.free(self.board);
        self.allocator.free(self.nextBoard);
        if (self.boardDrawed) |boardDrawed| {
            self.allocator.free(boardDrawed);
        }
        self.allocator.destroy(self);
    }

    pub fn update(self: *Game) !void {
        // TODO: move this to a generic input handling function
        handle_mouse_held(self);
        try handle_start_simulating(self);
        handle_reset_to_drawing(self);

        try run_simulation(self);
    }

    pub fn draw(self: *Game) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.dark_gray);

        draw_board(self.board);
    }
};

pub fn main() anyerror!void {
    var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = gpa_impl.allocator();

    const game = try Game.init(gpa);
    defer game.deinit();

    rl.initWindow(screenWidth, screenHeight, "Game of Life - brunobmello25");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        try game.update();
        game.draw();
    }
}

fn run_simulation(game: *Game) !void {
    if (game.state != .Running) return;

    for (0..@intCast(boardWidth * boardHeight)) |i| {
        const x, const y = delinearize(@intCast(i));
        const aliveNeighbors = count_alive_neighbors(game.board, @intCast(x), @intCast(y));

        if (is_alive(game.board, @intCast(x), @intCast(y))) {
            if (aliveNeighbors < 2 or aliveNeighbors > 3) {
                game.nextBoard[i] = false;
            } else {
                game.nextBoard[i] = true;
            }
        } else {
            if (aliveNeighbors == 3) {
                game.nextBoard[i] = true;
            } else {
                game.nextBoard[i] = false;
            }
        }
    }

    const temp = game.board;
    game.board = game.nextBoard;
    game.nextBoard = temp;
}

fn count_alive_neighbors(board: Board, x: i32, y: i32) i32 {
    var count: i32 = 0;

    const directions = [_]struct { i32, i32 }{
        .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 },
        .{ -1, 0 },  .{ 1, 0 },  .{ -1, 1 },
        .{ 0, 1 },   .{ 1, 1 },
    };

    for (directions) |dir| {
        const neighborX = x + dir.@"0";
        const neighborY = y + dir.@"1";

        if (is_valid_board_coord(neighborX, neighborY) and is_alive(board, neighborX, neighborY)) {
            count += 1;
        }
    }

    return count;
}

fn is_valid_board_coord(x: i32, y: i32) bool {
    return x >= 0 and x < boardWidth and y >= 0 and y < boardHeight;
}

fn handle_mouse_held(game: *Game) void {
    if (game.state != .Drawing) return;
    if (!rl.isMouseButtonDown(rl.MouseButton.left) and !rl.isMouseButtonDown(rl.MouseButton.right)) return;

    const boardCoord = screen_coord_to_board_coord(rl.getMouseX(), rl.getMouseY());
    const boardCoordLin: usize = @intCast(linearize(boardCoord.@"0", boardCoord.@"1"));

    if (rl.isMouseButtonDown(rl.MouseButton.left)) {
        game.board[boardCoordLin] = true;
    } else if (rl.isMouseButtonDown(rl.MouseButton.right)) {
        game.board[boardCoordLin] = false;
    }
}

fn handle_reset_to_drawing(game: *Game) void {
    if (game.state != .Running) return;

    if (rl.isKeyPressed(rl.KeyboardKey.r)) {
        game.state = .Drawing;

        game.allocator.free(game.board);
        game.board = game.boardDrawed.?;
        game.boardDrawed = null;

        for (0..@intCast(boardWidth * boardHeight)) |i| {
            game.nextBoard[i] = false;
        }

        rl.setTargetFPS(60);
    }
}

fn handle_start_simulating(game: *Game) !void {
    if (game.state != .Drawing) return;

    if (rl.isKeyPressed(rl.KeyboardKey.enter)) {
        game.state = .Running;
        game.boardDrawed = try clone_board(game.board, game.allocator);

        // FIXME: probably not the best way to handle slow simulation
        rl.setTargetFPS(15);
    }
}

fn clone_board(board: Board, allocator: std.mem.Allocator) !Board {
    var clonedBoard = try std.ArrayList(bool).initCapacity(allocator, board.len);
    for (board) |cell| {
        try clonedBoard.append(cell);
    }
    return try clonedBoard.toOwnedSlice();
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

// FIXME: should return usize
fn linearize(x: i32, y: i32) i32 {
    return y * boardWidth + x;
}

fn delinearize(index: i32) struct { i32, i32 } {
    const x = @mod(index, boardWidth);
    const y = @divFloor(index, boardWidth);
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
