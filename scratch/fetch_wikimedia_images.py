import urllib.request
import urllib.parse
import json

queries = {
    "dest_vn_ma_pi_leng": "Ma Pi Leng Pass Ha Giang",
    "dest_vn_o_quy_ho": "O Quy Ho Pass Hoang Lien Son",
    "dest_vn_ban_gioc": "Ban Gioc Waterfall Cao Bang",
    "dest_vn_ha_long_bay": "Ha Long Bay Vietnam",
    "dest_vn_lao_than": "Y Ty Lao Cai",
    "dest_vn_phong_nha": "Phong Nha Cave Quang Binh",
    "dest_vn_trang_an": "Trang An Ninh Binh",
    "dest_vn_hai_van": "Hai Van Pass Vietnam",
    "dest_vn_ta_nang_phan_dung": "Ta Nang Phan Dung",
    "dest_vn_langbiang": "Langbiang Da Lat",
    "dest_vn_cat_tien": "Cat Tien National Park",
    "dest_vn_ba_den": "Ba Den Mountain Tay Ninh",
    "dest_vn_con_dao": "Con Dao Island Vietnam",
    "dest_vn_phu_quoc": "Phu Quoc island Sao beach",
    "intl_mount_fuji": "Mount Fuji lake Kawaguchiko",
    "intl_everest_base_camp": "Everest Base Camp Sagarmatha",
    "intl_taj_mahal": "Taj Mahal Agra India",
    "intl_tour_du_mont_blanc": "Tour du Mont Blanc Alps",
    "intl_lofoten_islands": "Reinebringen Lofoten Norway",
    "intl_banff_rockies": "Moraine Lake Banff Rockies",
    "intl_milford_track": "Milford Track Fiordland",
    "intl_machu_picchu": "Machu Picchu Peru Andes",
    "intl_kilimanjaro": "Mount Kilimanjaro Amboseli"
}

results = {}

for dest_id, q in queries.items():
    url = f"https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch={urllib.parse.quote(q)}&gsrnamespace=6&prop=imageinfo&iiprop=url|size|extmetadata&format=json&gsrlimit=5"
    req = urllib.request.Request(url, headers={'User-Agent': 'TravelAppBot/1.0 (contact@travelapp.local)'})
    try:
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.load(resp)
            pages = data.get('query', {}).get('pages', {})
            items = []
            for pid, p in pages.items():
                title = p.get('title', '')
                if not (title.lower().endswith('.jpg') or title.lower().endswith('.jpeg') or title.lower().endswith('.png')):
                    continue
                ii = p.get('imageinfo', [{}])[0]
                img_url = ii.get('url', '')
                width = ii.get('width', 0)
                height = ii.get('height', 0)
                if width >= 1000 and img_url:
                    meta = ii.get('extmetadata', {})
                    artist = meta.get('Artist', {}).get('value', 'Wikimedia Commons')
                    # Strip HTML from artist
                    import re
                    clean_artist = re.sub('<[^<]+?>', '', artist).strip()
                    items.append({
                        'title': title,
                        'url': f"https://commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(title.replace('File:', ''))}?width=1280",
                        'raw_url': img_url,
                        'photographer': clean_artist[:40] if clean_artist else 'Wikimedia Commons'
                    })
            results[dest_id] = items[:2]
    except Exception as e:
        print(f"Error {dest_id}: {e}")

with open('c:/Users/DELL/Downloads/AI Coding/Gemini Code/TRAVEL_APP/scratch/wikimedia_images.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("Saved wikimedia_images.json successfully!")

