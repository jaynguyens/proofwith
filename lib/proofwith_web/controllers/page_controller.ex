defmodule ProofwithWeb.PageController do
  use ProofwithWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
