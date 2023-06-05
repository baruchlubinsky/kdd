defmodule Mix.Tasks.Podman.Db do
  @requirements ["app.config"]
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    if Mix.env() != :dev do
      Process.exit(self(), "Only for dev.")
    end

    settings = Kdd.Repo.config()

    db = Keyword.get(settings, :database)
    port = Keyword.get(settings, :port, 5432)
    username = Keyword.get(settings, :username)
    password = Keyword.get(settings, :password)

    run_db = "podman run --rm -d \
    --name kdd-db --replace \
    -e POSTGRES_DB=#{db} \
    -e POSTGRES_USER=#{username} \
    -e POSTGRES_PASSWORD=#{password} \
    --mount=type=volume,source=#{db},destination=/var/lib/postgresql/data \
    -p 127.0.0.1:#{port}:5432 \
    postgres:latest"

    Mix.shell().cmd(run_db)
  end

end
