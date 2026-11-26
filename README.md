# MODPACK

Modpack Minecraft xoay quanh **Create** và **Create Aeronautics**. Minecraft **1.21.1** · NeoForge **21.1.266**.

## Cài đặt

- **Client** — Import file `MODPACK-Client-<version>.mrpack` vào Prism Launcher. Bỏ chọn hết mod tùy chọn để chơi Lite, hoặc chọn thêm mod và shader theo ý muốn. Chọn Iris nếu dùng shader.
- **Server** — Dùng trình cài `.mrpack` có chế độ server với file `MODPACK-Server-<version>-r<N>.mrpack`. Nếu ghi chú phát hành có bản vá server, dùng bản mới nhất tương thích với Client.

[GitHub Releases](https://github.com/QuinnVN/MODPACK/releases) · [Danh sách Lite](profiles/lite/allow.txt) · [Danh sách Server](profiles/server/allow.txt)

## Build

Cần Python 3 trên `PATH` và Packwiz trên `PATH` hoặc trong `.tools/bin/`. Chạy từ thư mục gốc của repo. Gói build nằm trong `dist/`.

| Build | PowerShell | Bash |
| --- | --- | --- |
| Client và Server | `./build.ps1` | `bash ./build.sh` |
| Chỉ bản vá Server `r2` | `./build.ps1 -ServerRevision 2` | `bash ./build.sh --server-revision 2` |

[Quy trình phát hành](docs/release.md) · [Ghi chú về modpack](CONTEXT.md)
