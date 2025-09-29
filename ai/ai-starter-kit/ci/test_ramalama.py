#!/usr/bin/env python3
import sys
import requests
import time

def test_ramalama_health(ramalama_url):
    try:
        response = requests.get(f"{ramalama_url}/health", timeout=10)
        response.raise_for_status()
        print("Ramalama health check passed")
        return True
    except Exception as e:
        print(f"Ramalama health check failed: {e}")
        return False

def test_ramalama_api(ramalama_url):
    try:
        response = requests.get(f"{ramalama_url}/api/tags", timeout=10)
        response.raise_for_status()
        print("Ramalama API is responding")
        print(f"Response: {response.json()}")
        return True
    except Exception as e:
        print(f"Ramalama API test failed: {e}")
        return False

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 test_ramalama.py <ramalama_url>")
        sys.exit(1)
    
    ramalama_url = f"http://{sys.argv[1]}"
    
    print(f"Testing ramalama at {ramalama_url}")
    
    time.sleep(5)
    
    health_ok = test_ramalama_health(ramalama_url)
    api_ok = test_ramalama_api(ramalama_url)
    
    if health_ok and api_ok:
        print("All ramalama tests passed")
        sys.exit(0)
    else:
        print("Ramalama tests failed")
        sys.exit(1)