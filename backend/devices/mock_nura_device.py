# mock_nura_device.py
import requests
import json
import time
import os

# --- Configuration ---
# IMPORTANT: Replace with the actual URL where your Django backend is running
# If running Django locally, use your machine's IP address or 127.0.0.1
# If your Django backend is deployed to a cloud server, use its public URL
DJANGO_BASE_URL = "http://127.0.0.1:8000" # CHANGE THIS TO YOUR DJANGO SERVER IP/URL

# This mock device needs to know its own ID to check its status
MOCK_DEVICE_ID = "mock_nura_001" # This should match a device_id you created in Django admin

# For this mock, we'll assume a user is already logged in and we have their token.
# In a real scenario, the Pi would have its own device-specific token or be pre-authenticated.
# For testing, you'll need to get a token from your Django login API and paste it here.
# Example: After logging in via Postman/Flutter, copy the token.
MOCK_USER_AUTH_TOKEN = "YOUR_USER_AUTH_TOKEN_HERE" # <--- REPLACE THIS!

# How often the mock device checks its status with the backend (in seconds)
POLLING_INTERVAL_SECONDS = 5

# --- Global State ---
device_connected_status = False

# --- Functions ---
def get_device_status(token):
    url = f"{DJANGO_BASE_URL}/api/device/status/"
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Token {token}" # Authenticate as the user linked to the device
    }
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        data = response.json()
        return data.get('status', 'disconnected')
    except requests.exceptions.RequestException as e:
        print(f"Mock Device: Error checking status with Django: {e}")
        return 'disconnected' # Assume disconnected on error

def main():
    global device_connected_status
    print(f"Mock NURA Device '{MOCK_DEVICE_ID}' started.")
    print(f"Polling Django backend at: {DJANGO_BASE_URL}")
    print("Waiting for connection command from app...")

    if not MOCK_USER_AUTH_TOKEN or MOCK_USER_AUTH_TOKEN == "YOUR_USER_AUTH_TOKEN_HERE":
        print("\nWARNING: MOCK_USER_AUTH_TOKEN is not set. Please log in via Flutter/Postman, get the token, and paste it into mock_nura_device.py.")
        print("This mock device needs to authenticate as a user to check its status.")
        return

    while True:
        current_status = get_device_status(MOCK_USER_AUTH_TOKEN)

        if current_status == 'connected' and not device_connected_status:
            print(f"\n--- Mock Device: NURA Device '{MOCK_DEVICE_ID}' CONNECTED! ---")
            device_connected_status = True
            # In a real device, you might start audio recording, etc. here
        elif current_status == 'disconnected' and device_connected_status:
            print(f"\n--- Mock Device: NURA Device '{MOCK_DEVICE_ID}' DISCONNECTED! ---")
            device_connected_status = False
        elif current_status == 'disconnected' and not device_connected_status:
            # print("Mock Device: Still disconnected. Waiting...") # Optional: print this if you want constant feedback
            pass


        time.sleep(POLLING_INTERVAL_SECONDS)

if __name__ == "__main__":
    main()