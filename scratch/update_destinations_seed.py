import json

# Đọc file seed hiện tại
seed_path = 'c:/Users/DELL/Downloads/AI Coding/Gemini Code/TRAVEL_APP/mobile_flutter/assets/data/destinations_seed.json'
with open(seed_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Bản đồ cập nhật chi tiết cho 23 địa điểm
updates = {
    "dest_vn_ma_pi_leng": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Ma%20Pi%20Leng%20Pass%20winding%20road%20Ha%20Giang%20Vietnam.jpg?width=1280",
        "photographer": "Khánh Hmoong",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 2.0",
        "local_specialties": [
            "Thắng cố ngựa Đồng Văn truyền thống",
            "Cháo ấu tẩu chợ phiên giữ ấm đêm đông",
            "Phở tráng kìm gà đồi vàng óng",
            "Thịt trâu gác bếp Hà Giang hun khói củi nhãn",
            "Bánh tam giác mạch nướng thơm bùi",
            "Rượu ngô men lá Quản Bạ trứ danh"
        ],
        "must_try_activities": [
            "Chinh phục đỉnh đèo Mã Pí Lèng - một trong Tứ đại đỉnh đèo hiểm trở nhất Việt Nam",
            "Đi thuyền buồm hoặc chèo SUP xuyên hẻm vực Tu Sản trên dòng sông Nho Quế xanh ngọc bích",
            "Săn bình minh và biển mây cuồn cuộn từ mỏm đá Mã Pí Lèng nhìn xuống thung lũng",
            "Trải nghiệm không khí rộn rã tại chợ phiên Mèo Vạc vào sáng Chủ nhật"
        ],
        "cultural_highlights": [
            "Con đường Hạnh Phúc được hàng vạn thanh niên xung phong đục đẽo thủ công bằng xà beng qua vách đá trong 6 năm (1959 - 1965)",
            "Văn hóa độc đáo của đồng bào dân tộc H'Mông, Lô Lô, Giáy với những mái nhà trình tường đất nện ấm áp và trang phục thổ cẩm rực rỡ"
        ],
        "getting_there_advice": "Bắt xe khách giường nằm cao cấp từ bến xe Mỹ Đình (Hà Nội) lên TP Hà Giang (khoảng 6 tiếng). Tại TP Hà Giang, thuê xe máy số hoặc côn tay phượt theo Quốc lộ 4C cung đường Hạnh Phúc qua Quản Bạ, Yên Minh, Phố Cáo, Đồng Văn để đến đỉnh đèo.",
        "editorial_content": "Đèo Mã Pí Lèng dài khoảng 20 km uốn lượn ngoạn mục qua địa hình hiểm trở bậc nhất Công viên Địa chất Toàn cầu UNESCO Cao nguyên đá Đồng Văn. Dưới chân đèo là hẻm vực Tu Sản - hẻm núi kiến tạo sâu nhất Đông Nam Á với độ sâu gần 800m, nơi dòng sông Nho Quế màu xanh ngọc bích chảy lững lờ ngăn đôi hai dãy núi đá vôi sừng sững. Đây là cung đường biểu tượng cho ý chí quật cường của con người trước sự hùng vĩ khôn cùng của thiên nhiên miền biên viễn."
    },
    "dest_vn_o_quy_ho": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/O%20Quy%20Ho%20pass.jpg?width=1280",
        "photographer": "Kiếm Anh",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Cá hồi và cá tầm tươi nuôi Thác Bạc nướng than",
            "Lợn cắp nách Sa Pa nướng giòn bì",
            "Gà đen H'Mông hầm sâm dây và thảo quả rừng",
            "Rau ngọn su su & cải mèo xào tỏi đắng hậu ngọt",
            "Rượu táo mèo thơm nồng men rừng Tây Bắc"
        ],
        "must_try_activities": [
            "Đón hoàng hôn nhuộm vàng biển mây tại Cổng Trời Ô Quy Hồ trên độ cao 2.035m",
            "Chiêm ngưỡng Thác Bạc và Thác Tình Yêu đổ bọt trắng xóa giữa đại ngàn Hoàng Liên",
            "Chinh phục 'Nóc nhà Đông Dương' đỉnh Fansipan 3.143m huyền thoại",
            "Dừng chân quán nhỏ đỉnh đèo thưởng thức bắp nướng, trứng nướng và trà gừng sưởi ấm"
        ],
        "cultural_highlights": [
            "Tên đèo bắt nguồn từ tiếng hót ai oán của loài chim rừng gắn liền với thiên tình sử bi thương giữa nàng tiên thứ bảy và chàng tiều phu Ô Quy Hồ",
            "Ranh giới chia đôi hai tiểu vùng khí hậu đặc trưng: bên Lào Cai thường mù sương lạnh buốt, bên Lai Châu lại ngập tràn ánh nắng ấm áp"
        ],
        "getting_there_advice": "Từ Hà Nội di chuyển bằng tàu hỏa du lịch hoặc xe khách cao tốc Nội Bài - Lào Cai lên thị xã Sa Pa (khoảng 5 tiếng). Từ trung tâm Sa Pa, chạy xe máy hoặc taxi theo Quốc lộ 4D hướng đi Lai Châu khoảng 15 km là tới đỉnh đèo Ô Quy Hồ.",
        "editorial_content": "Vắt ngang dãy Hoàng Liên Sơn hùng vĩ ở độ cao trên 2.000m, Đèo Ô Quy Hồ được mệnh danh là 'Vua đèo miền Bắc' với chiều dài gần 50 km nối liền hai tỉnh Lào Cai và Lai Châu. Đỉnh đèo là một trong những điểm săn mây và hoàng hôn ngoạn mục nhất châu Á, nơi du khách được đắm chìm trong biển mây cuồn cuộn vờn quanh các ngọn núi tuyết phủ mùa đông và sắc đỏ hoa đỗ quyên rực rỡ mỗi độ xuân về."
    },
    "dest_vn_ban_gioc": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Ban%20Gioc%20Waterfall%20-%20Trung%20Kanh%20District%20-%20Cao%20Bang%20Province%20-%20Vietnam%20-%2005%20%2848119871617%29.jpg?width=1280",
        "photographer": "Adam Jones",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 2.0",
        "local_specialties": [
            "Bánh cuốn nước xương Cao Bằng ngọt béo đậm đà",
            "Vịt quay 7 vị Trùng Khánh thơm giòn mùi mật ong lá mắc mật",
            "Hạt dẻ Trùng Khánh rang bơ bùi béo trứ danh",
            "Phở chua Cao Bằng chua thanh độc đáo",
            "Miến dong Phia Đén đen tuyền dai giòn tự nhiên"
        ],
        "must_try_activities": [
            "Đi bè tre trên dòng sông Quây Sơn tiếp cận sát chân thác tung bọt trắng xóa mát lạnh",
            "Khám phá Động Ngườm Ngao - mê cung thạch nhũ hàng triệu năm lung linh kỳ ảo",
            "Cắm trại và picnic ven bãi cỏ phẳng bên dòng sông Quây Sơn xanh màu ngọc bích",
            "Check-in cột mốc biên giới 835 và viếng chùa Phật Tích Trúc Lâm Bản Giốc"
        ],
        "cultural_highlights": [
            "Văn hóa nhà sàn đá kiên cố hàng trăm năm của người Tày cổ bản Giốc",
            "Những giai điệu hát Then ngọt ngào hòa quyện cùng tiếng đàn Tính mộc mạc ru hồn du khách"
        ],
        "getting_there_advice": "Từ Hà Nội bắt xe khách đêm lên bến xe Cao Bằng (khoảng 280 km, 6 tiếng). Từ TP Cao Bằng bắt xe buýt tuyến hoặc thuê xe máy phượt theo đường tỉnh 206 qua đèo Mã Phục và đèo Liêu khoảng 85 km là đến Thác Bản Giốc.",
        "editorial_content": "Thác Bản Giốc là thác nước tự nhiên lớn thứ 4 thế giới nằm trên đường biên giới quốc gia, đồng thời là kiệt tác cảnh quan nổi bật của Công viên Địa chất Toàn cầu UNESCO Non Nước Cao Bằng. Dòng thác cuồn cuộn chia làm 3 tầng bậc thang đổ từ độ cao trên 30m xuống lòng sông Quây Sơn phẳng lặng, tạo nên bức tranh thủy mặc hữu tình giữa núi non điệp trùng biên cương Tổ quốc."
    },
    "dest_vn_ha_long_bay": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Ha%20Long%20Bay%2C%20Vietnam%2C%20Islands.jpg?width=1280",
        "photographer": "Vyacheslav Argenberg",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Chả mực giã tay Hạ Long thơm ngọt giòn sần sật",
            "Sá sùng Quan Lạn xào tỏi hoặc nấu nước dùng phở thơm lừng",
            "Bún bề bề Cột 5 đậm đà vị ngọt hải sản tươi sống",
            "Sam biển 7 món (chả sam, gỏi sam, sam xào chua ngọt)",
            "Bánh gật gù Tiên Yên chấm nước mắm mỡ gà ớt hành"
        ],
        "must_try_activities": [
            "Chèo thuyền Kayak luồn qua các vòm hang karst tự nhiên như Hang Luồn, Hang Sáng Tối",
            "Trải nghiệm du thuyền ngủ đêm ngắm hoàng hôn và bình minh giữa vịnh di sản",
            "Leo lên đài quan sát đảo Ti Tốp ngắm toàn cảnh 360 độ vịnh đảo kỳ vĩ",
            "Tham quan hệ thống hang động thạch nhũ lộng lẫy: Hang Sửng Sốt, Động Thiên Cung"
        ],
        "cultural_highlights": [
            "Truyền thuyết đàn Rồng Mẹ và Rồng Con giáng trần phun ngọc tạo thành nghìn đảo đá chặn thuyền giặc xâm lăng",
            "Nếp sống bình dị của ngư dân các làng chài cổ trên biển như Cửa Vạn, Vung Viêng lưu giữ bản sắc văn hóa biển đảo qua nhiều thế hệ"
        ],
        "getting_there_advice": "Từ Hà Nội di chuyển bằng xe limousine hoặc ô tô cá nhân theo cao tốc Hà Nội - Hải Phòng - Hạ Long chỉ mất khoảng 2 giờ (150 km). Xuống bến Cảng Tàu Khách Quốc tế Tuần Châu hoặc Hạ Long để làm thủ tục lên tàu/du thuyền ra vịnh.",
        "editorial_content": "Vịnh Hạ Long hai lần được UNESCO vinh danh là Di sản Thiên nhiên Thế giới về giá trị thẩm mỹ và địa chất địa mạo. Với gần 2.000 hòn đảo đá vôi nhô lên từ mặt nước biển xanh màu ngọc lục bảo qua hàng triệu năm kiến tạo carxtơ nhiệt đới, Hạ Long là kỳ quan thiên nhiên vô song, điểm đến dã ngoại và du thuyền hàng đầu thế giới."
    },
    "dest_vn_lao_than": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/M%C6%B0%E1%BB%9Dng%20Hoa%20Valley%2004.jpg?width=1280",
        "photographer": "Wikimedia Commons",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Lạp xưởng hun khói bã mía Y Tý đậm đà hương vị núi rừng",
            "Nấm hương rừng khô Mường Hum thơm nức",
            "Rượu Sim San men lá thảo mộc người Dao đỏ",
            "Rau ngọn cải mèo luộc chấm trứng gà luộc dầm xì dầu",
            "Thịt lợn cắp nách đen nướng mắc khén than hồng"
        ],
        "must_try_activities": [
            "Trekking chinh phục đỉnh Lảo Thẩn 2.860m - 'Nóc nhà Y Tý' địa đầu biên cương",
            "Cắm trại đêm lộng gió ngắm biển sao Ngân Hà (Milky Way) lung linh trên cao nguyên đá",
            "Săn bình minh và sóng mây tràn ngập biển mây thung lũng Dền Sáng",
            "Check-in mỏm đá 'sống ảo' hình mũi thuyền vươn mình giữa không trung"
        ],
        "cultural_highlights": [
            "Những ngôi nhà 'nấm đất' trình tường truyền thống độc đáo của người Hà Nhì đen có tường dày gần nửa mét ấm về mùa đông mát về mùa hè",
            "Lễ hội Khô Già Già cầu mùa - di sản văn hóa phi vật thể quốc gia của đồng bào Hà Nhì"
        ],
        "getting_there_advice": "Đi tàu hỏa hoặc xe khách lên TP Lào Cai hoặc Sa Pa, sau đó thuê xe máy phượt theo cung Bát Xát - Bản Vược - Mường Hum - Dền Sáng - Y Tý (khoảng 80 km). Tại bản Phìn Hồ, gặp porter bản địa dẫn đường lên lán nghỉ chân và đỉnh núi.",
        "editorial_content": "Đỉnh Lảo Thẩn (2.860m) sừng sững như một kim tự tháp tự nhiên giữa mây trời xã Y Tý, huyện Bát Xát, tỉnh Lào Cai. Nơi đây được giới xê dịch mệnh danh là 'thiên đường săn mây số một Tây Bắc' nhờ địa hình thoai thoải dễ trekking, không gian khoáng đạt và biển mây trắng muốt bồng bềnh phủ kín chân trời từ tháng 10 đến tháng 4 năm sau."
    },
    "dest_vn_phong_nha": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Phong%20Nha-Ke%20Bang%20cave3.jpg?width=1280",
        "photographer": "Tycho",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Cháo canh cá lóc Quảng Bình sợi bánh mềm ngọt nước hầm xương",
            "Cá trắm sông Son nướng chấm muối cheo thảo mộc đặc sản",
            "Gà đồi Phong Nha nướng than hồng ăn kèm xôi nếp nương",
            "Ram đẻn biển thơm giòn béo ngậy",
            "Mực một nắng Nhật Lệ nướng muối ớt cay nồng"
        ],
        "must_try_activities": [
            "Thám hiểm Động Thiên Đường - 'Hoàng cung trong lòng đất' với thạch nhũ dài ngoạn mục",
            "Chèo thuyền kayak và tắm bùn khoáng tự nhiên trong lòng Hang Tối",
            "Đi thuyền máy dọc sông Son chiêm ngưỡng cửa hang Phong Nha kỳ vĩ",
            "Trekking xuyên rừng nhiệt đới Vườn Quốc Gia khám phá hệ sinh thái động thực vật quý hiếm"
        ],
        "cultural_highlights": [
            "Khu karst cổ nhất châu Á hình thành từ hơn 400 triệu năm trước, chứa đựng các hang động lớn nhất hành tinh như Sơn Đoòng và hang Én",
            "Cái nôi sinh sống của các tộc người Rục, Arem sống hòa hợp ngàn đời giữa vách đá Trường Sơn"
        ],
        "getting_there_advice": "Bay thẳng tới sân bay Đồng Hới hoặc đi tàu hỏa đến ga Đồng Hới (Quảng Bình). Từ trung tâm thành phố Đồng Hới bắt xe buýt B4 hoặc taxi chạy thẳng 45 km theo đường Hồ Chí Minh nhánh Đông vào thị trấn Phong Nha.",
        "editorial_content": "Vườn Quốc gia Phong Nha - Kẻ Bàng được UNESCO hai lần công nhận là Di sản Thiên nhiên Thế giới nhờ giá trị địa chất địa mạo và đa dạng sinh học vượt trội. Sở hữu hơn 300 hang động lớn nhỏ cùng dòng sông ngầm dài nhất thế giới, Phong Nha là 'vương quốc hang động' huyền bí của thế giới, thu hút hàng triệu nhà thám hiểm và du khách dã ngoại toàn cầu."
    },
    "dest_vn_trang_an": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Trang%20An%20Landscape%2C%20Ninh%20Binh%20Province%2C%2020240202%201410%205232.jpg?width=1280",
        "photographer": "Jakub Hałun",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Thịt dê núi Ninh Bình tái chanh cuốn lá sung chấm tương bần",
            "Cơm cháy chà bông vàng ươm giòn tan rưới nước sốt tim cật dê",
            "Ốc núi đá Tam Điệp hấp sả gừng giòn sần sật",
            "Xôi trứng kiến Nho Quan béo bùi lạ miệng",
            "Rượu cần Nho Quan ủ chum đất men lá rừng"
        ],
        "must_try_activities": [
            "Ngồi thuyền nan mộc mạc len lỏi qua 9 hang động xuyên thủy kỳ ảo (Hang Sáng, Hang Tối, Hang Nấu Rượu)",
            "Chinh phục gần 500 bậc đá đỉnh Hang Múa ngắm toàn cảnh non nước Tam Cốc",
            "Thăm Đền Trần và Hành Cung Vũ Lâm cổ kính giữa thung lũng nước",
            "Đạp xe thư thái ngắm đồng lúa chín vàng nép bên chân núi đá vôi Hoa Lư"
        ],
        "cultural_highlights": [
            "Di sản Kép (Văn hóa và Thiên nhiên) đầu tiên và duy nhất tại Đông Nam Á được UNESCO vinh danh",
            "Dấu ấn lịch sử kinh đô Hoa Lư của ba triều đại Đinh - Tiền Lê - Lý và nơi đóng quân bí mật của nhà Trần trong kháng chiến chống quân Nguyên Mông"
        ],
        "getting_there_advice": "Từ Hà Nội di chuyển bằng xe limousine đón tận nơi hoặc tàu hỏa theo Quốc lộ 1A / Cao tốc Cầu Giẽ - Ninh Bình khoảng 95 km (chỉ mất 1.5 giờ). Đến TP Ninh Bình, chỉ cần 7 km taxi hoặc xe máy là tới bến thuyền Tràng An.",
        "editorial_content": "Quần thể danh thắng Tràng An được ví như 'Vịnh Hạ Long trên cạn' với hệ sinh thái đất ngập nước và cảnh quan tháp carxtơ nhiệt đới ngoạn mục. Dòng sông Sào Khê uốn lượn hiền hòa đưa du khách qua những hang động xuyên thủy kỳ ảo, nơi giao hòa tuyệt mỹ giữa vẻ đẹp tự nhiên và những di tích lịch sử linh thiêng của dân tộc."
    },
    "dest_vn_hai_van": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/L%C4%83ng%20C%C3%B4%2C%20H%E1%BA%A3i%20V%C3%A2n%20Pass%2C%202020-01%20CN-01.jpg?width=1280",
        "photographer": "Steffen Schmitz",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Bánh tráng cuốn thịt heo hai đầu da chấm mắm nêm Đà Nẵng",
            "Hải sản tươi sống đầm Lập An Lăng Cô (hàu nướng, sò huyết, mực ống)",
            "Gỏi cá mai và gỏi cá trích Nam Ô trứ danh",
            "Mì Quảng ếch Túy Loan nấu niêu đất đậm đà",
            "Nem tré Bà Đệ giòn chua cay nồng hạt tiêu sọ"
        ],
        "must_try_activities": [
            "Tham quan Hải Vân Quan - Di tích lịch sử quốc gia được vua Minh Mạng phong 'Thiên hạ đệ nhất hùng quan'",
            "Chạy xe máy phượt qua những khúc cua tay áo ngoạn mục ngắm cảnh một bên là vách núi một bên là biển Đông",
            "Ngắm đoàn tàu hỏa Bắc - Nam uốn lượn ven sườn đèo sát mép sóng",
            "Đón bình minh rực rỡ và thưởng thức cà phê sớm tại Mỏm Đá Cụ Rùa"
        ],
        "cultural_highlights": [
            "Cửa ngõ quân sự hiểm yếu ngàn đời trấn giữ con đường thiên lý Bắc - Nam của các triều đại phong kiến Việt Nam",
            "Ranh giới phân chia khí hậu rõ rệt: rặng Bạch Mã ngăn luồng gió mùa đông bắc tạo nên sự khác biệt thời tiết giữa xứ Huế và đất Quảng Nam Đà Nẵng"
        ],
        "getting_there_advice": "Từ sân bay hoặc trung tâm TP Đà Nẵng, thuê xe máy đi dọc theo đại lộ biển Nguyễn Tất Thành khoảng 25 km là lên tới chân đèo. Từ Huế, chạy ô tô hoặc xe máy theo QL1A qua thị trấn Lăng Cô rồi leo đèo khoảng 30 km.",
        "editorial_content": "Đèo Hải Vân dài khoảng 21 km uốn lượn vắt qua dãy núi Bạch Mã đâm ngang ra biển. Đứng trên đỉnh đèo lộng gió ở độ cao gần 500m nhìn xuống, du khách có thể thu trọn vào tầm mắt vịnh Lăng Cô xanh biếc bình yên ở phía bắc và thành phố biển Đà Nẵng hiện đại, năng động trải dài về phía nam."
    },
    "dest_vn_ta_nang_phan_dung": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Camping%20in%20grass%20hill%20in%20Ta%20Nang%20-%20Phan%20Dung%20trekking%20trail.jpg?width=1280",
        "photographer": "VinhNguyen.1257",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Cơm lam nướng ống tre kẹp thịt gà nướng than củi",
            "Măng le rừng luộc chấm kho quẹt cay nồng",
            "Rau bép rừng nấu canh cá suối mát lành",
            "Rượu cần truyền thống đồng bào Chu Ru",
            "Bánh tráng nướng mắm ruốc Phan Dũng giòn rụm"
        ],
        "must_try_activities": [
            "Trekking băng qua sống lưng khủng long trập trùng nối liền cao nguyên xuống đồng bằng duyên hải",
            "Cắm trại đêm trên đồi thông lộng gió ngắm biển sao băng và dải Ngân Hà rực sáng",
            "Đón bình minh rạng rỡ nhuộm sắc vàng cam trên những triền đồi cỏ bạt ngàn",
            "Tắm thác Yavly hoang sơ xua tan mệt mỏi chặng đường dài"
        ],
        "cultural_highlights": [
            "Giao thoa văn hóa đặc sắc giữa người Chu Ru sống trên thảo nguyên Lâm Đồng và người Rắc Lây, Chăm ở vùng duyên hải Bình Thuận",
            "Truyền thuyết về những cung đường di cư và săn bắn cổ xưa của đồng bào các dân tộc thiểu số"
        ],
        "getting_there_advice": "Từ TP.HCM bắt xe khách giường nằm đi Đà Lạt, xuống tại ngã ba Tà Hine (huyện Đức Trọng, Lâm Đồng). Từ đây đi xe ôm hoặc xe trung chuyển vào xã Đa Quyn để bắt đầu hành trình trekking bộ hành 35 km xuyên rừng sang xã Phan Dũng (huyện Tuy Phong, Bình Thuận).",
        "editorial_content": "Tà Năng - Phan Dũng được công nhận là một trong những cung trekking đẹp và thử thách bậc nhất miền Nam Việt Nam. Cung đường dài hơn 35 km băng qua ba tỉnh Lâm Đồng, Ninh Thuận và Bình Thuận, đưa người lữ hành từ những đồi thông đại ngàn và thảo nguyên cỏ xanh mướt mát ở độ cao 1.100m dần chuyển tiếp sang vùng rừng khộp rụng lá khô cằn đầy ngoạn mục."
    },
    "dest_vn_langbiang": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Lang%20Biang%20mountain%20in%20Da%20Lat%20Vietnam%20-%20panoramio.jpg?width=1280",
        "photographer": "Wikimedia Commons",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Lẩu gà lá é Tao Ngộ cay nồng thơm lừng",
            "Lẩu bò quán gỗ Ba Toa thịt bò mềm ngọt nước xương",
            "Bánh tráng nướng 'pizza Đà Lạt' giòn thơm mỡ hành",
            "Dâu tây tươi hái trực tiếp tại vườn công nghệ cao",
            "Hồng treo gió mềm ngọt ủ theo công nghệ Nhật Bản"
        ],
        "must_try_activities": [
            "Trekking xuyên rừng thông nguyên sinh chinh phục đỉnh Bà cao 2.167m",
            "Trải nghiệm đi xe Jeep chuyên dụng vượt dốc ngoạn mục lên đỉnh Ra-đa",
            "Cắm trại săn mây sớm và ngắm đồi cỏ hồng lãng mạn bên hồ Suối Vàng",
            "Hòa mình vào đêm hội giao lưu Cồng Chiêng Tây Nguyên quanh bếp lửa bập bùng"
        ],
        "cultural_highlights": [
            "Thiên tình sử đẫm lệ giữa chàng K'Lang (tộc Lạch) và nàng H'Biang (tộc Chil) minh chứng cho tình yêu bất diệt vượt qua mọi hủ tục dòng tộc",
            "Không gian văn hóa Cồng chiêng Tây Nguyên được UNESCO công nhận là Kiệt tác truyền khẩu và Di sản phi vật thể của nhân loại"
        ],
        "getting_there_advice": "Từ TP.HCM hoặc Hà Nội bay thẳng đến sân bay Liên Khương (Lâm Đồng) hoặc đi xe khách giường nằm lên Đà Lạt. Từ trung tâm Đà Lạt đi xe máy hoặc taxi về hướng bắc theo đường Phan Đình Phùng - Xô Viết Nghệ Tĩnh khoảng 12 km là đến chân núi Langbiang.",
        "editorial_content": "Được ví như 'Nóc nhà của xứ ngàn hoa Đà Lạt', đỉnh núi Langbiang sừng sững cao 2.167m thuộc Khu Dự trữ Sinh quyển Thế giới Langbiang được UNESCO công nhận. Từ trên đỉnh núi, du khách được chiêm ngưỡng bức tranh sơn thủy hữu tình thu trọn toàn cảnh thành phố sương mù, dòng Suối Vàng thơ mộng và những cánh rừng thông ba lá bạt ngàn."
    },
    "dest_vn_cat_tien": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Cat%20Tien%20National%20Park%2C%20Vietnam.jpg?width=1280",
        "photographer": "Vyacheslav Argenberg",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Cá lăng sông Đồng Nai om măng chua cay dịu",
            "Canh chua cá linh nấu bông điên điển thanh mát",
            "Rau rừng Cát Tiên luộc chấm kho quẹt tóp mỡ giòn",
            "Chuối hột rừng ngâm mật ong rừng tự nhiên",
            "Ốc bươu nướng tiêu xanh thơm nức mũi"
        ],
        "must_try_activities": [
            "Đạp xe dưới bóng mát rừng già chiêm ngưỡng cây Tung đại thụ hơn 500 năm tuổi",
            "Đi xe mui trần ngắm thú rừng hoang dã kiếm ăn ban đêm (nai, hoẵng, lợn rừng, chồn hương)",
            "Chèo xuồng kayak thám hiểm Bàu Sấu ngắm cá sấu xiêm tự nhiên trong khu Ramsar quốc tế",
            "Quan sát các loài chim quý hiếm và đàn voọc chà vá chân đen đu cành lúc bình minh"
        ],
        "cultural_highlights": [
            "Khu Di tích khảo cổ Cát Tiên thuộc vương quốc cổ Phù Nam thế kỷ IV - VIII với các đền tháp và tượng thần Linga - Yoni bằng đá nguyên khối",
            "Nếp sống gắn liền với rừng xanh của đồng bào dân tộc Mạ và S'tiêng bản địa"
        ],
        "getting_there_advice": "Từ TP.HCM đi ô tô hoặc xe khách theo Quốc lộ 20 hướng đi Đà Lạt khoảng 130 km đến ngã ba Tân Phú (Đồng Nai), rẽ trái chạy tiếp 24 km theo đường tỉnh 600 là đến cổng Vườn Quốc Gia Cát Tiên. Đi phà qua sông Đồng Nai vào trung tâm vườn.",
        "editorial_content": "Vườn Quốc gia Cát Tiên là Khu Dự trữ Sinh quyển Thế giới và Khu Ramsar Đất ngập nước Quốc tế quan trọng bậc nhất miền Nam Việt Nam. Nơi đây bảo tồn hệ sinh thái rừng mưa nhiệt đới gió mùa đa dạng sinh học bậc nhất Đông Dương với hàng trăm loài gỗ quý, thú lớn, chim muông và loài cá sấu nước ngọt quý hiếm sinh sống tự nhiên tại đầm Bàu Sấu."
    },
    "dest_vn_ba_den": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Ba%20Den%20Mountain%20summit%20temple%20illuminated%20night%20fog%20Tay%20Ninh%20Vietnam.jpg?width=1280",
        "photographer": "Vivu Vietnam",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Bò tơ Tây Ninh nướng tảng than hồng mềm ngọt thơm mùi sữa",
            "Bánh tráng phơi sương Trảng Bàng cuốn thịt luộc rau rừng chấm mắm nêm",
            "Bánh canh Trảng Bàng giò heo nước lèo ngọt trong thanh tú",
            "Muối tôm Tây Ninh rang tỏi ớt chính gốc thơm nồng",
            "Thằn lằn núi và ốc xu núi Bà xào dừa giòn béo"
        ],
        "must_try_activities": [
            "Chiêm bái Tượng Phật Bà Tây Bổ Đà Sơn bằng đồng nguyên chất cao nhất châu Á trên đỉnh núi",
            "Săn biển mây cuồn cuộn và cắm trại đêm ngắm toàn cảnh ánh đèn rực rỡ của TP Tây Ninh từ độ cao 986m",
            "Trekking chinh phục đỉnh núi qua cung đường Chùa hoặc cung Cột Điện đầy thử thách",
            "Thưởng ngoạn biển hoa rực rỡ sắc màu và công viên Phật giáo tâm linh trên đỉnh núi"
        ],
        "cultural_highlights": [
            "Huyền tích về nàng Lý Thị Thiên Hương (Linh Sơn Thánh Mẫu) tiết liệt linh thiêng che chở cho muôn dân",
            "Quần thể chùa Bà Đen với chùa Linh Sơn Tiên Thạch hơn 300 năm tuổi là trung tâm hành hương Phật giáo lớn nhất phương Nam"
        ],
        "getting_there_advice": "Từ TP.HCM di chuyển bằng ô tô hoặc xe máy theo Quốc lộ 22 qua Củ Chi, Trảng Bàng đến TP Tây Ninh khoảng 95 km (mất chừng 2 đến 2.5 giờ). Tại chân núi có hệ thống cáp treo hiện đại đưa du khách lên Chùa Bà hoặc thẳng lên đỉnh núi.",
        "editorial_content": "Núi Bà Đen cao 986m được mệnh danh là 'Nóc nhà Đông Nam Bộ', ngọn núi lửa cổ đã tắt sừng sững giữa đồng bằng bạt ngàn Tây Ninh. Không chỉ là điểm đến tâm linh linh thiêng bậc nhất phương Nam với quần thể Chùa Bà và Tượng Phật Bà kỷ lục, đỉnh núi còn là tọa độ trekking, săn mây và dã ngoại hấp dẫn hàng đầu cho giới trẻ miền Nam."
    },
    "dest_vn_con_dao": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Beach%20view%20from%20Six%20Senses%20Resort%20in%20C%C3%B4n%20%C4%90%E1%BA%A3o%20%28April%202022%29.jpg?width=1280",
        "photographer": "Wikimedia Commons",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Ốc vú nàng nướng mỡ hành giòn ngọt đậm đà",
            "Cua mặt trăng hấp sả hoặc rang me thơm ngậy",
            "Tôm hùm đỏ Côn Đảo tươi sống hấp bia",
            "Cá thu một nắng chiên sốt cà chua",
            "Mứt hạt bàng rang muối đường giòn bùi đặc sản đảo"
        ],
        "must_try_activities": [
            "Lặn biển ngắm các rạn san hô nguyên sinh sặc sỡ tại Hòn Cau, Hòn Tài",
            "Tham gia hoạt động thả rùa con về biển lúc rạng đông tại đảo Hòn Bảy Cạnh",
            "Tắm biển tại Bãi Đầm Trầu với bãi cát vàng mịn và làn nước trong vắt màu ngọc lam",
            "Viếng nghĩa trang Hàng Dương và dâng hương mộ nữ anh hùng Võ Thị Sáu vào ban đêm"
        ],
        "cultural_highlights": [
            "Di tích lịch sử Quốc gia đặc biệt Nhà tù Côn Đảo - 'địa ngục trần gian' suốt 113 năm minh chứng cho lòng yêu nước và ý chí bất khuất của các chiến sĩ cách mạng",
            "Khu bảo tồn biển Côn Đảo lưu giữ quần thể rùa biển (vích) lên đẻ trứng tự nhiên lớn nhất Việt Nam"
        ],
        "getting_there_advice": "Bay thẳng từ TP.HCM, Hà Nội hoặc Cần Thơ ra Cảng Hàng không Côn Đảo (chỉ từ 45 phút đến 2 giờ bay). Hoặc đi tàu cao tốc xuất phát từ cảng Cầu Đá (Vũng Tàu) hay cảng Trần Đề (Sóc Trăng) vượt biển khoảng 2 đến 4 giờ.",
        "editorial_content": "Quần đảo Côn Đảo gồm 16 hòn đảo lớn nhỏ nằm biệt lập ngoài khơi biển Bà Rịa - Vũng Tàu. Nổi tiếng với những bãi biển hoang sơ tuyệt mỹ, làn nước trong vắt nhìn thấu đáy và những rặng san hô cổ thụ, Côn Đảo vừa là thiên đường nghỉ dưỡng sinh thái biển đảo đẳng cấp, vừa là vùng đất thiêng liêng ghi dấu trang sử vàng hào hùng của dân tộc."
    },
    "dest_vn_phu_quoc": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Bai%20Sao%20Beach.jpg?width=1280",
        "photographer": "Prince Roy",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 2.0",
        "local_specialties": [
            "Gỏi cá trích Phú Quốc cuốn bánh tráng rau rừng chấm nước mắm nhĩ",
            "Bún quậy Kiến Xây chả tôm chả cá tươi tự quậy nước chấm",
            "Nhum biển (nhím biển) nướng mỡ hành và trứng gà thơm phức",
            "Ghẹ Hàm Ninh hấp chấm muối tiêu chanh ngọt chắc thịt",
            "Nước mắm truyền thống Phú Quốc cốt cá cơm than 40-43 độ đạm"
        ],
        "must_try_activities": [
            "Tắm biển và chụp ảnh tại Bãi Sao với bờ cát trắng mịn như kem và hàng dừa nghiêng bóng",
            "Lặn biển ngắm san hô và câu cá giải trí tại Quần đảo An Thới phía nam đảo",
            "Đi cáp treo Hòn Thơm vượt biển dài nhất thế giới ngắm toàn cảnh biển ngọc từ trên cao",
            "Khám phá khu rừng nguyên sinh thuộc Vườn Quốc Gia Phú Quốc và suối Tranh thơ mộng"
        ],
        "cultural_highlights": [
            "Làng nghề nước mắm Phú Quốc truyền thống hơn 200 năm tuổi với hàng trăm thùng gỗ bời lời khổng lồ",
            "Văn hóa nghề trồng tiêu cay nồng nổi tiếng và các làng chài lâu đời ven biển như Rạch Vẹm, Hàm Ninh"
        ],
        "getting_there_advice": "Có hàng chục chuyến bay thẳng mỗi ngày từ Hà Nội, TP.HCM, Hải Phòng, Đà Nẵng đáp xuống Sân bay Quốc tế Phú Quốc. Ngoài ra du khách có thể đi tàu cao tốc vượt biển từ bến phà Rạch Giá hoặc Hà Tiên ra đảo Phú Quốc (mất khoảng 1 đến 2.5 giờ).",
        "editorial_content": "Đảo Ngọc Phú Quốc là hòn đảo lớn nhất Việt Nam nằm trong vịnh Thái Lan, sở hữu khí hậu nhiệt đới quanh năm ấm áp và những bãi biển cát trắng nước trong thuộc hàng đẹp nhất thế giới. Với hạ tầng du lịch dã ngoại và nghỉ dưỡng phát triển toàn diện cùng vườn quốc gia nguyên sơ trù phú, Phú Quốc là điểm dừng chân hoàn hảo cho mọi tín đồ yêu thiên nhiên."
    },
    "intl_mount_fuji": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Lake%20Kawaguchiko%20Sakura%20Mount%20Fuji%204.JPG?width=1280",
        "photographer": "Midori",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Mì Hoto sợi dẹt hầm bí đỏ và rau củ thịt miso nóng hổi",
            "Thịt bò Koshu nướng phiến đá nham thạch núi lửa Phú Sĩ",
            "Bánh mì và bánh ngọt nướng bằng nước khoáng băng tan núi tuyết",
            "Rượu Sake ủ bằng dòng nước ngầm tinh khiết từ lòng núi Phú Sĩ",
            "Bánh phô mai nướng Fujisan hình ngọn núi Phú Sĩ"
        ],
        "must_try_activities": [
            "Trekking theo cung đường Yoshida leo lên đỉnh núi lửa 3.776m đón bình minh Goraiko thiêng liêng",
            "Chèo thuyền kayak hoặc đạp xe vòng quanh hồ Kawaguchiko ngắm núi Phú Sĩ soi bóng mặt hồ",
            "Thư giãn ngâm suối nước nóng Onsen truyền thống nhìn thẳng ra ngọn núi tuyết phủ",
            "Ghé thăm làng cổ Oshino Hakkai với 8 hồ nước trong vắt từ băng tan triệu năm"
        ],
        "cultural_highlights": [
            "Ngọn núi linh thiêng bậc nhất trong tín ngưỡng Thần đạo (Shinto) Nhật Bản và biểu tượng nghệ thuật bất hủ của xứ sở mặt trời mọc",
            "Di sản Văn hóa Thế giới UNESCO nhờ nguồn cảm hứng vô tận cho thơ ca, hội họa và triết lý sống của người Nhật"
        ],
        "getting_there_advice": "Từ thủ đô Tokyo, đón tàu tốc hành Chuo Line JR hoặc xe buýt cao tốc từ ga Shinjuku đến ga Kawaguchiko (khoảng 1 tiếng 45 phút). Từ đây có xe buýt tuyến đưa thẳng lên Trạm số 5 (Subaru Line 5th Station) để bắt đầu leo núi.",
        "editorial_content": "Núi Phú Sĩ (Fuji-san) cao 3.776m là đỉnh núi cao nhất Nhật Bản và là ngọn núi lửa tầng dạng nón đối xứng hoàn hảo kỳ quan của thế giới. Được bao bọc bởi vùng Ngũ Hồ thơ mộng, vẻ đẹp tuyết trắng của Phú Sĩ thay đổi diệu kỳ theo bốn mùa hoa anh đào, cây lá xanh, rừng phong đỏ và tuyết phủ tinh khôi."
    },
    "intl_everest_base_camp": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Everest%20base%20camp%20trek-0155.jpg?width=1280",
        "photographer": "Nepal Trek Adventures",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Cơm Dal Bhat truyền thống nạp năng lượng vô tận cho người đi bộ đường dài",
            "Bánh bao Momo hấp hoặc chiên nhân thịt bò Yak chấm sốt ớt cay",
            "Trà sữa bơ Yak béo ngậy làm ấm cơ thể giữa băng tuyết",
            "Súp tỏi Sherpa làm ấm phổi và chống say độ cao hiệu quả",
            "Bánh mì dẹt Roti Tây Tạng nướng than hồng ăn kèm mứt mơ"
        ],
        "must_try_activities": [
            "Chinh phục độ cao 5.364m tại Trại căn cứ Everest Base Camp (EBC) ngay sát sông băng Khumbu",
            "Leo đỉnh Kala Patthar 5.545m lúc tờ mờ sáng đón bình minh rực vàng trên đỉnh Everest",
            "Băng qua cây cầu treo Hillary huyền thoại bắc qua hẻm núi sâu vút",
            "Ghé thăm Tu viện Phật giáo Tengboche cổ kính lắng nghe tiếng tù và cầu nguyện giữa rặng Himalaya"
        ],
        "cultural_highlights": [
            "Văn hóa phi thường và lòng quả cảm của người Sherpa - những 'vị thần gác cổng' của dãy Himalaya huyền thoại",
            "Hàng ngàn lá cờ cầu nguyện Lungta năm màu rực rỡ tung bay trong gió mang lời chúc bình an và trí tuệ đến muôn loài"
        ],
        "getting_there_advice": "Bay từ thủ đô Kathmandu (Nepal) đến sân bay Tenzing-Hillary tại Lukla (sân bay nguy hiểm và ngoạn mục nhất thế giới). Bắt đầu hành trình trekking đi bộ 12 - 14 ngày xuyên qua Vườn Quốc gia Sagarmatha dưới sự hướng dẫn của hướng dẫn viên và porter Sherpa.",
        "editorial_content": "Everest Base Camp (5.364m) tại Nepal là tuyến đường đi bộ đường dài vĩ đại nhất hành tinh nằm dưới chân đỉnh núi cao nhất thế giới Sagarmatha (8.848m). Băng qua những thung lũng băng hà kỳ vĩ, những dòng sông băng gầm gào và rặng tuyết sơn trùng điệp của dãy Himalaya, EBC là hành trình thử thách ý chí và tôn vinh tinh thần chinh phục đỉnh cao của con người."
    },
    "intl_taj_mahal": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Aks%20The%20Reflection%20Taj%20Mahal.jpg?width=1280",
        "photographer": "Antrix3",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Bánh kẹo Petha Agra truyền thống từ bí đao thơm hương thảo quả",
            "Thịt cừu nướng sốt kem Mughlai Biryani đậm đà gia vị hoàng gia",
            "Bánh mì dẹt Tandoori nướng lò đất chấm cà ri bơ sữa",
            "Trà Masala Chai cay thơm thảo mộc và đinh hương sưởi ấm",
            "Sữa chua Lassi xoài thơm mát béo ngậy"
        ],
        "must_try_activities": [
            "Chiêm ngưỡng Taj Mahal lúc bình minh khi đá cẩm thạch trắng ánh lên sắc hồng cam kỳ ảo",
            "Ngắm bóng Taj Mahal soi bóng xuống hồ nước trung tâm Mehtab Bagh bên kia sông Yamuna",
            "Tham quan Pháo đài đỏ Agra Fort kiệt tác quân sự và cung điện hoàng gia Mughal",
            "Chiêm ngưỡng kỹ thuật khảm đá quý Pietra Dura tinh xảo trên tường cẩm thạch"
        ],
        "cultural_highlights": [
            "Bản tình ca bất diệt tạc bằng đá của Hoàng đế Shah Jahan dành cho người vợ yêu quý Mumtaz Mahal",
            "Đỉnh cao của kiến trúc Hồi giáo Mughal kết hợp hài hòa các phong cách kiến trúc Ba Tư, Ottoman và Ấn Độ cổ điển"
        ],
        "getting_there_advice": "Từ thủ đô New Delhi, đón tàu cao tốc Gatimaan Express chỉ mất 1 giờ 40 phút là đến ga Agra Cantt. Từ ga đi xe tuk-tuk hoặc xe điện thân thiện môi trường để vào cổng di tích.",
        "editorial_content": "Được nhà thơ vĩ đại Rabindranath Tagore ví như 'giọt nước mắt đọng trên gò má thời gian', Taj Mahal là Di sản Thế giới UNESCO và là một trong Bảy kỳ quan thế giới mới. Toàn bộ công trình được xây dựng bằng đá cẩm thạch trắng tinh khiết khảm ngọc quý, phản chiếu những sắc thái ánh sáng thần tiên theo từng giờ trong ngày."
    },
    "intl_tour_du_mont_blanc": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Glacier%20du%20Mont%20Mallet%20%28Glacier%20du%20G%C3%A9ant%29%20%26%20Mont%20Blanc%2C%202010%20July.jpg?width=1280",
        "photographer": "Ximonic",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Lẩu phô mai Fondue Savoyarde béo ngậy nhúng bánh mì giòn",
            "Tartiflette khoai tây nướng thịt hun khói và phô mai Reblochon",
            "Xúc xích khô Diot hầm vang trắng Pháp thơm nồng",
            "Thịt bò hầm vang đỏ vùng thung lũng Aosta (Ý)",
            "Bánh mì ngọt brioche hoa cam và sô-cô-la Thụy Sĩ"
        ],
        "must_try_activities": [
            "Đi bộ đường dài vòng quanh khối núi Mont Blanc băng qua 3 quốc gia Pháp, Ý và Thụy Sĩ",
            "Đi cáp treo lên đỉnh Aiguille du Midi (3.842m) chạm tay vào biển băng tuyết vĩnh cửu",
            "Nghỉ đêm tại các nhà gỗ Refuge trên sườn núi ngắm hoàng hôn đỏ rực trên vách đá",
            "Ngắm nhìn dòng sông băng Mer de Glace khổng lồ uốn lượn giữa hai sườn núi đá"
        ],
        "cultural_highlights": [
            "Văn hóa chăn thả gia súc trên đồng cỏ cao nguyên Alpage hàng ngàn năm của cư dân vùng núi Alps",
            "Nơi khai sinh ra môn thể thao leo núi hiện đại (Alpinism) từ thế kỷ 18 với cuộc chinh phục đỉnh Mont Blanc đầu tiên năm 1786"
        ],
        "getting_there_advice": "Bay đến sân bay quốc tế Geneva (Thụy Sĩ), đón xe buýt tốc hành chỉ mất 1 giờ 15 phút là đến thị trấn Chamonix (Pháp) - thủ phủ leo núi của châu Âu và điểm xuất phát truyền thống của cung Tour du Mont Blanc.",
        "editorial_content": "Tour du Mont Blanc (TMB) dài khoảng 170 km là tuyến trekking vòng quanh cung núi kinh điển bậc nhất hành tinh. Hành trình đưa du khách vượt qua những con đèo tuyết trắng, thung lũng băng hà xanh biếc và những đồng cỏ hoa dại rực rỡ, xuyên qua biên giới ba nền văn hóa ẩm thực và ngôn ngữ đặc sắc của Pháp, Ý và Thụy Sĩ."
    },
    "intl_lofoten_islands": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Reine%20i%20Lofoten%20LC0148.jpg?width=1280",
        "photographer": "Jörg Hempel",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Cá tuyết khô Klippfisk nướng bơ truyền thống Nauy",
            "Cá hồi hoang dã Bắc Cực áp chảo giòn da",
            "Súp hải sản Lofoten Fiskesuppe béo ngậy kem tươi",
            "Thịt cừu sấy muối khô Fenalår thái mỏng",
            "Bánh quế Krumkake giòn rụm kẹp kem quả mâm xôi mây"
        ],
        "must_try_activities": [
            "Leo đỉnh Reinebringen ngắm toàn cảnh các hòn đảo và vịnh hẹp Fjord đẹp như tranh vẽ",
            "Trải nghiệm ở trong những ngôi nhà gỗ rorbu màu đỏ truyền thống ngay trên mặt nước biển",
            "Săn hiện tượng Cực quang Bắc Cực (Northern Lights) huyền ảo nhảy múa trên bầu trời đêm",
            "Chèo thuyền kayak giữa vịnh biển phẳng lặng dưới bóng những ngọn núi đá thẳng đứng"
        ],
        "cultural_highlights": [
            "Truyền thống đánh bắt cá tuyết mùa đông của người Viking kéo dài hơn 1.000 năm với những giàn phơi cá gỗ khổng lồ",
            "Nơi mặt trời không bao giờ lặn vào mùa hè (Hiện tượng Mặt trời nửa đêm - Midnight Sun)"
        ],
        "getting_there_advice": "Bay từ Oslo (Na Uy) đến sân bay Bodø, sau đó đi phà vượt biển đến làng Moskenes hoặc bay chuyến bay nhỏ của hãng Widerøe đến sân bay Leknes hoặc Svolvær trên đảo Lofoten.",
        "editorial_content": "Nằm trọn trong Vòng Bắc Cực ngoài khơi bờ biển phía bắc Na Uy, Quần đảo Lofoten sở hữu vẻ đẹp hoang sơ đến nghẹt thở. Những bức tường núi đá granite dựng đứng vươn thẳng từ lòng biển xanh biếc, những bãi biển cát trắng tinh như vùng nhiệt đới và những ngôi làng chài rorbu đỏ thắm tạo nên một trong những cảnh quan thiên nhiên kỳ ảo nhất hành tinh."
    },
    "intl_banff_rockies": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Moraine%20Lake%2C%20Banff%20-%20Flickr%20-%20Jaykhuang.jpg?width=1280",
        "photographer": "Jay Huang",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY 2.0",
        "local_specialties": [
            "Thịt bò Alberta bít-tết nướng than gỗ thơm mềm",
            "Cá hồi nướng si-rô cây phong Canada (Maple Glazed Salmon)",
            "Khoai tây chiên sốt phô mai Poutine kiểu Canada nóng hổi",
            "Bánh bơ truyền thống Butter Tart béo ngậy ngọt ngào",
            "Bia thủ công ủ bằng nguồn nước băng tuyết dãy Rockies"
        ],
        "must_try_activities": [
            "Chèo xuồng kanoe gỗ đỏ trên mặt nước xanh màu ngọc lam sữa của Hồ Moraine và Hồ Louise",
            "Lái xe dọc đại lộ băng tuyết Icefields Parkway - cung đường ngắm cảnh đẹp nhất thế giới",
            "Đi xe thám hiểm khổng lồ trên dòng sông băng Columbia Icefield",
            "Ngâm mình thư giãn trong suối khoáng nóng tự nhiên Banff Upper Hot Springs"
        ],
        "cultural_highlights": [
            "Vườn quốc gia đầu tiên của Canada thành lập năm 1885, cái nôi của phong trào bảo tồn thiên nhiên Bắc Mỹ",
            "Vùng đất tổ của các bộ tộc bản địa First Nations tôn kính linh hồn núi đá và các dòng nước băng hà"
        ],
        "getting_there_advice": "Bay đến Sân bay Quốc tế Calgary (tỉnh Alberta, Canada). Từ sân bay thuê xe tự lái hoặc bắt xe buýt đưa đón Banff Airporter chạy theo đường cao tốc xuyên Canada (Trans-Canada Highway) khoảng 1.5 giờ (140 km) là đến thị trấn Banff.",
        "editorial_content": "Nằm giữa trái tim Dãy núi Rocky hùng vĩ của Canada, Vườn Quốc gia Banff là Di sản Thiên nhiên Thế giới UNESCO với những hồ nước băng hà mang màu xanh ngọc lam kỳ ảo do bột đá băng tạo nên. Bao quanh bởi những đỉnh núi tuyết nhọn hoắt và rừng thông bạt ngàn nơi gấu xám, nai sừng tấm sinh sống tự do, Banff là đỉnh cao của vẻ đẹp hoang dã Bắc Mỹ."
    },
    "intl_milford_track": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Clouds%20Boiling%20Over%20The%20Milford%20Track%20Pass.jpg?width=1280",
        "photographer": "Ingolfson",
        "source_name": "Wikimedia Commons",
        "license": "Public Domain",
        "local_specialties": [
            "Thịt cừu nướng hương thảo thảo nguyên Nam Đảo New Zealand",
            "Hàu biển Bluff tươi sống ngọt đậm đà vị biển nam cực",
            "Bánh Pavlova phủ kem tươi và quả kiwi, dâu rừng New Zealand",
            "Cá hồi nước ngọt nướng gỗ sồi thơm ngát",
            "Rượu vang trắng Sauvignon Blanc Marlborough lừng danh"
        ],
        "must_try_activities": [
            "Hoàn thành chuyến đi bộ 53.5 km trong 4 ngày xuyên qua Vườn Quốc gia Fiordland",
            "Chinh phục đèo Mackinnon Pass ngắm mây mù cuồn cuộn trên thung lũng băng hà",
            "Chiêm ngưỡng Thác Sutherland cao 580m - một trong những ngọn thác cao nhất thế giới",
            "Du thuyền trên vịnh hẹp Milford Sound ngắm cá heo, hải cẩu và đỉnh Mitre Peak sừng sững"
        ],
        "cultural_highlights": [
            "Thần thoại của người Maori kể về vị thần Tu-te-raki-whanoa dùng rìu đá đẽo gọt các vách đá tạo nên các vịnh hẹp Fiordland",
            "Bối cảnh quay phim huyền thoại của Chúa tể của những chiếc nhẫn (The Lord of the Rings)"
        ],
        "getting_there_advice": "Bay đến Queenstown (thủ đô phiêu lưu mạo hiểm của New Zealand), sau đó bắt xe buýt đến thị trấn Te Anau. Từ Te Anau Downs, đi tàu cao tốc đến đầu đường mòn tại Glade Wharf để bắt đầu hành trình trekking 4 ngày.",
        "editorial_content": "Được nhà thơ Blanche Baughan ca ngợi từ hơn một thế kỷ trước là 'chuyến đi bộ tuyệt vời nhất thế giới' (The finest walk in the world), Milford Track dài 53.5 km đưa người lữ hành băng qua rừng mưa ôn đới rêu phong cổ tích, những thác nước khổng lồ đổ từ độ cao hàng trăm mét và thung lũng băng hà kỳ vĩ của Di sản Thế giới Te Wahipounamu."
    },
    "intl_machu_picchu": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/80%20-%20Machu%20Picchu%20-%20Juin%202009%20-%20edit.jpg?width=1280",
        "photographer": "Martin St-Amant",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 3.0",
        "local_specialties": [
            "Gỏi cá sống Ceviche ướp nước cốt chanh ớt Peru tươi mát",
            "Thịt bò xào Lomo Saltado ăn kèm cơm nóng và khoai tây chiên",
            "Trà lá Coca làm ấm cơ thể và phòng chống say độ cao hiệu quả",
            "Ngô nướng bơ hạt to khổng lồ vùng thung lũng thiêng Urubamba",
            "Bánh ngô Tamales hấp nhân thịt gà và ớt vàng Aji Amarillo"
        ],
        "must_try_activities": [
            "Trekking theo con đường mòn Inca Trail 4 ngày vượt qua Cổng Trời Sun Gate ngắm trọn thành phố cổ",
            "Leo lên đỉnh Huayna Picchu ngắm nhìn toàn cảnh pháo đài đá từ trên mây",
            "Chiêm ngưỡng phiến đá thiêng Intihuatana đồng hồ mặt trời của người Inca",
            "Chụp ảnh cùng những chú lạc đà Llama và Alpaca thân thiện gặm cỏ trên các bậc thang đá"
        ],
        "cultural_highlights": [
            "Kỹ thuật ghép đá Ashlar phi thường của nền văn minh Inca: những khối đá nặng hàng tấn được mài khít khao không dùng vữa nhưng trụ vững qua bao trận động đất",
            "Thành phố thiêng ẩn mình trên mây bị lãng quên suốt gần 400 năm cho đến khi được Hiram Bingham tái phát hiện năm 1911"
        ],
        "getting_there_advice": "Bay đến thủ đô Lima (Peru), bay tiếp đến thành phố cổ Cusco (3.400m). Từ Cusco đi tàu hỏa ngắm cảnh Hiram Bingham hoặc PeruRail dọc sông Urubamba đến thị trấn Aguas Calientes, sau đó đi xe buýt 20 phút lên cổng di tích.",
        "editorial_content": "Nằm cheo leo trên sườn núi dốc đứng ở độ cao 2.430m giữa dãy Andes huyền bí, Machu Picchu là 'Thành phố đã mất của người Inca' và là một trong Bảy kỳ quan thế giới mới. Hòa quyện hoàn hảo giữa kỹ thuật kiến trúc đá siêu việt và khung cảnh thiên nhiên rừng nhiệt đới mây mù bao phủ, nơi đây là minh chứng vĩ đại cho trí tuệ của con người cổ đại."
    },
    "intl_kilimanjaro": {
        "image_url": "https://commons.wikimedia.org/wiki/Special:FilePath/Amboseli%20Park%20-%20Kilimanjaro%20Giraffe.jpg?width=1280",
        "photographer": "Lafleursauvage",
        "source_name": "Wikimedia Commons",
        "license": "CC-BY-SA 4.0",
        "local_specialties": [
            "Thịt nướng xiên Nyama Choma thơm lừng thảo mộc Đông Phi",
            "Bánh ngô đặc Ugali ăn kèm súp rau chân vịt xào",
            "Chuối xanh hầm thịt bò Ndizi Kaanga đậm đà",
            "Cà phê Arabica thơm ngát trồng trên sườn núi lửa Kilimanjaro",
            "Bánh gối Samusa chiên giòn nhân thịt băm cay nồng"
        ],
        "must_try_activities": [
            "Trekking chinh phục đỉnh Uhuru 5.895m - nóc nhà châu Phi băng qua 5 vùng khí hậu khác nhau",
            "Săn bình minh ngoạn mục trên đỉnh tuyết sơn nhìn xuống biển mây thảo nguyên Serengeti",
            "Chiêm ngưỡng các sông băng xích đạo khổng lồ đang dần tan biến theo biến đổi khí hậu",
            "Quan sát các loài thú hoang dã như hươu cao cổ, voi rừng và khỉ Colobus ở chân núi"
        ],
        "cultural_highlights": [
            "Văn hóa và niềm tin tín ngưỡng của người Chagga bản địa xem ngọn núi là nơi ngự trị của các vị thần tối cao",
            "Kỳ quan địa chất: ngọn núi lửa đứng độc lập không thuộc bất kỳ dãy núi nào cao nhất thế giới"
        ],
        "getting_there_advice": "Bay đến Sân bay Quốc tế Kilimanjaro (JRO) ở Tanzania. Xe đưa đón sẽ chở về thị trấn Moshi hoặc Arusha nghỉ ngơi một đêm chuẩn bị trang thiết bị trước khi bắt đầu hành trình leo núi 6 - 8 ngày theo các tuyến Machame hoặc Marangu.",
        "editorial_content": "Vươn mình kiêu hãnh giữa thảo nguyên Đông Phi bao la, Núi Kilimanjaro cao 5.895m là ngọn núi đứng độc lập cao nhất thế giới và là 'Nóc nhà của Lục địa Đen'. Hành trình leo núi đưa người thám hiểm đi từ rừng nhiệt đới ẩm ướt ở chân núi qua thảo nguyên thạch nam, hoang mạc núi cao và kết thúc tại đỉnh băng tuyết xích đạo trắng xóa kỳ vĩ."
    }
}

# Tiến hành cập nhật từng địa điểm trong seed
for dest in data.get('destinations', []):
    did = dest.get('id')
    if did in updates:
        up = updates[did]
        # Cập nhật media
        if dest.get('media'):
            dest['media'][0]['image_url'] = up['image_url']
            dest['media'][0]['photographer'] = up['photographer']
            dest['media'][0]['source_name'] = up['source_name']
            dest['media'][0]['license'] = up['license']
            dest['media'][0]['attribution'] = f"Ảnh: {up['photographer']} ({up['source_name']})"
        dest['local_specialties'] = up['local_specialties']
        dest['must_try_activities'] = up['must_try_activities']
        dest['cultural_highlights'] = up['cultural_highlights']
        dest['getting_there_advice'] = up['getting_there_advice']
        dest['editorial_content'] = up['editorial_content']

# Ghi lại file json với format đẹp mắt
with open(seed_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Updated destinations_seed.json with authentic photos & rich cultural data!")

