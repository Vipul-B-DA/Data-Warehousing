# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# --- INSTALL SYSTEM DEPENDENCIES (INCLUDING ODBC DRIVER) ---
# First, update the package manager and install necessary tools
RUN apt-get update && apt-get install -y curl gnupg unixodbc-dev

# Add the Microsoft package repository for the ODBC driver
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Finally, install the ODBC Driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17
# --- END OF SYSTEM DEPENDENCIES ---

# Copy your local code to the container's /app folder
COPY . .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# This command tells Render how to start your web server
# It replaces the need for a Procfile
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]