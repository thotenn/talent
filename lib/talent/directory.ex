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
  Gets a single person_info.
  """
  def get_person_info!(id), do: Repo.get!(PersonInfo, id) |> Repo.preload([:networks, :person_networks])

  @doc """
  Creates a person_info.
  """
  def create_person_info(attrs \\ %{}) do
    %PersonInfo{}
    |> PersonInfo.changeset(attrs)
    |> Repo.insert()
    |> handle_networks_data()
  end

  @doc """
  Updates a person_info.
  """
  def update_person_info(%PersonInfo{} = person_info, attrs) do
    person_info
    |> PersonInfo.changeset(attrs)
    |> Repo.update()
    |> handle_networks_data()
  end

  @doc """
  Creates or updates a person and adds relationships for networks.
  """
  def handle_networks_data({:ok, person} = _result) do
    if networks_data = person.networks_data do
      # Procesar cada entrada de red social
      Enum.each(networks_data, fn network_entry ->
        # Solo procesar si tenemos network_id y username
        network_id = Map.get(network_entry, "network_id") || Map.get(network_entry, :network_id)
        username = Map.get(network_entry, "username") || Map.get(network_entry, :username)

        if network_id && username do
          # Crear la estructura para la tabla de unión
          attrs = %{
            person_id: person.id,
            network_id: network_id,
            username: username
          }

          # Ver si ya existe esta red social para la persona
          case Repo.get_by(PersonNetwork, person_id: person.id, network_id: network_id) do
            nil ->
              # No existe, crear uno nuevo
              %PersonNetwork{}
              |> PersonNetwork.changeset(attrs)
              |> Repo.insert()

            existing ->
              # Ya existe, actualizar
              existing
              |> PersonNetwork.changeset(attrs)
              |> Repo.update()
          end
        end
      end)
    end

    # Recargar la persona con sus relaciones actualizadas
    {:ok, get_person_info!(person.id)}
  end

  def handle_networks_data(error), do: error

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
