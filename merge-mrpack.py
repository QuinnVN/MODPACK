import argparse
import json
from shutil import copyfileobj
from zipfile import ZIP_DEFLATED, ZipFile


INDEX = "modrinth.index.json"


def is_addon(path):
    return path.startswith(("mods/", "shaderpacks/"))


def merge_files(client_index, server_index, lite_paths):
    files = {}
    for side, index in (("client", client_index), ("server", server_index)):
        for entry in index["files"]:
            requirement = entry.get("env", {}).get(side, "required")
            if requirement == "unsupported":
                continue

            path = entry["path"]
            if side == "client" and is_addon(path) and path not in lite_paths:
                requirement = "optional"
            if path not in files:
                files[path] = {
                    **entry,
                    "env": {"client": "unsupported", "server": "unsupported"},
                }
            merged = files[path]
            if merged["env"][side] != "unsupported":
                raise ValueError(f"Duplicate {side} download: {path}")
            if merged["hashes"] != entry["hashes"] or merged["fileSize"] != entry["fileSize"]:
                raise ValueError(f"Client and server exports pin different files at {path}")
            merged["env"][side] = requirement
            merged["downloads"] = list(dict.fromkeys(merged["downloads"] + entry["downloads"]))
    return sorted(files.values(), key=lambda entry: entry["path"])


def overrides_for(archive, side):
    files = {}
    for folder in ("overrides/", f"{side}-overrides/"):
        for entry in archive.infolist():
            if not entry.is_dir() and entry.filename.startswith(folder):
                files[entry.filename[len(folder):]] = (archive, entry)
    return files


def write_overrides(output, client_files, server_files):
    for path in sorted(client_files.keys() | server_files.keys()):
        client = client_files.get(path)
        server = server_files.get(path)
        if (
            client is not None
            and server is not None
            and client[1].file_size == server[1].file_size
            and client[1].CRC == server[1].CRC
            and client[0].read(client[1]) == server[0].read(server[1])
        ):
            sources = [("overrides", client)]
        else:
            sources = [("client-overrides", client), ("server-overrides", server)]
        for folder, source_entry in sources:
            if source_entry is None:
                continue
            archive, entry = source_entry
            with archive.open(entry) as source, output.open(f"{folder}/{path}", "w") as target:
                copyfileobj(source, target)


def merge_mrpack(full_path, lite_path, server_path, output_path):
    with ZipFile(full_path) as full, ZipFile(lite_path) as lite, ZipFile(server_path) as server:
        full_index = json.loads(full.read(INDEX))
        lite_index = json.loads(lite.read(INDEX))
        server_index = json.loads(server.read(INDEX))
        for key in ("formatVersion", "game", "versionId", "dependencies"):
            if not full_index[key] == lite_index[key] == server_index[key]:
                raise ValueError(f"Full, Lite and Server exports disagree on {key}")

        full_overrides = overrides_for(full, "client")
        lite_overrides = overrides_for(lite, "client")
        for path in sorted(full_overrides.keys() - lite_overrides.keys()):
            if is_addon(path):
                raise ValueError(f"Optional add-on {path} needs a download URL in the manifest")

        lite_paths = lite_overrides.keys() | {
            entry["path"]
            for entry in lite_index["files"]
            if entry.get("env", {}).get("client", "required") != "unsupported"
        }
        full_index["files"] = merge_files(full_index, server_index, lite_paths)

        with ZipFile(output_path, "x", compression=ZIP_DEFLATED) as output:
            output.writestr(INDEX, json.dumps(full_index, indent=2))
            write_overrides(
                output,
                {**full_overrides, **lite_overrides},
                overrides_for(server, "server"),
            )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Combine the Full, Lite and Server Packwiz exports.")
    parser.add_argument("full")
    parser.add_argument("lite")
    parser.add_argument("server")
    parser.add_argument("output")
    args = parser.parse_args()
    merge_mrpack(args.full, args.lite, args.server, args.output)
