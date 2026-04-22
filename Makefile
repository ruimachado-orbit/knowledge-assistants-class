SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

VENV := .venv
PY := $(VENV)/bin/python
JUPYTER := $(VENV)/bin/jupyter
NB := lab1_graphrag_lightrag.ipynb
# nbconvert --output is the basename (exporter adds .ipynb)
NB_EXEC_BASE := lab1_graphrag_lightrag.executed

.PHONY: setup run

# Run project setup (venv + deps). With a TTY, drops into an interactive bash that already
# sourced .venv (type exit to leave). Without a TTY, prints the source command instead.
setup:
	@chmod +x ./setup.sh && ./setup.sh; \
	if [ -t 1 ]; then \
	  echo ""; \
	  echo "Entering subshell with .venv activated (type exit to return to your previous shell)."; \
	  . "$(CURDIR)/$(VENV)/bin/activate" && exec bash -i; \
	else \
	  echo ""; \
	  echo "Virtualenv is ready. No TTY — activate manually:"; \
	  echo "  source \"$(CURDIR)/$(VENV)/bin/activate\""; \
	fi

# Execute every cell in the lab notebook (writes $(NB_EXEC_BASE).ipynb; does not modify $(NB)).
run: $(PY)
	@test -f "$(NB)" || { echo "error: $(NB) not found"; exit 1; }
	"$(JUPYTER)" nbconvert \
		--to notebook \
		--execute "$(NB)" \
		--output "$(NB_EXEC_BASE)" \
		--ExecutePreprocessor.timeout=-1

$(PY):
	@echo "error: $(VENV) missing. Run: make setup" >&2
	@exit 1
