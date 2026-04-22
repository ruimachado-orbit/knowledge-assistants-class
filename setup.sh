#!/usr/bin/env bash
# Create a local venv with everything needed for lab1_graphrag_lightrag.ipynb
#
# Usage:
#   ./setup.sh
#   SKIP_VOYAGE=1 ./setup.sh    # omit voyageai (only if you never use EMBEDDING_BACKEND=voyage)
#   SKIP_OLLAMA=1 ./setup.sh    # do not run `ollama pull` (no Ollama or offline)
#   SKIP_OLLAMA_LLM=1 ./setup.sh  # pull only the embedding model, not the chat LLM
#   OLLAMA_EMBED_MODEL=mxbai-embed-large ./setup.sh   # override default embed model
#   RECREATE_VENV=1 ./setup.sh  # delete .venv first, then create fresh
#   PYTHON=/opt/homebrew/bin/python3.12 ./setup.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PYTHON="${PYTHON:-python3}"
VENV="${VENV:-.venv}"
SKIP_VOYAGE="${SKIP_VOYAGE:-0}"
SKIP_OLLAMA="${SKIP_OLLAMA:-0}"
SKIP_OLLAMA_LLM="${SKIP_OLLAMA_LLM:-0}"
SKIP_KERNEL="${SKIP_KERNEL:-0}"
RECREATE_VENV="${RECREATE_VENV:-0}"

if ! command -v "$PYTHON" >/dev/null 2>&1; then
  echo "error: '$PYTHON' not found. Install Python 3.10+ or set PYTHON=... to your interpreter." >&2
  exit 1
fi

echo "==> Using interpreter: $($PYTHON -c 'import sys; print(sys.executable)')"

if [[ "$RECREATE_VENV" == "1" ]] && [[ -d "$VENV" ]]; then
  echo "==> RECREATE_VENV=1: removing $ROOT/$VENV"
  rm -rf "$VENV"
fi
if [[ -d "$VENV" ]]; then
  echo "==> Reusing existing venv at $ROOT/$VENV (re-run pip install)"
else
  echo "==> Creating venv at $ROOT/$VENV"
  "$PYTHON" -m venv "$VENV"
fi

# shellcheck disable=SC1090
source "$VENV/bin/activate"

echo "==> Upgrading pip"
python -m pip install --upgrade pip

echo "==> Installing notebook dependencies"
# Core: LightRAG + OpenAI + dotenv (Section 0–1)
# networkx / matplotlib: graph inspection + optional plot cell
# ipykernel + jupyterlab: run the notebook inside this venv
# pymupdf: optional PDF path in Section 2 (fitz)
pip_packages=(
  "lightrag-hku>=1.4"
  "openai>=1.0"
  "python-dotenv>=1.0"
  "networkx>=3.0"
  "matplotlib>=3.8"
  "ipykernel>=6.0"
  "jupyterlab>=4.0"
  "nbconvert>=7.0"
  "pymupdf>=1.24"
)

if [[ "$SKIP_VOYAGE" != "1" ]]; then
  pip_packages+=("voyageai>=0.2")
else
  echo "==> Skipping voyageai (SKIP_VOYAGE=1). Install later if you use EMBEDDING_BACKEND=voyage."
fi

python -m pip install "${pip_packages[@]}"

if [[ "$SKIP_KERNEL" != "1" ]]; then
  echo "==> Registering Jupyter kernel for this venv (sys-prefix)"
  python -m ipykernel install --sys-prefix \
    --name brainster-lightrag \
    --display-name "Python (brainster-lightrag)"
else
  echo "==> Skipping ipykernel register (SKIP_KERNEL=1)"
fi

# --- Ollama (optional): local embeddings and/or local LLM for the notebook -----------------
# Matches defaults in .env.example (OLLAMA_EMBED_MODEL, OLLAMA_LLM_MODEL).
# Install: https://ollama.ai  (macOS: brew install --cask ollama)
if [[ "$SKIP_OLLAMA" == "1" ]]; then
  echo "==> SKIP_OLLAMA=1: skipping Ollama model pulls"
elif command -v ollama >/dev/null 2>&1; then
  OLLAMA_EMBED="${OLLAMA_EMBED_MODEL:-nomic-embed-text}"
  OLLAMA_LLM="${OLLAMA_LLM_MODEL:-llama3.2}"
  echo "==> Ollama: pulling embedding model (${OLLAMA_EMBED})"
  ollama pull "$OLLAMA_EMBED"
  if [[ "$SKIP_OLLAMA_LLM" != "1" ]]; then
    echo "==> Ollama: pulling LLM model (${OLLAMA_LLM}) for LIGHTRAG_PROVIDER=ollama"
    ollama pull "$OLLAMA_LLM"
  else
    echo "==> SKIP_OLLAMA_LLM=1: not pulling chat model (${OLLAMA_LLM})"
  fi
else
  echo "==> Ollama CLI not found in PATH — skipped model pulls."
  echo "    Install from https://ollama.ai then run:"
  echo "      ollama pull nomic-embed-text    # local embeddings (EMBEDDING_BACKEND=ollama)"
  echo "      ollama pull llama3.2          # local LLM (LIGHTRAG_PROVIDER=ollama)"
fi

echo ""
echo "Done."
echo "  Activate:  source \"$ROOT/$VENV/bin/activate\""
echo "  Jupyter:   jupyter lab \"$ROOT/lab1_graphrag_lightrag.ipynb\""
echo "  Or Cursor:  select interpreter → $ROOT/$VENV/bin/python"
echo ""
if [[ ! -f "$ROOT/.env" ]]; then
  echo "Tip: copy env template before running the notebook:"
  echo "  cp \"$ROOT/.env.example\" \"$ROOT/.env\" && edit .env"
fi
