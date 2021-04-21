defmodule UsersWeb.UserView do
  use UsersWeb, :view
  alias UsersWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user, token: token}) do
    %{user: render_one(user, UserView, "user.json"), token: token}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
      confirmed: user.confirmed,
      confirmation_token: user.confirmation_token}
  end
end
