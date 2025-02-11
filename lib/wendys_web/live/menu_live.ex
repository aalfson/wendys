defmodule WendysWeb.MenuLive do
  @moduledoc """
  Wendy's Menu & Ordering System.

  I borrowed pretty heavily from the following repos:
  https://github.com/fly-apps/live_beats
  https://github.com/toranb/liveview-transcription-example
  """
  use WendysWeb, :live_view

  alias Wendys.Menu.MenuItem

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, _} = create_uploads_folder()

    {:ok,
     socket
     |> assign(:menu_items, menu_items())
     |> assign(audio: nil, recording: false, task: nil)
     |> allow_upload(:audio, accept: :any, progress: &handle_progress/3, auto_upload: true)
     |> stream(:segments, [], dom_id: &"ss-#{&1.ss}")}
  end

  @impl true
  def handle_event("start", _value, socket) do
    IO.inspect "--------------------> Handling START event"
    socket = socket |> push_event("start", %{})
    {:noreply, assign(socket, recording: true)}
  end

  @impl true
  def handle_event("stop", _value, %{assigns: %{recording: recording}} = socket) do
    IO.inspect "--------------------> Handling STOP event"
    socket = if recording, do: socket |> push_event("stop", %{}), else: socket
    {:noreply, assign(socket, recording: false)}
  end

  @impl true
  def handle_event("noop", %{}, socket) do
    IO.inspect "--------------------> Handling NOOP event"
    # We need phx-change and phx-submit on the form for live uploads
    {:noreply, socket}
  end

  @impl true
  def handle_info({ref, results}, socket) when socket.assigns.task.ref == ref do
    IO.inspect "--------------------> Handling INFO 1 event"
    socket = socket |> assign(task: nil)

    socket =
      results
      |> Enum.reduce(socket, fn {_duration, ss, text}, socket ->
        socket |> stream_insert(:segments, %{ss: ss, text: text})
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket) do
    IO.inspect "--------------------> Handling INFO 2 event"
    {:noreply, socket}
  end

  def handle_progress(:audio, entry, socket) when entry.done? do
    IO.inspect "--------------------> Handling PROGRESS event"
    path =
      consume_uploaded_entry(socket, entry, fn upload ->
        dest = Path.join(["priv", "static", "uploads", Path.basename(upload.path)])
        File.cp!(upload.path, dest)
        {:ok, dest}
      end)

    {:ok, %{duration: duration}} = Mp3Duration.parse(path)

    task =
      speech_to_text(duration, path, 20, fn ss, text ->
        {duration, ss, text}
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

  def menu_items do
    [
      %MenuItem{id: 1, name: "Dave's Single", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2024-03/2024_DELIVERECT_Dave%27s%20Single_One%20Cheese_0.png?itok=1Q6EH2zs"},
      %MenuItem{id: 2, name: "Medium French Fry", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2021-05/fries-medium-22_medium_US_en.png?itok=dmgwkN1f"},
      %MenuItem{id: 3, name: "Small Frosty", image_url: "https://www.wendys.com/sites/default/files/styles/max_650x650/public/2021-05/jr-chocolate-frosty-37_medium_US_en.png?itok=Ea5g2v80"}
    ]
  end

end
