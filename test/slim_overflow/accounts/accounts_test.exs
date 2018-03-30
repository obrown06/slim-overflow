defmodule SlimOverflow.AccountsTest do
  use SlimOverflow.DataCase

  alias SlimOverflow.Accounts

  describe "users" do
    alias SlimOverflow.Accounts.User

    @valid_attrs %{email: "some@email.com", name: "some name", password: "some password", confirmed_at: Timex.now}
    @update_attrs %{email: "some@updatedemail.com", name: "some updated name"}
    @invalid_attrs %{email: nil, name: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      Accounts.get_user!(user.id)
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email.com"
      assert user.name == "some name"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some@updatedemail.com"
      assert user.name == "some updated name"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    #test "delete_user/1 deletes the user" do
    #  user = user_fixture()
    #  assert {:ok, %User{}} = Accounts.delete_user!(user)
    #  assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    #end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "promote_user/2 promotes the user" do
      user = user_fixture()
      assert user.is_admin == false
      assert {:ok, user} = Accounts.promote_user(user)
      assert user.is_admin == true
    end

    test "update_user_password/2 changes the user's password" do
      user = user_fixture()
      assert Comeonin.Bcrypt.checkpw("some password", user.password_hash)
      assert {:ok, updated_user} = Accounts.update_user_password(user, %{"new_password" => "some updated password"})
      assert Comeonin.Bcrypt.checkpw("some updated password", updated_user.password_hash)
    end

    test "update_user_password/2 with an invalid password returns error changeset" do
      user = user_fixture()
      assert Comeonin.Bcrypt.checkpw("some password", user.password_hash)
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.update_user_password(user, %{"new_password" => nil})
      assert Comeonin.Bcrypt.checkpw("some password", user.password_hash)
    end

    test "update_user_email/2 updates the user's email" do
      user = user_fixture()
      assert user.email == "some@email.com"
      assert user.confirmed_at != nil
      assert {:ok, updated_user} = Accounts.update_user_email(user, %{"new_email" => "updated@email.com"})
      assert updated_user.email == "updated@email.com"
      assert updated_user.confirmed_at == nil
    end

    test "update_user_email/2 with an invalid email returns error changeset" do
      user = user_fixture()
      assert user.email == "some@email.com"
      assert user.confirmed_at != nil
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_email(user, %{"new_email" => "bad"})
      user = Accounts.get_user!(user.id)
      assert user.email == "some@email.com"
      assert user.confirmed_at != nil
    end

    test "update_user_categories/2 updates when no associations set" do
      user = user_fixture()
      category_one = insert_category(%{name: "category one"})
      category_two = insert_category(%{name: "category two"})
      user = Repo.preload(user, :categories)
      assert user.categories == []
      assert {:ok, updated_user} = Accounts.update_user_categories(user, %{"categories" => [Integer.to_string(category_one.id), Integer.to_string(category_two.id)]})
      assert updated_user.categories == [category_one, category_two]
    end

    test "update_user_categories/2 updates when associations preset" do
      user = user_fixture()
      category_one = insert_category(%{name: "category one"})
      category_two = insert_category(%{name: "category two"})

      user = Repo.preload(user, :categories)
      assert user.categories == []

      assert {:ok, updated_user} = Accounts.update_user_categories(user, %{"categories" => [Integer.to_string(category_one.id), Integer.to_string(category_two.id)]})
      assert updated_user.categories == [category_one, category_two]

      assert {:ok, updated_user} = Accounts.update_user_categories(user, %{"categories" => []})
      assert updated_user.categories == []
    end

  end
end
