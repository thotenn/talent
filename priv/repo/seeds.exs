# Script para poblar la base de datos

alias Talent.Repo
alias Talent.Accounts
alias Talent.Accounts.User
alias Talent.Competitions
alias Talent.Scoring
alias Talent.Scoring.CriterionCategory
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

{:ok, amateur} = Competitions.create_category(%{
  name: "Amateur",
  description: "Categoría para bailarines amateur",
  max_points: 150
})

{:ok, profesional_femenino} = Competitions.create_category(%{
  name: "Profesional Femenino",
  description: "Categoría para bailarinas profesionales",
  max_points: 170
})

# Crear criterios de calificación (sin asociación directa a categorías)
{:ok, artistico} = %Talent.Scoring.ScoringCriterion{}
|> Talent.Scoring.ScoringCriterion.changeset(%{
  name: "Artístico",
  description: "Evaluación de aspectos artísticos",
  max_points: 35,
  is_discount: false
})
|> Talent.Repo.insert()

{:ok, expresividad} = Scoring.create_scoring_criterion(%{
  name: "Expresividad/Actitud Escénica",
  description: "Evaluación de la expresividad y actitud en escena",
  parent_id: artistico.id,
  max_points: 10,
  is_discount: false
})

{:ok, imagen} = Scoring.create_scoring_criterion(%{
  name: "Imagen Vestuario Maquillaje y Peinado",
  description: "Evaluación de la presentación visual",
  parent_id: artistico.id,
  max_points: 10,
  is_discount: false
})

{:ok, tecnico} = Scoring.create_scoring_criterion(%{
  name: "Técnico de Pole",
  description: "Evaluación de aspectos técnicos",
  max_points: 40,
  is_discount: false
})

{:ok, fuerza} = Scoring.create_scoring_criterion(%{
  name: "Fuerza",
  description: "Evaluación de la fuerza demostrada",
  parent_id: tecnico.id,
  max_points: 10,
  is_discount: false
})

{:ok, flexibilidad} = Scoring.create_scoring_criterion(%{
  name: "Flexibilidad",
  description: "Evaluación de la flexibilidad",
  parent_id: tecnico.id,
  max_points: 10,
  is_discount: false
})

# Crear un criterio de descuento
{:ok, caidas} = Scoring.create_scoring_criterion(%{
  name: "Caídas",
  description: "Penalización por caídas durante la presentación",
  max_points: 15,
  is_discount: true
})

# Asignar criterios a categorías mediante la nueva tabla de unión
# Asignar criterios artísticos a todas las categorías
Enum.each([principiantes.id, amateur.id, profesional_femenino.id], fn category_id ->
  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: artistico.id, category_id: category_id})
  |> Repo.insert!()

  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: expresividad.id, category_id: category_id})
  |> Repo.insert!()

  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: imagen.id, category_id: category_id})
  |> Repo.insert!()
end)

# Asignar criterios técnicos a principiantes y amateur
Enum.each([principiantes.id, amateur.id], fn category_id ->
  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: tecnico.id, category_id: category_id})
  |> Repo.insert!()

  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: fuerza.id, category_id: category_id})
  |> Repo.insert!()

  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: flexibilidad.id, category_id: category_id})
  |> Repo.insert!()
end)

# Asignar el criterio de descuento a todas las categorías
Enum.each([principiantes.id, amateur.id, profesional_femenino.id], fn category_id ->
  %CriterionCategory{}
  |> CriterionCategory.changeset(%{criterion_id: caidas.id, category_id: category_id})
  |> Repo.insert!()
end)

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
{:ok, juez} = Competitions.create_judge(%{
  name: "Juez Ejemplo",
  user_id: jurado_user.id
})

# Asignar el juez a categorías
Competitions.assign_judge_to_category(juez.id, principiantes.id)
Competitions.assign_judge_to_category(juez.id, amateur.id)

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

# Crear algunos participantes
{:ok, _} = Competitions.create_participant(%{
  name: "Ana Rodríguez",
  category_id: principiantes.id
})

{:ok, _} = Competitions.create_participant(%{
  name: "Carlos Gómez",
  category_id: principiantes.id
})

{:ok, _} = Competitions.create_participant(%{
  name: "Laura Fernández",
  category_id: amateur.id
})

{:ok, _} = Competitions.create_participant(%{
  name: "María Pérez",
  category_id: profesional_femenino.id
})

IO.puts("Datos iniciales creados correctamente!")
