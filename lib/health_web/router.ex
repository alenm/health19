defmodule HealthWeb.Router do
  use HealthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HealthWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/regions/:continent_iso", RegionsController, :show
    get "/regions/:continent_iso/:region_iso", RegionsController, :show
    get "/regions", RegionsController, :index
  end

end
