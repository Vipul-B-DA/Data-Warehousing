# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# --- INSTALL SYSTEM DEPENDENCIES (INCLUDING ODBC DRIVER) ---
# CORRECTED: Added 'curl' to this line
RUN apt-get update && apt-get install -y curl gnupg unixodbc-dev

# Add the Microsoft package repository for the ODBC driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Install the ODBC Driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17
# --- END OF SYSTEM DEPENDENCIES ---

# (The rest of your Dockerfile remains the same)
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]