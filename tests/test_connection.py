import pyodbc
import os
from dotenv import load_dotenv

# Load environment variables from your local .env file
load_dotenv()

# Get the full connection string
# IMPORTANT: Make sure this is the exact same string you have in Render
connection_string = os.getenv('DATABASE_CONNECTION_STRING')

if not connection_string:
    print("❌ ERROR: DATABASE_CONNECTION_STRING not found in your .env file.")
else:
    print("Attempting to connect to the database...")
    print("This may take up to 30 seconds.")
    try:
        # Try to establish a connection with a 30-second timeout
        cnxn = pyodbc.connect(connection_string, timeout=30)
        print("\n✅ SUCCESS: Connection established successfully!")
        cnxn.close()
        print("Connection closed.")
    except pyodbc.Error as ex:
        # ex.args[0] gives us the error code (SQLSTATE)
        sqlstate = ex.args[0]
        print(f"\n❌ FAILED: An error occurred.")
        print(f"SQLSTATE: {sqlstate}")
        print(ex)
