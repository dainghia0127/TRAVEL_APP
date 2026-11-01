import json
import os
import urllib.request
import urllib.parse
import re

seed_path = 'c:/Users/DELL/Downloads/AI Coding/Gemini Code/TRAVEL_APP/mobile_flutter/assets/data/destinations_seed.json'
output_dir = 'c:/Users/DELL/Downloads/AI Coding/Gemini Code/TRAVEL_APP/mobile_flutter/assets/images/destinations'
os.makedirs(output_dir, exist_ok=True)

with open(seed_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

destinations = data['destinations']

# Từ khóa tìm kiếm ảnh thật trên Wikimedia Commons cho từng địa điểm
search_queries = {
    "dest_vn_ma_pi_leng": "Ma Pi Leng Pass winding road Ha Giang",
    "dest_vn_o_quy_ho": "O Quy Ho pass Vietnam",
    "dest_vn_ban_gioc": "Ban Gioc Waterfall Cao Bang Province",
    "dest_vn_ha_long_bay": "Ha Long Bay Vietnam Islands",
    "dest_vn_lao_than": "Muong Hoa Valley terraced fields",
    "dest_vn_phong_nha": "Phong Nha-Ke Bang cave",
    "dest_vn_trang_an": "Trang An Landscape Complex Ninh Binh",
    "dest_vn_hai_van": "Hai Van Pass Lang Co",
    "dest_vn_ta_nang_phan_dung": "Camping in grass hill in Ta Nang",
    "dest_vn_langbiang": "Lang Biang mountain in Da Lat",
    "dest_vn_cat_tien": "Cat Tien National Park Vietnam",
    "dest_vn_ba_den": "Ba Den Mountain summit temple Tay Ninh",
    "dest_vn_con_dao": "Beach view from Six Senses Resort in Con Dao",
    "dest_vn_phu_quoc": "Bai Sao Beach Phu Quoc",
    "trend_hcm_bach_dang_waterbus": "Bach Dang Wharf Saigon river",
    "trend_hcm_thu_thiem_park": "Thu Thiem Bridge Saigon",
    "trend_hcm_42_nguyen_hue": "Nguyen Hue Street night Saigon",
    "trend_hcm_ho_con_rua": "Turtle Lake Saigon Ho Con Rua",
    "trend_hcm_cau_anh_sao": "Starlight Bridge Phu My Hung",
    "trend_hcm_can_gio": "Can Gio mangrove forest Vietnam",
    "trend_dl_thung_lung_den": "Da Lat Flower Park lake",
    "trend_hn_train_street": "Hanoi old quarter street train",
    "trend_dn_cau_vang": "Da Nang Dragon Bridge Han river",
    "intl_mount_fuji": "Lake Kawaguchiko Sakura Mount Fuji",
    "intl_everest_base_camp": "Everest base camp trek Nepal",
    "intl_taj_mahal": "Aks The Reflection Taj Mahal",
    "intl_tour_du_mont_blanc": "Mont Blanc massif Alps",
    "intl_lofoten_islands": "Reine i Lofoten Norway",
    "intl_banff_rockies": "Moraine Lake Banff National Park",
    "intl_milford_track": "Milford Track Pass Fiordland",
    "intl_machu_picchu": "Machu Picchu Peru",
    "intl_kilimanjaro": "Amboseli Park Kilimanjaro"
}

headers = {'User-Agent': 'TravelAppBot/1.0 (contact@travelapp.local)'}

for d in destinations:
    did = d['id']
    target_file = os.path.join(output_dir, f"{did}.jpg")
    
    # Nếu file đã tồn tại và kích thước > 50KB thì bỏ qua
    if os.path.exists(target_file) and os.path.getsize(target_file) > 50000:
        print(f"[EXISTS] {did}: {os.path.getsize(target_file)} bytes")
        d['media'][0]['local_asset_path'] = f"assets/images/destinations/{did}.jpg"
        continue
        
    query = search_queries.get(did, d['name'])
    api_url = f"https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch={urllib.parse.quote(query)}&gsrnamespace=6&prop=imageinfo&iiprop=url|size&format=json&gsrlimit=3"
    
    success = False
    try:
        req = urllib.request.Request(api_url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as resp:
            res_data = json.load(resp)
            pages = res_data.get('query', {}).get('pages', {})
            for pid, page in pages.items():
                title = page.get('title', '')
                if not (title.lower().endswith('.jpg') or title.lower().endswith('.jpeg') or title.lower().endswith('.png')):
                    continue
                ii = page.get('imageinfo', [{}])[0]
                raw_url = ii.get('url', '')
                if raw_url:
                    # Chuyển đổi sang URL thumbnail 1280px
                    # Dạng https://upload.wikimedia.org/wikipedia/commons/a/ab/Filename.jpg
                    # -> https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Filename.jpg/1280px-Filename.jpg
                    parts = raw_url.split('/wikipedia/commons/')
                    if len(parts) == 2:
                        sub = parts[1]
                        filename = os.path.basename(sub)
                        thumb_url = f"https://upload.wikimedia.org/wikipedia/commons/thumb/{sub}/1280px-{filename}"
                    else:
                        thumb_url = raw_url
                        
                    try:
                        thumb_req = urllib.request.Request(thumb_url, headers=headers)
                        with urllib.request.urlopen(thumb_req, timeout=12) as img_resp:
                            img_data = img_resp.read()
                            if len(img_data) > 20000:
                                with open(target_file, 'wb') as img_out:
                                    img_out.write(img_data)
                                print(f"[SUCCESS] Downloaded {did} ({len(img_data)} bytes) from {title}")
                                d['media'][0]['local_asset_path'] = f"assets/images/destinations/{did}.jpg"
                                success = True
                                break
                    except Exception as te:
                        # Thử tải raw_url
                        try:
                            raw_req = urllib.request.Request(raw_url, headers=headers)
                            with urllib.request.urlopen(raw_req, timeout=12) as img_resp:
                                img_data = img_resp.read()
                                if len(img_data) > 20000:
                                    with open(target_file, 'wb') as img_out:
                                        img_out.write(img_data)
                                    print(f"[SUCCESS-RAW] Downloaded {did} ({len(img_data)} bytes)")
                                    d['media'][0]['local_asset_path'] = f"assets/images/destinations/{did}.jpg"
                                    success = True
                                    break
                        except Exception as re:
                            print(f"[ERROR-RAW] {did}: {re}")
    except Exception as e:
        print(f"[API ERROR] {did}: {e}")
        
    if not success:
        print(f"[FAILED] Could not download image for {did}")

# Cập nhật seed
with open(seed_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("\nFinished downloading destination images and updated seed JSON!")

