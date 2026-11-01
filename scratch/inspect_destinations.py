import json

with open('c:/Users/DELL/Downloads/AI Coding/Gemini Code/TRAVEL_APP/mobile_flutter/assets/data/destinations_seed.json', encoding='utf-8') as f:
    data = json.load(f)

destinations = data['destinations']
print(f"Total destinations: {len(destinations)}")
for idx, d in enumerate(destinations):
    media = d.get('media', [{}])[0]
    print(f"{idx+1}. [{d['id']}] {d['name']}")
    print(f"   Image: {media.get('image_url')}")
    print(f"   LocalAsset: {media.get('local_asset_path')}")
    print(f"   Summary: {d.get('editorial_summary', '')[:60]}...")

