@[GLOBAL_AI_RULES](e:/AI Code/GLOBAL_AI_RULES.md)

# QUY TẮC LẬP TRÌNH VỚI AI — TIÊU CHUẨN THỰC HIỆN DỰ ÁN TRAVEL_APP

## 1. Phân tích và lập kế hoạch trước khi code
Trước khi thực hiện task, AI PHẢI:
- Khảo sát cấu trúc project, source code, cấu hình, dependencies và tài liệu liên quan.
- Hiểu kiến trúc hiện tại và các quy ước đang được sử dụng trước khi đề xuất thay đổi.
- Chia công việc thành các giai đoạn rõ ràng và các task nhỏ, có thể kiểm tra được.
- Xác định các công việc phụ thuộc, giả định, rủi ro, file bị ảnh hưởng và tác động có thể phát sinh.
- Xác định tiêu chí nghiệm thu cho từng task, bao gồm cách kiểm tra kết quả.
- Trình bày kế hoạch trước khi thực hiện các thay đổi đáng kể.
- Đối với task nhỏ, ít rủi ro, có thể lập kế hoạch ngắn gọn. Đối với task lớn, thay đổi kiến trúc hoặc có nguy cơ gây hậu quả nghiêm trọng, PHẢI lập kế hoạch chi tiết và chờ người dùng phê duyệt trước khi triển khai.
- KHÔNG được viết lại code hoặc thay đổi kiến trúc khi chưa hiểu mục đích của cách triển khai hiện tại.

## 2. Quản lý checklist và trạng thái công việc
Sử dụng một file duy nhất làm nguồn thông tin chính về tiến độ:
`docs/AI_TASK_PLAN.md`
Nếu project đã có file theo dõi tiến độ tương đương, hãy sử dụng file đó thay vì tạo file trùng lặp.

File này PHẢI ghi nhận:
- Mục tiêu và phạm vi công việc.
- Giai đoạn hiện tại và trạng thái tổng thể.
- Danh sách giai đoạn và checklist theo thứ tự thực hiện.
- Tiêu chí nghiệm thu của từng task.
- Công việc đã hoàn thành và bằng chứng kiểm tra.
- Công việc đang thực hiện.
- Công việc chưa bắt đầu và các trở ngại.
- Lỗi kiểm thử, vấn đề chưa giải quyết và các quyết định quan trọng.
- Các file đã thay đổi và cấu hình liên quan.
- Bước tiếp theo chính xác cần thực hiện khi tiếp tục dự án.

Sử dụng thống nhất các trạng thái:
- `[ ]` Chưa bắt đầu.
- `[~]` Đang thực hiện.
- `[x]` Đã hoàn thành và kiểm chứng.
- `[!]` Bị chặn hoặc cần người dùng quyết định.

Chỉ đánh dấu `[x]` khi tiêu chí nghiệm thu đã được kiểm tra. Việc viết xong code không đồng nghĩa với việc task đã hoàn thành.
Cập nhật checklist sau mỗi cột mốc quan trọng, khi xử lý xong trở ngại, thay đổi kế hoạch hoặc đưa ra quyết định có ảnh hưởng đến dự án.

## 3. Lưu trạng thái và tiếp tục sau khi bị gián đoạn
Luôn giả định rằng máy tính, terminal, IDE hoặc phiên làm việc với AI có thể dừng đột ngột.
Sau mỗi cột mốc quan trọng và trước khi kết thúc phiên làm việc, AI PHẢI:
- Lưu các thay đổi source code liên quan.
- Cập nhật `docs/AI_TASK_PLAN.md`.
- Ghi lại trạng thái đã kiểm chứng gần nhất và bước tiếp theo chính xác.
- Ghi lại phần việc còn dang dở, lỗi, kết quả kiểm thử và các quyết định chưa được giải quyết.
- Đảm bảo các task đã hoàn thành không bị thực hiện lại không cần thiết.

Khi bắt đầu hoặc tiếp tục một phiên làm việc, AI PHẢI:
- Đọc file quy tắc của project và `docs/AI_TASK_PLAN.md`.
- Kiểm tra Git status và các thay đổi hiện có.
- Đối chiếu source code thực tế với trạng thái được ghi nhận.
- Kiểm tra lại cột mốc gần nhất khi cần thiết.
- Tiếp tục từ task chưa hoàn thành hoặc chưa được kiểm chứng đầu tiên.
- KHÔNG được mặc định rằng công việc trước đó đã hoàn thành chỉ vì checklist ghi như vậy. Phải xác minh trạng thái thực tế trước khi tiếp tục.
- KHÔNG ghi đè hoặc loại bỏ các thay đổi chưa commit của người dùng.

## 4. Các trường hợp bắt buộc xin phê duyệt
AI PHẢI dừng và yêu cầu người dùng phê duyệt rõ ràng trước khi thực hiện hành động có hậu quả đáng kể, khó khôi phục, không thể đảo ngược hoặc ảnh hưởng đến hệ thống bên ngoài.
Các trường hợp bao gồm nhưng không giới hạn:
- Xóa hoặc ghi đè file quan trọng hay dữ liệu người dùng.
- Xóa bảng database, xóa dữ liệu hoặc chạy migration có nguy cơ phá hủy dữ liệu.
- Thay đổi kiến trúc lớn hoặc thay đổi public interface gây mất tương thích.
- Thay đổi cấu hình production, credentials, permissions hoặc các thiết lập bảo mật.
- Deploy production, publish ứng dụng hoặc phát hành phiên bản.
- Phát sinh chi phí dịch vụ đáng kể hoặc tạo tài nguyên trả phí.
- Thực hiện hành động vượt phạm vi đã thống nhất và có thể ảnh hưởng đến hệ thống hoặc người dùng khác.

Trước khi yêu cầu phê duyệt, AI PHẢI giải thích:
- Hành động dự kiến và lý do cần thực hiện.
- Rủi ro có thể xảy ra và đối tượng bị ảnh hưởng.
- Khả năng khôi phục hoặc đảo ngược hành động.
- Các phương án an toàn hơn và phương án được đề xuất.
- KHÔNG thực hiện hành động có rủi ro cao trước khi nhận được phê duyệt.
- KHÔNG coi sự im lặng, câu trả lời mơ hồ hoặc phê duyệt cho một task khác là sự cho phép thực hiện hành động đó.

## 5. Xử lý khi chưa chắc chắn
- KHÔNG dừng lại để hỏi người dùng về mọi vấn đề nhỏ.
- Trước tiên, AI phải chủ động giảm sự không chắc chắn bằng cách đọc code, tài liệu, kiểm tra các cách triển khai hiện có hoặc chạy thử nghiệm an toàn và có thể đảo ngược.
- Yêu cầu người dùng giải thích hoặc phê duyệt khi:
  - Thiếu yêu cầu quan trọng có thể làm thay đổi cách triển khai.
  - Có nhiều phương án hợp lý nhưng khác biệt đáng kể về chi phí, rủi ro hoặc kết quả.
  - Giả định sai có thể gây mất dữ liệu, vấn đề bảo mật, mất tương thích hoặc phải làm lại nhiều.
  - Thiếu credentials, quyền truy cập, quy tắc nghiệp vụ hoặc quyết định từ bên ngoài.
  - Không thể kiểm chứng an toàn bước tiếp theo.
- Khi hỏi, hãy nêu rõ vấn đề chưa chắc chắn, các phương án, hậu quả và đề xuất của AI.
- Với vấn đề nhỏ, ít rủi ro, AI được phép chọn phương án đơn giản nhất phù hợp với quy ước của project, ghi nhận giả định và tiếp tục thực hiện.
- KHÔNG tự tạo ra yêu cầu, khẳng định thông tin chưa được kiểm chứng hoặc âm thầm đưa ra quyết định lớn về sản phẩm.

## 6. Quy tắc triển khai code
- Thực hiện từng task logic một.
- Giữ các thay đổi trong phạm vi yêu cầu.
- Tuân thủ kiến trúc, quy tắc đặt tên và coding standards hiện có.
- Tránh refactor không liên quan và thêm dependencies không cần thiết.
- Ưu tiên thay đổi nhỏ, dễ kiểm tra và dễ khôi phục.
- Giữ nguyên hành vi hiện tại nếu task không yêu cầu thay đổi.
- KHÔNG thay thế một giải pháp đang hoạt động chỉ vì AI thích một phương án khác hơn.
- KHÔNG hardcode secrets, access tokens, private keys hoặc credentials production.
- Không chỉnh sửa file được sinh tự động hoặc dependency lockfile nếu không cần thiết.
- Nếu cần thay đổi phạm vi hoặc kiến trúc, cập nhật kế hoạch và xin phê duyệt khi thay đổi có ảnh hưởng đáng kể.

## 7. Kiểm chứng trước khi hoàn thành
Sau khi triển khai, AI PHẢI:
- Chạy các test, static analysis, formatter và build checks phù hợp với môi trường hiện có.
- Kiểm tra lỗi và cảnh báo; xử lý các vấn đề phát sinh từ thay đổi vừa thực hiện.
- Đối chiếu kết quả với tiêu chí nghiệm thu.
- Kiểm tra Git diff để phát hiện thay đổi ngoài ý muốn, thông tin bí mật hoặc code không liên quan.
- Phân biệt rõ kết quả đã xác minh với những bước chưa thể thực hiện.
- Cập nhật checklist, bằng chứng kiểm tra và các hạn chế còn tồn tại.
- KHÔNG được tuyên bố rằng code đã build thành công, test đã pass hoặc tính năng đã hoạt động nếu chưa kiểm tra kết quả tương ứng.
- Nếu kiểm thử thất bại, hãy điều tra và sửa lỗi trong phạm vi an toàn. Nếu việc sửa lỗi đòi hỏi thay đổi có rủi ro cao hoặc cần quyết định về sản phẩm, hãy dừng và xin phê duyệt.

## 8. Báo cáo kết quả
Khi hoàn thành task hoặc kết thúc một phiên làm việc, AI PHẢI báo cáo:
- Những công việc đã hoàn thành.
- Những file đã thay đổi và nội dung thay đổi chính.
- Các bước kiểm thử, kết quả thực tế và những gì chưa kiểm thử được.
- Các hạn chế, lỗi chưa xử lý và giả định còn tồn tại.
- Những quyết định hoặc phê duyệt đang chờ.
- Bước tiếp theo chính xác để tiếp tục công việc.
- KHÔNG báo cáo công việc chưa hoàn thành hoặc chưa kiểm chứng như thể đã hoàn thành.

## 9. Thứ tự ưu tiên khi có xung đột
Tuân thủ thứ tự ưu tiên sau:
1. Chỉ dẫn rõ ràng của người dùng và các phê duyệt cho task hiện tại.
2. Yêu cầu về an toàn, bảo mật và bảo vệ dữ liệu.
3. Quy tắc kiến trúc và coding standards của project.
4. Kế hoạch triển khai đã được phê duyệt.
5. Các sở thích lập trình chung.
- Nếu các chỉ dẫn mâu thuẫn, KHÔNG tự chọn cách diễn giải có thể gây hậu quả nghiêm trọng. Hãy giải thích xung đột và yêu cầu người dùng làm rõ.

## 10. Tiêu chí hoàn thành task
Một task chỉ được coi là hoàn thành khi:
- Hành vi được yêu cầu đã được triển khai.
- Các tiêu chí nghiệm thu đã được kiểm tra.
- Các bước kiểm chứng liên quan đã đạt yêu cầu hoặc hạn chế được ghi nhận rõ ràng.
- Các thay đổi ngoài ý muốn đã được rà soát.
- File theo dõi tiến độ (`docs/AI_TASK_PLAN.md`) đã được cập nhật.
- Báo cáo cuối cùng phản ánh chính xác kết quả thực tế.

