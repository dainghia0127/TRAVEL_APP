import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';

class OutdoorSkillsScreen extends StatefulWidget {
  const OutdoorSkillsScreen({super.key});

  @override
  State<OutdoorSkillsScreen> createState() => _OutdoorSkillsScreenState();
}

class _OutdoorSkillsScreenState extends State<OutdoorSkillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  final Set<String> _bookmarkedIds = {'skill_1', 'skill_2', 'skill_6'};

  final List<Map<String, dynamic>> _skillsList = [
    {
      'id': 'skill_1',
      'title': 'Sơ cứu khi bị rắn độc cắn',
      'category': 'Sơ cứu Y tế',
      'categoryIcon': Icons.medical_services_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Quy tắc vàng bất động & băng ép bản rộng bảo toàn tính mạng khi gặp tai nạn rắn cắn trong rừng sâu.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.editorialTerracotta,
      'equipment': [
        'Cuộn băng thun y tế (hoặc dải vải sạch rộng 10-15cm)',
        '2 thanh nẹp tre/gỗ thẳng dài 50-70cm',
        'Dải vải mềm buộc cố định nẹp',
        'Còi cứu nạn đa tần số',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Trấn an & Hạ thấp chi bị cắn dưới tim',
          'diagramType': 'immobilize_limb',
          'tag': 'BẤT ĐỘNG TUYỆT ĐỐI',
          'action': 'Yêu cầu nạn nhân nằm yên bất động TUYỆT ĐỐI. Khi hoảng sợ tim đập nhanh sẽ bơm nọc độc theo hệ bạch huyết đi khắp cơ thể chỉ trong vài phút. Đặt cánh tay hoặc chân bị cắn ở vị trí THẤP HƠN TIM. Tháo ngay nhẫn, vòng tay, đồng hồ hoặc giày dép trước khi vết cắn sưng to chèn ép mạch máu.',
          'keyRule': 'Tuyệt đối không để nạn nhân tự bước đi dù chỉ 1 bước đơn lẻ.',
          'tip': 'Dùng điện thoại chụp ảnh con rắn từ khoảng cách an toàn (trên 2m) để bác sĩ xác định đúng huyết thanh kháng độc. Tuyệt đối không đuổi bắt hoặc đập rắn.',
        },
        {
          'number': '02',
          'title': 'Kỹ thuật băng ép bản rộng (Pressure Immobilization)',
          'diagramType': 'pressure_wrap',
          'tag': 'BĂNG ÉP TỪ NGÓN LÊN GỐC',
          'action': 'Dùng cuộn băng thun quấn từ đầu ngón tay/ngón chân hướng ngược dần lên phía gốc chi (vượt qua vết cắn 15-20cm). Lực quấn chặt vừa phải tương đương sơ cứu bong gân cổ chân. Chú ý ĐỂ HỞ ĐẦU CÁC NGÓN để liên tục kiểm tra tuần hoàn máu.',
          'keyRule': 'Kiểm tra mạch ở mu chân hoặc cổ tay: nếu không sờ thấy mạch nghĩa là quấn quá chặt, cần nới lỏng nhẹ ra.',
          'tip': 'Nếu ngón tay hoặc ngón chân chuyển màu tím tái hoặc lạnh buốt, phải nới lỏng băng ép ngay lập tức.',
        },
        {
          'number': '03',
          'title': 'Nẹp cố định qua 2 khớp xương liền kề',
          'diagramType': 'splint_joint',
          'tag': 'KHÓA BẤT ĐỘNG 2 KHỚP',
          'action': 'Đặt 2 thanh nẹp dọc 2 bên chi bị thương (vượt qua cả 2 khớp liền kề vết thương, ví dụ qua khớp gối và cổ chân). Dùng dải vải buộc cố định nẹp để nạn nhân không thể co gập khớp (cử động cơ bắp là nguyên nhân chính đẩy nọc độc vào tuần hoàn máu).',
          'keyRule': 'Khóa bất động cả khớp trên và khớp dưới của vị trí vết cắn.',
          'tip': 'Chèn thêm lớp cỏ mềm hoặc áo thun giữa cành gỗ và da để tránh trầy xước mô mềm khi vận chuyển.',
        },
        {
          'number': '04',
          'title': 'Khiêng cáng di chuyển cấp cứu khẩn cấp',
          'diagramType': 'stretcher_carry',
          'tag': 'VẬN CHUYỂN NẰM NGANG',
          'action': 'Dùng võng dù, bạt dã ngoại hoặc 2 cây tre kết hợp luồn áo khoác làm cáng khiêng nạn nhân. Giữ đầu nạn nhân hơi nâng cao nhẹ. Vận chuyển khẩn trương đến bệnh viện huyện/tỉnh có huyết thanh kháng nọc gần nhất.',
          'keyRule': 'Luôn khiêng bằng cáng — nạn nhân đi bộ sẽ tăng tốc độ ngấm độc lên gấp 5 lần.',
          'tip': 'Dùng bút ghi nhớ giờ bị cắn trực tiếp lên mu bàn tay nạn nhân để bác sĩ theo dõi diễn tiến nhiễm độc.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG rạch da, trích nặn máu hoặc dùng miệng hút nọc (làm rách mạch máu khiến độc ngấm nhanh hơn và nhiễm độc người sơ cứu).',
        'TUYỆT ĐỐI KHÔNG thắt garo nghẽn động mạch (nguyên nhân hàng đầu gây hoại tử thiếu máu nuôi dẫn đến phải cưa cụt chi).',
        'TUYỆT ĐỐI KHÔNG đắp lá cây, bùn đất hoặc chườm đá lạnh (gây bỏng lạnh mô và nhiễm trùng uốn ván chết người).',
      ],
    },
    {
      'id': 'skill_2',
      'title': 'Xử lý hạ thân nhiệt (Hypothermia)',
      'category': 'Sinh tồn thời tiết',
      'categoryIcon': Icons.ac_unit_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Quy trình phục hồi thân nhiệt an toàn khi leo núi gặp mưa dầm, gió rét và hạ nhiệt độ đột ngột về đêm.',
      'priority': 'NGUY CẤP',
      'accent': AppColors.editorialPine,
      'equipment': [
        'Lều kín gió / bạt nhôm cứu sinh tráng bạc phản xạ nhiệt',
        'Khăn bông khô & đồ nỉ ấm khô ráo',
        'Túi ngủ dã ngoại chuyên dụng',
        'Bình giữ nhiệt nước đường gừng ấm',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Di chuyển ngay vào nơi chắn gió 360 độ',
          'diagramType': 'wind_shelter',
          'tag': 'CHẮN GIÓ LÙA TUYỆT ĐỐI',
          'action': 'Gió lùa và độ ẩm làm mất nhiệt cơ thể nhanh gấp 25 lần không khí khô tĩnh lặng. Đưa ngay người bị nạn vào lều khô ráo, vách đá khuất gió hoặc căng bạt chắn triệt để gió lùa từ mọi phía.',
          'keyRule': 'Lót thảm cách nhiệt hoặc cành lá khô dày dưới sàn lều — không để nạn nhân nằm trực tiếp lên nền đất lạnh.',
          'tip': 'Đóng kín tất cả các cửa thông gió của lều trong 30 phút đầu tiên.',
        },
        {
          'number': '02',
          'title': 'Cởi bỏ toàn bộ đồ ướt & Bọc chăn nhôm bạc',
          'diagramType': 'strip_wet_cloth',
          'tag': 'THAY ĐỒ KHÔ & ĐỘI MŨ LEN',
          'action': 'Nhanh chóng lột bỏ toàn bộ quần áo ướt sũng. Dùng khăn khô thấm nhẹ nước trên da (không chà xát mạnh). Thay ngay đồ khô ấm và đội mũ len che kín vùng đầu (đầu là nơi thất thoát tới 40% nhiệt lượng của cơ thể). Bọc chăn nhôm cứu sinh tráng bạc ra ngoài cùng.',
          'keyRule': 'Đội mũ len khô ấm cho nạn nhân ngay khi vừa cởi đồ ướt.',
          'tip': 'Chăn nhôm cứu sinh phản xạ 90% bức xạ nhiệt cơ thể phát ra trở lại cơ thể.',
        },
        {
          'number': '03',
          'title': 'Ủ ấm trung tâm: 4 điểm vàng mạch máu lớn',
          'diagramType': 'core_warming',
          'tag': 'Ủ ẤM CỔ • NGỰC • NÁCH • BẸN',
          'action': 'Cho nạn nhân vào túi ngủ khô. Dùng các bình nước ấm bọc trong khăn vải (khoảng 40-42°C) áp nhẹ vào 4 vị trí vàng: 2 bên CỔ, NGỰC TRUNG TÂM, 2 HỐ NÁCH và 2 BẸN ĐÙI. Đây là nơi có các động mạch lớn vận chuyển máu ấm nhanh nhất vào tim và não.',
          'keyRule': 'TUYỆT ĐỐI KHÔNG chườm ấm trực tiếp vào bàn tay/chân (gây sốc hạ nhiệt tim đột ngột do máu lạnh dồn về).',
          'tip': 'Có thể áp dụng phương pháp da tiếp da (ôm giữ nhiệt) nếu trong rừng không có đủ đồ sưởi ấm.',
        },
        {
          'number': '04',
          'title': 'Bổ sung nước ấm đường gừng từng ngụm nhỏ',
          'diagramType': 'warm_sip',
          'tag': 'UỐNG TỪNG NGỤM NHỎ',
          'action': 'Nếu nạn nhân còn tỉnh táo và tự nuốt được, cho uống từng ngụm nhỏ nước ấm pha mật ong, đường glucose hoặc trà gừng để bổ sung calo cho cơ thể tự tạo nhiệt.',
          'keyRule': 'Nếu nạn nhân lơ mơ hoặc bất tỉnh, KHÔNG ĐƯỢC ép uống nước (nguy cơ sặc vào khí quản).',
          'tip': 'Uống ngụm nhỏ cách nhau 2-3 phút để dạ dày hấp thụ từ từ.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG cho uống rượu / bia (cồn làm giãn mao mạch ngoại vi, tạo cảm giác nóng giả nhưng thực chất làm nhiệt lượng thoát ra môi trường nhanh gấp đôi).',
        'TUYỆT ĐỐI KHÔNG xoa bóp hoặc hơ lửa trực tiếp lên tay chân bị lạnh cóng (làm tổn thương mô đóng băng và gây bỏng nặng).',
      ],
    },
    {
      'id': 'skill_3',
      'title': '5 Nút dây dã ngoại cốt lõi',
      'category': 'Dựng trại & Dây',
      'categoryIcon': Icons.gesture_outlined,
      'readTime': '6 phút đọc',
      'desc': '5 nút dây nền tảng bảo đảm lều trại vững chãi trước dông bão và neo người an toàn khi vượt suối dốc.',
      'priority': 'CĂN BẢN',
      'accent': AppColors.editorialPine,
      'equipment': [
        'Dây sinh tồn Paracord 4mm (hoặc dây dù 7 lõi)',
        'Cọc lều dã ngoại nhôm/thép',
        'Carabiner chịu tải leo núi',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Nút dẹt (Reef Knot) — Nối 2 đầu dây',
          'diagramType': 'reef_knot',
          'tag': 'PHẢI QUA TRÁI • TRÁI QUA PHẢI',
          'action': 'Quy tắc vàng: "Phải qua trái rồi quấn — Trái qua phải rồi quấn". Đặt đầu dây phải bắt chéo lên đầu dây trái, quấn 1 vòng. Sau đó lấy đầu dây trái bắt chéo lên đầu dây phải, quấn 1 vòng rồi kéo siết chặt. Hai vòng dây lồng vào nhau cân xứng.',
          'keyRule': 'Chỉ dùng nối 2 sợi dây có cùng tiết diện và chất liệu.',
          'tip': 'Để tháo nút siêu nhanh: Giật mạnh một đầu dây tự do, nút sẽ tự bung ra mà không bị kẹt.',
        },
        {
          'number': '02',
          'title': 'Nút thòng lọng (Bowline) — Vua của các nút dây',
          'diagramType': 'bowline_knot',
          'tag': 'VÒNG KHUYÊN BẤT BIẾN KHÔNG THÍT',
          'action': 'Tạo một vòng khuyên cố định không bao giờ bị thít chặt dù chịu tải trọng hàng trăm kg. Câu thần chú: "Thỏ chui lên khỏi hang, vòng qua gốc cây đại thụ, rồi chui ngược lại vào hang". Tạo vòng khuyên nhỏ, luồn đầu dây từ dưới lên, vòng sau thân dây chính rồi xỏ ngược lại lỗ tròn, kéo siết.',
          'keyRule': 'Nút neo chịu tải an toàn số 1 thế giới — rất dễ tháo dù vừa kéo tải cực nặng.',
          'tip': 'Dùng làm vòng cứu sinh quấn quanh người khi hỗ trợ vượt suối hoặc neo võng vào thân cây to.',
        },
        {
          'number': '03',
          'title': 'Nút tăng đơ (Taut-line Hitch) — Căng dây lều tự động',
          'diagramType': 'tautline_knot',
          'tag': '2 VÒNG TRONG • 1 VÒNG NGOÀI TRƯỢT KHÓA',
          'action': 'Vòng dây qua cọc cắm đất. Quấn đầu dây 2 vòng bên trong lòng dây chính hướng về phía cọc lều. Sau đó vòng tiếp 1 vòng bên ngoài về phía lều rồi thắt nút khóa. Nút này ma sát tự khóa nhưng có thể dùng tay trượt lên xuống để chỉnh độ chùng căng của dây lều.',
          'keyRule': 'Trời mưa dây lều bị giãn, chỉ cần dùng ngón tay đẩy nút trượt lên là dây căng lại ngay.',
          'tip': 'Không cần phải tháo cọc cắm lại mỗi khi gió giật làm chùng bạt.',
        },
        {
          'number': '04',
          'title': 'Nút số 8 (Figure-Eight) — Khóa chặn đầu dây an toàn',
          'diagramType': 'figure8_knot',
          'tag': 'NÚT KHÓA CHẶN KHÔNG HẠI DÂY',
          'action': 'Gập đầu dây tạo vòng khuyên, vòng đầu dây qua thân dây chính rồi xỏ từ trên xuống xuyên qua vòng khuyên để tạo thành hình số 8 rõ rệt. Nút này lớn gấp đôi nút thắt thông thường và giữ 80% độ bền sợi dây.',
          'keyRule': 'Dùng làm chốt chặn ở đầu dây leo núi để dây không tuột qua ròng rọc hoặc carabiner.',
          'tip': 'Cực kỳ dễ tháo gỡ sau khi chịu lực kéo cực đại so với nút thắt đơn thông thường.',
        },
        {
          'number': '05',
          'title': 'Nút thuyền chài (Clove Hitch) — Neo cọc nhanh',
          'diagramType': 'clove_hitch',
          'tag': 'NEO THÂN CÂY SIÊU NHANH',
          'action': 'Quấn 1 vòng quanh thân cây, bắt chéo dây qua vòng đầu tiên, quấn tiếp vòng thứ 2 song song rồi luồn đầu dây luồn xuống dưới sợi dây chéo thứ 2, kéo siết chặt. Hai đầu dây ghì chặt thân cây nhờ lực ma sát.',
          'keyRule': 'Dùng neo cọc lều, buộc thuyền kayak hoặc làm nút khởi đầu khi đan giàn tre.',
          'tip': 'Nên thắt thêm 1 nút khóa phụ (half-hitch) ở đầu tự do nếu dây chịu lực rung lắc liên tục.',
        },
      ],
      'donts': [
        'Không dùng dây thừng đã sờn vỏ lõi hoặc bị mục ẩm để căng võng ngủ qua đêm trên cao.',
      ],
    },
    {
      'id': 'skill_4',
      'title': 'Khử trùng & Tự chế cột lọc nước sinh tồn 4 tầng',
      'category': 'Nước sạch',
      'categoryIcon': Icons.water_drop_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Cách chế tạo cột lọc 4 tầng tự nhiên và phương pháp khử trùng nguồn nước suối rừng an toàn.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.alpineCyan,
      'equipment': [
        'Vỏ chai nhựa 1.5L rỗng cắt đáy',
        'Vải lọc / khăn bông sạch / bông gòn',
        'Than củi gỗ sạch nghiền vụn',
        'Cát mịn tự nhiên & sỏi đá nhỏ',
        'Viên lọc nước Aquatabs hoặc cồn đun sôi',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Thu thập nguồn nước suối chảy liên tục',
          'diagramType': 'water_source',
          'tag': 'CHỌN NƯỚC CHẢY QUA GỜ ĐÁ',
          'action': 'Luôn lấy nước ở nơi có dòng nước chảy liên tục qua các gờ đá, nước trong suốt. Tránh lấy nước ở các vũng nước tù đọng có rêu xanh hoặc gần xác động vật thối rữa ở thượng nguồn.',
          'keyRule': 'Nước suối dù trong vắt vẫn chứa vi khuẩn E.coli và ký sinh trùng Giardia gây tiêu chảy cấp.',
          'tip': 'Hứng nước vào bình chứa, để yên 15-20 phút cho bùn cát lắng xuống đáy trước khi bắt đầu rót lọc.',
        },
        {
          'number': '02',
          'title': 'Thiết lập cột lọc tự nhiên 4 tầng chuẩn',
          'diagramType': 'filter_column',
          'tag': 'SỎI • CÁT • THAN • VẢI LỌC',
          'action': 'Lộn ngược chai nhựa cắt đáy. Tầng 1 (dưới cùng sát nắp chai có đục lỗ): Lót lớp vải bông sạch. Tầng 2: Lớp than củi nghiền nhỏ dày 6-8cm (than hoạt tính hấp phụ độc chất và mùi hôi). Tầng 3: Lớp cát sông mịn sạch dày 5cm. Tầng 4 (trên cùng): Lớp sỏi đá nhỏ để ngăn cát bị xáo trộn khi rót nước.',
          'keyRule': 'Rót nước nhẹ nhàng vào cột lọc, bỏ nước của 2-3 mẻ đầu tiên cho đến khi nước chảy ra trong veo.',
          'tip': 'Cột lọc chỉ loại bỏ cặn bẩn cơ học và khử mùi, KHÔNG DIỆT ĐƯỢC vi khuẩn siêu vi.',
        },
        {
          'number': '03',
          'title': 'Đun sôi tối thiểu 3 phút hoặc dùng viên Aquatabs',
          'diagramType': 'boil_sanitize',
          'tag': 'ĐUN SÔI SÙNG SỤC 3-5 PHÚT',
          'action': 'Sau khi lọc nước trong, cho vào ca inox đun sôi sùng sục liên tục trong ít nhất 3 phút (ở vùng núi cao trên 1,500m nhiệt độ sôi thấp hơn, cần đun 5 phút). Nếu không thể nhóm lửa, dùng 1 viên Aquatabs cho 2 lít nước, lắc đều và chờ đủ 30 phút trước khi uống.',
          'keyRule': 'Đun sôi tối thiểu 3 phút là tiêu chuẩn vàng diệt 99.9% mầm bệnh trong tự nhiên.',
          'tip': 'Để nước nguội tự nhiên trong bình kín, không thả đá bẩn hoặc lá cây chưa tiệt trùng vào.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG uống nước biển hoặc nước đọng trong hốc cây lâu ngày có mùi chua thối.',
        'TUYỆT ĐỐI KHÔNG uống nước lã trực tiếp từ suối dù nhìn rất trong và mát lạnh.',
      ],
    },
    {
      'id': 'skill_5',
      'title': 'Quy tắc sinh tồn S.T.O.P & Tín hiệu cứu hộ',
      'category': 'Định hướng',
      'categoryIcon': Icons.compass_calibration_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Nguyên lý tâm lý và hành động 4 bước giúp 95% người lạc rừng sống sót và được giải cứu an toàn.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.editorialTerracotta,
      'equipment': [
        'Còi cứu nạn dã ngoại (thổi mã SOS)',
        'La bàn cơ & bản đồ giấy / ứng dụng ngoại tuyến',
        'Bật lửa chống gió / đá đánh lửa sinh tồn',
        'Áo mưa hoặc bạt che màu nổi bật',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'S — STOP: Dừng lại ngay lập tức',
          'diagramType': 'stop_step',
          'tag': 'DỪNG LẠI • THỔI 3 HỒI CÒI DÀI',
          'action': 'Ngay khi phát hiện mất dấu đường mòn hoặc lạc đoàn: DỪNG LẠI NGAY LẬP TỨC. Ngồi xuống hít sâu 10 nhịp. Sự hoảng sợ bản năng sẽ thúc giục bạn cắm đầu chạy, và 90% trường hợp chấn thương nặng hoặc tử vong là do lao vào vực sâu trong cơn hoảng loạn.',
          'keyRule': 'Thổi 3 tiếng còi thật dài (Mã cứu nạn quốc tế: 3 hồi còi = SOS). Lắng nghe 1 phút xem có tiếng đáp.',
          'tip': 'Đánh dấu vị trí bạn đang đứng bằng cách buộc dải vải đỏ hoặc xếp cành cây chữ X.',
        },
        {
          'number': '02',
          'title': 'T — THINK: Suy nghĩ và định hình lại',
          'diagramType': 'think_step',
          'tag': 'HỒI TƯỞNG MỐC & XÁC ĐỊNH GPS',
          'action': 'Hồi tưởng lại: Bạn rời đoàn cách đây bao lâu? Điểm mốc quen thuộc cuối cùng bạn thấy là gì (thác nước, cây thông đôi, cột mốc)? Mở ứng dụng Travel App xem vị trí và tọa độ GPS đã lưu trên bộ đệm ngoại tuyến.',
          'keyRule': 'Nếu mới lạc dưới 10 phút, bạn có thể men theo dấu vết cỏ dập để quay lại vị trí ban đầu.',
          'tip': 'Ghi chép lại các thông tin vào điện thoại hoặc sổ tay để giữ bình tĩnh tinh thần.',
        },
        {
          'number': '03',
          'title': 'O — OBSERVE: Quan sát địa hình và thời tiết',
          'diagramType': 'observe_step',
          'tag': 'TÌM ĐẤT CAO • TRÁNH LÒNG SUỐI',
          'action': 'Quan sát mặt trời để định hướng Đông - Tây. Tìm kiếm nguồn nước suối gần đó, mỏm đất cao khô ráo không có nguy cơ sạt lở để trú ẩn. Nếu trời đã sau 16h30 hoặc có mây dông kéo đến, ngừng tìm đường và tập trung toàn lực vào việc trú ẩn.',
          'keyRule': 'TUYỆT ĐỐI KHÔNG đi men theo lòng khe suối hoang dã vì suối nhiệt đới luôn có vực thác dựng đứng 30-50m chắn lối.',
          'tip': 'Địa điểm trú ẩn tốt nhất là lưng chừng đồi, khuất gió và cách nguồn nước 50m.',
        },
        {
          'number': '04',
          'title': 'P — PLAN: Kế hoạch trú ẩn & Tín hiệu cứu hộ',
          'diagramType': 'plan_step',
          'tag': 'DỰNG TRẠI < 17H • 3 ĐỐNG LỬA SOS',
          'action': 'Dựng lều hoặc căng bạt trú ẩn trước 17h00. Thu gom củi khô dự trữ cho cả đêm. Tạo 3 đống lửa thành hình tam giác ở bãi đất trống (tín hiệu cấp cứu quốc tế). Ban ngày cho thêm lá cây tươi để tạo cột khói trắng dày bốc cao cho trực thăng hoặc đội tìm kiếm cứu nạn.',
          'keyRule': 'Ở YÊN MỘT CHỖ! Đội cứu hộ luôn khoanh vùng tìm kiếm bắt đầu từ điểm bạn được nhìn thấy cuối cùng.',
          'tip': 'Treo áo mưa hoặc bạt màu nổi lên ngọn cây cao để tăng khả năng phát hiện từ xa.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG cố dò đường di chuyển trong bóng đêm (dễ sẩy chân rơi xuống vực hoặc đụng phải thú dữ).',
      ],
    },
    {
      'id': 'skill_6',
      'title': 'Kỹ thuật nhóm lửa khi trời mưa & củi ướt',
      'category': 'Kỹ năng sinh tồn',
      'categoryIcon': Icons.local_fire_department_outlined,
      'readTime': '5 phút đọc',
      'desc': 'Cách tìm bùi nhùi khô trong rừng mưa nhiệt đới và dựng tháp củi tổ chim giữ ngọn lửa sinh tồn.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.tacticalOrange,
      'equipment': [
        'Thanh đánh lửa Magie (Ferro rod) / Hộp quẹt chống nước',
        'Dao gọt dã ngoại có sống dao sắc 90 độ',
        'Bọc nilon / Bạt che mưa tạo mái',
        'Nến nhỏ hoặc mẩu cao su ruột xe dự phòng',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Tìm kiếm lõi gỗ khô & nhựa thông tự nhiên',
          'diagramType': 'find_dry_wood',
          'tag': 'TÌM CÀNH CHẾT TRÊN CÂY (DEADWOOD)',
          'action': 'Tuyệt đối KHÔNG nhặt cành cây nằm dưới mặt đất ẩm ướt vì nước mưa đã ngấm vào tận tủy gỗ. Hãy bẻ những cành cây chết còn treo lơ lửng trên thân cây đứng (dead standing wood) hoặc tìm các thân cây thông bị gãy có đọng nhựa thơm (fatwood - gỗ chứa nhựa thông bắt lửa cực nhạy).',
          'keyRule': 'Cành cây chết trên cao luôn khô ráo bên trong kể cả sau 3 ngày mưa liên tục.',
          'tip': 'Bẻ cành cây: nếu nghe tiếng "rắc" giòn tan nghĩa là gỗ khô, nếu cành bị uốn cong dai nhách là gỗ còn tươi ngậm nước.',
        },
        {
          'number': '02',
          'title': 'Cạo phoi bùi nhùi lông vũ (Feather Stick)',
          'diagramType': 'feather_stick',
          'tag': 'CHẺ LÕI GỖ & GỌT PHOI MỎNG',
          'action': 'Dùng dao chẻ đôi khúc gỗ để lấy phần lõi gỗ khô bên trong. Cầm dao nghiêng 15-20 độ, gọt từng lát phoi gỗ mỏng xoăn tít dính liền trên thân que (tạo thành que lông vũ). Các sợi phoi mỏng như cánh hoa sẽ bắt tia lửa cực nhanh từ đá đánh lửa.',
          'keyRule': 'Chuẩn bị tối thiểu 3-5 que phoi lông vũ trước khi quẹt tia lửa đầu tiên.',
          'tip': 'Có thể cạo thêm lớp mùn cưa mịn từ gỗ nhựa thông để làm bùi nhùi mồi lửa nhạy nhất.',
        },
        {
          'number': '03',
          'title': 'Dựng tháp củi tổ chim đón gió thông thoáng',
          'diagramType': 'fire_teepee',
          'tag': 'LÓT ĐẾ GỖ • DỰNG THÁP CHỮ V',
          'action': 'Lót 3 khúc gỗ to dưới nền đất ướt làm bệ chắn ẩm (fire base). Đặt bùi nhùi phoi gỗ ở giữa, xếp các que củi nhỏ bằng que tăm xung quanh thành hình tháp tổ chim (teepee). Chừa một cửa nhỏ đón hướng gió để không khí mang oxy nuôi dưỡng ngọn lửa.',
          'keyRule': 'Quy tắc kích thước củi: Que tăm → Que đũa → Ngón tay → Cổ tay (không vội cho củi to quá sớm làm tắt ngấm khói).',
          'tip': 'Thổi nhẹ nhàng đều đặn vào gốc đốm than đỏ để lửa bùng lên ngọn.',
        },
        {
          'number': '04',
          'title': 'Căng bạt che mưa nghiêng trên cao 2.5m',
          'diagramType': 'fire_tarp',
          'tag': 'BẠT CHE NGHIÊNG THOÁT KHÓI',
          'action': 'Căng một tấm bạt nghiêng ở độ cao tối thiểu 2.2 - 2.5m phía trên đống lửa để che mưa trực tiếp nhưng không bị tàn lửa làm thủng bạt. Nghiêng tấm bạt 30 độ để nước mưa chảy trôi và khói bay thoát ra ngoài.',
          'keyRule': 'Xếp các khúc củi to ẩm xung quanh đống lửa để sức nóng sấy khô củi chuẩn bị đốt tiếp.',
          'tip': 'Luôn giữ một khúc củi cháy than đỏ vùi dưới tro để duy trì mồi lửa cho sáng hôm sau.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG dùng đá cuội ướt nhặt dưới lòng suối để kè quanh đống lửa (nước ngậm trong kẽ đá sôi giãn nở sẽ gây nổ đá văng mảnh cực kỳ nguy hiểm).',
      ],
    },
    {
      'id': 'skill_7',
      'title': 'Sơ cứu gãy xương & Trật khớp cổ chân',
      'category': 'Sơ cứu Y tế',
      'categoryIcon': Icons.healing_outlined,
      'readTime': '5 phút đọc',
      'desc': 'Kỹ thuật nẹp cố định chấn thương chi và bất động khớp cổ chân khi gặp tai nạn trượt ngã dốc đá.',
      'priority': 'NGUY CẤP',
      'accent': AppColors.editorialTerracotta,
      'equipment': [
        '2 cành cây thẳng cứng dài từ đùi đến qua gót chân',
        'Băng thun y tế / Áo thun xé dải làm dây buộc',
        'Khăn mặt mềm / Rêu cỏ mềm làm đệm lót',
        'Gậy leo núi làm điểm tựa di chuyển',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Bất động tại chỗ — Không nắn chỉnh xương',
          'diagramType': 'bone_immobilize',
          'tag': 'GIỮ NGUYÊN TƯ THẾ BIẾN DẠNG',
          'action': 'Giữ nạn nhân nằm yên tại vị trí ngã. TUYỆT ĐỐI KHÔNG cố gắng kéo nắn, bẻ thẳng hoặc ấn xương bị gãy/trật khớp về vị trí cũ (hành động này sẽ làm đầu xương gãy đâm rách mạch máu lớn và dây thần kinh gây sốc chấn thương).',
          'keyRule': 'Cắt bỏ ống quần hoặc giày dép nhẹ nhàng, không giật mạnh làm xê dịch ổ gãy.',
          'tip': 'Nếu là gãy hở có đầu xương chọc ra ngoài da: Tuyệt đối không ấn xương vào, chỉ dùng gạc sạch phủ lên miệng vết thương.',
        },
        {
          'number': '02',
          'title': 'Chêm đệm lá mềm vào các hõm tự nhiên',
          'diagramType': 'cushion_joint',
          'tag': 'CHÊM ĐỆM MỀM HỐ KHỚP',
          'action': 'Dùng khăn khô, áo thun mềm hoặc bọc lá cây sạch chêm vào các hõm hõm cơ thể: sau khoeo chân, mắt cá trong, mắt cá ngoài và háng. Việc này giúp thanh nẹp gỗ ép chặt mà không làm đau buốt các đầu xương tiếp xúc với thanh nẹp.',
          'keyRule': 'Chêm đệm đủ dày ở mắt cá chân để chân không bị xoay vẹo.',
          'tip': 'Giữ bàn chân luôn ở góc vuông 90 độ so với cẳng chân để khớp cổ chân ổn định nhất.',
        },
        {
          'number': '03',
          'title': 'Cố định nẹp bằng 4 dải buộc chắc chắn',
          'diagramType': 'four_tie_splint',
          'tag': '4 DẢI BUỘC CỐ ĐỊNH NẸP',
          'action': 'Đặt 1 nẹp mặt ngoài (từ hông qua mắt cá ngoài) và 1 nẹp mặt trong (từ bẹn qua mắt cá trong). Buộc 4 dải dây mềm: Dải 1 trên khớp gối, Dải 2 dưới ổ gãy, Dải 3 trên ổ gãy, Dải 4 quấn số 8 giữ chặt bàn chân vuông góc với cẳng chân.',
          'keyRule': 'Nút buộc luôn nằm ở mặt ngoài của thanh nẹp, không buộc đè lên vết thương.',
          'tip': 'Kiểm tra mạch mu chân sau khi buộc: nếu ngón chân tê dại hoặc mất cảm giác, nới lỏng dây buộc ngay.',
        },
        {
          'number': '04',
          'title': 'Hỗ trợ di chuyển an toàn bằng cáng võng dù',
          'diagramType': 'hammock_stretcher',
          'tag': 'DI CHUYỂN BẰNG CÁNG KHIÊNG',
          'action': 'Với gãy chân, nạn nhân không được tự đi. Kết hợp võng dù và 2 cây gỗ dài làm cáng khiêng. Nếu chỉ bong gân cổ chân nhẹ, 2 đồng đội có thể quàng tay đỡ nách di chuyển chậm rãi về trạm kiểm lâm.',
          'keyRule': 'Người khiêng cáng phải bước đều nhịp, tránh rung lắc giật cục trên đường dốc.',
          'tip': 'Chườm túi đá lạnh bọc vải lên khớp cổ chân bị bong gân (15 phút/lần) để giảm sưng tức thì.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG bôi dầu nóng, cồn xoa bóp hoặc đắp thuốc lào lên khớp bị trật (dầu nóng làm giãn mao mạch gây xuất huyết sưng nề to hơn).',
      ],
    },
    {
      'id': 'skill_8',
      'title': 'Xử lý say nắng & Kiệt sức do nhiệt (Heat Stroke)',
      'category': 'Sơ cứu Y tế',
      'categoryIcon': Icons.wb_sunny_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Phân biệt và xử lý khẩn cấp kiệt sức vì nhiệt và sốc nhiệt đe dọa tính mạng khi trekking dưới nắng gắt.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.tacticalOrange,
      'equipment': [
        'Khăn mặt bông / Khăn rằn thấm nước suối',
        'Gói bù điện giải Oresol / Nước chanh muối ấm',
        'Quạt nan hoặc mũ rộng vành làm quạt gió',
        'Bạt che nắng tạo bóng râm nhân tạo',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Đưa ngay vào bóng râm & Nới lỏng áo quần',
          'diagramType': 'shade_rest',
          'tag': 'HẠ NHIỆT TRONG BÓNG RÂM',
          'action': 'Ngay khi nạn nhân có biểu hiện hoa mắt, vã mồ hôi đầm đìa hoặc ngưng đổ mồ hôi da nóng bỏng: đưa ngay vào tán cây râm mát hoặc căng bạt chắn nắng. Đặt nạn nhân nằm ngửa, kê chân cao 20-30cm so với tim. Cởi bỏ bớt áo khoác dày, nới lỏng thắt lưng.',
          'keyRule': 'Kê chân cao giúp máu dồn về tim và não bộ chống ngất xỉu.',
          'tip': 'Dùng mũ rộng vành quạt liên tục tạo luồng gió mát lưu thông quanh cơ thể.',
        },
        {
          'number': '02',
          'title': 'Làm mát chủ động bằng nước suối mát',
          'diagramType': 'water_sponge',
          'tag': 'CHƯỜM MÁT TRÁN • CỔ • NÁCH • BẸN',
          'action': 'Vẩy nước mát lên khắp quần áo nạn nhân. Dùng khăn ướt đắp và lau liên tục vào các vị trí tỏa nhiệt nhanh: TRÁN, 2 BÊN CỔ, 2 HỐ NÁCH và BẸN. Quạt gió mạnh để hơi nước bốc hơi nhanh mang theo nhiệt lượng cơ thể thoát ra ngoài.',
          'keyRule': 'Hạ nhiệt độ cơ thể xuống dưới 38.5°C càng nhanh càng tốt để bảo vệ tế bào não.',
          'tip': 'TUYỆT ĐỐI KHÔNG dùng nước đá quá lạnh dội trực tiếp vào đầu vì sẽ gây co thắt mạch máu não đột ngột.',
        },
        {
          'number': '03',
          'title': 'Bù nước điện giải Oresol từng ngụm nhỏ',
          'diagramType': 'sip_oresol',
          'tag': 'BÙ NƯỚC ĐIỆN GIẢI TỪNG NGỤM',
          'action': 'Pha 1 gói Oresol đúng tỉ lệ vào bình nước suối sạch (hoặc nước chanh pha chút muối khoáng). Cho nạn nhân nhấp từng ngụm nhỏ cách nhau 2 phút. Bù nước từ từ giúp cân bằng lại lượng natri và kali đã mất qua tuyến mồ hôi.',
          'keyRule': 'Chỉ cho uống khi nạn nhân hoàn toàn tỉnh táo và tự nuốt được.',
          'tip': 'Không cho uống nước đường quá ngọt hoặc nước tăng lực có ga vì sẽ làm chậm hấp thu nước ở ruột non.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG để nạn nhân tiếp tục đeo balo nặng cố đi tiếp (nguy cơ co giật, hôn mê và tử vong do sốc nhiệt chỉ sau 15 phút).',
      ],
    },
    {
      'id': 'skill_9',
      'title': 'Sơ cứu khi bị ong đốt & Kiến ba khoang',
      'category': 'Sơ cứu Y tế',
      'categoryIcon': Icons.bug_report_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Cách loại bỏ ngòi nọc an toàn, xử lý độc tố axit và phát hiện sớm dấu hiệu sốc phản vệ nguy hiểm.',
      'priority': 'CĂN BẢN',
      'accent': AppColors.editorialTerracotta,
      'equipment': [
        'Thẻ nhựa cứng (thẻ ATM / CCCD / dao cùn)',
        'Bánh xà phòng hoặc dung dịch sát khuẩn',
        'Túi đá lạnh bọc khăn hoặc nước suối lạnh',
        'Thuốc kháng Histamin dị ứng (nếu có trong túi y tế)',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Gạt bỏ ngòi ong bằng mép thẻ nhựa cứng',
          'diagramType': 'scrape_stinger',
          'tag': 'DÙNG THẺ GẠT • KHÔNG NẶN ÉP',
          'action': 'Ngòi ong vò vẽ thường cắm lại túi nọc trên da và tiếp tục co bóp bơm nọc độc trong 2-3 phút sau khi đốt. Đặt mép thẻ ATM hoặc sống dao cùn sát bề mặt da, gạt nhanh ngang qua để hất ngòi nọc bay ra ngoài.',
          'keyRule': 'TUYỆT ĐỐI KHÔNG dùng móng tay hoặc nhíp kẹp bóp vào ngòi ong (hành động này vô tình bóp hết túi độc bơm sâu vào máu).',
          'tip': 'Thao tác gạt dứt khoát chỉ mất 2 giây nhưng giảm 70% lượng độc tố ngấm vào cơ thể.',
        },
        {
          'number': '02',
          'title': 'Rửa sạch vết thương bằng xà phòng kiềm tính',
          'diagramType': 'wash_soap',
          'tag': 'XÀ PHÒNG KIỀM TRUNG HÒA AXIT',
          'action': 'Rửa vết đốt liên tục dưới vòi nước suối chảy cùng xà phòng trong 5 phút. Nọc độc của ong mật có tính axit, tính kiềm của xà phòng sẽ giúp trung hòa độc tố, giảm cảm giác bỏng rát buốt và ngăn ngừa vi khuẩn xâm nhập.',
          'keyRule': 'Với kiến ba khoang: Không đập kiến nát trên da, chỉ thổi bay kiến đi và rửa ngay bằng cồn hoặc xà phòng.',
          'tip': 'Nếu không có xà phòng, có thể dùng dung dịch nước muối loãng hoặc cồn y tế 70 độ.',
        },
        {
          'number': '03',
          'title': 'Chườm lạnh 15 phút & Theo dõi sốc phản vệ',
          'diagramType': 'ice_compress',
          'tag': 'CHƯỜM LẠNH 15 PHÚT GIẢM PHÙ',
          'action': 'Bọc viên đá lạnh vào khăn vải sạch áp nhẹ lên vết sưng trong 15 phút (chườm 15 phút, nghỉ 10 phút). Theo dõi sát nạn nhân trong 30-60 phút. Nếu xuất hiện: KHÓ THỞ, PHÙ MẶT/MÔI, PHÁT BAN ĐỎ TOÀN THÂN → Sốc phản vệ độ 3 đe dọa tính mạng, cần đưa ngay đến trạm y tế gần nhất tiêm Adrenaline.',
          'keyRule': 'Khó thở hoặc nghẹn họng là dấu hiệu cấp cứu tối khẩn cấp.',
          'tip': 'Cho nạn nhân uống 1 viên thuốc chống dị ứng (Cetirizine hoặc Loratadine) nếu có sẵn trong túi sơ cứu.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG bôi vôi sống hoặc đắp bùn đất bẩn lên vết đốt (nguy cơ nhiễm trùng uốn ván và hoại tử da).',
      ],
    },
    {
      'id': 'skill_10',
      'title': 'Kỹ thuật chọn bãi cắm trại & Dựng lều an toàn',
      'category': 'Dựng trại & Dây',
      'categoryIcon': Icons.holiday_village_outlined,
      'readTime': '5 phút đọc',
      'desc': 'Nguyên tắc 4 đúng chọn địa hình cắm trại, tránh lũ quét ngầm, gió giật sập lều và động vật bò sát.',
      'priority': 'CĂN BẢN',
      'accent': AppColors.editorialPine,
      'equipment': [
        'Lều dã ngoại 2 lớp chống mưa ≥ 3000mm',
        'Cọc lều chữ Y nhôm chuyên dụng cắm đất mềm',
        'Xẻng gập dã ngoại đào rãnh thoát nước',
        'Dây néo phản quang ban đêm chống vấp ngã',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Quy tắc 60m & Tránh lòng suối cạn đáy vực',
          'diagramType': 'camp_location',
          'tag': 'CÁCH SUỐI 60M • CAO HƠN MỰC NƯỚC',
          'action': 'Luôn dựng lều cách nguồn nước suối tối thiểu 60m (khoảng 70 bước chân) và nằm ở gờ đồi cao hơn mặt nước suối ít nhất 3-5m. Tuyệt đối KHÔNG cắm trại ở lòng suối cạn đáy thung lũng, vì mưa lớn ở thượng nguồn cách đó 20km có thể sinh ra lũ quét đổ ập về trong tích tắc nửa đêm.',
          'keyRule': 'Nhìn lên vách đá: nếu thấy rác và cỏ khô dính trên cành cây cao, đó là mực nước lũ dâng từng quét qua.',
          'tip': 'Tránh cắm trại sát chân vách đá dựng đứng vì ban đêm nhiệt độ hạ có thể gây sạt lở đá lăn rơi tự do.',
        },
        {
          'number': '02',
          'title': 'Kiểm tra cây cổ thụ & Tránh bẫy sét đánh (Widowmakers)',
          'diagramType': 'check_trees',
          'tag': 'TRÁNH CÂY KHÔ MỤC & CÂY ĐỘC TÔN',
          'action': 'Ngước nhìn lên vòm cây phía trên bãi trại: kiểm tra xem có cành cây khô to mục (gọi là cành tử thần - widowmaker) có nguy cơ gãy đè sập lều khi gió lớn hay không. Tránh dựng lều dưới gốc cây cổ thụ độc tôn đứng chơ vơ trên đỉnh đồi trọc vì đó là cột thu lôi tự nhiên dễ bị sét đánh nhất.',
          'keyRule': 'Khu đất lý tưởng là giữa một cụm cây sống đều nhau, kín gió lùa.',
          'tip': 'Dọn sạch cành cây nhọn, rễ cây trồi và đá sắc nhọn trên mặt đất trước khi trải thảm lót lều.',
        },
        {
          'number': '03',
          'title': 'Đóng cọc góc 45 độ ngược hướng dây néo',
          'diagramType': 'stake_angle',
          'tag': 'CỌC LỀU NGHIÊNG 45 ĐỘ NGƯỢC CHIỀU',
          'action': 'Khi đóng cọc lều vào nền đất cỏ, luôn đóng cọc nghiêng một góc 45 độ hướng ra ngoài xa so với lều (ngược lại hướng kéo của dây néo). Góc nghiêng này tận dụng tối đa lực ghì ma sát của lòng đất, ngăn cọc bị bật bung khi gió giật cấp 6-7 về đêm.',
          'keyRule': 'Căng toàn bộ các dây néo chống gió của lớp phủ ngoài (rainfly) để bạt không chạm lớp trong làm ngấm nước.',
          'tip': 'Nếu đất cát quá mềm: chèn thêm một hòn đá to đè chặt lên đầu cọc cắm đất.',
        },
        {
          'number': '04',
          'title': 'Đào rãnh thoát nước quanh lều & Cất đồ ăn',
          'diagramType': 'trench_food',
          'tag': 'RÃNH THOÁT NƯỚC & CẤT THỰC PHẨM',
          'action': 'Dùng xẻng nhỏ đào một rãnh thoát nước sâu 10-15cm viền xung quanh mép bạt lều, dẫn dòng chảy về phía dốc thoải thấp hơn. Cất toàn bộ thức ăn thừa vào túi ziplock kín mùi và treo lên cành cây cách lều 20m để tránh thu hút chuột rừng, rắn rết hoặc thú săn mồi mò vào lều ban đêm.',
          'keyRule': 'Luôn kéo kín lưới chống muỗi của cửa lều mỗi khi ra vào.',
          'tip': 'Rắc một vòng tro bếp nguội hoặc bột tỏi xung quanh chân lều để xua đuổi côn trùng và bò sát hiệu quả.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG đốt nến, đun bếp gas hoặc mang than củi vào đóng kín cửa lều (khí độc CO không màu không mùi sẽ gây ngạt thở tử vong trong giấc ngủ).',
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_bookmarkedIds.contains(id)) {
        _bookmarkedIds.remove(id);
      } else {
        _bookmarkedIds.add(id);
      }
    });
  }

  List<Map<String, dynamic>> get _filteredSkills {
    return _skillsList.where((item) {
      final matchCat = _selectedCategory == 'Tất cả' || item['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          (item['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item['desc'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  /// Khung hình ảnh đồ họa trực quan minh họa đúng từng dòng thao tác
  Widget _buildStepVisualCard(Map<String, dynamic> step, Color accent) {
    final diagramType = step['diagramType'] as String? ?? '';
    final number = step['number'] as String? ?? '01';
    final title = step['title'] as String? ?? '';
    final tag = step['tag'] as String? ?? 'THAO TÁC KỸ THUẬT';
    final keyRule = step['keyRule'] as String? ?? '';

    IconData visualIcon = Icons.medical_services_outlined;
    String visualMetric = 'Chuẩn quốc tế';
    Color themeColor = accent;
    String annotationText = 'Thao tác chuẩn xác';

    if (diagramType == 'immobilize_limb') {
      visualIcon = Icons.accessibility_new;
      visualMetric = 'Vị trí: < Tim 15cm';
      annotationText = 'Hạ thấp cánh tay/chân dưới mức tim • Tháo ngay trang sức';
    } else if (diagramType == 'pressure_wrap') {
      visualIcon = Icons.healing;
      visualMetric = 'Độ chặt: 40-70 mmHg';
      annotationText = 'Quấn xoắn ốc từ ngón lên đùi • Để hở đầu ngón tay/chân';
    } else if (diagramType == 'splint_joint') {
      visualIcon = Icons.view_column;
      visualMetric = 'Khóa: 2 khớp liền kề';
      annotationText = 'Nẹp cố định qua khớp gối & cổ chân • Dây buộc 4 điểm';
    } else if (diagramType == 'stretcher_carry') {
      visualIcon = Icons.airline_seat_flat;
      visualMetric = 'Tư thế: Nằm ngang 180°';
      annotationText = 'Cáng võng dù 2 người khiêng • Giữ đầu hơi nâng cao nhẹ';
    } else if (diagramType == 'wind_shelter') {
      visualIcon = Icons.holiday_village;
      visualMetric = 'Gió lùa: 0 km/h';
      annotationText = 'Căng bạt che kín 360° • Lót thảm cách nhiệt dưới sàn';
    } else if (diagramType == 'strip_wet_cloth') {
      visualIcon = Icons.dry_cleaning;
      visualMetric = 'Giữ nhiệt: 90% bức xạ';
      annotationText = 'Cởi sạch đồ ướt • Bọc chăn nhôm phản xạ • Đội mũ len';
    } else if (diagramType == 'core_warming') {
      visualIcon = Icons.favorite;
      visualMetric = 'Nhiệt độ: 40 - 42°C';
      annotationText = 'Áp túi ấm vào 4 động mạch lớn: Cổ • Ngực • Nách • Bẹn';
    } else if (diagramType == 'warm_sip') {
      visualIcon = Icons.local_cafe;
      visualMetric = 'Khoảng cách: 2-3 phút/ngụm';
      annotationText = 'Uống từng ngụm nhỏ nước đường gừng ấm • Không uống ừng ực';
    } else if (diagramType == 'reef_knot') {
      visualIcon = Icons.all_inclusive;
      visualMetric = 'Tải trọng: Nối 2 đầu dây';
      annotationText = 'Phải qua Trái quấn 1 vòng • Trái qua Phải quấn 1 vòng';
    } else if (diagramType == 'bowline_knot') {
      visualIcon = Icons.loop;
      visualMetric = 'Độ an toàn: 100% không thít';
      annotationText = 'Thỏ ra khỏi hang • Vòng sau thân cây • Chui lại vào hang';
    } else if (diagramType == 'tautline_knot') {
      visualIcon = Icons.tune;
      visualMetric = 'Tự khóa: Ma sát trượt';
      annotationText = 'Quấn 2 vòng trong • 1 vòng ngoài • Trượt chỉnh căng lều';
    } else if (diagramType == 'figure8_knot') {
      visualIcon = Icons.looks_two;
      visualMetric = 'Độ bền dây: 80%';
      annotationText = 'Vòng qua thân dây chính • Xỏ qua vòng khuyên tạo số 8';
    } else if (diagramType == 'clove_hitch') {
      visualIcon = Icons.anchor;
      visualMetric = 'Neo cọc: Siêu tốc';
      annotationText = '2 vòng chéo ôm thân cây • Luồn đầu dây siết ma sát ghì';
    } else if (diagramType == 'water_source') {
      visualIcon = Icons.waves;
      visualMetric = 'Tốc độ: Nước chảy liên tục';
      annotationText = 'Chọn nước chảy qua ghềnh đá • Lắng cặn cát 15 phút';
    } else if (diagramType == 'filter_column') {
      visualIcon = Icons.filter_alt;
      visualMetric = 'Cấu tạo: 4 Tầng phân lớp';
      annotationText = 'Sỏi thô (3cm) → Cát mịn (5cm) → Than hoạt tính (8cm) → Vải bông';
    } else if (diagramType == 'boil_sanitize') {
      visualIcon = Icons.whatshot;
      visualMetric = 'Thời gian: ≥ 3 - 5 phút';
      annotationText = 'Đun sôi sùng sục ≥ 3 phút hoặc 1 viên Aquatabs / 2L';
    } else if (diagramType == 'stop_step') {
      visualIcon = Icons.pan_tool;
      visualMetric = 'Tín hiệu: 3 hồi còi dài';
      annotationText = 'Dừng ngay lập tức • Hít thở sâu 10 nhịp • Thổi còi SOS';
    } else if (diagramType == 'think_step') {
      visualIcon = Icons.psychology;
      visualMetric = 'GPS Offline: Travel App';
      annotationText = 'Hồi tưởng điểm mốc cũ • Mở tọa độ GPS trên bản đồ đã lưu';
    } else if (diagramType == 'observe_step') {
      visualIcon = Icons.visibility;
      visualMetric = 'Thời gian chốt: < 16h30';
      annotationText = 'Xác định hướng mặt trời • Tìm đất cao ráo • Tránh lòng suối';
    } else if (diagramType == 'plan_step') {
      visualIcon = Icons.mode_standby;
      visualMetric = '3 đống lửa: Tín hiệu SOS';
      annotationText = 'Dựng trại trước 17h • Đốt 3 đống lửa tam giác tạo khói cứu nạn';
    } else if (diagramType == 'find_dry_wood') {
      visualIcon = Icons.forest;
      visualMetric = 'Vị trí: Cành chết trên cao';
      annotationText = 'Bẻ cành khô trên cây đứng • Tìm lõi gỗ thông chứa dầu thơm';
    } else if (diagramType == 'feather_stick') {
      visualIcon = Icons.content_cut;
      visualMetric = 'Góc dao: Nghiêng 15-20°';
      annotationText = 'Gọt phoi mỏng lông vũ xoăn tít dính trên que để bắt tia lửa';
    } else if (diagramType == 'fire_teepee') {
      visualIcon = Icons.local_fire_department;
      visualMetric = 'Thứ tự: Tăm → Đũa → Ngón';
      annotationText = 'Lót đế gỗ chắn ẩm đất • Dựng tháp củi tổ chim đón hướng gió';
    } else if (diagramType == 'fire_tarp') {
      visualIcon = Icons.roofing;
      visualMetric = 'Chiều cao: ≥ 2.2 - 2.5m';
      annotationText = 'Căng bạt nghiêng 30 độ thoát khói • Tránh tàn lửa thủng bạt';
    } else if (diagramType == 'bone_immobilize') {
      visualIcon = Icons.airline_seat_recline_extra;
      visualMetric = 'Nguyên tắc: Giữ nguyên tư thế';
      annotationText = 'Không nắn bẻ xương • Cắt bỏ ống quần/giày nhẹ nhàng';
    } else if (diagramType == 'cushion_joint') {
      visualIcon = Icons.layers;
      visualMetric = 'Bàn chân: Vuông góc 90°';
      annotationText = 'Chêm khăn lá mềm vào khoeo chân & 2 mắt cá tránh đau buốt';
    } else if (diagramType == 'four_tie_splint') {
      visualIcon = Icons.format_line_spacing;
      visualMetric = '4 Dải buộc: Ngoài nẹp';
      annotationText = '2 nẹp gỗ kẹp 2 bên • Buộc 4 dải: Đùi • Dưới gối • Cẳng • Bàn chân';
    } else if (diagramType == 'hammock_stretcher') {
      visualIcon = Icons.transfer_within_a_station;
      visualMetric = 'Tốc độ: Bước đều nhịp';
      annotationText = 'Dùng võng dù & 2 cây gỗ làm cáng di chuyển người nằm ngang';
    } else if (diagramType == 'shade_rest') {
      visualIcon = Icons.wb_sunny;
      visualMetric = 'Kê chân: Cao 20-30cm';
      annotationText = 'Đưa vào bóng râm mát • Cởi áo dày • Kê cao chân chống ngất xỉu';
    } else if (diagramType == 'water_sponge') {
      visualIcon = Icons.dew_point;
      visualMetric = 'Mục tiêu: < 38.5°C';
      annotationText = 'Lau khăn ướt liên tục vào trán, cổ, nách, bẹn kết hợp quạt mát';
    } else if (diagramType == 'sip_oresol') {
      visualIcon = Icons.local_drink;
      visualMetric = 'Tần suất: 2 phút/ngụm';
      annotationText = 'Pha Oresol đúng tỉ lệ • Uống từng ngụm nhỏ bù natri và kali';
    } else if (diagramType == 'scrape_stinger') {
      visualIcon = Icons.credit_card;
      visualMetric = 'Thời gian: Trong 2-3 phút';
      annotationText = 'Dùng mép thẻ cứng gạt ngang ngòi ong • Tuyệt đối không kẹp bóp';
    } else if (diagramType == 'wash_soap') {
      visualIcon = Icons.soap;
      visualMetric = 'Thời gian: Xối 5 phút';
      annotationText = 'Rửa xà phòng kiềm tính để trung hòa axit nọc độc ong mật';
    } else if (diagramType == 'ice_compress') {
      visualIcon = Icons.ac_unit;
      visualMetric = 'Chu kỳ: 15p chườm / 10p nghỉ';
      annotationText = 'Bọc đá vào khăn chườm giảm sưng • Theo dõi khó thở phù mặt';
    } else if (diagramType == 'camp_location') {
      visualIcon = Icons.add_location_alt;
      visualMetric = 'Khoảng cách: ≥ 60 mét';
      annotationText = 'Cách dòng suối 60m • Trên gờ đồi cao hơn mặt nước 3-5m tránh lũ';
    } else if (diagramType == 'check_trees') {
      visualIcon = Icons.park;
      visualMetric = 'Kiểm tra: Vòm cây trên cao';
      annotationText = 'Tránh cành cây khô mục gãy rơi • Tránh cây cổ thụ đứng độc tôn';
    } else if (diagramType == 'stake_angle') {
      visualIcon = Icons.straighten;
      visualMetric = 'Góc cọc: Nghiêng 45°';
      annotationText = 'Đóng cọc nghiêng 45° ngược chiều dây néo để tăng lực ma sát ghì';
    } else if (diagramType == 'trench_food') {
      visualIcon = Icons.kitchen;
      visualMetric = 'Treo đồ ăn: Cách lều 20m';
      annotationText = 'Đào rãnh thoát nước sâu 15cm • Treo túi đồ ăn lên cành cây cao';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.editorialSurfaceAlt,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.editorialBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A17221B),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header Banner của hình ảnh minh họa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.12),
              border: Border(bottom: BorderSide(color: AppColors.editorialBorderSubtle)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: AppRadius.roundedPill,
                      ),
                      child: Text(
                        'BƯỚC $number',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.roundedSm,
                    border: Border.all(color: AppColors.editorialBorder),
                  ),
                  child: Text(
                    visualMetric,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.editorialInk,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Illustration Showcase Visual Box
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.editorialSurfaceSubtle.withValues(alpha: 0.6),
                  AppColors.editorialSurfaceAlt,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background subtle circular grid pattern
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 1.5),
                  ),
                ),
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeColor.withValues(alpha: 0.15),
                    border: Border.all(color: themeColor.withValues(alpha: 0.35), width: 2),
                  ),
                ),

                // Center Main Dynamic Vector Graphic
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(visualIcon, size: 44, color: themeColor),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: AppRadius.roundedPill,
                          border: Border.all(color: AppColors.editorialBorder),
                        ),
                        child: Text(
                          annotationText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: themeColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Corner indicators
                Positioned(
                  top: 8,
                  left: 12,
                  child: Text(
                    'SƠ ĐỒ HÌNH ẢNH MINH HỌA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.editorialMuted.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 12,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 12, color: themeColor),
                      const SizedBox(width: 4),
                      const Text(
                        'Đúng kỹ thuật',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.editorialInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Step Title & Action Guide
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.editorialInk,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Key Rule Box
                if (keyRule.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.editorialSurface,
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(color: AppColors.editorialBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.stars, size: 14, color: themeColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            keyRule,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.editorialInk,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openArticleDetail(Map<String, dynamic> skill) {
    final accent = skill['accent'] as Color;
    final equipment = (skill['equipment'] as List<dynamic>?) ?? [];
    final steps = (skill['steps'] as List<dynamic>?) ?? [];
    final donts = (skill['donts'] as List<dynamic>?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.editorialBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.96,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.editorialBorder,
                        borderRadius: AppRadius.roundedPill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category & Status Ribbon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedPill,
                          border: Border.all(color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          skill['category'] as String,
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.editorialSurface,
                          borderRadius: AppRadius.roundedPill,
                          border: Border.all(color: AppColors.editorialBorder),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.offline_pin, size: 13, color: AppColors.editorialPine),
                            SizedBox(width: 4),
                            Text(
                              'Đã lưu sẵn trên máy',
                              style: TextStyle(
                                color: AppColors.editorialInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Article Headline
                  Text(
                    skill['title'] as String,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.editorialInk,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    skill['desc'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.editorialMuted,
                      height: 1.5,
                    ),
                  ),

                  // Required Equipment Checklist
                  if (equipment.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text(
                      'DỤNG CỤ CẦN CHUẨN BỊ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.editorialPine,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: equipment.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurface,
                            borderRadius: AppRadius.roundedMd,
                            border: Border.all(color: AppColors.editorialBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 15, color: AppColors.editorialPine),
                              const SizedBox(width: 6),
                              Text(
                                item.toString(),
                                style: const TextStyle(
                                  color: AppColors.editorialInk,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Steps with Instructional Diagrams
                  const Text(
                    'QUY TRÌNH THỰC HIỆN TỪNG BƯỚC (KÈM HÌNH ẢNH MINH HỌA)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppColors.editorialPine,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...steps.map((s) {
                    final stepMap = s as Map<String, dynamic>;
                    final tip = stepMap['tip'] as String?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.editorialBorder, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C17221B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Khung hình ảnh minh họa chi tiết cho đúng từng bước
                          _buildStepVisualCard(stepMap, accent),
                          const SizedBox(height: 14),

                          // 2. Chi tiết từng dòng thao tác hành động
                          const Text(
                            'HƯỚNG DẪN THAO TÁC CHI TIẾT:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.editorialMuted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            stepMap['action'] as String,
                            style: const TextStyle(
                              color: AppColors.editorialInk,
                              height: 1.6,
                              fontSize: 13.5,
                            ),
                          ),

                          // 3. Pro-tip Callout
                          if (tip != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.editorialSurfaceAlt,
                                borderRadius: AppRadius.roundedSm,
                                border: Border.all(color: AppColors.editorialBorderSubtle),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.editorialTerracotta),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Mẹo thực chiến: $tip',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.editorialMuted,
                                        height: 1.45,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  // Warning / Don'ts Section
                  if (donts.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'ĐIỀU CẤM KỴ TUYỆT ĐỐI (NGUY HIỂM TÍNH MẠNG)',
                                style: TextStyle(
                                  color: AppColors.emergencyRed,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...donts.map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('✕ ', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Expanded(
                                      child: Text(
                                        d.toString(),
                                        style: const TextStyle(
                                          color: Color(0xFF991B1B),
                                          fontSize: 12,
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Completion Action Button
                  BouncingButton(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.editorialPine,
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Tôi Đã Nắm Rõ Quy Trình Này',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Tất cả', 'Sơ cứu Y tế', 'Sinh tồn thời tiết', 'Dựng trại & Dây', 'Nước sạch', 'Định hướng', 'Kỹ năng sinh tồn'];
    final filtered = _filteredSkills;

    return Scaffold(
      backgroundColor: AppColors.editorialBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 16, AppSpacing.space16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.editorialSurface,
                            borderRadius: AppRadius.roundedPill,
                            border: Border.all(color: AppColors.editorialBorder),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.offline_pin, size: 14, color: AppColors.editorialPine),
                              SizedBox(width: 6),
                              Text(
                                'Cẩm nang lưu sẵn ngoại tuyến (10 chủ đề)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.editorialInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_bookmarkedIds.length} bài đã lưu',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.editorialTerracotta,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Cẩm Nang Sinh Tồn',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.editorialInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sơ cứu khẩn cấp, kỹ năng dã ngoại & sinh tồn thực chiến rừng sâu',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.editorialMuted,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Search input
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: AppColors.editorialBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0617221B),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.editorialInk, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm bài sơ cứu rắn cắn, hạ thân nhiệt, nút dây, nhóm lửa...',
                          hintStyle: const TextStyle(color: AppColors.editorialMuted, fontSize: 12),
                          prefixIcon: const Icon(Icons.search, color: AppColors.editorialPine, size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16, color: AppColors.editorialMuted),
                                  onPressed: () => setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }),
                                )
                              : null,
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Category Selector Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: BouncingButton(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedCategory = cat);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.editorialPine : AppColors.editorialSurface,
                            borderRadius: AppRadius.roundedPill,
                            border: Border.all(
                              color: isSelected ? AppColors.editorialPine : AppColors.editorialBorder,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.editorialInk,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Quick Emergency Banner
            if (_selectedCategory == 'Tất cả' && _searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: AppColors.editorialTerracotta, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'SƠ CỨU CẤP TỐC (ƯU TIÊN HÀNG ĐẦU)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: AppColors.editorialTerracotta,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: BouncingButton(
                              onTap: () => _openArticleDetail(_skillsList[0]),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.editorialSurface,
                                  borderRadius: AppRadius.roundedMd,
                                  border: Border.all(color: AppColors.editorialTerracotta.withValues(alpha: 0.4), width: 1.2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0817221B),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.medical_services_outlined, size: 16, color: AppColors.editorialTerracotta),
                                        Spacer(),
                                        Text('4m', style: TextStyle(color: AppColors.editorialTerracotta, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'RẮN ĐỘC CẮN',
                                      style: TextStyle(color: AppColors.editorialInk, fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Băng ép & nẹp 2 khớp',
                                      style: TextStyle(color: AppColors.editorialMuted, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BouncingButton(
                              onTap: () => _openArticleDetail(_skillsList[1]),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.editorialSurface,
                                  borderRadius: AppRadius.roundedMd,
                                  border: Border.all(color: AppColors.editorialPine.withValues(alpha: 0.4), width: 1.2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0817221B),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.ac_unit_outlined, size: 16, color: AppColors.editorialPine),
                                        Spacer(),
                                        Text('4m', style: TextStyle(color: AppColors.editorialPine, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'HẠ THÂN NHIỆT',
                                      style: TextStyle(color: AppColors.editorialInk, fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Ủ ấm 4 điểm vàng',
                                      style: TextStyle(color: AppColors.editorialMuted, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],

            // Skills Card List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final skill = filtered[index];
                    final isBookmarked = _bookmarkedIds.contains(skill['id']);
                    final Color accent = skill['accent'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.editorialBorder, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A17221B),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _openArticleDetail(skill),
                          borderRadius: AppRadius.roundedLg,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '#${index < 9 ? '0' : ''}${index + 1}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                            color: accent,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: accent.withValues(alpha: 0.12),
                                            borderRadius: AppRadius.roundedPill,
                                          ),
                                          child: Text(
                                            skill['priority'] as String,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: accent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          skill['readTime'] as String,
                                          style: const TextStyle(fontSize: 11, color: AppColors.editorialMuted),
                                        ),
                                        const SizedBox(width: 8),
                                        BouncingButton(
                                          onTap: () => _toggleBookmark(skill['id'] as String),
                                          child: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                            color: isBookmarked ? AppColors.editorialTerracotta : AppColors.editorialMuted,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  skill['title'] as String,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.editorialInk,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  skill['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.editorialMuted,
                                    height: 1.45,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.photo_library_outlined, size: 14, color: accent),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Xem ${((skill['steps'] as List<dynamic>?) ?? []).length} bước có hình minh họa →',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: accent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(Icons.arrow_forward, size: 14, color: accent),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
