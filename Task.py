import requests

def get_random_quote():
    url = "https://api.quotable.io/random"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        print(f'"{data["content"]}" — {data["author"]}')
    else:
        print("Failed to retrieve quote. Try again later.")

print("Random Quote Generator (API)")
print("-----------------------------")
get_random_quote()
