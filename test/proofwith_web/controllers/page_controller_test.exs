defmodule ProofwithWeb.PageControllerTest do
  use ProofwithWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == "/users/log-in"
  end
end
