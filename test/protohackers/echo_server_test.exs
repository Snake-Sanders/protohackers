defmodule Protohackers.EchoServerTest do
  use ExUnit.Case

  test "echoes anything back" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 5001, mode: :binary, active: false)

    assert :gen_tcp.send(socket, "hello") == :ok
    assert :gen_tcp.send(socket, "bye") == :ok

    :gen_tcp.shutdown(socket, :write)

    assert :gen_tcp.recv(socket, 0, 5000) == {:ok, "hellobye"}
  end

  test "echo server has a max buffer size" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 5001, mode: :binary, active: false)

    assert :gen_tcp.send(socket, :binary.copy("x", 1024*100 + 1)) == :ok
    assert :gen_tcp.recv(socket, 0) == {:error, :closed}
  end
end
