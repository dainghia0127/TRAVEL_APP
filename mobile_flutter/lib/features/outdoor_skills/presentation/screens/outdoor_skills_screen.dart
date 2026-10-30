import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

class OutdoorSkillsScreen extends StatefulWidget {
  const OutdoorSkillsScreen({super.key});

  @override
  State<OutdoorSkillsScreen> createState() => _OutdoorSkillsScreenState();
}

class _OutdoorSkillsScreenState extends State<OutdoorSkillsScreen> {
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _skillsList = [
    {
      'title': 'Sơ cứu khi bị rắn độc cắn',
      'category': '🚨 Sơ cứu Y tế',
      'readTime': '3 phút',
      'desc': 'Quy tắc vàng bảo toàn tính mạng khi gặp tai nạn rắn độc cắn trong rừng.',
      'priority': 'SỐNG CÒN',
      'icon': Icons.medical_services,
      'accent': AppTheme.emergencyRed,
      'dos': [
        'Trấn an nạn nhân, giữ yên chi bị cắn ở vị trí thấp hơn tim.',
        'Băng ép cố định bản rộng từ ngón chi lên trên (áp lực vừa phải, sờ còn mạch đập).',
        'Dùng nẹp gỗ hoặc cành cây cố định bất động toàn bộ chi bị thương.',
        'Nhanh chóng vận chuyển nạn nhân đến cơ sở y tế gần nhất có huyết thanh.',
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG: Rạch da hoặc cố hút nọc độc (gây nhiễm trùng máu và hoại tử).',
        'TUYỆT ĐỐI KHÔNG: Garo nghẽn mạch máu (dẫn tới phải cưa cụt chi).',
        'TUYỆT ĐỐI KHÔNG: Đắp lá cây, bùn đất bừa bãi vào vết cắn.',
      ],
    },
    {
      'title': 'Xử lý hạ thân nhiệt (Hypothermia)',
      'category': '❄️ Sinh tồn thời tiết',
      'readTime': '4 phút',
      'desc': 'Kẻ giết người thầm lặng khi leo núi dầm mưa và gặp gió lạnh về đêm.',
      'priority': 'NGUY CẤP',
      'icon': Icons.ac_unit,
      'accent': AppTheme.tacticalOrange,
      'dos': [
        'Di chuyển nạn nhân ngay vào nơi kín gió (trong lều khô hoặc hang đá).',
        'Cởi bỏ ngay toàn bộ quần áo ướt, lau khô người.',
        'Ủ ấm từ từ vào các vùng trung tâm cơ thể: ngực, cổ, nách, bẹn.',
        'Cho uống nước ấm có đường hoặc gừng (nếu nạn nhân còn tỉnh táo).',
        'Bọc toàn thân bằng chăn cứu sinh tráng nhôm để phản xạ 90% nhiệt lượng.',
      ],
      'donts': [
        'TUYỆT ĐỐI KHÔNG: Cho uống rượu / đồ uống có cồn (làm giãn mạch gây mất nhiệt nhanh hơn).',
        'TUYỆT ĐỐI KHÔNG: Chà xát mạnh tay chân bị tê cóng.',
      ],
    },
    {
      'title': 'Kỹ thuật thắt nút dây dã ngoại',
      'category': '🏕️ Dựng trại & Dây',
      'readTime': '5 phút',
      'desc': 'Các nút dây cơ bản nhưng quyết định độ an toàn khi dựng lều và vượt dốc.',
      'priority': 'CƠ BẢN',
      'icon': Icons.line_style,
      'accent': AppTheme.emerald,
      'dos': [
        'Nút dẹt (Reef Knot): Dùng để nối 2 đầu dây cùng tiết diện, tháo gỡ nhanh.',
        'Nút thòng lọng (Bowline): Nút chúa của ngành dã ngoại, tạo vòng dây không bao giờ bị thắt chặt.',
        'Nút néo cọc lều (Taut-line Hitch): Tăng đơ điều chỉnh độ căng dây lều khi gió lớn.',
      ],
      'donts': [
        'Không dùng dây thừng mục để buộc võng qua đêm.',
      ],
    },
    {
      'title': 'Khử trùng và tìm nguồn nước sạch',
      'category': '💧 Nước sạch',
      'readTime': '3 phút',
      'desc': 'Cách thu thập và xử lý nước tự nhiên để uống an toàn không nhiễm khuẩn.',
      'priority': 'SỐNG CÒN',
      'icon': Icons.water_drop,
      'accent': AppTheme.alpineCyan,
      'dos': [
        'Ưu tiên lấy nước chảy siết trên đầu nguồn, tránh vũng nước đọng có phân thú.',
        'Lọc thô qua nhiều lớp vải sạch hoặc cát mịn để loại bỏ cặn bùn.',
        'Đun sôi sùng sục tối thiểu 3 phút để diệt sạch vi khuẩn và ký sinh trùng Giardia.',
        'Dùng 1 viên khử trùng Aquatabs cho 1 Lít nước, đợi 30 phút trước khi uống.',
      ],
      'donts': [
        'Không uống nước suối trực tiếp chưa qua xử lý dù nhìn thấy rất trong.',
      ],
    },
    {
      'title': 'Quy tắc STOP khi bị lạc trong rừng',
      'category': '🧭 Định hướng',
      'readTime': '4 phút',
      'desc': 'Bình tĩnh kiểm soát tình hình và sinh tồn chờ đội cứu hộ tiếp cận.',
      'priority': 'SỐNG CÒN',
      'icon': Icons.explore,
      'accent': AppTheme.neonGreen,
      'dos': [
        'S - Stop: Dừng lại ngay lập tức, hít thở sâu, tuyệt đối không hoảng loạn chạy mù quáng.',
        'T - Think: Nhớ lại điểm mốc cuối cùng bạn còn nhận ra rõ ràng.',
        'O - Observe: Quan sát hướng mặt trời, dấu vết lối mòn, địa hình và nguồn nước.',
        'P - Plan: Lập kế hoạch dựng lều trú ẩn trước khi trời tối (sau 16:30).',
        'Phát tín hiệu cứu hộ: Đốt 3 đống lửa tạo khói (hình tam giác) hoặc thổi 3 hồi còi dài ngắt quãng.',
      ],
      'donts': [
        'Không cố đi tiếp trong bóng đêm vì nguy cơ sảy chân rớt vực.',
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredSkills {
    return _skillsList.where((item) {
      final matchCat = _selectedCategory == 'Tất cả' || item['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          item['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['desc'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const categories = ['Tất cả', '🚨 Sơ cứu Y tế', '❄️ Sinh tồn thời tiết', '🏕️ Dựng trại & Dây', '💧 Nước sạch', '🧭 Định hướng'];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Cẩm Nang Sinh Tồn (Offline 100%)'),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceBase,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: TextField(
                style: const TextStyle(color: AppTheme.textMain, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kỹ năng sinh tồn, xử lý rắn cắn, nút dây...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.emerald, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppTheme.textMuted),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),

          // Categories Carousel
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.emerald : AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.emerald : AppTheme.borderLight),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? Colors.black : AppTheme.textMain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Skills Card List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: _filteredSkills.length,
              itemBuilder: (context, index) {
                final item = _filteredSkills[index];
                final Color accent = item['accent'] as Color;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBase,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showSkillDetail(item),
                      borderRadius: BorderRadius.circular(18),
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
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(item['icon'] as IconData, color: accent, size: 20),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      item['category'] as String,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: accent),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '⏱️ ${item['readTime']}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.textSub),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['title'] as String,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textMain),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['desc'] as String,
                              style: const TextStyle(fontSize: 13, color: AppTheme.textSub, height: 1.4),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    item['priority'] as String,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accent),
                                  ),
                                ),
                                const Row(
                                  children: [
                                    Text('Xem hướng dẫn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.emerald)),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14, color: AppTheme.emerald),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSkillDetail(Map<String, dynamic> skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final dos = skill['dos'] as List<String>;
        final donts = skill['donts'] as List<String>;
        final Color accent = skill['accent'] as Color;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(skill['icon'] as IconData, color: accent, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(skill['category'] as String, style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.bold)),
                            Text(
                              skill['title'] as String,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textMain),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppTheme.borderLight),

                  // DOs SECTION
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.emerald, size: 18),
                      SizedBox(width: 8),
                      Text('CÁC BƯỚC BẮT BUỘC PHẢI LÀM (DOs)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.emerald)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...dos.map((d) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.emerald.withValues(alpha: 0.2)),
                        ),
                        child: Text(d, style: const TextStyle(fontSize: 13, color: AppTheme.textMain, height: 1.4)),
                      )),

                  const SizedBox(height: 16),

                  // DONTs SECTION
                  if (donts.isNotEmpty) ...[
                    const Row(
                      children: [
                        Icon(Icons.cancel, color: AppTheme.emergencyRed, size: 18),
                        SizedBox(width: 8),
                        Text('TUYỆT ĐỐI KHÔNG ĐƯỢC LÀM (DON\'Ts)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.emergencyRed)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...donts.map((d) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.emergencyRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.emergencyRed.withValues(alpha: 0.3)),
                          ),
                          child: Text(d, style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.4)),
                        )),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.emerald,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đã Ghi Nhớ Quy Trình', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
