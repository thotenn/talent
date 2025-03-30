defmodule Talent.Directory do
  @moduledoc """
  The Directory context.
  """

  import Ecto.Query, warn: false
  alias Talent.Repo

  alias Talent.Directory.{Network, PersonInfo, PersonNetwork}

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

  #
  # PersonInfo functions
  #
  @doc """
  Returns the list of people_info.
  """
  def list_people_info do
    Repo.all(PersonInfo)
  end

  @doc """
  Gets a single person_info with all their networks preloaded.
  """
  def get_person_info!(id) do
    IO.puts("Obteniendo person_info #{id} con preloads")

    PersonInfo
    |> Repo.get!(id)
    |> Repo.preload(person_networks: :network)
  end

  @doc """
  Returns the list of people_info with networks preloaded.
  """
  def list_people_info_with_networks do
    IO.puts("Listando people_info con preloads")

    PersonInfo
    |> Repo.all()
    |> Repo.preload(person_networks: :network)
  end

  @doc """
  Creates a person_info.
  """
  def create_person_info(attrs \\ %{}) do
    IO.puts("Creando person_info con attrs: #{inspect(attrs)}")

    # Extraer redes sociales si existen
    networks_data =
      case attrs do
        %{"networks_data" => nd} when is_list(nd) -> nd
        %{networks_data: nd} when is_list(nd) -> nd
        _ -> nil
      end

    # Crear nuevo changeset
    changeset = %PersonInfo{}
                |> PersonInfo.changeset(attrs)

    # Si tenemos redes sociales, ponerlas en el changeset
    changeset = if networks_data do
      Ecto.Changeset.put_change(changeset, :networks_data, networks_data)
    else
      changeset
    end

    # Insertar y manejar las redes sociales
    changeset
    |> Repo.insert()
    |> handle_networks_data()
  end

  @doc """
  Updates a person_info.
  """
  def update_person_info(%PersonInfo{} = person_info, attrs) do
    IO.puts("Actualizando person_info #{person_info.id} con attrs: #{inspect(attrs)}")

    # Extraer redes sociales si existen
    networks_data =
      case attrs do
        %{"networks_data" => nd} when is_list(nd) -> nd
        %{networks_data: nd} when is_list(nd) -> nd
        _ -> nil
      end

    # Crear changeset
    changeset = PersonInfo.changeset(person_info, attrs)

    # Si tenemos redes sociales, ponerlas en el changeset
    changeset = if networks_data do
      Ecto.Changeset.put_change(changeset, :networks_data, networks_data)
    else
      changeset
    end

    # Actualizar y manejar las redes sociales
    changeset
    |> Repo.update()
    |> handle_networks_data()
  end

  @doc """
  Creates or updates a person and adds relationships for networks.
  """
  def handle_networks_data({:ok, person} = result) do
    networks_data = person.networks_data

    IO.puts("En handle_networks_data, person_id: #{person.id}, networks_data: #{inspect(networks_data)}")

    if is_list(networks_data) && length(networks_data) > 0 do
      # Procesar cada entrada de red social
      Enum.each(networks_data, fn network_entry ->
        # Extraer network_id y username
        {network_id, username} = extract_network_data(network_entry)

        # Solo procesar si tenemos datos válidos
        if network_id && username do
          handle_network_entry(person.id, network_id, username)
        end
      end)
    end

    # Recargar la persona con sus relaciones actualizadas
    person = get_person_info!(person.id)
    {:ok, person}
  end

  def handle_networks_data(error), do: error

  defp extract_network_data(network_entry) do
    # Extraer network_id
    network_id =
      case network_entry do
        %{"network_id" => id} when is_binary(id) and id != "" ->
          String.to_integer(id)
        %{"network_id" => id} when is_integer(id) -> id
        %{network_id: id} when is_integer(id) -> id
        %{network_id: id} when is_binary(id) and id != "" ->
          String.to_integer(id)
        _ -> nil
      end

    # Extraer username
    username =
      case network_entry do
        %{"username" => u} when is_binary(u) and u != "" -> u
        %{username: u} when is_binary(u) and u != "" -> u
        _ -> nil
      end

    {network_id, username}
  end

  defp handle_network_entry(person_id, network_id, username) do
    IO.puts("Procesando red para persona #{person_id}: network_id=#{network_id}, username=#{username}")

    # Crear la estructura para la tabla de unión
    attrs = %{
      person_id: person_id,
      network_id: network_id,
      username: username
    }

    # Ver si ya existe esta red social para la persona
    case Repo.get_by(PersonNetwork, person_id: person_id, network_id: network_id) do
      nil ->
        # No existe, crear uno nuevo
        IO.puts("Creando nueva entrada de red social")
        %PersonNetwork{}
        |> PersonNetwork.changeset(attrs)
        |> Repo.insert()
        |> case do
             {:ok, _} -> :ok
             {:error, changeset} -> IO.puts("Error inserting network: #{inspect(changeset)}")
           end

      existing ->
        # Ya existe, actualizar
        IO.puts("Actualizando red existente con ID: #{existing.id}")
        existing
        |> PersonNetwork.changeset(attrs)
        |> Repo.update()
        |> case do
             {:ok, _} -> :ok
             {:error, changeset} -> IO.puts("Error updating network: #{inspect(changeset)}")
           end
    end
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

  #
  # PersonNetwork functions
  #
  @doc """
  Returns the list of person_networks.
  """
  def list_person_networks do
    Repo.all(PersonNetwork)
  end

  @doc """
  Gets a single person_network.
  """
  def get_person_network!(id), do: Repo.get!(PersonNetwork, id)

  @doc """
  Creates a person_network.
  """
  def create_person_network(attrs \\ %{}) do
    %PersonNetwork{}
    |> PersonNetwork.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a person_network.
  """
  def update_person_network(%PersonNetwork{} = person_network, attrs) do
    person_network
    |> PersonNetwork.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a person_network.
  """
  def delete_person_network(%PersonNetwork{} = person_network) do
    Repo.delete(person_network)
  end

  @doc """
  Returns the social networks for a person
  """
  def get_networks_for_person(person_id) when is_integer(person_id) do
    PersonNetwork
    |> where([pn], pn.person_id == ^person_id)
    |> join(:inner, [pn], n in Network, on: pn.network_id == n.id)
    |> select([pn, n], %{id: pn.id, network_id: n.id, name: n.name, username: pn.username, url: pn.url})
    |> Repo.all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking person_network changes.
  """
  def change_person_network(%PersonNetwork{} = person_network, attrs \\ %{}) do
    PersonNetwork.changeset(person_network, attrs)
  end
end
