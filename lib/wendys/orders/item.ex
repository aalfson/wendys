defmodule Wendys.Orders.Item do
  use Ecto.Schema
  use Instructor

  import Ecto.Changeset

  @llm_doc """
  ## Field Descriptions:
  - position: A unique integer 0 >= x < 100 that is used to create a monotonic ordering of a set of Wendys.Orders.Item that are each associated with the same Wendys.Orders.Order.
  - quantity: The quantity of the Wendys.Menu.Item being ordered.
  - menu_item_id: The id of the Wendys.Menu.Item that is being is being ordered.
  """
  @primary_key false
  embedded_schema do
    field :position, :integer
    field :quantity, :integer
    field :menu_item_id, :integer
  end

  @required ~w(position quantity menu_item_id)a

  @impl true
  def validate_changeset(changeset) do
    changeset
    |> validate_required(@required)
    |> validate_inclusion(:position, 0..99)
    |> validate_inclusion(:menu_item_id, 0..2)
  end
end