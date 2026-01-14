## Mô tả
<!-- Mô tả ngắn gọn về thay đổi này -->

## Loại thay đổi
<!-- Đánh dấu [x] vào ô thích hợp -->
- [ ] 🐛 Bug fix
- [ ] ✨ Feature mới
- [ ] 🔧 Cập nhật cấu hình
- [ ] 📝 Cập nhật documentation
- [ ] 🔒 Security fix
- [ ] 🎨 Refactoring
- [ ] ⚡ Performance improvement

## Checklist
<!-- Đánh dấu [x] khi hoàn thành -->
- [ ] Code đã được format với `terraform fmt`
- [ ] Code đã pass `terraform validate`
- [ ] Đã test local với `terraform plan`
- [ ] Đã review Checkov security scan results
- [ ] Đã update documentation (nếu cần)
- [ ] Đã kiểm tra cost impact của thay đổi

## Terraform Plan Output
<!-- Paste kết quả terraform plan hoặc link đến workflow run -->
```
Paste terraform plan output here (optional)
```

## Checkov Scan Results
<!-- Các security issues từ Checkov (nếu có) -->
- [ ] Không có security issues
- [ ] Có issues nhưng đã được review và approve
- [ ] Đã fix tất cả security issues

## AWS Resources Impact
<!-- List các AWS resources bị ảnh hưởng -->
- Resources sẽ được tạo: 
- Resources sẽ bị xóa: 
- Resources sẽ bị modify: 

## Cost Estimate
<!-- Ước tính chi phí (nếu có) -->
- Estimated monthly cost: $
- Cost change: + / - / = 

## Testing
<!-- Mô tả cách test thay đổi này -->
- [ ] Tested locally
- [ ] Tested in dev environment
- [ ] Verified in AWS Console

## Screenshots / Logs
<!-- Thêm screenshots hoặc logs nếu cần -->

## Additional Notes
<!-- Thông tin bổ sung -->

---
**Reviewer Notes:**
- Review cẩn thận Terraform plan trước khi approve
- Kiểm tra Checkov security report
- Verify cost impact
- Đảm bảo không có hard-coded secrets
