FROM langflowai/langflow:latest
WORKDIR /app

# Copy dependency files first for caching
COPY pyproject.toml uv.lock /app/

# Install dependencies with cache
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-editable --extra postgresql

# Create directories to avoid COPY errors if folders do not exist
RUN mkdir -p /app/custom_components /app/flows

# Copy custom_components folder (if exists)
COPY custom_components /app/custom_components

# Copy flows folder (if exists)
COPY flows /app/flows

# Default environment variable values (overwritten by CapRover at runtime)
ENV LANGFLOW_COMPONENTS_PATH=${LANGFLOW_COMPONENTS_PATH:-/app/custom_components} \
    LANGFLOW_LOAD_FLOWS_PATH=${LANGFLOW_LOAD_FLOWS_PATH:-/app/flows} \
    LANGFLOW_LOG_ENV=${LANGFLOW_LOG_ENV:-container} \
    LANGFLOW_PORT=${LANGFLOW_PORT:-7860}

EXPOSE ${LANGFLOW_PORT:-7860}

CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "${LANGFLOW_PORT}"]
