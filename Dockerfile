FROM python:3.8-slim

WORKDIR /app

# Install build-essential for compiling C extensions (needed by spacy)
# git is needed because requirements.txt installs pandas-profiling from a git URL
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel for better dependency resolution
RUN pip install --upgrade pip setuptools wheel

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]