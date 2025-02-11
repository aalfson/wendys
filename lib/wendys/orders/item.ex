defmodule Wendys.Orders.Item do
  defstruct ~w(number menu_item_id quantity)a

  @max_num 1_000_000_000

  def new(menu_item_id, quantity \\ 0) do
    %__MODULE__{
      number: :rand.uniform(@max_num),
      menu_item_id: menu_item_id,
      quantity: quantity
    }
  end
end