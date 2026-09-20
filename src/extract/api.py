import requests


PAGE_SIZE = 30


def get_data(url, data_key):
    data_list = []
    skip = 0

    while True:

        params = {
            "limit": PAGE_SIZE,
            "skip": skip
        }

        response = requests.get(
            url,
            params=params,
            timeout=30
        )

        response.raise_for_status()

        data = response.json()

        data_list.extend(data[data_key])

        total = data["total"]

        skip += PAGE_SIZE

        if skip >= total:
            break

    return data_list