defmodule WendysWeb.MenuLive do
  @moduledoc """
  Wendy's Menu & Ordering System.

  I borrowed pretty heavily from the following repos:
  https://github.com/fly-apps/live_beats
  https://github.com/toranb/liveview-transcription-example
  https://github.com/thmsmlr/instructor_ex/blob/main/pages/llm-providers/ollama.livemd
  """
  use WendysWeb, :live_view

  alias Wendys.Menu.API, as: Menu
  alias Wendys.Orders.API, as: Orders
  alias Wendys.Orders.Item, as: OrderItem

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, _} = create_uploads_folder()

    {:ok,
     socket
     |> assign(:menu_items, Menu.get_menu_items())
     |> assign(audio: nil, recording: false, task: nil)
     |> allow_upload(:audio, accept: :any, progress: &handle_progress/3, auto_upload: true)
     |> stream(:segments, [], dom_id: &"ss-#{&1.order_item.position}")}
  end

  @impl true
  def handle_event("start", _value, socket) do
    socket = socket |> push_event("start", %{})
    {:noreply, assign(socket, recording: true)}
  end

  @impl true
  def handle_event("stop", _value, %{assigns: %{recording: recording}} = socket) do
    socket = if recording, do: socket |> push_event("stop", %{}), else: socket
    {:noreply, assign(socket, recording: false)}
  end

  @impl true
  def handle_event("noop", %{}, socket) do
    # We need phx-change and phx-submit on the form for live uploads
    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, results}, socket) when socket.assigns.task.ref == ref do
    socket = socket |> assign(task: nil)

    socket =
      results
      |> Enum.reduce(socket, fn %OrderItem{} = order_item, socket ->
        socket |> stream_insert(:segments, %{order_item: order_item})
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def handle_progress(:audio, entry, socket) when entry.done? do
    path =
      consume_uploaded_entry(socket, entry, fn upload ->
        dest = Path.join(["priv", "static", "uploads", Path.basename(upload.path)])
        File.cp!(upload.path, dest)
        {:ok, dest}
      end)

    {:ok, %{duration: duration}} = Mp3Duration.parse(path)

    task =
      speech_to_text(duration, path, 20, fn _ss, text ->
        {:ok, %OrderItem{} = item} = Orders.create_order_items(text)
        item
      end)

    {:noreply, assign(socket, task: task)}
  end

  def handle_progress(_name, _entry, socket), do: {:noreply, socket}

  def speech_to_text(duration, path, chunk_time, func) do
    Task.async(fn ->
      format = get_format()

      0..duration//chunk_time
      |> Task.async_stream(
        fn ss ->
          args = ~w(-ac 1 -ar 16k -f #{format} -ss #{ss} -t #{chunk_time} -v quiet -)
          {data, 0} = System.cmd("ffmpeg", ["-i", path] ++ args)
          {ss, Nx.Serving.batched_run(WhisperServing, Nx.from_binary(data, :f32))}
        end,
        max_concurrency: 4,
        timeout: :infinity
      )
      |> Enum.map(fn {:ok, {ss, %{results: [%{text: text}]}}} ->
        func.(ss, text)
      end)
    end)
  end

  def get_format() do
    case System.endianness() do
      :little -> "f32le"
      :big -> "f32be"
    end
  end

  defp create_uploads_folder do
    path = Path.join(["priv", "static", "uploads"])

    case File.mkdir(path) do
      :ok ->
        {:ok, path}

      {:error, :eexist} ->
        {:ok, path}

      {:error, :eacces} ->
        raise "Missing search or write permissions for the parent directories of path"
    end
  end

  def human_readable_order_item(%OrderItem{} = item) do
    menu_item = Enum.find(Menu.get_menu_items(), &(&1.id == item.menu_item_id))
    "Item: #{menu_item.name}, quantity: #{item.quantity}"
  end
end
