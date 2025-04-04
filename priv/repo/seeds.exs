# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Talent.Repo.insert!(%Talent.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Talent.Repo
alias Talent.Accounts
alias Talent.Accounts.{User, PersonInfo}
alias Talent.Competitions
alias Talent.Competitions.{Category, Judge, Participant}
alias Talent.Scoring
alias Talent.Scoring.{ScoringCriterion, JudgeCriterion}

IO.puts("Comenzando a crear datos de seed...")

# =====================
# Limpiar datos existentes
# =====================

# Es importante limpiar las tablas para evitar conflictos
# El orden es importante debido a las restricciones de clave foránea

# Limpiar puntuaciones
Repo.delete_all(Talent.Scoring.Score)

# Limpiar asignaciones de criterios a jueces
Repo.delete_all(Talent.Scoring.JudgeCriterion)

# Limpiar asignaciones de categorías a criterios
Repo.delete_all(Talent.Scoring.CriterionCategory)

# Limpiar criterios
Repo.delete_all(Talent.Scoring.ScoringCriterion)

# Limpiar participantes
Repo.delete_all(Talent.Competitions.Participant)

# Limpiar asignaciones de categorías a jueces
Repo.delete_all(Talent.Competitions.CategoryJudge)

# Limpiar jueces
Repo.delete_all(Talent.Competitions.Judge)

# Limpiar categorías
Repo.delete_all(Talent.Competitions.Category)

# Limpiar redes sociales de personas
Repo.delete_all(Talent.Accounts.PersonNetwork)

# Limpiar redes sociales
Repo.delete_all(Talent.Accounts.Network)

# Limpiar tokens de usuarios
Repo.delete_all(Talent.Accounts.UserToken)

# Limpiar usuarios
Repo.delete_all(Talent.Accounts.User)

# Limpiar información de personas
Repo.delete_all(Talent.Accounts.PersonInfo)

IO.puts("Tablas limpiadas correctamente")

# =====================
# Crear Usuario Administrador
# =====================

# Crear usuario administrador con su información personal
{:ok, %{user: admin_user}} = Accounts.create_user_with_person_info(
  %{
    "email" => "admin@admin.com",
    "password" => "AdminPassword123!",
    "role" => "administrador"
  },
  %{
    "full_name" => "Administrador del Sistema",
    "gender" => "Prefiero no decirlo"
  },
  %{}
)

# Confirmar el usuario administrador
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
admin_user
|> Ecto.Changeset.change(confirmed_at: now)
|> Repo.update!()

IO.puts("Usuario administrador creado: #{admin_user.email}")

# =====================
# Función para crear jueces con sus usuarios
# =====================

create_judge = fn name, email ->
  # Crear usuario con información personal
  {:ok, %{user: user}} = Accounts.create_user_with_person_info(
    %{
      "email" => email,
      "password" => "AdminPassword123!",
      "role" => "jurado"
    },
    %{
      "full_name" => name,
      "gender" => "Prefiero no decirlo"
    },
    %{}
  )

  # Confirmar el usuario
  user = user
  |> Ecto.Changeset.change(confirmed_at: now)
  |> Repo.update!()

  # Crear juez asociado al usuario
  {:ok, judge} = Competitions.create_judge(%{
    name: name,
    user_id: user.id,
    scores_access: true
  })

  judge
end

# =====================
# Crear Jueces con sus Usuarios
# =====================

# Crear todos los jueces
franca = create_judge.("Franca Checo", "franca@jurado.com")
franco = create_judge.("Franco Burna", "franco@jurado.com")
adriana = create_judge.("Adriana Vera", "adriana@jurado.com")
sofia = create_judge.("Sofia Musitani", "sofia@jurado.com")
silvia = create_judge.("Silvia Ailin", "silvia@jurado.com")
marisol = create_judge.("Marisol Moreno", "marisol@jurado.com")

IO.puts("Jueces creados con sus usuarios")

# =====================
# Crear Categorías Padre
# =====================

# Función para crear categoría - sin argumentos opcionales
create_category = fn name, description, max_points, is_father, father_id ->
  {:ok, category} = Competitions.create_category(%{
    name: name,
    description: description,
    max_points: if(is_father, do: nil, else: max_points),
    father: is_father,
    father_id: father_id
  })

  category
end

# Crear categorías padre
exotic_parent = create_category.("Exotic", "Categoría de pole dance con elementos exóticos", nil, true, nil)
pole_dance_parent = create_category.("Pole Dance", "Categoría de pole dance tradicional", nil, true, nil)

IO.puts("Categorías padre creadas")

# =====================
# Crear Subcategorías
# =====================

# Subcategorías de Exotic
exotic_principiante = create_category.("Principiante", "Nivel principiante de Exotic", 100, false, exotic_parent.id)
exotic_amateur = create_category.("Amateur", "Nivel amateur de Exotic", 100, false, exotic_parent.id)
exotic_master40 = create_category.("Master 40", "Nivel master +40 de Exotic", 100, false, exotic_parent.id)
exotic_profesional = create_category.("Profesional", "Nivel profesional de Exotic", 100, false, exotic_parent.id)

# Subcategorías de Pole Dance
pole_principiante = create_category.("Principiante", "Nivel principiante de Pole Dance", 100, false, pole_dance_parent.id)
pole_amateur = create_category.("Amateur", "Nivel amateur de Pole Dance", 100, false, pole_dance_parent.id)
pole_profesional = create_category.("Profesional", "Nivel profesional de Pole Dance", 100, false, pole_dance_parent.id)
pole_master40 = create_category.("Master 40", "Nivel master +40 de Pole Dance", 100, false, pole_dance_parent.id)
pole_elite_femenino = create_category.("Elite Femenino", "Nivel elite femenino de Pole Dance", 100, false, pole_dance_parent.id)
pole_elite_masculino = create_category.("Elite Masculino", "Nivel elite masculino de Pole Dance", 100, false, pole_dance_parent.id)

IO.puts("Subcategorías creadas")

# Lista de todas las categorías para usar más adelante
all_categories = [
  exotic_principiante, exotic_amateur, exotic_master40, exotic_profesional,
  pole_principiante, pole_amateur, pole_profesional, pole_master40, pole_elite_femenino, pole_elite_masculino
]

# =====================
# Crear Participantes
# =====================

# Función para crear participante
create_participant = fn name, category_id ->
  {:ok, participant} = Competitions.create_participant(%{
    name: name,
    category_id: category_id
  })

  participant
end

# Exotic Principiante
create_participant.("Ana Cortazar", exotic_principiante.id)
create_participant.("Araceli Araujo", exotic_principiante.id)
create_participant.("Ayelen Conde", exotic_principiante.id)
create_participant.("Berenice Zarate", exotic_principiante.id)
create_participant.("Maria Fernanda Gomez", exotic_principiante.id)

# Exotic Amateur
create_participant.("Alejandra Stark", exotic_amateur.id)
create_participant.("Alexa Rowena", exotic_amateur.id)
create_participant.("Ellen Candia", exotic_amateur.id)
create_participant.("Julia Coronel", exotic_amateur.id)
create_participant.("Mary Mareco", exotic_amateur.id)
create_participant.("Rebhecka De Lemos", exotic_amateur.id)
create_participant.("Yemina Dominguez", exotic_amateur.id)

# Exotic Master 40
create_participant.("Carolina Gonzalez", exotic_master40.id)
create_participant.("Gloria Arza", exotic_master40.id)
create_participant.("Liliana Reguera", exotic_master40.id)
create_participant.("Nathalia Acosta", exotic_master40.id)
create_participant.("Rosi Hohemberg", exotic_master40.id)
create_participant.("Valeria Florentin", exotic_master40.id)

# Exotic Profesional
create_participant.("Andrea Esquivel", exotic_profesional.id)
create_participant.("Monica Zarza", exotic_profesional.id)
create_participant.("Paola Armijo", exotic_profesional.id)
create_participant.("Roemi Caceres", exotic_profesional.id)
create_participant.("Sol Enciso", exotic_profesional.id)

# Pole Dance Principiante
create_participant.("Andrea Isnardi", pole_principiante.id)
create_participant.("Ana Galiano", pole_principiante.id)
create_participant.("Paola Miranda", pole_principiante.id)
create_participant.("Sara Cañete", pole_principiante.id)

# Pole Dance Amateur
create_participant.("Adriana Piris", pole_amateur.id)
create_participant.("Ana Gomez", pole_amateur.id)
create_participant.("Carolina Gonzalez", pole_amateur.id)
create_participant.("Carmen Duarte", pole_amateur.id)
create_participant.("Erika Ayala", pole_amateur.id)
create_participant.("Shirley Rios", pole_amateur.id)

# Pole Dance Profesional
create_participant.("Achi Garcete", pole_profesional.id)
create_participant.("Macarena Grña", pole_profesional.id)
create_participant.("Milka Romero", pole_profesional.id)

# Pole Dance Master 40
create_participant.("Analiz Figueredo", pole_master40.id)
create_participant.("Carmen Vergara", pole_master40.id)
create_participant.("Celeste Chaux", pole_master40.id)
create_participant.("Elizabeth Gumita", pole_master40.id)
create_participant.("Rosa Riveros", pole_master40.id)

# Pole Dance Elite Femenino
create_participant.("Ana Piatti", pole_elite_femenino.id)

# Pole Dance Elite Masculino
create_participant.("Marcelo Vargas", pole_elite_masculino.id)

IO.puts("Participantes creados")

# =====================
# Crear Criterios de Evaluación
# =====================

# Función para crear criterio sin argumentos opcionales
create_criterion = fn name, description, max_points, parent_id, is_discount ->
  {:ok, criterion} = Scoring.create_scoring_criterion(%{
    name: name,
    description: description,
    max_points: max_points,
    parent_id: parent_id,
    is_discount: is_discount
  })

  criterion
end

# Criterio general para todos los jueces
general_criterio = create_criterion.("Apreciacion General de Cada Jurado", "Evaluación general del jurado sobre la presentación", 20, nil, false)

# Asignar a todas las categorías
Scoring.assign_categories_to_criterion(general_criterio.id, Enum.map(all_categories, & &1.id))

# Criterios para Franca Checo
combinacion_trucos_giratorio = create_criterion.("Combinacion de Trucos en el Pole Giratorio", "Evaluación de la combinación de trucos realizados en el pole giratorio", 20, nil, false)
espectacularidad = create_criterion.("Espectacularidad del show", "Evaluación del impacto visual y espectacularidad de la rutina", 20, nil, false)
exceso_pole_tricks = create_criterion.("Exceso de Pole Tricks", "Penalización por exceso de trucos en el pole para categorías Exotic", 20, nil, true)

# Asignar a categorías
Scoring.assign_categories_to_criterion(combinacion_trucos_giratorio.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(espectacularidad.id, Enum.map(all_categories, & &1.id))
# El criterio de exceso solo para categorías Exotic
Scoring.assign_categories_to_criterion(exceso_pole_tricks.id, [
  exotic_principiante.id, exotic_amateur.id, exotic_master40.id, exotic_profesional.id
])

# Criterios para Franco Burna
caida = create_criterion.("Caida", "Penalización por caída durante la rutina", 20, nil, true)
ajustes_pole = create_criterion.("Ajustes en el Pole", "Penalización por ajustes visibles en el pole durante la rutina", 20, nil, true)
resbalarse = create_criterion.("Resbalarse o trastabillarse en la base del Pole/Piso", "Penalización por resbalones o trastabilleos", 20, nil, true)
limpieza_ejecucion = create_criterion.("Limpieza en ejecucion y transicion", "Evaluación de la limpieza en la ejecución y transiciones", 20, nil, false)

# Asignar a todas las categorías
Scoring.assign_categories_to_criterion(caida.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(ajustes_pole.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(resbalarse.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(limpieza_ejecucion.id, Enum.map(all_categories, & &1.id))

# Criterios para Adriana Vera
interpretacion = create_criterion.("Interpretacion musical expresividad y actitud escenica", "Evaluación de la interpretación musical, expresividad y actitud en el escenario", 20, nil, false)
imagen = create_criterion.("Imagen (Vestuario, Maquillaje y Peinado)", "Evaluación de la presentación visual general", 20, nil, false)

# Asignar a todas las categorías
Scoring.assign_categories_to_criterion(interpretacion.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(imagen.id, Enum.map(all_categories, & &1.id))

# Criterios para Sofia Musitani
fuerza = create_criterion.("Fuerza", "Evaluación de la fuerza demostrada en la rutina", 20, nil, false)
flexibilidad = create_criterion.("Flexibilidad", "Evaluación de la flexibilidad demostrada en la rutina", 20, nil, false)
elementos_acrobaticos_piso = create_criterion.("Elementos Acrobaticos de piso", "Evaluación de los elementos acrobáticos realizados en el piso", 20, nil, false)

# Asignar a todas las categorías
Scoring.assign_categories_to_criterion(fuerza.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(flexibilidad.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(elementos_acrobaticos_piso.id, Enum.map(all_categories, & &1.id))

# Criterios para Silvia Ailin
basework = create_criterion.("Basework", "Evaluación del trabajo de base", 20, nil, false)
lineas_tren_inferior = create_criterion.("Lineas de tren inferior", "Evaluación de las líneas del tren inferior", 20, nil, false)
lineas_tren_superior = create_criterion.("Lineas de tren superior", "Evaluación de las líneas del tren superior", 20, nil, false)

# Asignar a todas las categorías
Scoring.assign_categories_to_criterion(basework.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(lineas_tren_inferior.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(lineas_tren_superior.id, Enum.map(all_categories, & &1.id))

# Criterios para Marisol Moreno
combinacion_pole_estatico = create_criterion.("Combinacion de Pole estatico", "Evaluación de la combinación de trucos en pole estático", 20, nil, false)
dead_lift_aereo = create_criterion.("Dead Lift Aereo", "Evaluación del dead lift aéreo (solo para categorías Elite)", 20, nil, false)
floorwork = create_criterion.("Floorwork", "Evaluación del trabajo de piso", 20, nil, false)
elementos_acrobaticos_pole = create_criterion.("Elementos Acrobaticos de Pole", "Evaluación de los elementos acrobáticos realizados en el pole", 20, nil, false)

# Asignar a categorías correspondientes
Scoring.assign_categories_to_criterion(combinacion_pole_estatico.id, Enum.map(all_categories, & &1.id))
# Dead Lift solo para categorías Elite
Scoring.assign_categories_to_criterion(dead_lift_aereo.id, [pole_elite_femenino.id, pole_elite_masculino.id])
Scoring.assign_categories_to_criterion(floorwork.id, Enum.map(all_categories, & &1.id))
Scoring.assign_categories_to_criterion(elementos_acrobaticos_pole.id, Enum.map(all_categories, & &1.id))

IO.puts("Criterios de evaluación creados")

# =====================
# Asignar Jueces a Categorías
# =====================

# Asignar todos los jueces a todas las categorías
Enum.each([franca, franco, adriana, sofia, silvia, marisol], fn judge ->
  Enum.each(all_categories, fn category ->
    Competitions.assign_judge_to_category(judge.id, category.id)
  end)
end)

IO.puts("Jueces asignados a categorías")

# =====================
# Asignar Criterios a Jueces
# =====================

# Para Franca Checo
Enum.each(all_categories, fn category ->
  # Criterio general para todos
  Scoring.assign_criterion_to_judge(franca.id, general_criterio.id, category.id)

  # Sus criterios específicos
  Scoring.assign_criterion_to_judge(franca.id, combinacion_trucos_giratorio.id, category.id)
  Scoring.assign_criterion_to_judge(franca.id, espectacularidad.id, category.id)

  # El criterio de exceso solo para categorías Exotic
  if Enum.member?([exotic_principiante.id, exotic_amateur.id, exotic_master40.id, exotic_profesional.id], category.id) do
    Scoring.assign_criterion_to_judge(franca.id, exceso_pole_tricks.id, category.id)
  end
end)

# Para Franco Burna
Enum.each(all_categories, fn category ->
  # Criterio general para todos
  Scoring.assign_criterion_to_judge(franco.id, general_criterio.id, category.id)

  # Sus criterios específicos
  Scoring.assign_criterion_to_judge(franco.id, caida.id, category.id)
  Scoring.assign_criterion_to_judge(franco.id, ajustes_pole.id, category.id)
  Scoring.assign_criterion_to_judge(franco.id, resbalarse.id, category.id)
  Scoring.assign_criterion_to_judge(franco.id, limpieza_ejecucion.id, category.id)
end)

# Para Adriana Vera
Enum.each(all_categories, fn category ->
  # Criterio general para todos
  Scoring.assign_criterion_to_judge(adriana.id, general_criterio.id, category.id)

  # Sus criterios específicos
  Scoring.assign_criterion_to_judge(adriana.id, interpretacion.id, category.id)
  Scoring.assign_criterion_to_judge(adriana.id, imagen.id, category.id)
end)

# Para Sofia Musitani
Enum.each(all_categories, fn category ->
  # Criterio general para todos
  Scoring.assign_criterion_to_judge(sofia.id, general_criterio.id, category.id)

  # Sus criterios específicos
  Scoring.assign_criterion_to_judge(sofia.id, fuerza.id, category.id)
  Scoring.assign_criterion_to_judge(sofia.id, flexibilidad.id, category.id)
  Scoring.assign_criterion_to_judge(sofia.id, elementos_acrobaticos_piso.id, category.id)
end)

# Para Silvia Ailin
Enum.each(all_categories, fn category ->
  # Criterio general para todos
  Scoring.assign_criterion_to_judge(silvia.id, general_criterio.id, category.id)

  # Sus criterios específicos
  Scoring.assign_criterion_to_judge(silvia.id, basework.id, category.id)
  Scoring.assign_criterion_to_judge(silvia.id, lineas_tren_inferior.id, category.id)
  Scoring.assign_criterion_to_judge(silvia.id, lineas_tren_superior.id, category.id)
end)

# Para Marisol Moreno
Enum.each(all_categories, fn category ->
  # Criterio general para todos
  Scoring.assign_criterion_to_judge(marisol.id, general_criterio.id, category.id)

  # Sus criterios específicos
  Scoring.assign_criterion_to_judge(marisol.id, combinacion_pole_estatico.id, category.id)
  Scoring.assign_criterion_to_judge(marisol.id, floorwork.id, category.id)
  Scoring.assign_criterion_to_judge(marisol.id, elementos_acrobaticos_pole.id, category.id)

  # Dead Lift solo para categorías Elite
  if Enum.member?([pole_elite_femenino.id, pole_elite_masculino.id], category.id) do
    Scoring.assign_criterion_to_judge(marisol.id, dead_lift_aereo.id, category.id)
  end
end)

IO.puts("Criterios asignados a jueces por categoría")

# Confirmación de finalización
IO.puts("\n¡Datos de seed creados exitosamente!")
IO.puts("Usuario administrador: admin@admin.com con contraseña: AdminPassword123!")
IO.puts("Todos los usuarios de jurado tienen contraseña: AdminPassword123!")
