defmodule HealthWeb.PageControllerTest do
  use HealthWeb.ConnCase

  test "GET /, will redirect to the regions", %{conn: conn} do
    conn = get(conn, "/")
    assert redirected_to(conn, 302) =~ "/regions"
  end

end
