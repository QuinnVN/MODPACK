# MODPACK

Snapshot Full của instance PrismLauncher, dùng Minecraft **1.21.1** và NeoForge **21.1.266**. `pack/pack.toml` là manifest packwiz, `pack/index.toml` là index sinh tự động. Kế hoạch Lite và Server nằm trong [CONTEXT.md](CONTEXT.md).

- `pack/mods/` có 218 pin `.pw.toml` từ metadata Prism và bản `voxy-0.6.0.jar` cục bộ. Hash của từng pin khớp với JAR đang bật tại thời điểm chụp snapshot.
- `pack/shaderpacks/` có hai pin shader. `pack/config/`, `pack/defaultconfigs/` và `pack/kubejs/` chứa cấu hình và nội dung KubeJS từ instance.
- `dist/` chứa bản `.mrpack` cục bộ để import vào một instance mới trong PrismLauncher. Packwiz nhúng 14 JAR CurseForge và JAR Voxy, còn 204 mod và hai shader được tải theo URL trong manifest.

Các entry Prism gắn `server` được đặt `both` trong snapshot để Full giữ đủ mod đang bật. Cần xác minh lại `side` trước khi build Server. Hai mod đang tắt trong Prism được bỏ qua. Snapshot bỏ qua `options.txt`, file `.bak`, một số trạng thái client, world save và dữ liệu người chơi. Patch chất lỏng trong `CONTEXT.md` chưa có trong thư mục KubeJS nguồn.

## Dùng packwiz

Chạy `./build.ps1` trong PowerShell hoặc `bash ./build.sh` trong Bash từ thư mục gốc `MODPACK`. Cả hai tạo `dist/MODPACK-Full-0.1.0-snapshot.mrpack` và ưu tiên packwiz cục bộ trong `.tools/bin/` (`packwiz.exe` trên Windows, `packwiz` trên Linux/macOS). Nếu thiếu bản cục bộ, script tìm `packwiz` trong PATH.

Có thể chạy từng lệnh bên dưới trong PowerShell từ `MODPACK/pack`. [Tài liệu packwiz](https://packwiz.infra.link/tutorials/creating/getting-started/)

```powershell
& ../.tools/bin/packwiz.exe list
& ../.tools/bin/packwiz.exe refresh
New-Item -ItemType Directory -Path ../dist -Force | Out-Null
& ../.tools/bin/packwiz.exe --cache ../.tools/packwiz-cache modrinth export -o ../dist/MODPACK-Full-0.1.0-snapshot.mrpack
```

Git bỏ qua JAR cục bộ. Khi dùng checkout mới, khôi phục `pack/mods/voxy-0.6.0.jar` từ instance nguồn trước khi chạy `refresh` hoặc export. SHA-256 của JAR có trong `pack/index.toml`.
