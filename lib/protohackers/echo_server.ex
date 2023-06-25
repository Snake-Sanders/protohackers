defmodule Protohackers.EchoServer do
  use GenServer
  require Logger

  def start_link([] = _opts) do
    GenServer.start_link(__MODULE__, :no_state)
  end

  defstruct [:listen_socket]

  @impl true
  def init(:no_state) do
    listen_options = [
      mode: :binary,
      active: false,
      reuseaddr: true,
      exit_on_close: false
    ]

    case :gen_tcp.listen(5001, listen_options) do
      {:ok, listen_socket} ->
        Logger.info("Starting echo server on port 5001")
        state = %__MODULE__{listen_socket: listen_socket}
        {:ok, state, {:continue, :accept}}

      {:error, reason} ->
        Logger.info("Failed to start server on port 5001 :(")
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept, %__MODULE__{} = state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, socket} ->
        handle_connection(socket)
        {:noreply, state, {:continue, :accept}}

      {:error, reason} ->
        {:stop, reason, state}
    end
  end

  ## Helpers

  defp handle_connection(socket) do
    case recv_until_close(socket, _buffer = "", _buffered_size = 0) do
      {:ok, data} -> :gen_tcp.send(socket, data)
      {:error, reason} -> Logger.error("Failed to receive data: #{inspect(reason)}")
    end

    :gen_tcp.close(socket)
  end

  @limit _100_kb = 1024 * 100

  defp recv_until_close(socket, buffer, buffered_size) do
    case :gen_tcp.recv(socket, _read_all_bytes = 0, _timeout = 10_000) do
      {:ok, data} when buffered_size + byte_size(data) > @limit ->
        {:error, :buffer_overflow}

      {:ok, data} ->
        recv_until_close(socket, [buffer, data], buffered_size + byte_size(data))

      {:error, :closed} ->
        {:ok, buffer}

      {:error, reason} ->
        {:stop, reason}
    end
  end
end
