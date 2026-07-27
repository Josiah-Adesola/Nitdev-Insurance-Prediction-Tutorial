FROM python:3.8-slim

WORKDIR /app

# Install git + build tools (needed for pandas-profiling and spacy)
RUN apt-get update && apt-get install -y git gcc && rm -rf /var/lib/apt/lists/*

# Upgrade pip & friends
RUN pip install --upgrade pip setuptools wheel

# Copy and install requirements (GitHub URL will be processed here)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your app and the model file
COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]