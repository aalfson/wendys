defmodule WendysWeb.MenuLive do
  @moduledoc """
  Wendy's Menu & Ordering System
  """
  use WendysWeb, :live_view

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:foo, "bar")}
  end
end
