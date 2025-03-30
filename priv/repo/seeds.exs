# Script para poblar la base de datos

alias Talent.Repo
alias Talent.Accounts
alias Talent.Accounts.User
alias Talent.Competitions
alias Talent.Scoring
alias Talent.Scoring.CriterionCategory
alias Talent.Directory.Network
alias Talent.Directory.PersonInfo
alias Talent.Directory.PersonNetwork
import Ecto.Query, only: [from: 2]

# Mostrar opciones de género disponibles para depuración
IO.puts("Opciones de género disponibles:")
IO.inspect(PersonInfo.gender_options())

# Crear redes sociales
{:ok, instagram} = %Network{}
|> Network.changeset(%{
  name: "Instagram",
  base_url: "https://instagram.com/"
})
|> Repo.insert()

{:ok, facebook} = %Network{}
|> Network.changeset(%{
  name: "Facebook",
  base_url: "https://facebook.com/"
})
|> Repo.insert()

{:ok, youtube} = %Network{}
|> Network.changeset(%{
  name: "YouTube",
  base_url: "https://youtube.com/c/"
})
|> Repo.insert()

# Crear información personal para el administrador
{:ok, admin_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Administrador del Sistema",
  short_name: "Admin",
  phone: "+59891234567",
  identity_number: "1.234.567-8",
  birth_date: ~D[1980-01-01],
  gender: "Otros",
  extra_data: "Cuenta de administración principal del sistema"
})
|> Repo.insert()

# Crear usuario administrador
{:ok, admin} = Accounts.register_user(%{
  email: "admin@admin.com",
  password: "AdminPassword123!",
  role: "administrador",
  person_id: admin_person.id
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
|> Repo.insert()

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

# Crear información personal para el jurado
{:ok, jurado_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Juez Ejemplo Completo",
  short_name: "Juez Ejemplo",
  phone: "+59892345678",
  identity_number: "2.345.678-9",
  birth_date: ~D[1975-05-15],
  gender: "Masculino",
  extra_data: "Bailarín profesional y juez desde 2010"
})
|> Repo.insert()

# Agregar redes sociales al jurado
{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: jurado_person.id,
  network_id: instagram.id,
  username: "juez_ejemplo"
})
|> Repo.insert()

{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: jurado_person.id,
  network_id: facebook.id,
  username: "juezejemplo"
})
|> Repo.insert()

# Crear un usuario con rol de jurado
{:ok, jurado_user} = Accounts.register_user(%{
  email: "jurado@example.com",
  password: "JuradoPassword123!",
  role: "jurado",
  person_id: jurado_person.id
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

# Crear información personal para el secretario
{:ok, secretario_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Secretario Ejemplo",
  short_name: "Secretario",
  phone: "+59893456789",
  identity_number: "3.456.789-0",
  birth_date: ~D[1985-08-20],
  gender: "Masculino",
  extra_data: "Encargado de administración y registro"
})
|> Repo.insert()

# Crear un usuario secretario
{:ok, secretario} = Accounts.register_user(%{
  email: "secretario@example.com",
  password: "SecretarioPassword123!",
  role: "secretario",
  person_id: secretario_person.id
})

# Confirmar el usuario secretario
Repo.update_all(
  from(u in User, where: u.id == ^secretario.id),
  set: [confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)]
)

# Crear información personal para la escribana
{:ok, escribana_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Escribana Ejemplo",
  short_name: "Escribana",
  phone: "+59894567890",
  identity_number: "4.567.890-1",
  birth_date: ~D[1982-11-10],
  gender: "Femenino",
  extra_data: "Encargada de verificar resultados"
})
|> Repo.insert()

# Agregar red social a la escribana
{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: escribana_person.id,
  network_id: instagram.id,
  username: "escribana_oficial"
})
|> Repo.insert()

# Crear un usuario escribana
{:ok, escribana} = Accounts.register_user(%{
  email: "escribana@example.com",
  password: "EscribanaPassword123!",
  role: "escribana",
  person_id: escribana_person.id
})

# Confirmar el usuario escribana
Repo.update_all(
  from(u in User, where: u.id == ^escribana.id),
  set: [confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)]
)

# Crear información personal para participantes
{:ok, participante1_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Ana Rodríguez López",
  short_name: "Ana Rodríguez",
  phone: "+59895678901",
  identity_number: "5.678.901-2",
  birth_date: ~D[1995-03-25],
  gender: "Femenino",
  extra_data: "Estudiante de danza desde 2020"
})
|> Repo.insert()

{:ok, participante2_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Carlos Alberto Gómez Mendoza",
  short_name: "Carlos Gómez",
  phone: "+59896789012",
  identity_number: "6.789.012-3",
  birth_date: ~D[1992-07-18],
  gender: "Masculino",
  extra_data: "Bailarín principiante"
})
|> Repo.insert()

{:ok, participante3_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "Laura Fernández García",
  short_name: "Laura Fernández",
  phone: "+59897890123",
  identity_number: "7.890.123-4",
  birth_date: ~D[1990-12-05],
  gender: "Femenino",
  extra_data: "3 años de experiencia en pole dance"
})
|> Repo.insert()

{:ok, participante4_person} = %PersonInfo{}
|> PersonInfo.changeset(%{
  full_name: "María José Pérez Rodríguez",
  short_name: "María Pérez",
  phone: "+59898901234",
  identity_number: "8.901.234-5",
  birth_date: ~D[1988-09-30],
  gender: "Femenino",
  extra_data: "Bailarina profesional con 10 años de experiencia"
})
|> Repo.insert()

# Agregar redes sociales a los participantes
{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: participante1_person.id,
  network_id: instagram.id,
  username: "ana_rodriguez_dance"
})
|> Repo.insert()

{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: participante2_person.id,
  network_id: facebook.id,
  username: "CarlosGomezDancer"
})
|> Repo.insert()

{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: participante3_person.id,
  network_id: instagram.id,
  username: "laura_pole_star"
})
|> Repo.insert()

{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: participante4_person.id,
  network_id: youtube.id,
  username: "MariaPoleProChannel"
})
|> Repo.insert()

{:ok, _} = %PersonNetwork{}
|> PersonNetwork.changeset(%{
  person_id: participante4_person.id,
  network_id: instagram.id,
  username: "maria_pro_dancer"
})
|> Repo.insert()

# Crear algunos participantes
{:ok, _} = Competitions.create_participant(%{
  name: "Ana Rodríguez",
  category_id: principiantes.id,
  person_id: participante1_person.id
})

{:ok, _} = Competitions.create_participant(%{
  name: "Carlos Gómez",
  category_id: principiantes.id,
  person_id: participante2_person.id
})

{:ok, _} = Competitions.create_participant(%{
  name: "Laura Fernández",
  category_id: amateur.id,
  person_id: participante3_person.id
})

{:ok, _} = Competitions.create_participant(%{
  name: "María Pérez",
  category_id: profesional_femenino.id,
  person_id: participante4_person.id
})

IO.puts("Datos iniciales creados correctamente!")
