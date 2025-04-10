# yt-db-termux

A YouTube downloader that stores video metadata in an SQLite database. Built for Termux with support for storage access and checksum bypass.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/YourUsername/yt-db-termux/main/install.sh | bash
```

## Usage

```bash
cd ~/yt-db
nano urls.txt  # add YouTube video URLs
python downloader.py
```

Videos are saved to your Downloads folder.
