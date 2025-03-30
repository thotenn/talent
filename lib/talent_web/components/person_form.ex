defmodule TalentWeb.Components.PersonForm do
  use TalentWeb, :html

  alias Talent.Directory.PersonInfo

  attr :person, :map, default: %{}
  attr :field_name, :string, default: "person_data"

  def person_form_fields(assigns) do
    # Ajustamos assigns para asegurar que tenemos person incluso si es nil
    assigns = assign_new(assigns, :person, fn -> nil end)

    # Obtenemos los género disponibles
    gender_options = PersonInfo.gender_options() |> Enum.map(&{&1, &1})

    # Añadimos estas variables a assigns
    assigns = assigns
      |> assign(:gender_options, gender_options)

    ~H"""
    <div class="mt-6 grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-6">
      <!-- Información básica de la persona -->
      <div class="sm:col-span-6">
        <h3 class="text-lg font-medium text-gray-900">Información Personal</h3>
        <p class="mt-1 text-sm text-gray-500">Ingrese los datos personales del perfil.</p>
      </div>

      <!-- Función auxiliar para extraer valores seguros de person -->
      <%
        get_person_field = fn field_name ->
          cond do
            is_nil(@person) -> nil
            is_struct(@person, Ecto.Association.NotLoaded) -> nil
            is_map(@person) -> Map.get(@person, field_name)
            true -> nil
          end
        end
      %>

      <!-- Nombre completo (Obligatorio) -->
      <div class="sm:col-span-6">
        <.input
          type="text"
          label="Nombre completo"
          name={"#{@field_name}[full_name]"}
          id={"#{@field_name}_full_name"}
          value={get_person_field.(:full_name)}
          required
        />
      </div>

      <!-- Nombre corto/Alias (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="text"
          label="Nombre corto o alias"
          name={"#{@field_name}[short_name]"}
          id={"#{@field_name}_short_name"}
          value={get_person_field.(:short_name)}
        />
      </div>

      <!-- Teléfono (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="tel"
          label="Teléfono"
          name={"#{@field_name}[phone]"}
          id={"#{@field_name}_phone"}
          value={get_person_field.(:phone)}
          placeholder="+123456789"
        />
      </div>

      <!-- Número de Identidad (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="text"
          label="Número de Identidad"
          name={"#{@field_name}[identity_number]"}
          id={"#{@field_name}_identity_number"}
          value={get_person_field.(:identity_number)}
        />
      </div>

      <!-- Fecha de Nacimiento (Opcional) -->
      <div class="sm:col-span-3">
        <.input
          type="date"
          label="Fecha de Nacimiento"
          name={"#{@field_name}[birth_date]"}
          id={"#{@field_name}_birth_date"}
          value={get_person_field.(:birth_date)}
        />
      </div>

      <!-- Género (Opcional, pero con opciones limitadas) -->
      <div class="sm:col-span-3">
        <.input
          type="select"
          label="Género"
          name={"#{@field_name}[gender]"}
          id={"#{@field_name}_gender"}
          value={get_person_field.(:gender)}
          options={@gender_options}
          prompt="Seleccione un género"
        />
      </div>

      <!-- Datos adicionales (Opcional) -->
      <div class="sm:col-span-6">
        <.input
          type="textarea"
          label="Datos adicionales"
          name={"#{@field_name}[extra_data]"}
          id={"#{@field_name}_extra_data"}
          value={get_person_field.(:extra_data)}
          placeholder="Información adicional relevante..."
        />
      </div>

      <!-- Sección de Redes Sociales - Solo título -->
      <div class="sm:col-span-6 mt-4">
        <h3 class="text-lg font-medium text-gray-900">Redes Sociales</h3>
        <p class="mt-1 text-sm text-gray-500">Añada sus perfiles en redes sociales usando el formulario debajo.</p>
      </div>
    </div>
    """
  end
end
