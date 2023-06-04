import requests
import shutil

for i in range(1, 277):
  number = f'{i:04}'
  res = requests.get(f"https://elib.nlu.org.ua/files/Disk1/000000001044//jpg/{number}.jpg", stream = True)

  if res.status_code == 200:
    with open(f'{number}.jpg','wb') as f:
      shutil.copyfileobj(res.raw, f)
  else:
    raise

