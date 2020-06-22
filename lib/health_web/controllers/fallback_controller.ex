defmodule HealthWeb.FallbackController do
    use HealthWeb, :controller

    def call(conn, {:error, msg}) when is_binary(msg) do
        conn
        |> put_flash(:error, msg)
        |> redirect(to: Routes.regions_path(conn, :index))
    end

    def call(conn, {:info, msg}) when is_binary(msg) do
        conn
        |> put_flash(:info, msg)
        |> redirect(to: Routes.regions_path(conn, :index))
    end

    def call(conn, {:not_found, msg}) when is_binary(msg) do
        conn
        |> put_flash(:info, msg)
        |> redirect(to: Routes.regions_path(conn, :index))
    end



end