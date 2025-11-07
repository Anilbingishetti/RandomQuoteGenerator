<<<<<<< HEAD
import random

quotes = [
    "The best way to get started is to quit talking and begin doing. – Walt Disney",
    "It’s not whether you get knocked down, it’s whether you get up. – Vince Lombardi",
    "Your time is limited, so don’t waste it living someone else’s life. – Steve Jobs",
    "If you can dream it, you can do it. – Walt Disney",
    "The future depends on what you do today. – Mahatma Gandhi",
    "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill"
]

print("Random Quote Generator!")
print("------------------------")
print(random.choice(quotes))
=======
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
>>>>>>> 3ee16dd (comming from new folder)
