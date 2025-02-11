defmodule Wendys.Orders.Order do
  defstruct ~w(number items)a

  @max_num 1_000_000_000

  def new do
    %__MODULE__{
      number: :rand.uniform(@max_num),
      items: []
    }
  end
end