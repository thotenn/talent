# Script para poblar la base de datos

alias Talent.Repo
alias Talent.Accounts
alias Talent.Accounts.User
alias Talent.Competitions
alias Talent.Scoring
import Ecto.Query, only: [from: 2]

# Crear usuario administrador
{:ok, admin} = Accounts.register_user(%{
  email: "admin@admin.com",
  password: "AdminPassword123!",
  role: "administrador"
})

# En lugar de usar confirm_user, vamos a actualizar directamente el campo confirmed_at
Repo.update_all(
  from(u in User, where: u.id == ^admin.id),
  set: [confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)]
)

# Crear algunas categorías
{:ok, principiantes} = Competitions.create_category(%{
  name: "Principiantes",
  description: "Categoría para bailarines principiantes",
  max_points: 120
})

{:ok, _amateur} = Competitions.create_category(%{
  name: "Amateur",
  description: "Categoría para bailarines amateur",
  max_points: 150
})

{:ok, _profesional_femenino} = Competitions.create_category(%{
  name: "Profesional Femenino",
  description: "Categoría para bailarinas profesionales",
  max_points: 170
})

# Crear criterios de calificación para la categoría principiantes
{:ok, artistico} = Scoring.create_scoring_criterion(%{
  name: "Artístico",
  category_id: principiantes.id,
  max_points: 35
})

{:ok, _expresividad} = Scoring.create_scoring_criterion(%{
  name: "Expresividad/Actitud Escénica",
  category_id: principiantes.id,
  parent_id: artistico.id,
  max_points: 10
})

{:ok, _imagen} = Scoring.create_scoring_criterion(%{
  name: "Imagen Vestuario Maquillaje y Peinado",
  category_id: principiantes.id,
  parent_id: artistico.id,
  max_points: 10
})

{:ok, tecnico} = Scoring.create_scoring_criterion(%{
  name: "Técnico de Pole",
  category_id: principiantes.id,
  max_points: 40
})

{:ok, _fuerza} = Scoring.create_scoring_criterion(%{
  name: "Fuerza",
  category_id: principiantes.id,
  parent_id: tecnico.id,
  max_points: 10
})

{:ok, _flexibilidad} = Scoring.create_scoring_criterion(%{
  name: "Flexibilidad",
  category_id: principiantes.id,
  parent_id: tecnico.id,
  max_points: 10
})

# Crear un usuario con rol de jurado
{:ok, jurado_user} = Accounts.register_user(%{
  email: "jurado@example.com",
  password: "JuradoPassword123!",
  role: "jurado"
})

# Confirmar el usuario jurado
Repo.update_all(
  from(u in User, where: u.id == ^jurado_user.id),
  set: [confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)]
)

# Crear un juez asociado con el usuario jurado
{:ok, _juez} = Competitions.create_judge(%{
  name: "Juez Ejemplo",
  user_id: jurado_user.id
})

# Crear un usuario secretario
{:ok, secretario} = Accounts.register_user(%{
  email: "secretario@example.com",
  password: "SecretarioPassword123!",
  role: "secretario"
})

# Confirmar el usuario secretario
Repo.update_all(
  from(u in User, where: u.id == ^secretario.id),
  set: [confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)]
)

# Crear un usuario escribana
{:ok, escribana} = Accounts.register_user(%{
  email: "escribana@example.com",
  password: "EscribanaPassword123!",
  role: "escribana"
})

# Confirmar el usuario escribana
Repo.update_all(
  from(u in User, where: u.id == ^escribana.id),
  set: [confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)]
)

IO.puts("Datos iniciales creados correctamente!")
