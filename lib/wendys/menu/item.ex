defmodule Wendys.Menu.Item do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field :id, :integer
    field :name, :string
    field :image_url, :string
  end
end