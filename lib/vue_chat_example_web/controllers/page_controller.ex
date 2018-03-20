defmodule VueChatExampleWeb.PageController do
  use VueChatExampleWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
