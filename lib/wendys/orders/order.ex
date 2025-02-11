defmodule Wendys.Orders.Order do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :number, :integer
    field :items, {:array, :map}
  end
end