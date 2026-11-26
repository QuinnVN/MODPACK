# MODPACK

Modpack Minecraft tập trung vào **Create** và **Create Aeronautics**, với địa hình Overworld từ Regions Unexplored và Tectonic. Một tệp `.mrpack` dùng chung cho máy chơi và máy chủ chuyên dụng.

**Minecraft 1.21.1** · **NeoForge 21.1.266** · **Phiên bản `0.1.1-snapshot`**

## Cài đặt

Nhập `MODPACK-<timestamp>.mrpack` vào Prism Launcher. Trong hộp thoại chọn mod tùy chọn, bỏ chọn tất cả để chơi với bộ mod Lite, hoặc chọn các hiệu ứng muốn dùng. Cả hai cách đều dùng thiết lập đồ họa Lite khi cài mới. Shader mặc định tắt. [Danh sách mod Lite](profiles/lite/allow.txt) · [Thiết lập đồ họa](profiles/lite/configureddefaults/options.txt)

Máy chơi luôn cài CreativeCore, MRU và Entity Texture Features. Chọn Iris nếu muốn dùng shader, Iris Veil Compat hoặc Colorwheel. Nếu chọn shader, bật shader trong phần cài đặt video. Để dùng shader đã vá với Colorwheel, chọn cả Colorwheel và Colorwheel Patcher. Chọn Voxy NeoForge nếu muốn dựng địa hình xa hoặc dùng Voxy Fog.

Dùng cùng tệp đó với trình cài đặt `.mrpack` có hỗ trợ chế độ máy chủ. Máy chủ cài Chunky, Voxy Server Side và các mod có trong danh sách Server. [Danh sách mod Server](profiles/server/allow.txt)

Phiên chơi E4All từ Full từng từ chối máy chơi Lite vì thiếu Particular. Trước khi phát hành, khởi động máy chủ chuyên dụng và thử kết nối từ máy chơi với bộ mod Lite và với đầy đủ mod tùy chọn. [Ghi chú tương thích và kiểm thử](CONTEXT.md#full-lite-and-server-packaging)

## Tạo gói từ mã nguồn

1. Cài packwiz vào `PATH` hoặc đặt tệp thực thi trong `.tools/bin/`. Script ưu tiên thư mục này và tìm `packwiz.exe` trên Windows hoặc `packwiz` trên Linux và macOS. [Hướng dẫn cài packwiz](https://packwiz.infra.link/tutorials/creating/getting-started/)
2. Cài Python 3 vào `PATH`. Script dùng Python để ghép các bản xuất của packwiz.
3. Từ thư mục gốc của repo, chạy lệnh tương ứng với shell đang dùng.

   **PowerShell**

   ```powershell
   ./build.ps1
   ```

   **Bash**

   ```bash
   bash ./build.sh
   ```

Mỗi lần chạy tạo một tệp `MODPACK-<timestamp>.mrpack` trong `dist/`. `<timestamp>` là dấu thời gian Unix tính bằng giây khi bắt đầu build. Script xuất Full, Lite và Server từ bản sao tạm của `pack/` rồi ghép chúng vào tệp này.

Sửa `profiles/lite/allow.txt` để chọn mod và shader bắt buộc khi chơi. Mod và shader còn lại trong Full là tùy chọn trên máy chơi và cần có URL tải xuống. Sửa `profiles/server/allow.txt` để chọn mod và shader cho máy chủ. Mỗi dòng là một đường dẫn tệp tương đối trong `pack/`, ví dụ `mods/farmers-delight.pw.toml`. Script bỏ qua dòng trống và dòng bắt đầu bằng `#`.

## Cấu trúc repo

| Đường dẫn | Nội dung |
| --- | --- |
| [`pack/pack.toml`](pack/pack.toml), [`pack/index.toml`](pack/index.toml) | Manifest và index do packwiz quản lý. |
| [`pack/mods/`](pack/mods/), [`pack/shaderpacks/`](pack/shaderpacks/) | Phiên bản mod và shader được ghim bằng các tệp `.pw.toml`. |
| [`pack/config/`](pack/config/), [`pack/defaultconfigs/`](pack/defaultconfigs/), [`pack/kubejs/`](pack/kubejs/) | Cấu hình và nội dung KubeJS dùng chung. |
| [`profiles/`](profiles/) | Danh sách tệp được đóng gói và thiết lập riêng cho từng bản. |
| `dist/` | Các gói `.mrpack` sinh ra khi build, được bỏ qua trong Git. |

Xem mục tiêu của từng bản, kết quả thử nghiệm hiệu năng và các hạng mục đang phát triển trong [CONTEXT.md](CONTEXT.md).
