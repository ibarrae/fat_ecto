defmodule FatEcto.ConnCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      alias FatEcto.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      alias MyApp.Query
      import FatEcto.Factory
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(FatEcto.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(FatEcto.Repo, {:shared, self()})
    # Repo.start_link()
  end
end
