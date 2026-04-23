# ==============================================================================
# Stage 1: Builder (полный образ Python)
# ==============================================================================
FROM python:3.10.20-bookworm as builder

WORKDIR /build
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ==============================================================================
# Stage 2: Final (минималистичный образ)
# ==============================================================================
FROM python:3.10.20-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        libpq5 \
        libblas3 \
        liblapack3 \
        libgfortran5 \
    && rm -rf /var/lib/apt/lists/*

# WORKDIR /app

# Копируем установленные пакеты из builder
COPY --from=builder /usr/local/lib/python3.10/site-packages \
                    /usr/local/lib/python3.10/site-packages

COPY --from=builder /usr/local/bin/pip* \
                    /usr/local/bin/

# COPY . .

# RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
# USER appuser

CMD ["python3"]
