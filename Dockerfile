FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# --- INSTALL SYSTEM DEPENDENCIES (MODERN METHOD) ---
# Install prerequisite packages for PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev
# --- END OF SYSTEM DEPENDENCIES ---

# Copy the rest of the application
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run the application
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]
