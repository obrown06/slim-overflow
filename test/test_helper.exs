Application.ensure_all_started(:hound)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(SlimOverflow.Repo, :manual)
