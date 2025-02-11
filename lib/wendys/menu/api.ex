defmodule Wendys.Menu.API do

  alias Wendys.Menu.Item

  def get_menu_items do
    [
      %Item{id: 0, name: "Hamburger", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2024-03/2024_DELIVERECT_Dave%27s%20Single_One%20Cheese_0.png?itok=1Q6EH2zs"},
      %Item{id: 1, name: "French Fry", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2021-05/fries-medium-22_medium_US_en.png?itok=dmgwkN1f"},
      %Item{id: 2, name: "Milkshake", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2021-05/jr-chocolate-frosty-37_medium_US_en.png?itok=Ea5g2v80"}
    ]
  end
end