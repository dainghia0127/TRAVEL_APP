import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';
import 'package:mobile_flutter/core/widgets/bouncing_button.dart';
import 'package:mobile_flutter/core/widgets/tactical_badge.dart';

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
      'readTime': '3 phút',
      'desc': 'Quy tắc vàng bất động & băng ép bảo toàn tính mạng khi gặp tai nạn rắn cắn trong rừng.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.emergencyRed,
      'heroImage': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&q=80',
      'equipment': ['Cuộn băng thun y tế (hoặc dải vải sạch)', '2 thanh gỗ/cành cây thẳng', 'Dây vải buộc cố định', 'Điện thoại/Còi cứu hộ'],
      'steps': [
        {
          'title': 'Bước 1: Trấn an & Hạ thấp chi bị cắn',
          'action': 'Yêu cầu nạn nhân nằm yên bất động TUYỆT ĐỐI. Sự hoảng sợ và tim đập nhanh sẽ bơm nọc độc theo dòng máu đi khắp cơ thể chỉ trong vài phút. Đặt cánh tay hoặc chân bị cắn ở vị trí THẤP HƠN TIM. Tháo ngay nhẫn, vòng tay, đồng hồ hoặc giày dép trước khi vết cắn bắt đầu sưng phù to.',
          'imageUrl': 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?w=800&q=80',
          'tip': 'Chụp ảnh con rắn từ khoảng cách an toàn (để bác sĩ cấp đúng huyết thanh), tuyệt đối KHÔNG đuổi bắt hoặc đập rắn.',
        },
        {
          'title': 'Bước 2: Kỹ thuật băng ép bản rộng (Pressure Immobilization)',
          'action': 'Dùng cuộn băng thun quấn từ đầu ngón tay/ngón chân hướng ngược dần lên phía gốc chi (vượt qua vết thương 10-15cm). Lực quấn chặt vừa phải như khi quấn sơ cứu bong gân cổ chân. Chú ý ĐỂ HỞ ĐẦU NGÓN TAY/CHÂN để liên tục theo dõi tuần hoàn máu.',
          'imageUrl': 'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=800&q=80',
          'tip': 'Kiểm tra mạch ở mu bàn chân hoặc cổ tay: nếu không sờ thấy mạch đập nghĩa là bạn đang quấn quá chặt, cần nới lỏng ra một chút.',
        },
        {
          'title': 'Bước 3: Nẹp cố định toàn bộ khớp xương',
          'action': 'Đặt 2 thanh gỗ hoặc cành cây thẳng ở 2 bên chi bị thương (qua cả 2 khớp liền kề, ví dụ qua cả khớp gối và cổ chân). Dùng dải vải buộc cố định nẹp vào chân để nạn nhân dù vô tình cũng không thể co duỗi chân được (cử động cơ bắp là nguyên nhân chính khiến nọc độc lan vào hệ bạch huyết).',
          'imageUrl': 'https://images.unsplash.com/photo-1516574187841-cb9cc2ca948b?w=800&q=80',
          'tip': 'Lót thêm lớp lá cây mềm hoặc áo thun giữa cành cây và da nạn nhân để tránh trầy xước mô mềm.',
        },
        {
          'title': 'Bước 4: Khiêng cáng di chuyển cấp cứu khẩn cấp',
          'action': 'Dùng võng, bạt dã ngoại hoặc 2 cây tre dài làm cáng khiêng nạn nhân. Tuyệt đối KHÔNG ĐỂ NẠN NHÂN TỰ ĐI BỘ dù chỉ 1 bước. Vận chuyển khẩn trương đến bệnh viện huyện/tỉnh có huyết thanh kháng độc gần nhất.',
          'imageUrl': 'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=800&q=80',
          'tip': 'Gọi ngay 115 hoặc đội cứu hộ địa phương thông báo tọa độ GPS và thời gian chính xác nạn nhân bị cắn.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG rạch da, trích nặn hoặc dùng miệng hút nọc (làm rách mạch máu khiến nọc ngấm nhanh hơn 10 lần và nhiễm độc cho người cứu).',
        'TUYỆT ĐỐI KHÔNG dùng garo nghẽn tĩnh mạch (nguyên nhân hàng đầu gây thiếu máu nuôi và hoại tử phải cưa bỏ chi).',
        'TUYỆT ĐỐI KHÔNG đắp lá cây, bùn đất bừa bãi hoặc chườm đá lạnh (gây bỏng lạnh tế bào và nhiễm trùng uốn ván chết người).',
      ],
    },
    {
      'id': 'skill_2',
      'title': 'Xử lý hạ thân nhiệt (Hypothermia)',
      'category': 'Sinh tồn thời tiết',
      'categoryIcon': Icons.ac_unit,
      'readTime': '4 phút',
      'desc': 'Kẻ giết người thầm lặng khi leo núi dầm mưa và gặp gió lạnh về đêm.',
      'priority': 'NGUY CẤP',
      'accent': AppColors.tacticalOrange,
      'heroImage': 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=800&q=80',
      'equipment': ['Lều kín gió / bạt cứu sinh tráng bạc', 'Khăn lau khô & quần áo len/nỉ khô', 'Túi ngủ dã ngoại', 'Bình giữ nhiệt nước đường gừng'],
      'steps': [
        {
          'title': 'Bước 1: Chuyển ngay vào nơi kín gió tuyệt đối',
          'action': 'Gió lùa và độ ẩm là nguyên nhân làm mất nhiệt nhanh gấp 25 lần không khí khô. Đưa ngay người bị nạn vào lều khô, hang đá hoặc dùng bạt che kín xung quanh chắn triệt để gió.',
          'imageUrl': 'https://images.unsplash.com/photo-1510312305653-8ed496efae75?w=800&q=80',
          'tip': 'Lót thảm cách nhiệt hoặc cành lá khô dày dưới sàn lều, không để nạn nhân nằm trực tiếp lên nền đất lạnh.',
        },
        {
          'title': 'Bước 2: Cởi bỏ toàn bộ quần áo ướt sũng',
          'action': 'Nhanh chóng lột bỏ toàn bộ quần áo bị ướt. Dùng khăn khô mềm thấm nước trên da (thấm nhẹ nhàng, không chà xát mạnh). Thay ngay quần áo khô ấm và đội mũ len che kín vùng đầu (đầu là nơi thất thoát 40% nhiệt lượng của cơ thể).',
          'imageUrl': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&q=80',
          'tip': 'Nếu không có đồ khô thay thế, hãy bọc kín nạn nhân bằng chăn nhôm cứu sinh tráng bạc phản xạ nhiệt.',
        },
        {
          'title': 'Bước 3: Ủ ấm từ từ vào trung tâm cơ thể',
          'action': 'Bọc nạn nhân vào túi ngủ dã ngoại. Chườm ấm (bình nước ấm bọc vải) vào 4 vị trí vàng: 2 bên CỔ, NGỰC, 2 HỐ NÁCH và BẸN. Đây là nơi có các động mạch lớn chạy qua giúp đưa máu ấm nuôi tim và não bộ.',
          'imageUrl': 'https://images.unsplash.com/photo-1516939884455-1445c8652f83?w=800&q=80',
          'tip': 'TUYỆT ĐỐI KHÔNG chườm ấm trực tiếp vào bàn tay, bàn chân vì sẽ khiến máu lạnh ứ đọng từ chi ùa ngược về tim gây rung thất ngừng tim đột ngột.',
        },
        {
          'title': 'Bước 4: Bổ sung nước ấm có đường/gừng',
          'action': 'Nếu nạn nhân còn tỉnh táo và tự nuốt được, cho uống từng ngụm nhỏ nước ấm pha mật ong, đường glucose hoặc trà gừng ấm để cung cấp calo cho cơ thể tự sinh nhiệt lại.',
          'imageUrl': 'https://images.unsplash.com/photo-1517824806704-9040b037703b?w=800&q=80',
          'tip': 'Nếu nạn nhân lơ mơ hoặc bất tỉnh, TUYỆT ĐỐI KHÔNG ép uống nước vì nguy cơ sặc nước vào khí quản gây ngạt thở.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG cho uống rượu / bia (cồn gây giãn mạch ngoại vi, làm cơ thể mất nhiệt nhanh hơn gấp nhiều lần).',
        'TUYỆT ĐỐI KHÔNG chà xát mạnh tay chân bị cóng vì tế bào da đang đóng băng rất dễ bị giập nát và hoại tử.',
      ],
    },
    {
      'id': 'skill_3',
      'title': 'Kỹ thuật thắt nút dây dã ngoại',
      'category': 'Dựng trại & Dây',
      'categoryIcon': Icons.line_style,
      'readTime': '5 phút',
      'desc': 'Các nút dây cơ bản nhưng quyết định độ an toàn khi dựng lều và vượt dốc.',
      'priority': 'CƠ BẢN',
      'accent': AppColors.emerald,
      'heroImage': 'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=800&q=80',
      'equipment': ['Dây sinh tồn Paracord 4mm hoặc 7 lõi', 'Dây thừng dù chịu lực', 'Cọc lều dã ngoại'],
      'steps': [
        {
          'title': 'Nút dẹt (Reef Knot) — Nối 2 đầu dây',
          'action': 'Quy tắc vàng: "Phải qua trái rồi vòng, Trái qua phải rồi vòng". Bắt chéo đầu dây phải lên đầu dây trái rồi quấn 1 vòng. Sau đó bắt chéo đầu trái lên đầu phải rồi quấn 1 vòng, kéo chặt. Nút tạo thành 2 vòng lồng vào nhau cân xứng.',
          'imageUrl': 'https://images.unsplash.com/photo-1516939884455-1445c8652f83?w=800&q=80',
          'tip': 'Dùng để nối 2 sợi dây có cùng tiết diện hoặc buộc dải băng y tế, tháo mở siêu nhanh chỉ bằng 1 động tác giật nhẹ.',
        },
        {
          'title': 'Nút thòng lọng (Bowline) — Vua của các nút dây',
          'action': 'Tạo một vòng tròn không bao giờ bị thít chặt dù chịu tải nặng hàng trăm kg. Câu thần chú dễ nhớ: "Thỏ chui ra khỏi hang, chạy vòng quanh thân cây, rồi chui ngược lại vào hang". Tạo 1 vòng khuyên nhỏ, luồn đầu dây từ dưới lên, vòng qua thân dây chính, rồi luồn lại vào khuyên, kéo siết chặt.',
          'imageUrl': 'https://images.unsplash.com/photo-1527631746610-bca00a040d60?w=800&q=80',
          'tip': 'Dùng buộc quanh người khi cứu hộ vượt suối, neo võng hoặc kéo đồ nặng lên vách đá an toàn.',
        },
        {
          'title': 'Nút néo tăng đơ (Taut-line) — Tăng giảm độ căng dây lều',
          'action': 'Vòng đầu dây qua cọc cắm đất. Quấn đầu dây 2 vòng bên trong lòng dây chính về phía cọc lều, sau đó quấn tiếp 1 vòng bên ngoài về phía lều và thắt nút lại. Nút này có thể dùng ngón tay trượt lên xuống để điều chỉnh độ căng của dây lều khi trời mưa gió.',
          'imageUrl': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&q=80',
          'tip': 'Khi trời đổ mưa, dây lều sẽ bị chùng do ngấm nước, bạn chỉ cần dùng tay đẩy nút trượt lên phía trên là lều lại căng đét mà không cần tháo dây.',
        },
      ],
      'donts': [
        'Không dùng dây thừng đã mục nát, tơi sợi hoặc sờn vỏ ngoài để mắc võng qua đêm.',
      ],
    },
    {
      'id': 'skill_4',
      'title': 'Khử trùng và tìm nguồn nước sạch',
      'category': 'Nước sạch',
      'categoryIcon': Icons.water_drop,
      'readTime': '3 phút',
      'desc': 'Cách thu thập và xử lý nước tự nhiên để uống an toàn không nhiễm khuẩn.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.alpineCyan,
      'heroImage': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
      'equipment': ['Khăn rằn / vải sạch nhiều lớp', 'Chai nước hoặc bình dã ngoại', 'Ấm đun nước & bếp gas mini', 'Viên khử khuẩn Aquatabs'],
      'steps': [
        {
          'title': 'Bước 1: Chọn nguồn nước thiên nhiên tối ưu',
          'action': 'Luôn lấy nước từ các con suối đá chảy xiết trên cao. Tuyệt đối tránh xa các vũng nước tù đọng dưới thung lũng, nơi chăn thả trâu bò hoặc gần rác thải. Nước chảy xiết có nồng độ oxy cao và ít vi khuẩn kỵ khí hơn.',
          'imageUrl': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800&q=80',
          'tip': 'Nếu chỉ có vũng nước đục, hãy đào một hố sâu cách mép nước 1 mét, nước ngấm qua cát vào hố sẽ trong hơn rất nhiều.',
        },
        {
          'title': 'Bước 2: Lọc cơ học loại bỏ bùn đất & ký sinh trùng',
          'action': 'Gập chiếc khăn rằn hoặc áo thun làm 4-6 lớp, đặt lên miệng bình chứa. Rót nước từ từ qua lớp vải để giữ lại 100% cát, lá cây mục, ấu trùng muỗi và trứng giun sán. Có thể lót thêm than củi giã nhỏ ở giữa 2 lớp vải để khử mùi hôi của bùn.',
          'imageUrl': 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?w=800&q=80',
          'tip': 'Lọc vải chỉ làm nước trong, KHÔNG tiêu diệt được virus và vi khuẩn gây bệnh tiêu chảy.',
        },
        {
          'title': 'Bước 3: Đun sôi sùng sục tối thiểu 3 phút',
          'action': 'Đun nước trên bếp ga mini hoặc lửa trại. Khi nước sôi ùng ục, giữ lửa sôi liên tục tối thiểu 3 phút (ở vùng núi cao trên 1,000m nước sôi ở nhiệt độ thấp hơn nên cần đun sôi 5 phút). Nhiệt độ 100°C tiêu diệt hoàn toàn amip ăn não, vi khuẩn tả và E.coli.',
          'imageUrl': 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=800&q=80',
          'tip': 'Nước sau khi đun sôi có vị ngang vì mất oxy, bạn hãy rót qua lại giữa 2 chiếc cốc vài lần để hòa tan oxy lại trước khi uống.',
        },
        {
          'title': 'Bước 4: Sử dụng viên lọc hóa học Aquatabs',
          'action': 'Nếu không thể nhóm lửa đun sôi, thả 1 viên Aquatabs 8.5mg vào 1 Lít nước đã lọc trong. Đậy nắp kín, lắc đều và CHỜ ĐỦ 30 PHÚT trước khi mở ra uống. Clo trong viên sẽ khử trùng hoàn toàn vi sinh vật gây hại.',
          'imageUrl': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&q=80',
          'tip': 'Luôn mang theo 1 vỉ viên lọc nước khẩn cấp trong ngăn kéo khóa nhỏ nhất của balo leo núi.',
        },
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG uống nước suối trực tiếp chưa qua xử lý dù nhìn thấy rất trong vắt (nguy cơ nhiễm ký sinh trùng Giardia gây mất nước cấp).',
      ],
    },
    {
      'id': 'skill_5',
      'title': 'Quy tắc STOP khi bị lạc trong rừng',
      'category': 'Định hướng',
      'categoryIcon': Icons.explore,
      'readTime': '4 phút',
      'desc': 'Bình tĩnh kiểm soát tình hình và sinh tồn chờ đội cứu hộ tiếp cận.',
      'priority': 'SỐNG CÒN',
      'accent': AppColors.neonGreen,
      'heroImage': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
      'equipment': ['Còi cứu nạn đa năng', 'La bàn & bản đồ offline', 'Bật lửa / đá đánh lửa', 'Áo mưa / bạt cứu sinh'],
      'steps': [
        {
          'title': 'S — STOP (Dừng lại ngay lập tức)',
          'action': 'Ngay khi nhận ra bạn không còn thấy đồng đội hoặc lạc mất dấu đường mòn: DỪNG LẠI NGAY LẬP TỨC. Ngồi xuống một tảng đá, hít thở sâu 10 nhịp. Nỗi sợ hãi sẽ thôi thúc bạn chạy loạn xạ, và 90% nạn nhân tử vong vì lao vào khe vực hoặc kiệt sức do chạy hoảng loạn.',
          'imageUrl': 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=800&q=80',
          'tip': 'Thổi 3 hồi còi thật dài (Mã cứu nạn quốc tế: 3 tiếng còi = SOS). Dừng lại 1 phút lắng nghe phản hồi.',
        },
        {
          'title': 'T — THINK (Suy nghĩ và định hình lại)',
          'action': 'Cố gắng nhớ lại: Bạn tách đoàn bao lâu rồi? Điểm mốc quen thuộc cuối cùng bạn nhìn thấy là gì (con suối, cây thông sét đánh, mỏm đá đôi)? Mở ứng dụng Travel App kiểm tra tọa độ GPS ngoại tuyến đã lưu trên bản đồ.',
          'imageUrl': 'https://images.unsplash.com/photo-1508873696983-2df5293cb325?w=800&q=80',
          'tip': 'Nếu bạn chỉ mới lạc 5-10 phút, bạn có thể men theo dấu chân cỏ dập để quay lại điểm mốc trước đó.',
        },
        {
          'title': 'O — OBSERVE (Quan sát địa hình xung quanh)',
          'action': 'Quan sát mặt trời để xác định hướng Đông - Tây. Nhìn xung quanh tìm: nguồn nước sạch, mỏm đất cao kín gió để trú ẩn. Để ý sương mù và mây đen: nếu trời sắp tối (sau 16h30) hoặc sắp mưa, dừng việc tìm đường và chuyển ngay sang chế độ trú ẩn.',
          'imageUrl': 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=800&q=80',
          'tip': 'Tuyệt đối KHÔNG men theo lòng suối cạn đi xuống vực sâu hoang dã vì địa hình suối thác ở Việt Nam thường có các vách dựng đứng 30-50m không thể leo xuống.',
        },
        {
          'title': 'P — PLAN (Lập kế hoạch sinh tồn & Phát tín hiệu)',
          'action': 'Dựng lều hoặc căng bạt trú ẩn trước 17h00. Thu gom củi khô dự trữ cho cả đêm. Đốt 3 đống lửa tạo thành hình tam giác ở khoảng đất trống (tín hiệu cấp cứu quốc tế). Ban ngày cho thêm lá cây tươi để tạo khói trắng bốc cao cho trực thăng hoặc đội tìm kiếm phát hiện.',
          'imageUrl': 'https://images.unsplash.com/photo-1470246973918-29a93221c455?w=800&q=80',
          'tip': 'Ở yên một chỗ! Đội tìm kiếm cứu hộ luôn bắt đầu lùng soát từ điểm cuối cùng bạn được nhìn thấy.',
        },
      ],
      'donts': [
        'Không cố đi tiếp trong bóng đêm vì nguy cơ sảy chân rớt vực sâu.',
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

  void _openArticleDetail(Map<String, dynamic> skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final steps = (skill['steps'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
        final donts = (skill['donts'] as List<dynamic>?)?.cast<String>() ?? [];
        final equipment = (skill['equipment'] as List<dynamic>?)?.cast<String>() ?? [];
        final Color accent = skill['accent'] as Color;
        final String? heroImage = skill['heroImage'] as String?;

        return DraggableScrollableSheet(
          initialChildSize: 0.90,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: AppRadius.roundedPill),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hero Image Header
                  if (heroImage != null) ...[
                    ClipRRect(
                      borderRadius: AppRadius.roundedLg,
                      child: Stack(
                        children: [
                          Image.network(
                            heroImage,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 120,
                              color: AppColors.surfaceHigh,
                              child: Center(child: Icon(Icons.terrain, color: accent, size: 40)),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 14,
                            right: 14,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TacticalPill(
                                  text: skill['category'] as String,
                                  color: accent,
                                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                                ),
                                TacticalPill(
                                  text: 'NGOẠI TUYẾN 100%',
                                  color: AppColors.emerald,
                                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Article Headline
                  Text(skill['title'] as String, style: AppTypography.displayHero.copyWith(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(skill['desc'] as String, style: AppTypography.bodyLarge),

                  // Required Equipment Checklist
                  if (equipment.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('DỤNG CỤ CẦN CHUẨN BỊ', style: AppTypography.captionBadge.copyWith(color: AppColors.emerald)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: equipment.map((item) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceBase,
                            borderRadius: AppRadius.roundedPill,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline, size: 14, color: AppColors.emerald),
                              const SizedBox(width: 6),
                              Text(item, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const Divider(height: 28, color: AppColors.borderSubtle),

                  // Step by step breakdown with instructional images
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('HƯỚNG DẪN THỰC HIỆN TỪNG BƯỚC', style: AppTypography.captionBadge.copyWith(color: AppColors.emerald)),
                      Text('${steps.length} BƯỚC', style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  ...steps.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final s = entry.value;
                    final stepImg = s['imageUrl'] as String?;
                    final tip = s['tip'] as String?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step Header
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: accent.withValues(alpha: 0.2),
                                child: Text('$idx', style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  s['title'] as String,
                                  style: AppTypography.titleMedium.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Step Illustration Image
                          if (stepImg != null) ...[
                            ClipRRect(
                              borderRadius: AppRadius.roundedMd,
                              child: Stack(
                                children: [
                                  Image.network(
                                    stepImg,
                                    height: 140,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 90,
                                      color: AppColors.surfaceBase,
                                      child: Center(child: Icon(Icons.medical_services_outlined, color: accent, size: 30)),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: AppRadius.roundedPill,
                                      ),
                                      child: Text(
                                        'HÌNH MINH HỌA THAO TÁC',
                                        style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Action guide text
                          Text(
                            s['action'] as String,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.5, fontSize: 13),
                          ),

                          // Pro Tip Box
                          if (tip != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withValues(alpha: 0.10),
                                borderRadius: AppRadius.roundedMd,
                                border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.emerald),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'MẸO VÀNG: $tip',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
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

                  const SizedBox(height: 8),

                  // DONTs Warning Box
                  if (donts.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyRed.withValues(alpha: 0.12),
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.emergencyRed),
                              SizedBox(width: 8),
                              Text('ĐIỀU CẤM KỴ TUYỆT ĐỐI (NGUY HIỂM TÍNH MẠNG)', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.w900, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...donts.map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✕ ', style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold, fontSize: 13)),
                                Expanded(child: Text(d, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, height: 1.4))),
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
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: Colors.black, size: 18),
                            SizedBox(width: 8),
                            Text('Tôi Đã Nắm Rõ Quy Trình Này', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
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
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Offline Status
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.space16, 12, AppSpacing.space16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TacticalPill(
                          icon: Icons.offline_pin,
                          text: 'NGOẠI TUYẾN 100%',
                          color: AppColors.emerald,
                          backgroundColor: AppColors.surfaceHigh,
                        ),
                        Text(
                          '${_bookmarkedIds.length} bài ghim',
                          style: AppTypography.captionBadge.copyWith(color: AppColors.tacticalOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cẩm Nang Sinh Tồn',
                      style: AppTypography.displayHero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sơ cứu khẩn cấp, kỹ năng dã ngoại & thoát hiểm trong rừng',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // Search input
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBase,
                        borderRadius: AppRadius.roundedMd,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Tìm bài sơ cứu rắn cắn, hạ thân nhiệt, nút dây...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          prefixIcon: const Icon(Icons.search, color: AppColors.emerald, size: 18),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16, color: AppColors.textMuted),
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
                height: 40,
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
                            color: isSelected ? AppColors.emerald : AppColors.surfaceHigh,
                            borderRadius: AppRadius.roundedPill,
                            border: Border.all(color: isSelected ? AppColors.emerald : AppColors.borderSubtle),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? Colors.black : Colors.white,
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

            // Quick Emergency Banner (Breaking card monotony)
            if (_selectedCategory == 'Tất cả' && _searchQuery.isEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, color: AppColors.emergencyRed, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'SƠ CỨU CẤP TỐC (EMERGENCY)',
                            style: AppTypography.captionBadge.copyWith(color: AppColors.emergencyRed, letterSpacing: 0.6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: BouncingButton(
                              onTap: () => _openArticleDetail(_skillsList[0]),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.emergencyRed.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.roundedMd,
                                  border: Border.all(color: AppColors.emergencyRed.withValues(alpha: 0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.medical_services_outlined, size: 16, color: AppColors.emergencyRed),
                                        Spacer(),
                                        Text('3m', style: TextStyle(color: AppColors.emergencyRed, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('RẮN ĐỘC CẮN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text('Quy tắc nẹp ép cố định', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
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
                                  color: AppColors.tacticalOrange.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.roundedMd,
                                  border: Border.all(color: AppColors.tacticalOrange.withValues(alpha: 0.4)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.ac_unit, size: 16, color: AppColors.tacticalOrange),
                                        Spacer(),
                                        Text('4m', style: TextStyle(color: AppColors.tacticalOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Text('HẠ THÂN NHIỆT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text('Xử lý mưa lạnh dã ngoại', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('SỔ TAY THỰC ĐỊA (FIELD MANUAL)', style: AppTypography.captionBadge.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],

            // Skills Card List (Styled as Field Manual with left accent stripe & serial number)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final skill = filtered[index];
                    final isBookmarked = _bookmarkedIds.contains(skill['id']);
                    final Color accent = skill['accent'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBase,
                        borderRadius: AppRadius.roundedLg,
                        border: Border(
                          left: BorderSide(color: accent, width: 4),
                          top: const BorderSide(color: AppColors.borderSubtle),
                          right: const BorderSide(color: AppColors.borderSubtle),
                          bottom: const BorderSide(color: AppColors.borderSubtle),
                        ),
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
                                        TacticalPill(
                                          text: skill['priority'] as String,
                                          color: accent,
                                          backgroundColor: accent.withValues(alpha: 0.15),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          skill['readTime'] as String,
                                          style: AppTypography.captionBadge.copyWith(color: AppColors.textMuted),
                                        ),
                                        const SizedBox(width: 8),
                                        BouncingButton(
                                          onTap: () => _toggleBookmark(skill['id'] as String),
                                          child: Icon(
                                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                            color: isBookmarked ? AppColors.tacticalOrange : AppColors.textMuted,
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
                                  style: AppTypography.headlineMedium.copyWith(fontSize: 17),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  skill['desc'] as String,
                                  style: AppTypography.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Xem hướng dẫn chi tiết →',
                                      style: AppTypography.captionBadge.copyWith(color: AppColors.emerald),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.emerald),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 200.ms, delay: (index * 40).ms).slideY(begin: 0.05, end: 0);
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
