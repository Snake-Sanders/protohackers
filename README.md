# Protohackers

Following exercises done in the TY [channel](https://www.youtube.com/channel/UCiaFBwlunX1m8FKwZQ1GOSA) 

## Installation

See `./.tool-versions`

```
asdf install elixir 1.14.2
asdf global elixir 1.14.2 
asdf global erlang 25.2
```

Created with `mix new protohackers --sup`

## Execution 

`mix run --no-halt`

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/protohackers](https://hexdocs.pm/protohackers).

## Testing 

For testing the port it is convinient to use `netcat`.
Start the _Echo Server_ in a terminal and, in a separate terminal, send a message as shown below:

```
echo hello world | nc localhost 5001
hello world
```
