# brainster

Local lab for **LightRAG** using the notebook `lab1_graphrag_lightrag.ipynb` (GraphRAG-style indexing and querying with configurable LLM and embedding backends).

## Prerequisites

- **Python 3.10+** (`python3` on your PATH)
- Optional: **[Ollama](https://ollama.com)** if you use local models (`LIGHTRAG_PROVIDER=ollama` and/or `EMBEDDING_BACKEND=ollama`)

## Quick start

1. **Create the virtualenv and install dependencies**

   ```bash
   make setup
   ```

   Or run the script directly (see `setup.sh` for flags like `SKIP_VOYAGE=1`, `SKIP_OLLAMA=1`, `RECREATE_VENV=1`):

   ```bash
   chmod +x ./setup.sh && ./setup.sh
   ```

   With a TTY, `make setup` opens a subshell with the venv already activated; type `exit` to leave.

2. **Configure secrets and provider settings**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` and set at least what your chosen `LIGHTRAG_PROVIDER` needs (for example `OPENAI_API_KEY` when using OpenAI). All variables are documented in `.env.example`.

3. **Run the notebook**

   ```bash
   source .venv/bin/activate
   jupyter lab lab1_graphrag_lightrag.ipynb
   ```

   In **Cursor / VS Code**, pick the interpreter `.venv/bin/python` and open the same notebook. If you registered the kernel during setup, you can choose **Python (brainster-lightrag)** in Jupyter.

## Headless run (execute all cells)

Requires a working `.env` and whatever APIs or local services the notebook uses:

```bash
make run
```

This writes `lab1_graphrag_lightrag.executed.ipynb` and does not overwrite the original notebook.

## Troubleshooting

- **Missing venv**: run `make setup` again.
- **Ollama**: if you skipped pulls during setup, install Ollama and run the `ollama pull` commands printed at the end of `setup.sh`, or set `SKIP_OLLAMA=1` when you only use cloud providers.
