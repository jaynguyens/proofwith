defmodule Proofwith.Repo.Migrations.CreateProjects do
  use Ecto.Migration

  def change do
    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :meta, :map
      add :organization_id, references(:organizations, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:projects, [:organization_id])
    create unique_index(:projects, [:organization_id, :slug])
  end
end
