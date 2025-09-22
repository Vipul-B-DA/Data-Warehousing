FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# --- INSTALL SYSTEM DEPENDENCIES (MODERN METHOD) ---
# Install prerequisite packages including gpg
RUN apt-get update && apt-get install -y curl gpg apt-transport-https unixodbc-dev

# Download and install the Microsoft GPG key securely (avoids apt-key)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

# Add the Microsoft repository referencing the new key
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" > /etc/apt/sources.list.d/mssql-release.list

# Install the ODBC Driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y msodbcsql17
# --- END OF SYSTEM DEPENDENCIES ---

# Copy the rest of the application
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Command to run the application
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]