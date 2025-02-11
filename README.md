# Wendys

Sir, this is a Wendys.

Requires running ollama w/ qwen2.5:7b.
`ollama pull qwen2.5:7b`
`ollama run qwen2.5:7b`

This works by using Nx, Bumblebee, and an openAI whisper model to convert speech to text.
It then uses the gerated text and Instructor, Ollama, and the qwen2.5:7b model to map
predefined menu items into a set of order items.

Demo Video: https://vimeo.com/1055635853