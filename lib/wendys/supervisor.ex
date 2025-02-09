defmodule Wendys.Transcription.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do

    Nx.default_backend(EXLA.Backend)

    {:ok, whisper} = Bumblebee.load_model({:hf, "openai/whisper-tiny"})
    {:ok, featurizer} = Bumblebee.load_featurizer({:hf, "openai/whisper-tiny"})
    {:ok, tokenizer} = Bumblebee.load_tokenizer({:hf, "openai/whisper-tiny"})
    {:ok, generation_config} = Bumblebee.load_generation_config({:hf, "openai/whisper-tiny"})

    serving =
      Bumblebee.Audio.speech_to_text(whisper, featurizer, tokenizer, generation_config,
        defn_options: [compiler: EXLA]
      )

    children = [
      {Nx.Serving, name: WhisperServing, serving: serving},
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end