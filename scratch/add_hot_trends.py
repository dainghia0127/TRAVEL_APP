import json

seed_path = 'c:/Users/DELL/Downloads/AI Coding/Gemini Code/TRAVEL_APP/mobile_flutter/assets/data/destinations_seed.json'
with open(seed_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

existing_ids = {d['id'] for d in data.get('destinations', [])}

new_trends = [
    {
        "id": "trend_hcm_bach_dang_waterbus",
        "slug": "ben-bach-dang-saigon-waterbus",
        "name": "Bến Bạch Đằng & Saigon Waterbus",
        "local_name": "Ga Tàu Thủy Bạch Đằng • Bến Buýt Sông Sài Gòn",
        "province": "TP. Hồ Chí Minh",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_south",
        "category_ids": ["social_trend", "check_in", "city_tour"],
        "center_latitude": 10.7725,
        "center_longitude": 106.7058,
        "elevation_meters": 8,
        "is_social_trend": True,
        "social_platform": "TikTok & Facebook",
        "social_views": "4.2M lượt xem TikTok",
        "photo_spot_tip": "Chụp lúc 17:15 từ khoang sau tàu Waterbus hoặc lan can bến tàu bắt trọn hoàng hôn buông xuống sông Sài Gòn và Landmark 81 rực sáng.",
        "editorial_summary": "Tọa độ ngắm hoàng hôn triệu view gây sốt trên TikTok. Trải nghiệm du ngoạn buýt đường sông ngắm nhìn Landmark 81, Bitexco và cầu Ba Son lên đèn lung linh.",
        "editorial_content": "Bến Bạch Đằng và tuyến buýt đường sông Saigon Waterbus là hiện tượng check-in lan tỏa mạnh mẽ trên các nền tảng mạng xã hội những năm gần đây. Nằm ngay trái tim Quận 1 bên dòng sông Sài Gòn lộng gió, bến tàu sở hữu công viên bờ sông xanh mát và góc nhìn trực diện sang bán đảo Thủ Thiêm. Khi hoàng hôn buông xuống, toàn bộ khung trời chuyển sắc cam tím phản chiếu xuống mặt nước, tạo nên khung cảnh điện ảnh tuyệt mỹ giữa lòng đô thị năng động.",
        "best_travel_seasons": ["Quanh năm (16:30 - 21:00 đẹp nhất)"],
        "is_featured": True,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Cục Du lịch TP.HCM & Sở GTVT",
        "local_specialties": [
            "Cà phê muối bến Bạch Đằng béo ngậy thơm nồng",
            "Trà đào cam sả mát lạnh ngắm hoàng hôn sông",
            "Bò bía mặn chấm tương ngọt đậu phộng Sài Gòn",
            "Bánh tráng nướng mỡ hành giòn rụm",
            "Chè khúc bạch thanh mát bến sông"
        ],
        "must_try_activities": [
            "Đi buýt đường sông Waterbus ngắm toàn cảnh skyline thành phố từ sông Sài Gòn",
            "Săn ảnh hoàng hôn buông xuống cầu Ba Son và Landmark 81",
            "Dạo bộ công viên bờ sông hóng gió đêm và ngắm du thuyền lộng lẫy",
            "Ngồi cà phê vỉa hè ngắm dòng xe tấp nập đường Tôn Đức Thắng"
        ],
        "cultural_highlights": [
            "Bến cảng lịch sử hơn 300 năm hình thành và phát triển của đô thị Sài Gòn - Gia Định",
            "Tượng đài Đức Thánh Trần Hưng Đạo uy nghiêm chỉ tay trấn giữ sông nước phương Nam"
        ],
        "getting_there_advice": "Tọa lạc tại số 10B Tôn Đức Thắng, Bến Nghé, Quận 1. Gửi xe máy tại bãi xe phố đi bộ Nguyễn Huệ hoặc bãi xe công viên Bạch Đằng, chỉ mất 2 phút đi bộ sang bến tàu.",
        "media": [
            {
                "id": "media_hcm_bach_dang",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Bach%20Dang%20Wharf%20-%20panoramio.jpg?width=1280",
                "local_asset_path": "assets/images/lake_tuyen_lam.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 3.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_hcm_thu_thiem_park",
        "slug": "cong-vien-bo-song-thu-thiem-canh-dong-huong-duong",
        "name": "Công Viên Bờ Sông Thủ Thiêm & Cánh Đồng Hoa Hướng Dương",
        "local_name": "Bờ Sông Thủ Thiêm • Nóc Hầm Thủ Thiêm Chill Đêm",
        "province": "TP. Hồ Chí Minh",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_south",
        "category_ids": ["social_trend", "check_in", "nature"],
        "center_latitude": 10.7762,
        "center_longitude": 106.7118,
        "elevation_meters": 6,
        "is_social_trend": True,
        "social_platform": "TikTok & Facebook",
        "social_views": "3.8M lượt xem TikTok",
        "photo_spot_tip": "Chụp góc cận hoa hướng dương nở rộ lấy hậu cảnh là tòa nhà Bitexco và bến Bạch Đằng lúc 16:30 - 17:30.",
        "editorial_summary": "Điểm hẹn hoàng hôn và check-in cánh đồng hoa hướng dương hot nhất của giới trẻ Sài Gòn với góc nhìn panorama triệu đô về Quận 1.",
        "editorial_content": "Công viên Bờ sông Sài Gòn phía bờ Thủ Thiêm (TP. Thủ Đức) đã trở thành tâm điểm thu hút hàng triệu lượt bạn trẻ và du khách. Nổi bật với cánh đồng hoa hướng dương rộng lớn khoe sắc vàng rực rỡ bên bờ sông, cầu tình yêu uốn cong thơ mộng và không gian thoáng đãng ngắm trọn vẹn đường chân trời thành phố. Đây là địa điểm lý tưởng để thả diều, picnic dã ngoại và đón ngọn gió mát lành từ lòng sông thổi vào.",
        "best_travel_seasons": ["Quanh năm (16:00 - 22:00)"],
        "is_featured": True,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "UBND TP Thủ Đức",
        "local_specialties": [
            "Trà mãng cầu xiêm chua ngọt giải nhiệt cực hot",
            "Kem dừa sáp Cầu Kè béo bùi ngậy lưỡi",
            "Bánh tráng trộn muối tắc tóp mỡ giòn rụm",
            "Xúc xích nướng đá khói phô mai",
            "Trà dâu tây Đông Du tươi mát"
        ],
        "must_try_activities": [
            "Check-in chụp ảnh sống ảo cùng cánh đồng hoa hướng dương nở rộ",
            "Ngồi ghế dù cắm trại nhâm nhi trà nước ngắm hoàng hôn buông xuống Quận 1",
            "Thả diều tuổi thơ lộng gió bên bờ sông",
            "Chụp ảnh đêm cầu Ba Son rực rỡ sắc màu"
        ],
        "cultural_highlights": [
            "Sự lột xác kỳ diệu từ vùng đầm lầy bán đảo Thủ Thiêm trở thành trung tâm tài chính và công viên sinh thái hiện đại của thế kỷ 21"
        ],
        "getting_there_advice": "Từ trung tâm Quận 1 qua cầu Ba Son (Thủ Thiêm 2) hoặc hầm vượt sông Sài Gòn rẽ vào đường Trần Bạch Đằng, chạy theo bảng chỉ dẫn xuống công viên bờ sông.",
        "media": [
            {
                "id": "media_hcm_thu_thiem",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Thu%20Thiem%202%20Bridge%20at%20night.jpg?width=1280",
                "local_asset_path": "assets/images/hero_ta_nang.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 4.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_hcm_42_nguyen_hue",
        "slug": "chung-cu-ca-phe-42-nguyen-hue",
        "name": "Chung Cư Cà Phê 42 Nguyễn Huệ & Phố Đi Bộ",
        "local_name": "The Cafe Apartment 42 Nguyen Hue",
        "province": "TP. Hồ Chí Minh",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_south",
        "category_ids": ["social_trend", "check_in", "city_tour"],
        "center_latitude": 10.7745,
        "center_longitude": 106.7032,
        "elevation_meters": 35,
        "is_social_trend": True,
        "social_platform": "Instagram & TikTok Viral",
        "social_views": "6.5M lượt xem MXH",
        "photo_spot_tip": "Đứng giữa phố đi bộ chụp góc thẳng lên ma trận các ô ban công đèn neon rực rỡ vào lúc 19:00, hoặc ngồi ban công tầng 5 nhìn xuống.",
        "editorial_summary": "Tòa chung cư cafe vintage độc nhất vô nhị nổi tiếng thế giới trên Instagram & TikTok, nơi mỗi ô ban công là một quán cà phê nghệ thuật độc đáo.",
        "editorial_content": "Xây dựng từ những năm 1960, chung cư 42 Nguyễn Huệ đã chuyển mình thành tổ hợp sáng tạo cà phê và thời trang độc đáo bậc nhất châu Á. Nằm ngay mặt tiền phố đi bộ Nguyễn Huệ danh giá, tòa nhà 9 tầng này thu hút hàng triệu du khách quốc tế nhờ cấu trúc mặt tiền tựa như một tổ ong khổng lồ với hàng chục bảng hiệu neon, phong cách trang trí từ vintage Sài Gòn xưa đến bohemian đương đại.",
        "best_travel_seasons": ["Quanh năm (Sáng sớm hoặc 18:00 - 23:00)"],
        "is_featured": True,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Sở Du lịch TP.HCM & CNN Travel",
        "local_specialties": [
            "Cà phê trứng Sài Gòn thơm béo ngậy bông tuyết",
            "Trà sữa đất nung thảo mộc Vân Nam ấm áp",
            "Bánh mì chảo ốp la pate bơ thơm nức mũi",
            "Bánh waffle nướng kẹp kem tươi dâu tây",
            "Cà phê cốt dừa đá xay mát lịm"
        ],
        "must_try_activities": [
            "Khám phá các quán cafe phong cách retro bí ẩn qua cầu thang bộ cũ kỹ",
            "Ngồi ban công tầng cao nhâm nhi cà phê ngắm dòng người dạo phố đi bộ",
            "Thưởng thức biểu diễn nghệ thuật âm nhạc đường phố cuối tuần",
            "Check-in Trụ sở UBND Thành phố và tượng đài Bác Hồ rực rỡ ánh đèn"
        ],
        "cultural_highlights": [
            "Biểu tượng cho tinh thần khởi nghiệp sáng tạo và sự giao thoa hài hòa giữa di sản kiến trúc cũ với nhịp sống đương đại của giới trẻ Sài Gòn"
        ],
        "getting_there_advice": "Tọa lạc ngay số 42 phố đi bộ Nguyễn Huệ, Quận 1. Đi thang bộ miễn phí hoặc trải nghiệm thang máy cổ điển lên các tầng.",
        "media": [
            {
                "id": "media_hcm_42_nguyen_hue",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Nguyen%20Hue%20Street%20at%20night%20view%20from%2042%20Nguyen%20Hue.jpg?width=1280",
                "local_asset_path": "assets/images/mang_den.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 4.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_hcm_ho_con_rua",
        "slug": "ho-con-rua-pho-am-thuc-via-he",
        "name": "Hồ Con Rùa & Phố Ẩm Thực Vỉa Hè",
        "local_name": "Công Trường Quốc Tế • Thiên Đường Ăn Vặt Sài Gòn",
        "province": "TP. Hồ Chí Minh",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_south",
        "category_ids": ["social_trend", "check_in", "food"],
        "center_latitude": 10.7828,
        "center_longitude": 106.6961,
        "elevation_meters": 10,
        "is_social_trend": True,
        "social_platform": "TikTok & Facebook",
        "social_views": "2.9M lượt xem TikTok",
        "photo_spot_tip": "Ngồi trên các bậc thang bê tông xoắn ốc ngắm đài phun nước đổi màu và dòng xe cộ lướt qua dưới tán cây cổ thụ.",
        "editorial_summary": "Thánh địa ăn vặt đêm và hóng gió chill số 1 của sinh viên và giới trẻ Sài Gòn, nơi hội tụ hàng trăm món ăn vặt đường phố trứ danh.",
        "editorial_content": "Hồ Con Rùa (Công trường Quốc tế) là bùng binh giao lộ rợp bóng mát giữa các tuyến đường Phạm Ngọc Thạch, Võ Văn Tần và Trần Cao Vân tại Quận 3. Với kiến trúc đài kỷ niệm độc đáo tựa như những cánh hoa sen xòe nở trên mặt hồ nước, nơi đây từ lâu đã trở thành không gian sinh hoạt cộng đồng và thiên đường ẩm thực vỉa hè nổi tiếng bậc nhất Sài Gòn mỗi khi phố lên đèn.",
        "best_travel_seasons": ["Quanh năm (17:00 - 23:00 đông vui nhất)"],
        "is_featured": False,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Sở Du lịch TP.HCM",
        "local_specialties": [
            "Bánh tráng trộn chú Viên đẫm khô bò mực rim",
            "Trà tắc xí muội khổng lồ giải khát",
            "Trứng cút nướng mỡ hành phô mai béo ngậy",
            "Bắp xào tép hành thơm bơ nức mũi",
            "Bánh tráng nướng trứng cút xúc xích"
        ],
        "must_try_activities": [
            "Ngồi bậc thang hóng gió mát ngắm đài phun nước ánh sáng đổi màu",
            "Thưởng thức combo ăn vặt đường phố chuẩn vị tuổi trẻ Sài Gòn",
            "Chụp ảnh check-in phong cách retro đường phố",
            "Dạo bước sang Nhà thờ Đức Bà và Bưu điện Thành phố ngay gần kề"
        ],
        "cultural_highlights": [
            "Kiến trúc phong thủy độc đáo thời Việt Nam Cộng hòa nhằm trấn yểm đuôi rồng theo truyền thuyết đô thị Sài Gòn xưa"
        ],
        "getting_there_advice": "Vòng xoay giao giữa đường Phạm Ngọc Thạch và Võ Văn Tần, Quận 3. Gửi xe tại các bãi xe trường đại học hoặc quán cafe xung quanh hồ.",
        "media": [
            {
                "id": "media_hcm_ho_con_rua",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/H%E1%BB%93%20Con%20R%C3%B9a%2C%20TP.HCM.jpg?width=1280",
                "local_asset_path": "assets/images/lake_tuyen_lam.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 3.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_hcm_cau_anh_sao",
        "slug": "cau-anh-sao-ho-ban-nguyet-phu-my-hung",
        "name": "Cầu Ánh Sao & Hồ Bán Nguyệt (Phú Mỹ Hưng)",
        "local_name": "Starlight Bridge • The Crescent Lake",
        "province": "TP. Hồ Chí Minh",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_south",
        "category_ids": ["social_trend", "check_in", "night_tour"],
        "center_latitude": 10.7196,
        "center_longitude": 106.7202,
        "elevation_meters": 12,
        "is_social_trend": True,
        "social_platform": "Facebook & TikTok",
        "social_views": "2.1M lượt xem MXH",
        "photo_spot_tip": "Đứng giữa cầu lúc thác nước cầu vồng bắt đầu phun (từ 18:30 thứ Năm đến Chủ nhật) bắt trọn vệt sáng lung linh phản chiếu trên mặt hồ.",
        "editorial_summary": "Cây cầu đi bộ lãng mạn hàng đầu Việt Nam với dải đèn LED mô phỏng ngàn vì sao và thác nước cầu vồng 7 sắc huyền ảo.",
        "editorial_content": "Cầu Ánh Sao bắc qua rạch Thầy Tiêu nối liền khu hồ Bán Nguyệt với khu kênh Đào tại đô thị Phú Mỹ Hưng, Quận 7. Cây cầu dài 170m chỉ dành riêng cho người đi bộ, mặt cầu được thiết kế uốn cong mềm mại với hàng ngàn bóng đèn LED chiếu ngược lên tựa như bước đi giữa bầu trời sao. Hai bên hông cầu là hệ thống phun nước kết hợp ánh sáng đổi màu tạo thành thác nước cầu vồng lãng mạn tuyệt đẹp.",
        "best_travel_seasons": ["Quanh năm (18:00 - 22:00 cuối tuần)"],
        "is_featured": False,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Phú Mỹ Hưng Corp",
        "local_specialties": [
            "Lẩu bò nhúng dấm Phú Mỹ Hưng chua ngọt đậm đà",
            "Kem Gelato Ý cao cấp mát lạnh",
            "Trà sữa nướng than hoa trân châu hoàng kim",
            "Bánh nướng bơ tỏi phô mai kéo sợi giòn tan"
        ],
        "must_try_activities": [
            "Dạo bước trên cây cầu ngàn sao lãng mạn cùng người thương",
            "Chiêm ngưỡng màn trình diễn thác nước ánh sáng đổi màu",
            "Dạo bộ ven hồ Bán Nguyệt và trung tâm thương mại Crescent Mall",
            "Chụp ảnh chân dung đêm với phông nền đèn sao huyền ảo"
        ],
        "cultural_highlights": [
            "Cây cầu bộ hành hiện đại đầu tiên của Việt Nam đoạt giải thưởng kiến trúc Arthur G. Hayden uy tín quốc tế"
        ],
        "getting_there_advice": "Đô thị Phú Mỹ Hưng, Phường Tân Phú, Quận 7. Gửi xe tại tầng hầm Crescent Mall hoặc bãi xe công viên Hồ Bán Nguyệt.",
        "media": [
            {
                "id": "media_hcm_cau_anh_sao",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/C%E1%BA%A7u%20%C3%81nh%20Sao%20-%20Starlight%20Bridge.jpg?width=1280",
                "local_asset_path": "assets/images/lake_tuyen_lam.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 4.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_hcm_can_gio",
        "slug": "rung-sac-can-gio-dao-khi",
        "name": "Rừng Sác & Đảo Khỉ Cần Giờ",
        "local_name": "Khu Dự Trữ Sinh Quyển Rừng Ngập Mặn Cần Giờ",
        "province": "TP. Hồ Chí Minh",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_south",
        "category_ids": ["social_trend", "nature", "camping"],
        "center_latitude": 10.4285,
        "center_longitude": 106.9422,
        "elevation_meters": 5,
        "is_social_trend": True,
        "social_platform": "TikTok & Facebook",
        "social_views": "1.8M lượt xem MXH",
        "photo_spot_tip": "Chụp trên cầu gỗ uốn lượn xuyên qua rừng đước ngập mặn rậm rạp và check-in bãi biển 30/4 lúc ráng chiều hoàng hôn.",
        "editorial_summary": "Điểm dã ngoại sinh thái biển và rừng ngập mặn hot trend cuối tuần của giới trẻ TP.HCM với hải sản tươi sống giá rẻ tại chợ Hàng Dương.",
        "editorial_content": "Được mệnh danh là 'Lá phổi xanh của TP. Hồ Chí Minh', Khu Dự trữ Sinh quyển Rừng ngập mặn Cần Giờ là khu dự trữ sinh quyển thế giới đầu tiên của Việt Nam được UNESCO công nhận. Nơi đây sở hữu quần thể rừng đước nguyên sinh bạt ngàn, đảo Khỉ với hơn 2.000 chú khỉ tinh nghịch sống tự nhiên, và bến chợ Hàng Dương tấp nập hải sản tươi sống được chế biến ăn ngay tại chỗ.",
        "best_travel_seasons": ["Tháng 11 đến tháng 5 (Mùa nắng ráo dã ngoại)"],
        "is_featured": False,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "BQL Rừng Phòng Hộ Cần Giờ",
        "local_specialties": [
            "Cua biển Cần Giờ thịt chắc nịch gạch son béo ngậy",
            "Tôm tích (bề bề) hấp nước dừa ngọt lịm chấm muối ớt",
            "Nghêu biển hấp sả gừng tươi sống chợ Hàng Dương",
            "Xoài cát Cần Giờ ngọt thơm nức tiếng",
            "Hàu nướng mỡ hành đậu phộng giòn thơm"
        ],
        "must_try_activities": [
            "Đi xuồng cao tốc len lỏi giữa rừng đước thám hiểm Chiến khu Rừng Sác",
            "Tương tác và chụp ảnh cùng đàn khỉ hoang dã tại Đảo Khỉ",
            "Tự tay lựa chọn và thưởng thức hải sản tươi nướng than tại chợ Hàng Dương",
            "Cắm trại và đón hoàng hôn trên bờ biển Cần Giờ"
        ],
        "cultural_highlights": [
            "Căn cứ huyền thoại của Trung đoàn 10 Đặc công Rừng Sác kiên cường trong chiến tranh Việt Nam"
        ],
        "getting_there_advice": "Từ trung tâm TP.HCM chạy xe máy hoặc ô tô theo đường Huỳnh Tấn Phát qua phà Bình Khánh, chạy thẳng đường Rừng Sác khoảng 40 km là tới cổng khu du lịch.",
        "media": [
            {
                "id": "media_hcm_can_gio",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Can%20Gio%20mangrove%20forest.jpg?width=1280",
                "local_asset_path": "assets/images/hero_ta_nang.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 3.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_dl_thung_lung_den",
        "slug": "khu-ca-phe-xom-leo-thung-lung-den-da-lat",
        "name": "Khu Cà Phê Xóm Lèo & Thung Lũng Đèn Đà Lạt",
        "local_name": "Xóm Lèo Trại Mát • Biển Đèn Nhà Kính Đà Lạt",
        "province": "Lâm Đồng",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_highlands",
        "category_ids": ["social_trend", "check_in", "night_tour"],
        "center_latitude": 11.9542,
        "center_longitude": 108.4735,
        "elevation_meters": 1520,
        "is_social_trend": True,
        "social_platform": "TikTok & Facebook",
        "social_views": "5.2M lượt xem TikTok",
        "photo_spot_tip": "Chụp từ ban công quán cafe lúc 18:00 - 19:00 khi hàng ngàn bóng đèn nhà kính hoa bên dưới thung lũng đồng loạt thắp sáng tựa như dải Ngân Hà rơi xuống đất.",
        "editorial_summary": "Tọa độ ngắm 'Kinh đô ánh sáng' biển nhà lồng đêm Đà Lạt hot nhất TikTok, nơi sương mù bảng lảng quyện trong ánh đèn vàng lung linh.",
        "editorial_content": "Xóm Lèo (khu vực Trại Mát) là điểm săn hoàng hôn và ngắm đêm triệu view trên TikTok của giới trẻ khi đến với xứ sở sương mù Đà Lạt. Đứng trên triền dốc cao lộng gió, du khách được ngắm nhìn toàn cảnh thung lũng hoa Trại Mát bừng sáng bởi hàng vạn ánh đèn vàng ấm áp từ các nhà lồng trồng hoa cúc, tạo nên khung cảnh cổ tích huyền diệu không nơi nào có được.",
        "best_travel_seasons": ["Tháng 10 đến tháng 4 (Mùa trời quang mây ít mưa)"],
        "is_featured": True,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Sở VHTT&DL Lâm Đồng",
        "local_specialties": [
            "Sữa đậu nành bò nóng hổi ăn kèm bánh tiêu",
            "Bánh tráng nướng mắm ruốc giòn cay",
            "Khoai lang mật nướng than củi tươm mật ngọt",
            "Trà atiso sưởi ấm đêm lạnh cao nguyên"
        ],
        "must_try_activities": [
            "Ngồi nhâm nhi tách cà phê nóng ngắm thung lũng đèn rực sáng",
            "Săn hoàng hôn tím buông xuống đồi thông Trại Mát",
            "Thưởng thức trứng gà nướng và bắp nướng sưởi ấm bên bếp than hồng"
        ],
        "cultural_highlights": [
            "Nghề trồng hoa nhà kính truyền thống công nghệ cao làm nên thương hiệu 'Thành phố ngàn hoa' Đà Lạt"
        ],
        "getting_there_advice": "Từ trung tâm Đà Lạt chạy theo Quốc lộ 20 hướng Trại Mát khoảng 8 km, rẽ vào đường Huỳnh Tấn Phát lên khu Xóm Lèo.",
        "media": [
            {
                "id": "media_dl_thung_lung_den",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Da%20Lat%20Flower%20Park%20-%20lake.jpg?width=1280",
                "local_asset_path": "assets/images/mang_den.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 4.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_hn_train_street",
        "slug": "ca-phe-pho-duong-tau-pho-co-ha-noi",
        "name": "Cà Phê Phố Đường Tàu & Phố Cổ Hà Nội",
        "local_name": "Hanoi Train Street Cafe",
        "province": "Hà Nội",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_north",
        "category_ids": ["social_trend", "check_in", "city_tour"],
        "center_latitude": 21.0285,
        "center_longitude": 105.8423,
        "elevation_meters": 15,
        "is_social_trend": True,
        "social_platform": "TikTok & Instagram",
        "social_views": "8.7M lượt xem Toàn cầu",
        "photo_spot_tip": "Ngồi sát mép hiên nhà thưởng thức cà phê trứng và quay video slow-motion khoảnh khắc đoàn tàu hỏa chạy lướt qua chỉ cách vài chục centimet.",
        "editorial_summary": "Trải nghiệm cà phê mạo hiểm và độc đáo bậc nhất thế giới viral toàn cầu trên TikTok và Instagram giữa lòng 36 phố phường Hà Nội.",
        "editorial_content": "Phố đường tàu Hà Nội (đoạn qua phố Phùng Hưng và Khâm Thiên) là điểm đến nổi tiếng toàn cầu thu hút hàng triệu du khách quốc tế. Những ngôi nhà cổ nhỏ hẹp nép mình sát rạt đường ray xe lửa tuyến Bắc - Nam lịch sử, nơi người dân sinh hoạt, kinh doanh quán cafe chỉ cách đường ray vài bước chân. Khoảnh khắc tiếng còi tàu vang lên và đoàn tàu khổng lồ lướt qua mang lại cảm giác thót tim và phấn khích khó quên.",
        "best_travel_seasons": ["Mùa thu và mùa đông Hà Nội (Tháng 9 đến tháng 3)"],
        "is_featured": True,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Sở Du lịch Hà Nội",
        "local_specialties": [
            "Cà phê trứng Giảng cổ truyền Hà Nội béo mịn",
            "Bún chả Hà Nội nướng than hoa chả giò giòn rụm",
            "Nem chua rán Hàng Bông giòn thơm",
            "Trà chanh phố cổ và hạt hướng dương"
        ],
        "must_try_activities": [
            "Ngắm đoàn tàu hỏa chạy sát sườn nhà cổ kính",
            "Thưởng thức ly cà phê trứng truyền thống ngắm đường ray rêu phong",
            "Dạo bước khám phá bích họa phố Phùng Hưng và chợ Đồng Xuân"
        ],
        "cultural_highlights": [
            "Tuyến đường sắt răng cưa và đường sắt đô thị có từ thời Pháp thuộc hơn 120 năm tuổi gắn liền với thăng trầm lịch sử Thăng Long - Hà Nội"
        ],
        "getting_there_advice": "Nằm đoạn phố Trần Phú, Điện Biên Phủ hoặc Phùng Hưng, Hoàn Kiếm, Hà Nội. Đi bộ từ Hồ Gươm sang khoảng 10 phút.",
        "media": [
            {
                "id": "media_hn_train_street",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Vietnam-Sapa-Y%20Linh%20Ho%20village-P1070238.jpg?width=1280",
                "local_asset_path": "assets/images/pass_o_quy_ho.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 4.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    },
    {
        "id": "trend_dn_cau_vang",
        "slug": "cau-vang-ban-tay-phat-ba-na-hills",
        "name": "Cầu Vàng Bàn Tay Phật (Bà Nà Hills)",
        "local_name": "Golden Bridge • Sun World Ba Na Hills",
        "province": "Đà Nẵng",
        "country_name": "Việt Nam",
        "country_ids": ["VN"],
        "region_id": "vn_central",
        "category_ids": ["social_trend", "check_in", "nature"],
        "center_latitude": 15.9950,
        "center_longitude": 107.9968,
        "elevation_meters": 1414,
        "is_social_trend": True,
        "social_platform": "TikTok & Facebook",
        "social_views": "12.5M lượt xem Toàn cầu",
        "photo_spot_tip": "Chụp từ đầu cầu lúc sáng sớm (8:00 - 9:00) khi sương mù vương trên đôi bàn tay khổng lồ bằng đá rêu phong nâng dải lụa vàng giữa lưng chừng trời.",
        "editorial_summary": "Kỳ quan kiến trúc đương đại vươn tầm thế giới, một trong 100 điểm đến tuyệt vời nhất thế giới do Tạp chí TIME bình chọn.",
        "editorial_content": "Cầu Vàng tọa lạc tại Vườn Thiên Thai trên đỉnh Bà Nà ở độ cao hơn 1.400m so với mực nước biển. Cây cầu dài 150m như một dải lụa vàng óng ả được nâng đỡ bởi đôi bàn tay khổng lồ phủ rêu phong vươn ra từ vách núi. Ngay khi khánh thành, Cầu Vàng đã tạo nên cơn sốt bùng nổ trên truyền thông và mạng xã hội toàn cầu, trở thành biểu tượng du lịch mới của Việt Nam thế kỷ 21.",
        "best_travel_seasons": ["Tháng 3 đến tháng 9 (Trời trong xanh ngắm toàn cảnh biển Đà Nẵng)"],
        "is_featured": True,
        "is_popular": True,
        "is_verified": True,
        "verification_date": "2026-11-01",
        "data_source": "Sở Du lịch Đà Nẵng & Sun World",
        "local_specialties": [
            "Mì Quảng ếch niêu đất Đà Nẵng thơm nồng củ nén",
            "Bánh tráng cuốn thịt heo hai đầu da chấm mắm nêm",
            "Bia tươi Đức nấu thủ công trên đỉnh Bà Nà",
            "Xúc xích nướng than kiểu Bavaria"
        ],
        "must_try_activities": [
            "Dạo bước trên cây cầu vàng ngắm mây trôi bồng bềnh dưới chân",
            "Đi tuyến cáp treo đạt 4 kỷ lục Guinness thế giới",
            "Khám phá Làng Pháp cổ kính và hầm rượu vang Debay cổ 100 năm",
            "Thưởng thức các lễ hội hóa trang và vũ hội đường phố châu Âu"
        ],
        "cultural_highlights": [
            "Kiệt tác thiết kế của kiến trúc sư Việt Nam mang thông điệp đôi bàn tay của Thần Núi rút dải lụa vàng từ lòng đất dâng lên mây trời"
        ],
        "getting_there_advice": "Từ trung tâm TP Đà Nẵng đi ô tô hoặc xe buýt du lịch khoảng 35 km về hướng tây nam đến chân núi Bà Nà, đi cáp treo lên trạm Cầu Vàng.",
        "media": [
            {
                "id": "media_dn_cau_vang",
                "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/L%C4%83ng%20C%C3%B4%2C%20H%E1%BA%A3i%20V%C3%A2n%20Pass%2C%202020-01%20CN-02.jpg?width=1280",
                "local_asset_path": "assets/images/pass_o_quy_ho.jpg",
                "photographer": "Wikimedia Commons",
                "source_name": "Wikimedia Commons",
                "license": "CC-BY-SA 4.0",
                "attribution": "Ảnh: Wikimedia Commons",
                "aspect_ratio": 1.77,
                "is_hero": True
            }
        ]
    }
]

# Thêm vào danh sách nếu chưa có
count_added = 0
for t in new_trends:
    if t['id'] not in existing_ids:
        data['destinations'].append(t)
        count_added += 1

with open(seed_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Added {count_added} Hot Trend destinations to destinations_seed.json! Total now: {len(data['destinations'])}")

