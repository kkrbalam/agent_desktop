defmodule AgentDesktop.IframePlug do
  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> Plug.Conn.delete_resp_header("x-frame-options")
  end
end
