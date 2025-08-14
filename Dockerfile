FROM langflowai/langflow:latest
WORKDIR /app

# Kopiowanie folderów
COPY custom_components /app/custom_components
COPY flows /app/flows

# Kopiowanie plików z zależnościami
COPY pyproject.toml uv.lock /app/

# Instalacja zależności z cache
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-editable --extra postgresql

# Domyślne wartości zmiennych środowiskowych mogą być podane jako fallback,
# a CapRover nadpisze je swoimi ustawieniami deploymentu.

ENV LANGFLOW_COMPONENTS_PATH=${LANGFLOW_COMPONENTS_PATH:-/app/custom_components} \
    LANGFLOW_LOAD_FLOWS_PATH=${LANGFLOW_LOAD_FLOWS_PATH:-/app/flows} \
    LANGFLOW_LOG_ENV=${LANGFLOW_LOG_ENV:-container} \
    LANGFLOW_PORT=${LANGFLOW_PORT:-7860}

EXPOSE ${LANGFLOW_PORT:-7860}

CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "${LANGFLOW_PORT}"]
