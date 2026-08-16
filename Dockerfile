# Stage 1: Install Python dependencies
FROM python:3.10-slim AS builder

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2: Runtime image
FROM python:3.10-slim

RUN groupadd --system appgroup \
    && useradd --system --gid appgroup appuser

WORKDIR /app

COPY --from=builder /install /usr/local

COPY backend ./backend

USER appuser

EXPOSE 8000

WORKDIR /app/backend

CMD ["sh", "-c", "python migrate.py && exec uvicorn main:app --host 0.0.0.0 --port 8000"]