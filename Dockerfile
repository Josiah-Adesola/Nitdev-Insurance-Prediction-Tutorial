FROM python:3.8-slim

WORKDIR /app

# 1️⃣ Install git (needed for the GitHub pip install) and a C compiler
RUN apt-get update && apt-get install -y git gcc && rm -rf /var/lib/apt/lists/*

# 2️⃣ Upgrade pip, setuptools, wheel (optional but recommended)
RUN pip install --upgrade pip setuptools wheel

# 3️⃣ Copy requirements.txt (this file contains the git+ line)
COPY requirements.txt .

# 4️⃣ Install all dependencies – git is now available
RUN pip install --no-cache-dir -r requirements.txt

# 5️⃣ Copy the rest of the application (including model file)
COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]