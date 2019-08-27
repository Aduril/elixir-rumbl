defmodule RumblWeb.UserController do
  import Logger
	use RumblWeb, :controller

  alias Elixir.Plug.Conn
  alias Rumbl.Accounts
  alias Rumbl.Accounts.User

  plug :authenticate when action in [:index, :show]

  def index(conn, _params) do
    render(conn, "index.html", users: Accounts.list_users())
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user)
  end
  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end
  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> RumblWeb.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


  defp authenticate(%Conn{ assigns: %{current_user: %{username: user}}} = conn, _) when is_binary(user) do
    conn
  end
  defp authenticate(conn, _) do
    conn
    |> put_flash(:error, "You must be logged in to access that page")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end
