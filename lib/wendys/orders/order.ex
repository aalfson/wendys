# defmodule Wendys.Orders.Order do
#   use Ecto.Schema

#   @primary_key false
#   embedded_schema do
#     field :number, :integer
#     field :items, {:array, :map}
#   end
# end

defmodule Wendys.Orders.Order do
  use Ecto.Schema
  use Instructor

  import Ecto.Changeset
  alias Wendys.Orders.Item

  @llm_doc """
  ## Field Descriptions:
  - items: A array of Wendys.Orders.Item.
  """
  @primary_key false
  embedded_schema do
    field :items, {:array, :map}
  end

  @required ~w(items)a

  @impl true
  def validate_changeset(changeset) do
    changeset
    |> validate_required(@required)
  end
end