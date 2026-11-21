# MODPACK

Modpack Minecraft tập trung vào **Create** và **Create Aeronautics**, với địa hình Overworld từ Regions Unexplored và Tectonic. Hai bản chơi Full và Lite được thiết kế để kết nối vào cùng một máy chủ chuyên dụng chạy bản Server.

**Minecraft 1.21.1** · **NeoForge 21.1.266** · **Phiên bản `0.1.0-snapshot`**

## Các phiên bản

| Bản | Tệp xuất | Nội dung |
| --- | --- | --- |
| **Full** | `MODPACK-<date>.mrpack` | Bản chơi đầy đủ, gồm shader, Voxy và các hiệu ứng hình ảnh. |
| **Lite** | `MODPACK-<date>-lite.mrpack` | Bản chơi cho máy cấu hình thấp. Giữ Sodium và ImmediatelyFast, dùng thiết lập đồ họa nhẹ và lược bỏ shader, Voxy phía máy chơi và Particular. [Danh sách loại trừ](profiles/lite/exclude.txt) · [Thiết lập đồ họa](profiles/lite/options.txt) |
| **Server** | `MODPACK-<date>-server.mrpack` | Bản cho máy chủ chuyên dụng. Giữ Chunky và Voxy Server Side, lược bỏ mod phía máy chơi, shader và NumFlux. [Danh sách loại trừ](profiles/server/exclude.txt) |

Để chơi, nhập tệp `.mrpack` của bản Full hoặc Lite vào Prism Launcher. Với máy chủ chuyên dụng, dùng tệp của bản Server với trình cài đặt hỗ trợ `.mrpack` phía máy chủ.

Bản Lite từng bị phiên chơi E4All từ Full từ chối vì thiếu Particular. Quy trình kiểm thử trước khi phát hành là khởi động bản Server rồi thử kết nối từ cả hai bản chơi mới cài. [Ghi chú tương thích và kiểm thử](CONTEXT.md#full-lite-and-server-packaging)

## Tạo gói từ mã nguồn

1. Cài packwiz vào `PATH` hoặc đặt tệp thực thi trong `.tools/bin/`. Script ưu tiên thư mục này và tìm `packwiz.exe` trên Windows hoặc `packwiz` trên Linux và macOS. [Hướng dẫn cài packwiz](https://packwiz.infra.link/tutorials/creating/getting-started/)
2. Chép `voxy-0.6.0.jar` từ instance Prism Launcher gốc vào `pack/mods/`. Tệp JAR này được bỏ qua trong Git và cần có để chạy script build. SHA-256 của tệp được ghi trong [index của packwiz](pack/index.toml).
3. Từ thư mục gốc của repo, chạy lệnh tương ứng với shell đang dùng.

   **PowerShell**

   ```powershell
   ./build.ps1
   ```

   **Bash**

   ```bash
   bash ./build.sh
   ```

Mỗi lần chạy tạo cả ba gói trong `dist/`. `<date>` là ngày build theo định dạng `YYYY-MM-DD`. Script áp dụng cấu hình từng bản trên bản sao tạm của `pack/`, sau đó chạy `packwiz refresh` và `packwiz modrinth export`.

Để chỉnh bản Lite hoặc Server, sửa `exclude.txt` tương ứng. Mỗi dòng là một đường dẫn tệp tương đối trong `pack/`, ví dụ `mods/iris.pw.toml`. Script bỏ qua dòng trống và dòng bắt đầu bằng `#`.

## Cấu trúc repo

| Đường dẫn | Nội dung |
| --- | --- |
| [`pack/pack.toml`](pack/pack.toml), [`pack/index.toml`](pack/index.toml) | Manifest và index do packwiz quản lý. |
| [`pack/mods/`](pack/mods/), [`pack/shaderpacks/`](pack/shaderpacks/) | Phiên bản mod và shader được ghim bằng các tệp `.pw.toml`. |
| [`pack/config/`](pack/config/), [`pack/defaultconfigs/`](pack/defaultconfigs/), [`pack/kubejs/`](pack/kubejs/) | Cấu hình và nội dung KubeJS dùng chung. |
| [`profiles/`](profiles/) | Danh sách loại trừ và thiết lập riêng cho từng bản. |
| `dist/` | Các gói `.mrpack` sinh ra khi build, được bỏ qua trong Git. |

Xem mục tiêu của từng bản, kết quả thử nghiệm hiệu năng và các hạng mục đang phát triển trong [CONTEXT.md](CONTEXT.md).
