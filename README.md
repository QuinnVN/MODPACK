# MODPACK

Modpack từ snapshot của instance PrismLauncher, dùng Minecraft **1.21.1** và NeoForge **21.1.266**. `pack/pack.toml` là manifest packwiz, `pack/index.toml` là index sinh tự động. Xem [CONTEXT.md](CONTEXT.md) để biết mục tiêu của từng bản.

- `pack/mods/` có 218 pin `.pw.toml` từ metadata Prism và bản `voxy-0.6.0.jar` cục bộ. Hash của từng pin khớp với JAR đang bật tại thời điểm chụp snapshot.
- `pack/shaderpacks/` có hai pin shader. `pack/config/`, `pack/defaultconfigs/` và `pack/kubejs/` chứa cấu hình và nội dung KubeJS từ instance.
- Trong bản Full, packwiz nhúng 14 JAR CurseForge và JAR Voxy. Manifest cung cấp URL tải 204 mod và hai shader.

Các entry Prism gắn `server` được đặt `both` trong snapshot để Full giữ đủ mod đang bật. Hai mod đang tắt trong Prism được bỏ qua. Snapshot bỏ qua `options.txt`, file `.bak`, một số trạng thái client, world save và dữ liệu người chơi.

## Dùng packwiz

Chạy `./build.ps1` trong PowerShell hoặc `bash ./build.sh` trong Bash từ thư mục gốc `MODPACK`. Mỗi lần chạy xuất ba gói vào `dist/`, với `<date>` là ngày build theo định dạng `YYYY-MM-DD`.

- `MODPACK-<date>.mrpack` là bản Full.
- `MODPACK-<date>-lite.mrpack` dùng [danh sách Lite](profiles/lite/exclude.txt) và [thiết lập đồ họa nhẹ](profiles/lite/options.txt). Lite giữ Sodium và ImmediatelyFast, bỏ shader, Voxy client và Particular. Một host E4All cũ từng từ chối Lite vì thiếu Particular.
- `MODPACK-<date>-server.mrpack` dùng [danh sách Server](profiles/server/exclude.txt) để bỏ mod client, shader và NumFlux. Bản Server giữ Chunky và Voxy Server Side.

Mỗi dòng trong `exclude.txt` là đường dẫn tương đối trong `pack/`, ví dụ `mods/iris.pw.toml`. Dòng trống và dòng bắt đầu bằng `#` được bỏ qua. Script áp dụng danh sách lên bản sao tạm trước khi chạy `packwiz refresh` và export từng bản, rồi đưa cả ba gói ra `dist/`.

Script ưu tiên packwiz cục bộ trong `.tools/bin/` (`packwiz.exe` trên Windows, `packwiz` trên Linux/macOS), sau đó tìm `packwiz` trong PATH. Khi dùng checkout mới, khôi phục `pack/mods/voxy-0.6.0.jar` từ instance nguồn trước khi build. SHA-256 của JAR có trong `pack/index.toml`. [Tài liệu packwiz](https://packwiz.infra.link/tutorials/creating/getting-started/)
