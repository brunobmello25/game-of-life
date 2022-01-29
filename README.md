# Compilação do projeto

Primeiramente é necessário estar com compilador `ghc` instalado.

```
sudo apt install ghc
```

Em seguida, rode o comando

```
make build
```

# Execução do projeto

Após a compilação, surgirá um binário `program` no diretório raiz do projeto. Agora basta executar este binário, passando com argumentos o nome do caso de teste seguido do número máximo de iterações que deseja executar.

Por exemplo, se quiser executar o exemplos/exemplo1.txt com 10 iterações, rode o seguinte comando:

```
./program exemplo1 10
```
