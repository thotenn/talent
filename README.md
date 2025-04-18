# talent

## Requisitos

sudo apt-get install inotify-tools

## Iniciar

mix ecto.create
mix ecto.migrate

# para poblar la base de datos
mix ecto.reset  # borra la base de datos y la vuelve a crear
mix run priv/repo/seeds.exs

## Ejecutar el servidor

mix phx.server

### Hacer deploy en produccion, cada git pull 
sudo systemctl stop talent
MIX_ENV=prod mix clean && MIX_ENV=prod mix deps.get && MIX_ENV=prod mix compile && MIX_ENV=prod mix assets.deploy && MIX_ENV=prod mix release
chmod +x /home/apps/talent/_build/prod/rel/talent/bin/talent
sudo systemctl daemon-reload
sudo systemctl start talent


### Otros comandos utiles (PRECAUCION)
mix deps.clean --all
mix clean
mix phx.digest.clean
rm -rf _build
mix deps.get
mix compile
MIX_ENV=prod mix phx.digest
sudo systemctl restart talent

# Resumen Ejecutivo: Asignación de Criterios de Evaluación a Jueces

## Descripción del Feature

Hemos implementado una nueva funcionalidad en el sistema de gestión de competencias Talent que permite asignar criterios específicos de evaluación a cada juez para cada categoría. Esta mejora proporciona una mayor flexibilidad en la gestión de evaluaciones y permite que los jueces se especialicen en áreas específicas dentro de cada categoría.

## Beneficios Clave

- **Especialización de jueces**: Cada juez puede enfocarse en evaluar criterios específicos acorde a su experiencia o área de especialización.
- **Distribución de trabajo**: Los administradores pueden distribuir la carga de evaluación entre múltiples jueces.
- **Evaluaciones más precisas**: Al limitar el alcance de evaluación de cada juez, se obtienen calificaciones más precisas y enfocadas.
- **Mayor control**: Los administradores tienen control granular sobre qué aspectos puede evaluar cada juez.

## Flujo de Trabajo

1. El administrador asigna una o varias categorías a un juez.
2. Para cada categoría asignada, el administrador puede especificar qué criterios de evaluación puede calificar el juez.
3. Cuando el juez ingresa a calificar a un participante, solo verá los criterios que le fueron asignados.
4. Los resultados finales consideran las restricciones de criterios al calcular los puntajes totales y promedios.

## Implementación Técnica

La implementación incluye:

- Nueva tabla `judge_criteria` que relaciona jueces, criterios y categorías.
- Interfaz administrativa para asignar criterios a jueces a través de un modal.
- Filtrado de criterios en la vista de calificación para mostrar solo los asignados.
- Cálculo de resultados que considera las restricciones de criterios.

## Uso y Acceso

Para utilizar esta nueva funcionalidad:

1. Acceder al panel de administración.
2. Ir a la sección "Gestionar Jueces".
3. Seleccionar un juez y asignarle categorías.
4. Para cada categoría asignada, hacer clic en "Criterios Asignados" para especificar qué criterios puede calificar.

Esta mejora está disponible de inmediato para todos los usuarios con rol de administrador.

## Adaptabilidad y Compatibilidad

Para mantener la compatibilidad con la configuración existente:

- Si no se asignan criterios específicos a un juez, podrá evaluar todos los criterios de la categoría.
- Las puntuaciones existentes no se verán afectadas por esta nueva funcionalidad.

## Conclusión

La implementación de asignación de criterios a jueces representa una mejora significativa en la flexibilidad y precisión del sistema de evaluación, permitiendo una distribución más eficiente del trabajo entre los jueces y mejorando la calidad de las evaluaciones.