defmodule Explorer.Repo.Migrations.UpdateTokensTableDecimalsFromBigintToNumeric do
  use Ecto.Migration

  def up do
    alter table("tokens") do
      modify(:decimals, :decimal)
    end
  end

  def down do
    alter table("tokens") do
      modify(:decimals, :bigint)
    end
  end
end
