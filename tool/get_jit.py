import time
import jwt
import requests

# 設定
APP_ID =''
PRIVATE_KEY_PATH = ''

# JWT 作成
with open(PRIVATE_KEY_PATH, 'r') as f:
    private_key = f.read()

payload = {
    'iat': int(time.time()),
    'exp': int(time.time()) + 600,
    'iss': APP_ID
}

jwt_token = jwt.encode(payload, private_key, algorithm='RS256')

# Installation ID を取得
headers = {
    'Authorization': f'Bearer {jwt_token}',
    'Accept': 'application/vnd.github+json'
}
res = requests.get('https://api.github.com/app/installations', headers=headers)
installation_id = res.json()[0]['id']

# JIT token を取得
res = requests.post(
    f'https://api.github.com/app/installations/{installation_id}/access_tokens',
    headers=headers
)

print('✅ Installation Token:')
print(res.json()['token'])
