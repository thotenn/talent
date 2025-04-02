defmodule Talent.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Accounts.{User, UserToken, UserNotifier, Network, PersonInfo, PersonNetwork}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: email)
    if User.valid_password?(user, password) && user.confirmed_at != nil do
      user
    else
      nil
    end
  end

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  # defp confirm_user_automatically(user) do
  #   now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  #   user
  #   |> Ecto.Changeset.change(confirmed_at: now)
  #   |> Repo.update()
  # end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_user_email(user, "valid password", %{email: ...})
      {:ok, %User{}}

      iex> apply_user_email(user, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_user_email(user, password, attrs) do
    user
    |> User.email_changeset(attrs)
    |> User.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset =
      user
      |> User.email_changeset(%{email: email})
      |> User.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(%User{} = user, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if user.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, user_token} = UserToken.build_email_token(user, "confirm")
      Repo.insert!(user_token)
      UserNotifier.deliver_confirmation_instructions(user, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "confirm"),
         %User{} = user <- Repo.one(query),
         {:ok, %{user: user}} <- Repo.transaction(confirm_user_multi(user)) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  defp confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(%User{} = user, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "reset_password")
    Repo.insert!(user_token)
    UserNotifier.deliver_reset_password_instructions(user, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      %User{}

      iex> get_user_by_reset_password_token("invalidtoken")
      nil

  """
  def get_user_by_reset_password_token(token) do
    with {:ok, query} <- UserToken.verify_email_token_query(token, "reset_password"),
         %User{} = user <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, User.password_changeset(user, attrs))
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Gets a list of users with a specific role.
  """
  def list_users_by_role(role) do
    User
    |> where([u], u.role == ^role)
    |> Repo.all()
  end

  @doc """
  Updates a user's role.
  """
  def update_user_role(%User{} = user, role) do
    user
    |> User.role_changeset(%{role: role})
    |> Repo.update()
  end

  alias Talent.Accounts.User

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
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
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

  @doc """
  Desactiva un usuario estableciendo confirmed_at a nil.
  """
  def deactivate_user(%User{} = user) do
    user
    |> Ecto.Changeset.change(confirmed_at: nil)
    |> Repo.update()
  end

  #
  # Network functions
  #
  @doc """
  Returns the list of networks.
  """
  def list_networks do
    Repo.all(Network)
  end

  @doc """
  Gets a single network.
  """
  def get_network!(id), do: Repo.get!(Network, id)

  @doc """
  Creates a network.
  """
  def create_network(attrs \\ %{}) do
    %Network{}
    |> Network.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a network.
  """
  def update_network(%Network{} = network, attrs) do
    network
    |> Network.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a network.
  """
  def delete_network(%Network{} = network) do
    Repo.delete(network)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking network changes.
  """
  def change_network(%Network{} = network, attrs \\ %{}) do
    Network.changeset(network, attrs)
  end

  # PersonInfo functions
  @doc """
  Returns the list of person_infos.
  """
  def list_person_infos do
    Repo.all(PersonInfo)
  end

  @doc """
  Gets a single person_info.
  """
  def get_person_info!(id), do: Repo.get!(PersonInfo, id) |> Repo.preload(:person_networks)

  @doc """
  Creates a person_info.
  """
  def create_person_info(attrs \\ %{}) do
    %PersonInfo{}
    |> PersonInfo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a person_info.
  """
  def update_person_info(%PersonInfo{} = person_info, attrs) do
    person_info
    |> PersonInfo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a person_info.
  """
  def delete_person_info(%PersonInfo{} = person_info) do
    Repo.delete(person_info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person_info changes.
  """
  def change_person_info(%PersonInfo{} = person_info, attrs \\ %{}) do
    PersonInfo.changeset(person_info, attrs)
  end

# Funciones simplificadas y robustas para agregar al final de lib/talent/accounts.ex

  @doc """
  Creates a person_info with associated networks.
  """
  def create_person_info_with_networks(person_info_params, networks_params) do
    # Si no hay un nombre completo, no crear person_info
    if is_nil(person_info_params) || is_nil(person_info_params["full_name"]) || person_info_params["full_name"] == "" do
      {:ok, %{person_info: nil}}
    else
      # Insertar persona
      person_info_changeset = PersonInfo.changeset(%PersonInfo{}, person_info_params)
      case Repo.insert(person_info_changeset) do
        {:ok, person_info} ->
          # Crear redes sociales si existen
          create_networks_for_person(person_info.id, networks_params)
          {:ok, %{person_info: person_info}}

        {:error, changeset} ->
          {:error, :person_info, changeset, %{}}
      end
    end
  end

  @doc """
  Updates a person_info with associated networks.
  """
  def update_person_info_with_networks(%PersonInfo{} = person_info, person_info_params, networks_params) do
    # Si no hay un nombre completo, no actualizar
    if is_nil(person_info_params) || is_nil(person_info_params["full_name"]) || person_info_params["full_name"] == "" do
      {:ok, %{person_info: person_info}}
    else
      # Actualizar persona
      person_info_changeset = PersonInfo.changeset(person_info, person_info_params)
      case Repo.update(person_info_changeset) do
        {:ok, updated_person_info} ->
          # Eliminar redes existentes
          Repo.delete_all(from pn in PersonNetwork, where: pn.person_id == ^updated_person_info.id)

          # Crear nuevas redes
          create_networks_for_person(updated_person_info.id, networks_params)
          {:ok, %{person_info: updated_person_info}}

        {:error, changeset} ->
          {:error, :person_info, changeset, %{}}
      end
    end
  end

  # Crear redes sociales para una persona
  defp create_networks_for_person(person_id, networks_params) do
    if is_map(networks_params) && map_size(networks_params) > 0 do
      Enum.each(networks_params, fn {_index, network_params} ->
        if valid_network_params?(network_params) do
          network_id = parse_network_id(network_params["network_id"])

          %PersonNetwork{}
          |> PersonNetwork.changeset(%{
            person_id: person_id,
            network_id: network_id,
            username: network_params["username"] || "",
            url: network_params["url"] || ""
          })
          |> Repo.insert()
        end
      end)
    end
  end

  # Validar que los params de network sean válidos
  defp valid_network_params?(params) do
    is_map(params) &&
    params["network_id"] &&
    params["network_id"] != "" &&
    params["username"] &&
    params["username"] != ""
  end

  # Convertir ID a entero si es string
  defp parse_network_id(id) when is_binary(id) do
    {int_id, _} = Integer.parse(id)
    int_id
  end
  defp parse_network_id(id), do: id

  @doc """
  Creates a user with associated person_info.
  """
  def create_user_with_person_info(user_params, person_info_params, networks_params) do
    # Crear usuario
    user_changeset = %User{} |> User.registration_changeset(user_params)

    case Repo.insert(user_changeset) do
      {:ok, user} ->
        # Si hay info personal válida
        if has_valid_person_info?(person_info_params) do
          # Crear persona
          case create_person_info_with_networks(person_info_params, networks_params) do
            {:ok, %{person_info: person_info}} when not is_nil(person_info) ->
              # Actualizar usuario con referencia a persona
              user
              |> User.changeset(%{"person_id" => person_info.id})
              |> Repo.update()
              |> case do
                {:ok, updated_user} -> {:ok, %{user: updated_user}}
                {:error, _} -> {:ok, %{user: user}} # Devolver usuario original si falla la actualización
              end

            _ -> {:ok, %{user: user}} # Devolver usuario original si falla la creación de persona
          end
        else
          {:ok, %{user: user}} # Devolver usuario si no hay info personal
        end

      {:error, changeset} ->
        {:error, :user, changeset, %{}}
    end
  end

  @doc """
  Updates a user with associated person_info.
  """
  def update_user_with_person_info(%User{} = user, user_params, person_info_params, networks_params) do
    # Actualizar usuario
    user_changeset = User.changeset(user, user_params)

    case Repo.update(user_changeset) do
      {:ok, updated_user} ->
        # Si hay info personal válida
        if has_valid_person_info?(person_info_params) do
          if updated_user.person_id do
            # Si ya tiene person_id, actualizar
            case update_person_info_with_networks(
              get_person_info!(updated_user.person_id),
              person_info_params,
              networks_params
            ) do
              {:ok, _} -> {:ok, %{user: updated_user}}
              {:error, op, val, _} -> {:error, op, val, %{}}
            end
          else
            # Si no tiene person_id, crear nueva persona
            case create_person_info_with_networks(person_info_params, networks_params) do
              {:ok, %{person_info: person_info}} when not is_nil(person_info) ->
                # Actualizar usuario con referencia a la nueva persona
                updated_user
                |> User.changeset(%{"person_id" => person_info.id})
                |> Repo.update()
                |> case do
                  {:ok, user_with_person} -> {:ok, %{user: user_with_person}}
                  {:error, changeset} -> {:error, :user_update, changeset, %{}}
                end

              _ -> {:ok, %{user: updated_user}} # Devolver usuario actualizado si falla crear persona
            end
          end
        else
          {:ok, %{user: updated_user}} # Devolver usuario actualizado si no hay info personal
        end

      {:error, changeset} ->
        {:error, :user, changeset, %{}}
    end
  end

  # Verificar si hay información personal válida
  defp has_valid_person_info?(params) do
    is_map(params) &&
    params["full_name"] &&
    params["full_name"] != ""
  end
end
