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