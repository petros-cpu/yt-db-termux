#!/data/data/com.termux/files/usr/bin/bash
pkg update -y && pkg upgrade -y
pkg install python git ffmpeg sqlite -y
pip install yt-dlp

mkdir -p ~/yt-db && cd ~/yt-db

sqlite3 youtube.db "CREATE TABLE IF NOT EXISTS videos (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, url TEXT, duration TEXT, downloaded INTEGER DEFAULT 0);"

cat <<EOF > downloader.py
import sqlite3
import yt_dlp
import os

def save_video_to_db(title, url, duration):
    conn = sqlite3.connect("youtube.db")
    cursor = conn.cursor()
    cursor.execute("INSERT INTO videos (title, url, duration, downloaded) VALUES (?, ?, ?, ?)",
                   (title, url, duration, 1))
    conn.commit()
    conn.close()

def download_video(url):
    ydl_opts = {
        'outtmpl': '/data/data/com.termux/files/home/storage/downloads/%(title)s.%(ext)s',
        'nocheckcertificate': True,
        'check_formats': False,
        'ignoreerrors': True,
        'nooverwrites': True,
        'quiet': False,
        'postprocessors': [{
            'key': 'FFmpegVideoConvertor',
            'preferedformat': 'mp4'
        }]
    }

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=True)
        if info is not None:
            title = info.get('title')
            duration = str(info.get('duration'))
            save_video_to_db(title, url, duration)

def batch_download():
    filepath = os.path.expanduser("~/yt-db/urls.txt")
    if not os.path.exists(filepath):
        print("URL list file not found.")
        return

    with open(filepath, 'r') as f:
        for line in f:
            url = line.strip()
            if url:
                print(f"Downloading: {url}")
                download_video(url)

if __name__ == "__main__":
    batch_download()
EOF

touch urls.txt

echo "Setup complete. Run: python ~/yt-db/downloader.py"
