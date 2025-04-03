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
alias Talent.Accounts.{User, PersonInfo, Network}
alias Talent.Competitions
alias Talent.Competitions.{Category, Participant, Judge, CategoryJudge}
alias Talent.Scoring
alias Talent.Scoring.{ScoringCriterion, CriterionCategory, JudgeCriterion}
import Ecto.Query

# Clear existing data - Only use in development!
IO.puts("Clearing existing data...")
Repo.delete_all("scores")
Repo.delete_all("judge_criteria")
Repo.delete_all("criteria_categories")
Repo.delete_all("category_judges")
Repo.delete_all("participants")
Repo.delete_all("scoring_criteria")
Repo.delete_all("judges")
Repo.delete_all("categories")
Repo.delete_all("users_tokens")
Repo.delete_all("person_networks")
Repo.delete_all("people_info")
Repo.delete_all("users")
Repo.delete_all("networks")

IO.puts("Creating admin user...")
{:ok, admin_user} = Accounts.register_user(%{
  email: "admin@admin.com",
  password: "AdminPassword123!",
  role: "administrador"
})

# Confirm the admin user
now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
admin_user
|> Ecto.Changeset.change(confirmed_at: now)
|> Repo.update!()

# Create people info for admin
admin_person_info = Repo.insert!(%PersonInfo{
  full_name: "Admin Usuario",
  short_name: "Admin",
  phone: "123456789",
  gender: "Prefiero no decirlo"
})

# Update admin user with person_id
admin_user
|> Ecto.Changeset.change(person_id: admin_person_info.id)
|> Repo.update!()

IO.puts("Creating parent categories...")
# Create parent categories
exotic_parent = Repo.insert!(%Category{
  name: "Exotic",
  description: "Categoría para estilos de pole dance exóticos",
  father: true,
  max_points: nil
})

pole_dance_parent = Repo.insert!(%Category{
  name: "Pole Dance",
  description: "Categoría para estilos de pole dance tradicionales",
  father: true,
  max_points: nil
})

IO.puts("Creating subcategories...")
# Create subcategories for Exotic
exotic_subcategories = [
  %{name: "Principiante", description: "Nivel principiante de Exotic", max_points: 200},
  %{name: "Amateur", description: "Nivel amateur de Exotic", max_points: 200},
  %{name: "Master 40", description: "Nivel master 40+ de Exotic", max_points: 200},
  %{name: "Profesional", description: "Nivel profesional de Exotic", max_points: 200}
]

# Create subcategories for Pole Dance
pole_dance_subcategories = [
  %{name: "Principiante", description: "Nivel principiante de Pole Dance", max_points: 200},
  %{name: "Amateur", description: "Nivel amateur de Pole Dance", max_points: 200},
  %{name: "Profesional", description: "Nivel profesional de Pole Dance", max_points: 200},
  %{name: "Master 40", description: "Nivel master 40+ de Pole Dance", max_points: 200},
  %{name: "Elite Femenino", description: "Nivel elite femenino de Pole Dance", max_points: 200},
  %{name: "Elite Masculino", description: "Nivel elite masculino de Pole Dance", max_points: 200}
]

# Insert Exotic subcategories
exotic_categories = Enum.map(exotic_subcategories, fn cat_attrs ->
  Repo.insert!(%Category{
    name: cat_attrs.name,
    description: cat_attrs.description,
    max_points: cat_attrs.max_points,
    father_id: exotic_parent.id,
    father: false
  })
end)

# Insert Pole Dance subcategories
pole_dance_categories = Enum.map(pole_dance_subcategories, fn cat_attrs ->
  Repo.insert!(%Category{
    name: cat_attrs.name,
    description: cat_attrs.description,
    max_points: cat_attrs.max_points,
    father_id: pole_dance_parent.id,
    father: false
  })
end)

# Create a map to look up categories by name and parent
category_map = %{
  "exotic_principiante" => Enum.at(exotic_categories, 0),
  "exotic_amateur" => Enum.at(exotic_categories, 1),
  "exotic_master_40" => Enum.at(exotic_categories, 2),
  "exotic_profesional" => Enum.at(exotic_categories, 3),

  "pole_dance_principiante" => Enum.at(pole_dance_categories, 0),
  "pole_dance_amateur" => Enum.at(pole_dance_categories, 1),
  "pole_dance_profesional" => Enum.at(pole_dance_categories, 2),
  "pole_dance_master_40" => Enum.at(pole_dance_categories, 3),
  "pole_dance_elite_femenino" => Enum.at(pole_dance_categories, 4),
  "pole_dance_elite_masculino" => Enum.at(pole_dance_categories, 5)
}

IO.puts("Creating scoring criteria based on the image...")

# Main Criteria Categories (Parent criteria)
artistico = Repo.insert!(%ScoringCriterion{
  name: "ARTÍSTICO",
  description: "Evaluación de aspectos artísticos",
  max_points: 30,
  is_discount: false
})

aptitudes_fisicas = Repo.insert!(%ScoringCriterion{
  name: "APTITUDES FÍSICAS",
  description: "Evaluación de aptitudes físicas",
  max_points: 20,
  is_discount: false
})

tecnico_de_pole = Repo.insert!(%ScoringCriterion{
  name: "TÉCNICO DE POLE",
  description: "Evaluación de técnicas de pole",
  max_points: 40,
  is_discount: false
})

tecnico_de_danza = Repo.insert!(%ScoringCriterion{
  name: "TÉCNICO DE DANZA",
  description: "Evaluación de técnicas de danza",
  max_points: 60,
  is_discount: false
})

apreciacion_general = Repo.insert!(%ScoringCriterion{
  name: "APRECIACIÓN GENERAL DE CADA JURADO",
  description: "Evaluación general por parte del jurado",
  max_points: 50,
  is_discount: false
})

# Child criteria for ARTÍSTICO
artistico_children = [
  %{name: "EXPRESIVIDAD / ACTITUD ESCÉNICA", description: "Evaluación de la expresividad y actitud en escena", max_points: 10},
  %{name: "IMAGEN (VESTUARIO, MAQUILLAJE Y PEINADO)", description: "Evaluación de la imagen general", max_points: 10},
  %{name: "ESPECTACULARIDAD DEL SHOW", description: "Evaluación del impacto del show", max_points: 10}
]

artistico_subcriteria = Enum.map(artistico_children, fn crit ->
  Repo.insert!(%ScoringCriterion{
    name: crit.name,
    description: crit.description,
    max_points: crit.max_points,
    parent_id: artistico.id,
    is_discount: false
  })
end)

# Child criteria for APTITUDES FÍSICAS
aptitudes_fisicas_children = [
  %{name: "FUERZA", description: "Evaluación de la fuerza demostrada", max_points: 10},
  %{name: "FLEXIBILIDAD", description: "Evaluación de la flexibilidad demostrada", max_points: 10}
]

aptitudes_fisicas_subcriteria = Enum.map(aptitudes_fisicas_children, fn crit ->
  Repo.insert!(%ScoringCriterion{
    name: crit.name,
    description: crit.description,
    max_points: crit.max_points,
    parent_id: aptitudes_fisicas.id,
    is_discount: false
  })
end)

# Child criteria for TÉCNICO DE POLE
tecnico_de_pole_children = [
  %{name: "COMBINACIÓN DE TRUCOS EN POLE ESTÁTICO", description: "Evaluación de trucos en pole estático", max_points: 10},
  %{name: "COMBINACIÓN DE TRUCOS EN POLE GIRATORIO", description: "Evaluación de trucos en pole giratorio", max_points: 10},
  %{name: "LIMPIEZA EN EJECUCIÓN Y TRANSICIÓN", description: "Evaluación de la limpieza en ejecuciones", max_points: 10},
  %{name: "ELEMENTOS ACROBÁTICOS DE POLE", description: "Evaluación de elementos acrobáticos", max_points: 10}
]

tecnico_de_pole_subcriteria = Enum.map(tecnico_de_pole_children, fn crit ->
  Repo.insert!(%ScoringCriterion{
    name: crit.name,
    description: crit.description,
    max_points: crit.max_points,
    parent_id: tecnico_de_pole.id,
    is_discount: false
  })
end)

# Child criteria for TÉCNICO DE DANZA
tecnico_de_danza_children = [
  %{name: "BASEWORK", description: "Evaluación del trabajo de base", max_points: 10},
  %{name: "FLOORWORK", description: "Evaluación del trabajo en suelo", max_points: 10},
  %{name: "LÍNEAS DE TREN INFERIOR", description: "Evaluación de líneas de tren inferior", max_points: 10},
  %{name: "LÍNEAS DE TREN SUPERIOR", description: "Evaluación de líneas de tren superior", max_points: 10},
  %{name: "INTERPRETACIÓN MUSICAL", description: "Evaluación de interpretación musical", max_points: 10},
  %{name: "ELEMENTOS ACROBÁTICOS DE PISO", description: "Evaluación de acrobacias en piso", max_points: 10}
]

tecnico_de_danza_subcriteria = Enum.map(tecnico_de_danza_children, fn crit ->
  Repo.insert!(%ScoringCriterion{
    name: crit.name,
    description: crit.description,
    max_points: crit.max_points,
    parent_id: tecnico_de_danza.id,
    is_discount: false
  })
end)

# Discount criteria (penalties)
discount_criteria = [
  %{name: "CAÍDA", description: "Deducción por caída", max_points: 10, is_discount: true},
  %{name: "AJUSTES EN EL POLE", description: "Deducción por ajustes", max_points: 5, is_discount: true},
  %{name: "RESBALARSE O TRASTABILLAR EN LA BASE DEL POLE/PISO", description: "Deducción por resbalón", max_points: 5, is_discount: true},
  %{name: "EXCESO DE POLE TRICKS (Sólo categoría Exotic Pole)", description: "Deducción por exceso de trucos", max_points: 10, is_discount: true}
]

discount_criteria_records = Enum.map(discount_criteria, fn crit ->
  Repo.insert!(%ScoringCriterion{
    name: crit.name,
    description: crit.description,
    max_points: crit.max_points,
    is_discount: crit.is_discount
  })
end)

# Bonus criterion
bonus_criterion = Repo.insert!(%ScoringCriterion{
  name: "DEAD LIFT AÉREO (Sólo sub-categoría Elite)",
  description: "Bonificación por dead lift aéreo",
  max_points: 10,
  is_discount: false  # This is actually a bonus, not a discount
})

# Collect all criteria for easier assignment later
all_parent_criteria = [artistico, aptitudes_fisicas, tecnico_de_pole, tecnico_de_danza, apreciacion_general]
all_subcriteria = artistico_subcriteria ++ aptitudes_fisicas_subcriteria ++ tecnico_de_pole_subcriteria ++ tecnico_de_danza_subcriteria
all_discount_criteria = discount_criteria_records ++ [bonus_criterion]

all_criteria = all_parent_criteria ++ all_subcriteria ++ all_discount_criteria

# Assign criteria to categories with appropriate logic
IO.puts("Assigning criteria to categories...")
for criterion <- all_criteria do
  for category <- exotic_categories ++ pole_dance_categories do
    # Skip "EXCESO DE POLE TRICKS" for Pole Dance categories
    should_skip = (criterion.name == "EXCESO DE POLE TRICKS (Sólo categoría Exotic Pole)" &&
                  Enum.member?(pole_dance_categories, category)) ||
                  # Skip "DEAD LIFT AÉREO" for non-Elite categories
                  (criterion.name == "DEAD LIFT AÉREO (Sólo sub-categoría Elite)" &&
                  !(category.name == "Elite Femenino" || category.name == "Elite Masculino"))

    unless should_skip do
      # Insert the criterion-category relationship
      Repo.insert!(%CriterionCategory{
        criterion_id: criterion.id,
        category_id: category.id
      })
    end
  end
end

IO.puts("Creating judges and their users...")
# Create judges
judges_data = [
  %{name: "Franca Checo", email: "franca@jurado.com"},
  %{name: "Franco Burna", email: "franco@jurado.com"},
  %{name: "Adriana Vera", email: "adriana@jurado.com"},
  %{name: "Sofia Musitani", email: "sofia@jurado.com"},
  %{name: "Silivia Ailin", email: "silivia@jurado.com"},
  %{name: "Marisol Moreno", email: "marisol@jurado.com"}
]

judges = Enum.map(judges_data, fn judge_attrs ->
  # Create user for judge
  {:ok, user} = Accounts.register_user(%{
    email: judge_attrs.email,
    password: "AdminPassword123!",
    role: "jurado"
  })

  # Confirm the user
  user = user
  |> Ecto.Changeset.change(confirmed_at: now)
  |> Repo.update!()

  # Create person info
  person_info = Repo.insert!(%PersonInfo{
    full_name: judge_attrs.name,
    short_name: String.split(judge_attrs.name) |> Enum.at(0),
    gender: "Prefiero no decirlo"
  })

  # Update user with person_id
  user = user
  |> Ecto.Changeset.change(person_id: person_info.id)
  |> Repo.update!()

  # Create judge
  Repo.insert!(%Judge{
    name: judge_attrs.name,
    user_id: user.id,
    scores_access: true
  })
end)

IO.puts("Assigning categories to judges...")
# Assign all categories to all judges
for judge <- judges do
  for category <- exotic_categories ++ pole_dance_categories do
    Repo.insert!(%CategoryJudge{
      judge_id: judge.id,
      category_id: category.id
    })
  end
end

# Assign all applicable criteria to all judges for all their categories
IO.puts("Assigning criteria to judges...")
for judge <- judges do
  for category <- exotic_categories ++ pole_dance_categories do
    for criterion <- all_criteria do
      # Check if we should skip this criterion for this category
      should_skip = (criterion.name == "EXCESO DE POLE TRICKS (Sólo categoría Exotic Pole)" &&
                    Enum.member?(pole_dance_categories, category)) ||
                    # Skip "DEAD LIFT AÉREO" for non-Elite categories
                    (criterion.name == "DEAD LIFT AÉREO (Sólo sub-categoría Elite)" &&
                    !(category.name == "Elite Femenino" || category.name == "Elite Masculino"))

      unless should_skip do

        # Insert the judge-criterion-category relationship
        Repo.insert!(%JudgeCriterion{
          judge_id: judge.id,
          criterion_id: criterion.id,
          category_id: category.id
        })
      end
    end
  end
end

IO.puts("Creating participants...")
# Define participants with their categories
participants_data = [
  # Exotic Principiante
  %{name: "Ana Cortazar", category_key: "exotic_principiante"},
  %{name: "Araceli Araujo", category_key: "exotic_principiante"},
  %{name: "Ayelen Conde", category_key: "exotic_principiante"},
  %{name: "Berenice Zarate", category_key: "exotic_principiante"},
  %{name: "Maria Fernanda Gomez", category_key: "exotic_principiante"},

  # Exotic Amateur
  %{name: "Alejandra Stark", category_key: "exotic_amateur"},
  %{name: "Alexa Rowena", category_key: "exotic_amateur"},
  %{name: "Ellen Candia", category_key: "exotic_amateur"},
  %{name: "Julia Coronel", category_key: "exotic_amateur"},
  %{name: "Mary Mareco", category_key: "exotic_amateur"},
  %{name: "Rebhecka De Lemos", category_key: "exotic_amateur"},
  %{name: "Yemina Dominguez", category_key: "exotic_amateur"},

  # Exotic Master 40
  %{name: "Carolina Gonzalez", category_key: "exotic_master_40"},
  %{name: "Gloria Arza", category_key: "exotic_master_40"},
  %{name: "Liliana Reguera", category_key: "exotic_master_40"},
  %{name: "Nathalia Acosta", category_key: "exotic_master_40"},
  %{name: "Rosi Hohemberg", category_key: "exotic_master_40"},
  %{name: "Valeria Florentin", category_key: "exotic_master_40"},

  # Exotic Profesional
  %{name: "Andrea Esquivel", category_key: "exotic_profesional"},
  %{name: "Monica Zarza", category_key: "exotic_profesional"},
  %{name: "Paola Armijo", category_key: "exotic_profesional"},
  %{name: "Roemi Caceres", category_key: "exotic_profesional"},
  %{name: "Sol Enciso", category_key: "exotic_profesional"},

  # Pole Dance Principiante
  %{name: "Andrea Isnardi", category_key: "pole_dance_principiante"},
  %{name: "Ana Galiano", category_key: "pole_dance_principiante"},
  %{name: "Paola Miranda", category_key: "pole_dance_principiante"},
  %{name: "Sara Cañete", category_key: "pole_dance_principiante"},

  # Pole Dance Amateur
  %{name: "Adriana Piris", category_key: "pole_dance_amateur"},
  %{name: "Ana Gomez", category_key: "pole_dance_amateur"},
  %{name: "Carolina Gonzalez", category_key: "pole_dance_amateur"},
  %{name: "Carmen Duarte", category_key: "pole_dance_amateur"},
  %{name: "Erika Ayala", category_key: "pole_dance_amateur"},
  %{name: "Shirley Rios", category_key: "pole_dance_amateur"},

  # Pole Dance Profesional
  %{name: "Achi Garcete", category_key: "pole_dance_profesional"},
  %{name: "Macarena Grña", category_key: "pole_dance_profesional"},
  %{name: "Milka Romero", category_key: "pole_dance_profesional"},

  # Pole Dance Master 40
  %{name: "Analiz Figueredo", category_key: "pole_dance_master_40"},
  %{name: "Carmen Vergara", category_key: "pole_dance_master_40"},
  %{name: "Celeste Chaux", category_key: "pole_dance_master_40"},
  %{name: "Elizabeth Gumita", category_key: "pole_dance_master_40"},
  %{name: "Rosa Riveros", category_key: "pole_dance_master_40"},

  # Pole Dance Elite Femenino
  %{name: "Ana Piatti", category_key: "pole_dance_elite_femenino"},

  # Pole Dance Elite Masculino
  %{name: "Marcelo Vargas", category_key: "pole_dance_elite_masculino"}
]

# Create participants
for participant_data <- participants_data do
  category = Map.get(category_map, participant_data.category_key)

  # Create person info for participant
  person_info = Repo.insert!(%PersonInfo{
    full_name: participant_data.name,
    short_name: String.split(participant_data.name) |> Enum.at(0),
    gender: "Prefiero no decirlo"
  })

  # Create participant
  Repo.insert!(%Participant{
    name: participant_data.name,
    category_id: category.id,
    person_id: person_info.id
  })
end

IO.puts("Seed data creation completed successfully!")
