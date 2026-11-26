import argparse
import json
from pathlib import Path
from shutil import copyfileobj
from zipfile import ZIP_DEFLATED, ZipFile


INDEX = "modrinth.index.json"


def is_addon(path):
    return path.startswith(("mods/", "shaderpacks/"))


def files_for(index, side, lite_paths=None):
    files = {}
    for entry in index["files"]:
        requirement = entry.get("env", {}).get(side, "required")
        if requirement == "unsupported":
            continue

        path = entry["path"]
        if path in files:
            raise ValueError(f"Duplicate {side} download: {path}")
        if lite_paths is not None and is_addon(path) and path not in lite_paths:
            requirement = "optional"
        env = {"client": "unsupported", "server": "unsupported"}
        env[side] = requirement
        files[path] = {**entry, "env": env}
    return files


def overrides_for(archive, side):
    files = {}
    for folder in ("overrides/", f"{side}-overrides/"):
        for entry in archive.infolist():
            if not entry.is_dir() and entry.filename.startswith(folder):
                files[entry.filename[len(folder):]] = (archive, entry)
    return files


def write_pack(path, index, downloads, overrides):
    with ZipFile(path, "x", compression=ZIP_DEFLATED) as output:
        output.writestr(INDEX, json.dumps(
            {**index, "files": [downloads[name] for name in sorted(downloads)]},
            indent=2,
        ))
        for _, (archive, entry) in sorted(overrides.items()):
            with archive.open(entry) as source, output.open(entry.filename, "w") as target:
                copyfileobj(source, target)


def write_server(output_dir, index, downloads, archive, revision):
    version = f"{index['versionId']}-r{revision}"
    index = {**index, "name": f"{index['name']} Server", "versionId": version}
    write_pack(output_dir / f"MODPACK-Server-{version}.mrpack",
               index, downloads, overrides_for(archive, "server"))


def package_both(full_path, lite_path, server_path, output_dir):
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

        lite_paths = lite_overrides.keys() | files_for(lite_index, "client").keys()
        client_files = files_for(full_index, "client", lite_paths)
        server_files = files_for(server_index, "server")
        for path in client_files.keys() & server_files.keys():
            client, dedicated = client_files[path], server_files[path]
            if client["hashes"] != dedicated["hashes"] or client["fileSize"] != dedicated["fileSize"]:
                raise ValueError(f"Client and server exports pin different files at {path}")

        version = full_index["versionId"]
        write_pack(output_dir / f"MODPACK-Client-{version}.mrpack", full_index, client_files,
                   {**full_overrides, **lite_overrides})
        write_server(output_dir, server_index, server_files, server, revision=1)


def package_server(server_path, output_dir, revision):
    with ZipFile(server_path) as server:
        index = json.loads(server.read(INDEX))
        write_server(output_dir, index, files_for(index, "server"), server, revision)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Package the Client and Server Packwiz exports.")
    commands = parser.add_subparsers(dest="command", required=True)
    both = commands.add_parser("both")
    both.add_argument("full", type=Path)
    both.add_argument("lite", type=Path)
    both.add_argument("server", type=Path)
    both.add_argument("output_dir", type=Path)
    server = commands.add_parser("server")
    server.add_argument("server", type=Path)
    server.add_argument("output_dir", type=Path)
    server.add_argument("revision", type=int)
    args = parser.parse_args()
    if args.command == "both":
        package_both(args.full, args.lite, args.server, args.output_dir)
    else:
        package_server(args.server, args.output_dir, args.revision)
