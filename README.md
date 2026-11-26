# MODPACK

Modpack Minecraft tập trung vào **Create** và **Create Aeronautics**, với địa hình Overworld từ Regions Unexplored và Tectonic. Bản phát hành chính có hai tệp `.mrpack`, một cho máy chơi và một cho máy chủ chuyên dụng.

**Minecraft 1.21.1** · **NeoForge 21.1.266**

## Cài đặt

Tải `MODPACK-Client-<version>.mrpack` trong **Assets** của bản phát hành chính rồi nhập vào Prism Launcher. Trong hộp thoại chọn mod tùy chọn, bỏ chọn tất cả để chơi với bộ mod Lite, hoặc chọn các hiệu ứng muốn dùng. Cả hai cách đều dùng thiết lập đồ họa Lite khi cài mới. Shader mặc định tắt. [Bản phát hành mới nhất](https://github.com/QuinnVN/MODPACK/releases/latest) · [Danh sách mod Lite](profiles/lite/allow.txt) · [Thiết lập đồ họa](profiles/lite/configureddefaults/options.txt)

Máy chơi luôn cài CreativeCore, MRU và Entity Texture Features. Chọn Iris nếu muốn dùng shader, Iris Veil Compat hoặc Colorwheel. Nếu chọn shader, bật shader trong phần cài đặt video. Để dùng shader đã vá với Colorwheel, chọn cả Colorwheel và Colorwheel Patcher. Chọn Voxy NeoForge nếu muốn dựng địa hình xa hoặc dùng Voxy Fog.

Tải `MODPACK-Server-<version>-r1.mrpack` trong **Assets** để dựng máy chủ, hoặc theo liên kết **Bản vá server mới nhất** trong ghi chú phát hành nếu có. Dùng trình cài đặt `.mrpack` có hỗ trợ chế độ máy chủ. Máy chủ cài Chunky, Voxy Server Side và các mod có trong danh sách Server. [Danh sách mod Server](profiles/server/allow.txt)

Với các release cũ chỉ có một file `.mrpack`, dùng file đó cho cả máy chơi và máy chủ.

Phiên chơi E4All từ Full từng từ chối máy chơi Lite vì thiếu Particular. Trước khi phát hành, khởi động máy chủ chuyên dụng và thử kết nối từ máy chơi với bộ mod Lite và với đầy đủ mod tùy chọn. [Ghi chú tương thích và kiểm thử](CONTEXT.md#full-lite-and-server-packaging)

## Tạo gói từ mã nguồn

1. Cài packwiz vào `PATH` hoặc đặt tệp thực thi trong `.tools/bin/`. Script ưu tiên thư mục này và tìm `packwiz.exe` trên Windows hoặc `packwiz` trên Linux và macOS. [Hướng dẫn cài packwiz](https://packwiz.infra.link/tutorials/creating/getting-started/)
2. Cài Python 3 vào `PATH`. Script dùng Python để đóng gói các bản xuất của packwiz.
3. Từ thư mục gốc của repo, chạy lệnh tương ứng với shell đang dùng.

   **PowerShell**

   ```powershell
   ./build.ps1
   ```

   **Bash**

   ```bash
   bash ./build.sh
   ```

Lệnh mặc định tạo `MODPACK-Client-<version>.mrpack` và `MODPACK-Server-<version>-r1.mrpack` trong `dist/`. Để chỉ tạo bản vá Server, chạy `./build.ps1 -ServerRevision 2` hoặc `bash ./build.sh --server-revision 2`. Lệnh này chỉ tạo `MODPACK-Server-<version>-r2.mrpack` và giữ các file Client đã build. `<version>` lấy từ `pack/pack.toml`.

Sửa `profiles/lite/allow.txt` để chọn mod và shader bắt buộc khi chơi. Mod và shader còn lại trong Full là tùy chọn trên máy chơi và cần có URL tải xuống. Sửa `profiles/server/allow.txt` để chọn mod và shader cho máy chủ. Mỗi dòng là một đường dẫn tệp tương đối trong `pack/`, ví dụ `mods/farmers-delight.pw.toml`. Script bỏ qua dòng trống và dòng bắt đầu bằng `#`.

## Phát hành trên GitHub

Để phát hành bản chính, cập nhật `version` trong `pack/pack.toml`, commit thay đổi rồi push tag `v<version>`. Ví dụ với `0.4.0`:

```bash
git tag v0.4.0
git push origin v0.4.0
```

Workflow đính kèm cả Client và Server vào bản nháp. Thử kết nối từ Lite và Full trước khi bấm **Publish release**, rồi đánh dấu **Set as latest release** cho bản chính ổn định. Phiên bản có hậu tố như `-snapshot` được đánh dấu prerelease. [Workflow phát hành](.github/workflows/release.yml)

Khi chỉ vá server, giữ `version` trùng với bản chính đã đăng. Commit bản vá rồi push tag `server-v<version>-r<N>`, bắt đầu từ `r2`.

```bash
git tag server-v0.4.0-r2
git push origin server-v0.4.0-r2
```

Bản nháp này chỉ đính kèm file Server và ghi rõ phiên bản Client tương thích. Thử kết nối bằng cả Lite và Full từ bản Client đã phát hành. Khi bấm **Publish release**, để trống **Set as latest release**. Workflow sẽ thêm liên kết bản vá mới nhất vào ghi chú bản chính. Các thay đổi yêu cầu người chơi cập nhật loader hoặc mod dùng chung đi theo quy trình phát hành bản chính.

## Cấu trúc repo

| Đường dẫn | Nội dung |
| --- | --- |
| [`pack/pack.toml`](pack/pack.toml), [`pack/index.toml`](pack/index.toml) | Manifest và index do packwiz quản lý. |
| [`pack/mods/`](pack/mods/), [`pack/shaderpacks/`](pack/shaderpacks/) | Phiên bản mod và shader được ghim bằng các tệp `.pw.toml`. |
| [`pack/config/`](pack/config/), [`pack/defaultconfigs/`](pack/defaultconfigs/), [`pack/kubejs/`](pack/kubejs/) | Cấu hình và nội dung KubeJS dùng chung. |
| [`profiles/`](profiles/) | Danh sách tệp được đóng gói và thiết lập riêng cho từng bản. |
| `dist/` | Các gói `.mrpack` sinh ra khi build, được bỏ qua trong Git. |

Xem mục tiêu của từng bản, kết quả thử nghiệm hiệu năng và các hạng mục đang phát triển trong [CONTEXT.md](CONTEXT.md).
