FROM python:3.8-slim

WORKDIR /app

# Install git (for the GitHub clone) AND g++ (C++ compiler)
# We also keep the cleanup to keep the image small.
RUN apt-get update && apt-get install -y git g++ && rm -rf /var/lib/apt/lists/*

# Upgrade pip, setuptools, wheel to avoid dependency resolution issues
RUN pip install --upgrade pip setuptools wheel

COPY requirements.txt .

# This will now succeed because g++ is available to compile the C++ extensions
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]