# Phát hành trên GitHub

## Bản chính

Cập nhật `version` trong `pack/pack.toml`, commit thay đổi rồi tạo và push tag `v<version>` như ví dụ dưới đây. [Packwiz manifest](../pack/pack.toml)

```bash
git tag v0.4.0
git push origin v0.4.0
```

Workflow tạo bản nháp có file Client và Server `r1`. Thử kết nối vào server từ cả Client Lite và Full trước khi bấm **Publish release**. Chọn **Set as latest release** cho bản chính ổn định. Phiên bản có hậu tố như `-snapshot` được đánh dấu prerelease. [Workflow phát hành](../.github/workflows/release.yml)

## Bản vá server

Giữ `version` trùng với bản chính đã đăng. Commit bản vá rồi tạo và push tag `server-v<version>-r<N>`, bắt đầu từ `r2`.

```bash
git tag server-v0.4.0-r2
git push origin server-v0.4.0-r2
```

Bản nháp chỉ có file Server và ghi rõ phiên bản Client tương thích. Thử kết nối từ cả Lite và Full của bản Client đã phát hành. Khi đăng, để trống **Set as latest release**. Workflow sẽ cập nhật liên kết **Bản vá server mới nhất** trong ghi chú bản chính.

Nếu thay đổi loader hoặc mod dùng chung khiến người chơi phải cập nhật Client, phát hành bản chính mới.
