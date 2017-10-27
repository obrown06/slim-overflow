defmodule PlungerWeb.Token do
  @moduledoc """
  Handles creating and validating tokens.
  """

  alias Plunger.Accounts.User

  @account_verification_salt "account verification salt"

  def verify_new_account_token(token) do
    max_age = 86_400
    Phoenix.Token.verify(PlungerWeb.Endpoint, @account_verification_salt, token, max_age: max_age)
  end

  def generate_new_account_token(%User{id: user_id}) do
    Phoenix.Token.sign(PlungerWeb.Endpoint, @account_verification_salt, user_id)
  end
end
