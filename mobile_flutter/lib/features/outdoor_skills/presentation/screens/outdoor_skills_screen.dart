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
  final Set<String> _bookmarkedIds = {'skill_1', 'skill_2'};

  final List<Map<String, dynamic>> _skillsList = [
    {
      'id': 'skill_1',
      'title': 'Sơ cứu khi bị rắn độc cắn',
      'category': 'Sơ cứu Y tế',
      'categoryIcon': Icons.medical_services_outlined,
      'readTime': '3 phút đọc',
      'desc': 'Quy tắc vàng bất động & băng ép bảo toàn tính mạng khi gặp tai nạn rắn cắn trong rừng sâu.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.editorialTerracotta,
      'equipment': [
        'Cuộn băng thun y tế (hoặc dải vải sạch rộng 10cm)',
        '2 thanh gỗ/tre thẳng làm nẹp cố định',
        'Dây vải mềm buộc nẹp',
        'Còi cứu nạn đa tần số',
      ],
      'steps': [
        {
          'number': '01',
          'title': 'Trấn an & Hạ thấp chi bị cắn',
          'diagramType': 'immobilize_limb',
          'action': 'Yêu cầu nạn nhân nằm yên bất động TUYỆT ĐỐI. Sự hoảng sợ làm tim đập nhanh sẽ thúc đẩy nọc độc theo dòng bạch huyết đi khắp cơ thể. Đặt chân/tay bị cắn ở vị trí THẤP HƠN TIM. Tháo ngay đồng hồ, nhẫn, vòng và giày trước khi chi bắt đầu sưng phù.',
          'keyRule': 'Tuyệt đối không để nạn nhân tự di chuyển dù chỉ một bước.',
          'tip': 'Dùng điện thoại chụp ảnh con rắn từ khoảng cách an toàn (trên 2m) để bác sĩ xác định đúng huyết thanh. Không đuổi đánh hoặc cầm nắm rắn.',
        },
        {
          'number': '02',
          'title': 'Kỹ thuật băng ép bản rộng (Pressure Immobilization)',
          'diagramType': 'pressure_wrap',
          'action': 'Dùng cuộn băng thun quấn từ đầu ngón tay/ngón chân hướng ngược dần lên phía gốc chi (vượt qua vết cắn 15cm). Lực quấn chặt vừa phải tương đương khi băng sơ cứu bong gân cổ chân. Chú ý ĐỂ HỞ ĐẦU CÁC NGÓN để theo dõi lưu thông máu.',
          'keyRule': 'Kiểm tra mạch mu chân/cổ tay: nếu không sờ thấy mạch nghĩa là quấn quá chặt, cần nới lỏng nhẹ.',
          'tip': 'Nếu ngón tay/chân chuyển màu tím tái hoặc lạnh buốt, nới lỏng băng ép ngay lập tức.',
        },
        {
          'number': '03',
          'title': 'Nẹp cố định toàn bộ khớp xương',
          'diagramType': 'splint_joint',
          'action': 'Đặt 2 thanh nẹp nẹp dọc 2 bên chi bị thương (vượt qua cả 2 khớp liền kề vết thương, ví dụ qua khớp gối và cổ chân). Dùng dây buộc cố định để nạn nhân không thể co gập khớp (cử động cơ bắp là nguyên nhân chính đẩy nọc độc vào tuần hoàn).',
          'keyRule': 'Khóa bất động cả khớp trên và khớp dưới của vị trí vết cắn.',
          'tip': 'Chèn thêm lớp cỏ mềm hoặc áo thun giữa cành gỗ và da để tránh trầy xước mô mềm khi vận chuyển.',
        },
        {
          'number': '04',
          'title': 'Khiêng cáng di chuyển cấp cứu khẩn cấp',
          'diagramType': 'stretcher_carry',
          'action': 'Dùng võng dù, bạt dã ngoại hoặc 2 cây tre kết hợp luồn áo khoác làm cáng khiêng nạn nhân. Giữ đầu nạn nhân hơi nâng cao nhẹ. Vận chuyển khẩn trương đến cơ sở y tế huyện hoặc tỉnh có sẵn huyết thanh kháng nọc.',
          'keyRule': 'Luôn khiêng bằng cáng — nạn nhân đi bộ sẽ tăng tốc độ nhiễm độc lên gấp 5 lần.',
          'tip': 'Ghi nhớ hoặc viết thời gian bị cắn lên mu bàn tay nạn nhân để bác sĩ theo dõi diễn tiến.',
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
      'desc': 'Quy trình phục hồi thân nhiệt an toàn khi leo núi gặp mưa dầm, gió rét và hạ nhiệt độ về đêm.',
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
          'title': 'Di chuyển vào nơi chắn gió tuyệt đối',
          'diagramType': 'wind_shelter',
          'action': 'Gió lùa và hơi ẩm làm mất nhiệt cơ thể nhanh gấp 25 lần không khí khô. Đưa ngay người bị nạn vào lều khô ráo, vách đá khuất gió hoặc căng bạt chắn triệt để gió lùa 360 độ.',
          'keyRule': 'Lót thảm cách nhiệt hoặc cành lá khô dày dưới sàn — không nằm trực tiếp lên nền đất ẩm lạnh.',
          'tip': 'Đóng kín tất cả các cửa thông gió của lều trong 30 phút đầu tiên.',
        },
        {
          'number': '02',
          'title': 'Cởi bỏ đồ ướt & Bọc chăn nhôm phản xạ',
          'diagramType': 'strip_wet_cloth',
          'action': 'Nhanh chóng lột bỏ toàn bộ quần áo ướt sũng. Dùng khăn khô thấm nhẹ nước trên da (không chà xát mạnh). Thay ngay đồ khô ấm và đội mũ len che kín vùng đầu (đầu là nơi thất thoát tới 40% nhiệt lượng của cơ thể). Bọc chăn nhôm cứu sinh ra ngoài cùng.',
          'keyRule': 'Đội mũ len khô ấm cho nạn nhân ngay khi cởi đồ ướt.',
          'tip': 'Chăn nhôm phản xạ 90% bức xạ nhiệt cơ thể phát ra trở lại cơ thể.',
        },
        {
          'number': '03',
          'title': 'Ủ ấm trung tâm: 4 điểm vàng mạch máu',
          'diagramType': 'core_warming',
          'action': 'Cho nạn nhân vào túi ngủ khô. Dùng các bình nước ấm bọc trong khăn vải (khoảng 40-42°C) áp nhẹ vào 4 vị trí vàng: 2 bên CỔ, NGỰC TRUNG TÂM, 2 HỐ NÁCH và 2 BẸN ĐÙI. Đây là nơi có các động mạch lớn vận chuyển máu ấm nhanh nhất vào tim và não.',
          'keyRule': 'TUYỆT ĐỐI KHÔNG chườm ấm trực tiếp vào bàn tay/chân (gây sốc hạ nhiệt tim đột ngột do máu lạnh dồn về).',
          'tip': 'Có thể áp dụng phương pháp da tiếp da (ôm giữ nhiệt) nếu không có đủ đồ sưởi ấm.',
        },
        {
          'number': '04',
          'title': 'Bổ sung năng lượng nước đường gừng ấm',
          'diagramType': 'warm_sip',
          'action': 'Nếu nạn nhân còn tỉnh táo và có phản xạ nuốt bình thường, cho uống từng ngụm nhỏ nước ấm pha mật ong, đường glucose hoặc trà gừng để bổ sung calo cho cơ thể tự tạo nhiệt.',
          'keyRule': 'Nếu nạn nhân lơ mơ hoặc bất tỉnh, KHÔNG ĐƯỢC cho uống nước (nguy cơ sặc vào phổi).',
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
      'title': '3 Nút dây dã ngoại căn bản',
      'category': 'Dựng trại & Dây',
      'categoryIcon': Icons.gesture_outlined,
      'readTime': '5 phút đọc',
      'desc': '3 nút dây cốt lõi bảo đảm lều trại vững chãi trước dông bão và neo người an toàn khi vượt suối dốc.',
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
          'action': 'Quy tắc vàng: "Phải qua trái rồi vòng — Trái qua phải rồi vòng". Đặt đầu dây phải bắt chéo lên đầu dây trái, quấn 1 vòng. Sau đó lấy đầu dây trái bắt chéo lên đầu dây phải, quấn 1 vòng rồi kéo siết chặt. Hai vòng dây lồng vào nhau cân xứng.',
          'keyRule': 'Chỉ dùng nối 2 sợi dây có cùng tiết diện và chất liệu.',
          'tip': 'Để tháo nút siêu nhanh: Giật mạnh một đầu dây tự do, nút sẽ tự bung ra mà không bị kẹt.',
        },
        {
          'number': '02',
          'title': 'Nút thòng lọng (Bowline) — Vua của các nút dây',
          'diagramType': 'bowline_knot',
          'action': 'Tạo một vòng khuyên cố định không bao giờ bị thít chặt dù chịu tải trọng hàng trăm kg. Câu thần chú: "Thỏ chui lên khỏi hang, vòng qua gốc cây đại thụ, rồi chui ngược lại vào hang". Tạo vòng khuyên nhỏ, luồn đầu dây từ dưới lên, vòng sau thân dây chính rồi xỏ ngược lại lỗ tròn, kéo siết.',
          'keyRule': 'Nút neo chịu tải an toàn số 1 thế giới — rất dễ tháo dù vừa kéo tải cực nặng.',
          'tip': 'Dùng làm vòng cứu sinh quấn quanh người khi hỗ trợ vượt suối hoặc neo võng vào thân cây to.',
        },
        {
          'number': '03',
          'title': 'Nút tăng đơ (Taut-line Hitch) — Căng dây lều tự động',
          'diagramType': 'tautline_knot',
          'action': 'Vòng dây qua cọc cắm đất. Quấn đầu dây 2 vòng bên trong lòng dây chính hướng về phía cọc lều. Sau đó vòng tiếp 1 vòng bên ngoài về phía lều rồi thắt nút khóa. Nút này ma sát tự khóa nhưng có thể dùng tay trượt lên xuống để chỉnh độ chùng căng của dây lều.',
          'keyRule': 'Trời mưa dây lều bị giãn, chỉ cần dùng ngón tay đẩy nút trượt lên là dây căng lại ngay.',
          'tip': 'Không cần phải tháo cọc cắm lại mỗi khi gió giật làm chùng bạt.',
        },
      ],
      'donts': [
        'Không dùng dây thừng đã sờn vỏ lõi hoặc bị mục ẩm để căng võng ngủ qua đêm trên cao.',
      ],
    },
    {
      'id': 'skill_4',
      'title': 'Khử trùng & Lọc nước sinh tồn',
      'category': 'Nước sạch',
      'categoryIcon': Icons.water_drop_outlined,
      'readTime': '4 phút đọc',
      'desc': 'Cách chế tạo cột lọc 4 tầng tự nhiên và phương pháp khử trùng nguồn nước suối rừng an toàn.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.editorialTerracotta,
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
          'title': 'Thu thập nguồn nước suối chảy',
          'diagramType': 'water_source',
          'action': 'Luôn lấy nước ở nơi có dòng nước chảy liên tục qua các gờ đá, nước trong suốt. Tránh lấy nước ở các vũng nước tù đọng có rêu xanh hoặc gần xác động vật thối rữa ở thượng nguồn.',
          'keyRule': 'Nước suối dù trong vắt vẫn chứa vi khuẩn E.coli và ký sinh trùng Giardia gây tiêu chảy cấp.',
          'tip': 'Hứng nước vào bình chứa, để yên 15-20 phút cho bùn cát lắng xuống đáy trước khi bắt đầu lọc.',
        },
        {
          'number': '02',
          'title': 'Thiết lập cột lọc tự nhiên 4 tầng',
          'diagramType': 'filter_column',
          'action': 'Lộn ngược chai nhựa cắt đáy. Tầng 1 (dưới cùng sát nắp chai có đục lỗ): Lót lớp vải bông sạch. Tầng 2: Lớp than củi nghiền nhỏ dày 6-8cm (than hoạt tính hấp phụ độc chất và mùi hôi). Tầng 3: Lớp cát sông mịn sạch dày 5cm. Tầng 4 (trên cùng): Lớp sỏi đá nhỏ để ngăn cát bị xáo trộn khi rót nước.',
          'keyRule': 'Rót nước nhẹ nhàng vào cột lọc, bỏ nước của 2-3 mẻ đầu tiên cho đến khi nước chảy ra trong veo.',
          'tip': 'Cột lọc chỉ loại bỏ cặn bẩn cơ học và khử mùi, KHÔNG DIỆT ĐƯỢC vi khuẩn siêu vi.',
        },
        {
          'number': '03',
          'title': 'Đun sôi tối thiểu 3 phút hoặc dùng viên Aquatabs',
          'diagramType': 'boil_sanitize',
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
      'title': 'Quy tắc sinh tồn S.T.O.P khi lạc rừng',
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
          'action': 'Ngay khi phát hiện mất dấu đường mòn hoặc lạc đoàn: DỪNG LẠI NGAY LẬP TỨC. Ngồi xuống hít sâu 10 nhịp. Sự hoảng sợ bản năng sẽ thúc giục bạn cắm đầu chạy, và 90% trường hợp chấn thương nặng hoặc tử vong là do lao vào vực sâu trong cơn hoảng loạn.',
          'keyRule': 'Thổi 3 tiếng còi thật dài (Mã cứu nạn quốc tế: 3 hồi còi = SOS). Lắng nghe 1 phút xem có tiếng đáp.',
          'tip': 'Đánh dấu vị trí bạn đang đứng bằng cách buộc dải vải đỏ hoặc xếp cành cây chữ X.',
        },
        {
          'number': '02',
          'title': 'T — THINK: Suy nghĩ và định hình lại',
          'diagramType': 'think_step',
          'action': 'Hồi tưởng lại: Bạn rời đoàn cách đây bao lâu? Điểm mốc quen thuộc cuối cùng bạn thấy là gì (thác nước, cây thông đôi, cột mốc)? Mở ứng dụng Travel App xem vị trí và tọa độ GPS đã lưu trên bộ đệm ngoại tuyến.',
          'keyRule': 'Nếu mới lạc dưới 10 phút, bạn có thể men theo dấu vết cỏ dập để quay lại vị trí ban đầu.',
          'tip': 'Ghi chép lại các thông tin vào điện thoại hoặc sổ tay để giữ bình tĩnh tinh thần.',
        },
        {
          'number': '03',
          'title': 'O — OBSERVE: Quan sát địa hình và thời tiết',
          'diagramType': 'observe_step',
          'action': 'Quan sát mặt trời để định hướng Đông - Tây. Tìm kiếm nguồn nước suối gần đó, mỏm đất cao khô ráo không có nguy cơ sạt lở để trú ẩn. Nếu trời đã sau 16h30 hoặc có mây dông kéo đến, ngừng tìm đường và tập trung toàn lực vào việc trú ẩn.',
          'keyRule': 'TUYỆT ĐỐI KHÔNG đi men theo lòng khe suối hoang dã vì suối nhiệt đới luôn có vực thác dựng đứng 30-50m chắn lối.',
          'tip': 'Địa điểm trú ẩn tốt nhất là lưng chừng đồi, khuất gió và cách nguồn nước 50m.',
        },
        {
          'number': '04',
          'title': 'P — PLAN: Kế hoạch trú ẩn & Tín hiệu cứu hộ',
          'diagramType': 'plan_step',
          'action': 'Dựng lều hoặc căng bạt trú ẩn trước 17h00. Thu gom củi khô dự trữ cho cả đêm. Tạo 3 đống lửa thành hình tam giác ở bãi đất trống (tín hiệu cấp cứu quốc tế). Ban ngày cho thêm lá cây tươi để tạo cột khói trắng dày bốc cao cho trực thăng hoặc đội tìm kiếm cứu nạn.',
          'keyRule': 'Ở YÊN MỘT CHỖ! Đội cứu hộ luôn khoanh vùng tìm kiếm bắt đầu từ điểm bạn được nhìn thấy cuối cùng.',
          'tip': 'Treo áo mưa hoặc bạt màu nổi lên ngọn cây cao để tăng khả năng phát hiện từ xa.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG cố dò đường di chuyển trong bóng đêm (dễ sẩy chân rơi xuống vực hoặc đụng phải thú dữ).',
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

  Widget _buildStepDiagramCard(Map<String, dynamic> step, Color accent) {
    final diagramType = step['diagramType'] as String? ?? '';
    final number = step['number'] as String? ?? '01';
    final title = step['title'] as String? ?? '';
    final keyRule = step['keyRule'] as String? ?? '';

    IconData diagramIcon = Icons.medical_services_outlined;
    String diagramSub = 'Sơ đồ thao tác chuẩn';

    if (diagramType == 'immobilize_limb') {
      diagramIcon = Icons.accessibility_new_outlined;
      diagramSub = 'Quy chuẩn bất động chi thấp hơn tim';
    } else if (diagramType == 'pressure_wrap') {
      diagramIcon = Icons.healing_outlined;
      diagramSub = 'Kỹ thuật băng ép bản rộng hở ngón';
    } else if (diagramType == 'splint_joint') {
      diagramIcon = Icons.view_column_outlined;
      diagramSub = 'Nẹp cố định vượt qua 2 khớp liền kề';
    } else if (diagramType == 'stretcher_carry') {
      diagramIcon = Icons.airline_seat_flat_outlined;
      diagramSub = 'Vận chuyển nạn nhân bằng cáng mềm';
    } else if (diagramType == 'wind_shelter') {
      diagramIcon = Icons.holiday_village_outlined;
      diagramSub = 'Chắn gió lùa 360 độ & lót thảm cách nhiệt';
    } else if (diagramType == 'strip_wet_cloth') {
      diagramIcon = Icons.dry_cleaning_outlined;
      diagramSub = 'Cởi đồ ướt & bọc chăn nhôm phản xạ nhiệt';
    } else if (diagramType == 'core_warming') {
      diagramIcon = Icons.favorite_outline;
      diagramSub = 'Ủ ấm 4 điểm vàng mạch máu trung tâm';
    } else if (diagramType == 'warm_sip') {
      diagramIcon = Icons.local_cafe_outlined;
      diagramSub = 'Bổ sung nước ấm gừng ngụm nhỏ';
    } else if (diagramType == 'reef_knot') {
      diagramIcon = Icons.all_inclusive;
      diagramSub = 'Phải qua Trái • Trái qua Phải';
    } else if (diagramType == 'bowline_knot') {
      diagramIcon = Icons.loop;
      diagramSub = 'Thỏ ra khỏi hang • Vòng qua cây • Vào lại hang';
    } else if (diagramType == 'tautline_knot') {
      diagramIcon = Icons.tune;
      diagramSub = '2 vòng trong • 1 vòng ngoài trượt tự khóa';
    } else if (diagramType == 'water_source') {
      diagramIcon = Icons.waves;
      diagramSub = 'Chọn nước suối chảy liên tục qua gờ đá';
    } else if (diagramType == 'filter_column') {
      diagramIcon = Icons.filter_alt_outlined;
      diagramSub = 'Sỏi nhỏ → Cát mịn → Than hoạt tính → Vải lọc';
    } else if (diagramType == 'boil_sanitize') {
      diagramIcon = Icons.whatshot_outlined;
      diagramSub = 'Đun sôi sùng sục 3-5 phút hoặc Aquatabs';
    } else if (diagramType == 'stop_step') {
      diagramIcon = Icons.pan_tool_outlined;
      diagramSub = 'Dừng lại ngay lập tức • Thổi 3 hồi còi dài';
    } else if (diagramType == 'think_step') {
      diagramIcon = Icons.psychology_outlined;
      diagramSub = 'Hồi tưởng điểm mốc • Kiểm tra tọa độ GPS';
    } else if (diagramType == 'observe_step') {
      diagramIcon = Icons.visibility_outlined;
      diagramSub = 'Quan sát hướng mặt trời • Tránh lòng vực suối';
    } else if (diagramType == 'plan_step') {
      diagramIcon = Icons.mode_standby;
      diagramSub = 'Dựng trại trước 17h • Đốt 3 đống lửa tam giác';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.editorialBg,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.editorialBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedSm,
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Icon(diagramIcon, color: accent, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BƯỚC $number: $title',
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.editorialInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      diagramSub,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (keyRule.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.roundedSm,
                border: Border.all(color: AppColors.editorialBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      keyRule,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.editorialInk,
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
          initialChildSize: 0.88,
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
                    'QUY TRÌNH THỰC HIỆN TỪNG BƯỚC',
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
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.editorialSurface,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.editorialBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Instructional Diagram Card
                          _buildStepDiagramCard(stepMap, accent),
                          const SizedBox(height: 12),

                          // Action text
                          Text(
                            stepMap['action'] as String,
                            style: const TextStyle(
                              color: AppColors.editorialInk,
                              height: 1.55,
                              fontSize: 13,
                            ),
                          ),

                          // Pro-tip Callout
                          if (tip != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.editorialBg,
                                borderRadius: AppRadius.roundedSm,
                                border: Border.all(color: AppColors.editorialBorder),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 15, color: AppColors.editorialTerracotta),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.editorialMuted,
                                        height: 1.4,
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
    const categories = ['Tất cả', 'Sơ cứu Y tế', 'Sinh tồn thời tiết', 'Dựng trại & Dây', 'Nước sạch', 'Định hướng'];
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
                                'Cẩm nang lưu sẵn ngoại tuyến',
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
                      'Sơ cứu khẩn cấp, kỹ năng dã ngoại & thoát hiểm trong rừng sâu',
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
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColors.editorialInk, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm bài sơ cứu rắn cắn, hạ thân nhiệt, nút dây...',
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
                            'SƠ CỨU CẤP TỐC',
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
                                  border: Border.all(color: AppColors.editorialTerracotta.withValues(alpha: 0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.medical_services_outlined, size: 16, color: AppColors.editorialTerracotta),
                                        Spacer(),
                                        Text('3m', style: TextStyle(color: AppColors.editorialTerracotta, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'RẮN ĐỘC CẮN',
                                      style: TextStyle(color: AppColors.editorialInk, fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Băng ép & nẹp cố định',
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
                                  border: Border.all(color: AppColors.editorialPine.withValues(alpha: 0.4)),
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
                        border: Border.all(color: AppColors.editorialBorder),
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
                                          '#0${index + 1}',
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
                                            color: accent.withValues(alpha: 0.1),
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
                                    Text(
                                      'Xem hướng dẫn chi tiết →',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
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
