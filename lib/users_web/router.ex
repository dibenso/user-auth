defmodule UsersWeb.Router do
  use UsersWeb, :router

  pipeline :graphql do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()
    plug UsersWeb.Context

    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :graphql

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      interface: :playground,
      schema: UsersWeb.Schema,
      json_codec: Jason

    forward "/", Absinthe.Plug, schema: UsersWeb.Schema
  end
end
