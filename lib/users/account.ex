defmodule Users.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Users.Repo

  alias Users.Account.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users with a "user" role.

  ## Examples

      iex> list_non_admin_users()
      [%User{}, ...]

  """
  def list_non_admin_users do
    query = from u in User, where: u.role == "user"
    Repo.all(query)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns a User if found by id or nil if not found

  ## Examples

      iex> get_user(123)
      User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by email.

  Returns a User if found by email or nil if not found

  ## Examples

      iex> get_user_by_email("email@example.com")
      User{}

      iex> get_user_by_email("does_not_exist@invalid.com")
      nil

  """
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Gets a single user by confirmation_token.

  Returns a User if found by confirmation_token or nil if not found

  ## Examples

      iex> get_user_by_confirmation_token("2e4ff1c2a ...")
      User{}

      iex> get_user_by_confirmation_token("9a2f4a4aa ...")
      nil

  """
  def get_user_by_confirmation_token(confirmation_token), do: Repo.get_by(User, confirmation_token: confirmation_token)

  @doc """
  Gets a single user by password_reset_token.

  Returns a User if found by password_reset_token or nil if not found

  ## Examples

      iex> get_user_by_password_reset_token("2e4ff1c2a ...")
      User{}

      iex> get_user_by_password_reset_token("9a2f4a4aa ...")
      nil

  """
  def get_user_by_password_reset_token(password_reset_token), do: Repo.get_by(User, password_reset_token: password_reset_token)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a user with an admin role.

  ## Examples

      iex> create_admin(%{field: value})
      {:ok, %User{}}

      iex> create_admin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_admin(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> change(%{role: "admin", confirmed: true})
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Confirms a user.

  ## Examples

      iex> confirm_user(user)
      {:ok, %User{}}

      iex> confirm_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def confirm_user(%User{} = user) do
    user
    |> User.update_changeset(%{confirmed: true, confirmation_token: ""})
    |> Repo.update()
  end

  @doc """
  Change user password.

  ## Examples

      iex> update_password(user, "$SuperStrong%P4ssW0rd?")
      {:ok, %User{}}

      iex> update_password(user, "badpass")
      {:error, %Ecto.Changeset{}}

  """
  def update_password(%User{} = user, password) do
    user
    |> User.update_password_changeset(%{password: password})
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
