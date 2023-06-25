defmodule Protohackers.EchoServerTest do
  use ExUnit.Case

  test "echoes anything back" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 5001, mode: :binary, active: false)

    assert :gen_tcp.send(socket, "hello") == :ok
    assert :gen_tcp.send(socket, "bye") == :ok
    # closes only the write side of the socket
    :gen_tcp.shutdown(socket, :write)

    assert :gen_tcp.recv(socket, 0, 5000) == {:ok, "hellobye"}
  end

  test "echo server has a max buffer size" do
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 5001, mode: :binary, active: false)

    assert :gen_tcp.send(socket, :binary.copy("x", 1024 * 100 + 1)) == :ok
    assert :gen_tcp.recv(socket, 0) == {:error, :closed}
  end

  test "handles multiple concurrent connections" do
    tasks =
      for _ <- 1..4 do
        Task.async(fn ->
          {:ok, socket} = :gen_tcp.connect(~c"localhost", 5001, mode: :binary, active: false)

          assert :gen_tcp.send(socket, "hello") == :ok
          assert :gen_tcp.send(socket, "bye") == :ok
          # closes only the write side of the socket
          :gen_tcp.shutdown(socket, :write)

          assert :gen_tcp.recv(socket, 0, 5000) == {:ok, "hellobye"}
        end)
      end

    Enum.each(tasks, &Task.await/1)
  end
end
