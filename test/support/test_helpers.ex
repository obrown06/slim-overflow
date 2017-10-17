defmodule Plunger.TestHelpers do
  alias Plunger.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{name: "Test User",
    username: "testuser",
    email: "test@test.com",
    password: "test123",
    }, attrs)

    %Plunger.Accounts.User{}
    |> Plunger.Accounts.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_category(attrs \\ %{}) do
    changes = Dict.merge(%{name: "Test Category",
    }, attrs)

    %Plunger.Categories.Category{}
    |> Plunger.Categories.Category.changeset(changes)
    |> Repo.insert!()
  end

end
