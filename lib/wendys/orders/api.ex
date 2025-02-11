defmodule Wendys.Orders.API do
  alias Wendys.Orders.Item

  @doc """
  Calls local ollama instance to convert textual representation of
  order into one or more menu items.
  """
  def create_order_items(text) do
    Instructor.chat_completion(
      model: "qwen2.5:7b",
      mode: :json,
      max_retries: 3,
      response_model: Item,
      messages: [
        %{
          role: "user",
          content: """
          Your purpose is to create and return a list of zero or more Wendys.Orders.Item by
          mapping the set of available Wendys.Menu.Item to a Wendys.Orders.Item
          by using a textual representation of the customers order.

          This is for a fast food business.
          They sell hamburgers, french fries, and milkshakes.

          Available Wendys.Menu.Item:
          [
            %Wendys.Menu.Item{id: 0, name: "Hamburger", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2024-03/2024_DELIVERECT_Dave%27s%20Single_One%20Cheese_0.png?itok=1Q6EH2zs"},
            %Wendys.Menu.Item{id: 1, name: "French Fry", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2021-05/fries-medium-22_medium_US_en.png?itok=dmgwkN1f"},
            %Wendys.Menu.Item{id: 2, name: "Milkshake", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2021-05/jr-chocolate-frosty-37_medium_US_en.png?itok=Ea5g2v80"}
          ]

          Textual representation of the customers order:
          #{text}
          """
        }
      ]
    )
  end
end