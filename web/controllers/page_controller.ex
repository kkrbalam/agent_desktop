defmodule AgentDesktop.PageController do
  use AgentDesktop.Web, :controller
  import ShortMaps

  @cookie_minutes 1

  def real_secret, do: Application.get_env(:agent_desktop, :secret)

  def index(conn, params) do
    IO.inspect(params)
    render(conn, "index.html")
  end

  def show(conn, params = %{"type" => "call", "voter_account" => account_id}) do
    script = AgentDesktop.Scripts.script_for(account_id)
    voter = extract_voter(params)
    IO.inspect(script)

    conn
    |> put_resp_cookie("last_voter_account", account_id, max_age: @cookie_minutes * 60)
    |> render("call.html", ~m(script voter)a)
  end

  def show(conn, _params = %{"type" => "ready"}) do
    ~m(ready_html) = get_stage_htmls(conn)
    render(conn, "ready.html", ~m(ready_html)a)
  end

  def show(conn, _params = %{"type" => "notready"}) do
    ~m(not_ready_html) = get_stage_htmls(conn)
    render(conn, "notready.html", ~m(not_ready_html)a)
  end

  def get_stage_htmls(conn) do
    if Map.has_key?(conn.cookies, "last_voter_account") do
      AgentDesktop.Scripts.script_for(conn.cookies["last_voter_account"]).listing
    else
      AgentDesktop.Scripts.script_for("FALLBACK").listing
    end
  end

  def extract_voter(params) do
    params
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, "voter_") end)
    |> Enum.map(fn {k, v} -> {String.replace(k, "voter_", ""), v} end)
    |> Enum.into(%{})
  end

  def update(conn, ~m(secret)) do
    if secret == real_secret() do
      AgentDesktop.AirtableConfig.update()
      text(conn, "updated")
    else
      text(conn, "wrong secret. contact ben")
    end
  end

  def update(conn, _) do
    text(conn, "missing secret")
  end
end
