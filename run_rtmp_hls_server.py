#!/usr/bin/env python3
"""
Bootstrap an RTMP ingest + HLS playback server using MediaMTX via Python.

What this script does:
  - Detects your macOS architecture (arm64 or x86_64)
  - Downloads MediaMTX binary
  - Writes a minimal config enabling RTMP (1935) and HLS (8080)
  - Starts the server and prints the publish/play URLs

Usage:
  python3 run_rtmp_hls_server.py --port 8080 --rtmp 1935 --path live --stream stream

Then in your iOS app:
  - RTMP (publish): rtmp://<Mac_IP>:1935/<path>/<stream>
  - HLS (play):    http://<Mac_IP>:8080/<path>/<stream>/index.m3u8
"""

import argparse
import os
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

def find_system_mediatx() -> str | None:
    # Try PATH first
    path = shutil.which("mediamtx")
    if path:
        return path
    # Common Homebrew locations on Apple Silicon and Intel
    candidates = [
        "/opt/homebrew/bin/mediamtx",
        "/usr/local/bin/mediamtx",
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return None


def detect_mediatx_asset() -> str:
    system = platform.system().lower()
    machine = platform.machine().lower()
    if system != "darwin":
        print("This helper targets macOS (darwin).", file=sys.stderr)
        sys.exit(2)
    if "arm64" in machine or "aarch64" in machine:
        return "mediamtx_darwin_arm64.tar.gz"
    # assume x86_64
    return "mediamtx_darwin_amd64.tar.gz"


def download_file(url: str, dest: str):
    print(f"Downloading {url} ...")
    with urllib.request.urlopen(url) as resp, open(dest, "wb") as out:
        shutil.copyfileobj(resp, out)
    print(f"Saved to {dest}")


def extract_tar_gz(archive_path: str, target_dir: str):
    with tarfile.open(archive_path, "r:gz") as tar:
        tar.extractall(path=target_dir)


def write_config(cfg_path: str, http_port: int, rtmp_port: int, path_name: str):
    cfg = f"""
rtmp:
  enabled: yes
  address: :{rtmp_port}

hls:
  enabled: yes
  address: :{http_port}

paths:
  {path_name}:
    source: publisher
    hlsSegmentCount: 6
    hlsSegmentDuration: 1s
    hlsPartDuration: 200ms
""".lstrip()
    with open(cfg_path, "w") as f:
        f.write(cfg)


def main(argv):
    parser = argparse.ArgumentParser(description="Run RTMP+HLS server (MediaMTX)")
    parser.add_argument("--port", type=int, default=8080, help="HLS HTTP port")
    parser.add_argument("--rtmp", type=int, default=1935, help="RTMP port")
    parser.add_argument("--path", default="live", help="Application/path name")
    parser.add_argument("--stream", default="stream", help="Stream key/name")
    args = parser.parse_args(argv)

    # Ensure a working directory for config/artifacts
    work_dir = os.path.join(os.getcwd(), "mediamtx_bin")
    os.makedirs(work_dir, exist_ok=True)

    # Prefer a system-installed mediamtx (brew) to avoid broken URLs
    binary_path = find_system_mediatx()
    if not binary_path:
        # Attempt Homebrew install non-interactively
        print("mediamtx not found; attempting Homebrew install ...")
        try:
            subprocess.run(["brew", "install", "mediamtx"], check=True)
            binary_path = find_system_mediatx()
        except Exception as exc:
            print(f"Homebrew install failed: {exc}. Falling back to direct download ...")

    if not binary_path:
        asset = detect_mediatx_asset()
        url = f"https://github.com/bluenviron/mediamtx/releases/latest/download/{asset}"

        archive_path = os.path.join(work_dir, asset)

        try:
            download_file(url, archive_path)
            extract_tar_gz(archive_path, work_dir)
        except Exception as exc:
            print(f"Direct download failed: {exc}", file=sys.stderr)
            return 1

        binary_path = os.path.join(work_dir, "mediamtx")
        if not os.path.isfile(binary_path):
            print("mediamtx binary not found after extraction", file=sys.stderr)
            return 1
        os.chmod(binary_path, 0o755)

    cfg_path = os.path.join(work_dir, "mediamtx.yml")
    write_config(cfg_path, args.port, args.rtmp, args.path)

    publish_url = f"rtmp://<Mac_IP>:{args.rtmp}/{args.path}/{args.stream}"
    hls_url = f"http://<Mac_IP>:{args.port}/{args.path}/{args.stream}/index.m3u8"
    print("\nURLs (replace <Mac_IP> with your LAN IP):")
    print(f"  RTMP publish: {publish_url}")
    print(f"  HLS play:     {hls_url}\n")

    print("Starting MediaMTX ... Press Ctrl+C to stop.\n")
    # Run in foreground; caller can background if needed
    env = os.environ.copy()
    cmd = [binary_path, cfg_path]
    proc = subprocess.Popen(cmd)
    try:
        proc.wait()
    except KeyboardInterrupt:
        proc.terminate()
        proc.wait()
    return proc.returncode


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))


