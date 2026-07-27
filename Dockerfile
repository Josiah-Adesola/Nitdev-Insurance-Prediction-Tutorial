FROM python:3.8-slim

WORKDIR /app

# Install git (for the GitHub clone), g++ (C++ compiler for spacy), and clean up
RUN apt-get update && apt-get install -y git g++ && rm -rf /var/lib/apt/lists/*

# Allow the deprecated 'sklearn' package to be installed (required by pyLDAvis)
ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

# Upgrade pip and install cython (speeds up compilation of spacy)
RUN pip install --upgrade pip setuptools wheel cython

COPY requirements.txt .

# Install all dependencies – scikit‑learn is already satisfied by the line in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["sh", "-c", "uvicorn app:app --host 0.0.0.0 --port $PORT"]