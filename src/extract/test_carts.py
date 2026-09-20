import requests

url = "https://dummyjson.com/carts"

response = requests.get(
    url,
    params={
        "limit": 30,
        "skip": 0
    },
    timeout=30
)

response.raise_for_status()

data = response.json()

print("Total informado pela API:", data["total"])
print("Quantidade retornada:", len(data["carts"]))
print("Skip:", data["skip"])
print("Limit:", data["limit"])