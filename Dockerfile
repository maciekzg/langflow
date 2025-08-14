FROM langflowai/langflow:latest
WORKDIR /app

# 1. Copy dependency definition files first to leverage Docker cache
COPY pyproject.toml uv.lock /app/

# 2. Copy source code needed for local package installation
#    Required because uv will look for the backend package here
COPY src /app/src
COPY README.md /app/

# 3. Install dependencies with uv (with cache for faster builds)
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-editable --extra postgresql

# 4. Create required dirs to avoid COPY errors
RUN mkdir -p /app/custom_components /app/flows

# 5. Copy custom components and flows (if exist in repo)
COPY custom_components /app/custom_components
COPY flows /app/flows

# 6. Default environment variables (CapRover can override at runtime)
ENV LANGFLOW_COMPONENTS_PATH=/app/custom_components \
    LANGFLOW_LOAD_FLOWS_PATH=/app/flows \
    LANGFLOW_LOG_ENV=container \
    LANGFLOW_PORT=7860

# 7. Expose Langflow port
EXPOSE 7860

# 8. Start Langflow
CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
