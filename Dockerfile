FROM python:3.8-slim

WORKDIR /app

# Install git (needed for the GitHub install) and gcc (for native extensions)
RUN apt-get update && apt-get install -y git gcc && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel to avoid build errors
RUN pip install --upgrade pip setuptools wheel

COPY requirements.txt .

# This will install pandas-profiling from GitHub (via the git+ line) and the rest
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]