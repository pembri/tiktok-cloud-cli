# TikTok Cloud CLI

**TikTok Cloud CLI by Rira Project** is a TikTok video downloader for your terminal. Paste a link, check the video info, and download it as MP4. Built for **Termux (Android)**.

## Features

- Download TikTok **videos** as MP4 (video and audio are merged without re-encoding, so it is fast and keeps the original quality)
- Supports full links and short links (`vt.tiktok.com`, `vm.tiktok.com`)
- Shows the video info (title, uploader, duration, quality, estimated size) before downloading
- **Multi-download**: give several links and get them all in one run
- Automatic retry when TikTok temporarily refuses a download
- One-command update (`--update`) that refreshes the required components first
- Colorized, easy-to-read terminal UI
- Single-file installer and a clean uninstaller that never touches your downloads

## Requirements

- Termux (Android)
- Internet connection
- `git` (only to clone this repo): `pkg install git`

Everything else (Python, FFmpeg, yt-dlp, Deno, curl) is installed by the installer.

## Installation

```bash
pkg install -y git && git clone https://github.com/pembri/tiktok-cloud-cli && cd tiktok-cloud-cli && chmod +x install.sh && ./install.sh
```

The installer will automatically:
1. Check that you are running Termux
2. Install `python`, `ffmpeg` and `deno`
3. Install `yt-dlp`
4. Check storage access (tap **Allow** when Android asks for permission)
5. Fetch the `tiktok-cloud` command and install it so it can be run from anywhere

The cloned `tiktok-cloud-cli` folder is removed automatically once installation finishes. You don't need to clean it up yourself, and it isn't needed to run `tiktok-cloud` afterward.

If you see `command not found` after installing, run `exec $SHELL` and try again.

## Usage

| Command | What it does |
|---|---|
| `tiktok-cloud` | Interactive mode, asks for the link |
| `tiktok-cloud "URL"` | Show the video info, then choose the quality |
| `tiktok-cloud "URL" "URL" "URL"` | Download several links at once |
| `tiktok-cloud --version` | Show the version number |
| `tiktok-cloud --help` | Show the help page |
| `tiktok-cloud --update` | Refresh the required components, then update to the latest version |
| `tiktok-cloud --remove` | Uninstall TikTok Cloud CLI |

Interactive mode looks like this:

```
 ########\##\ ##\         ##\               ##\
\__##  __|\__|## |        ## |              ## |
   ## |   ##\ ## |  ##\ ######\    ######\  ## |  ##\
   ## |   ## |## | ##  |\_##  _|  ##  __##\ ## | ##  |
   ## |   ## |######  /   ## |    ## /  ## |######  /
   ## |   ## |##  _##<    ## |##\ ## |  ## |##  _##<
   ## |   ## |## | \##\   \####  |\######  |## | \##\
   \__|   \__|\__|  \__|   \____/  \______/ \__|  \__|
 ######\  ##\                           ##\
##  __##\ ## |                          ## |
## /  \__|## | ######\  ##\   ##\  ####### |
## |      ## |##  __##\ ## |  ## |##  __## |
## |      ## |## /  ## |## |  ## |## /  ## |
## |  ##\ ## |## |  ## |## |  ## |## |  ## |
\######  |## |\######  |\######  |\####### |
 \______/ \__| \______/  \______/  \_______|


##############################################################\
##                     TikTok Cloud CLI                     ## |
##            TikTok Video Downloader For Termux            ## |
##                                                          ## |
##  Version   : v2.1                                        ## |
##  Developed : Rira Project                                ## |
##  Github    : https://github.com/pembri/tiktok-cloud-cli  ## |
\############################################################# |

Input URL :
```

Steps:
1. Paste one or more links (separated by spaces)
2. Check the video info
3. Choose the video quality (or `0) Exit` to cancel)
4. The video is saved to the download folder

### Downloading several links

- Separate the links with spaces, with or without quotes: `tiktok-cloud "URL" "URL"` or `tiktok-cloud URL URL`
- The same works at the `Input URL :` prompt (all links on one line)
- One failed link never stops the others, and a summary is shown at the end

## Download Location

```
/sdcard/Download/tiktok-cloud/
```

The folder is created automatically on the first download. Files are named `Title [video id].mp4`.

## Repo Structure

```
tiktok-cloud-cli/
├── install.sh
└── README.md
```

`install.sh` fetches the `tiktok-cloud` command and installs it directly to Termux's `bin` folder. The cloned repo folder is deleted automatically right after installation, so nothing is left behind except the ready-to-use `tiktok-cloud` command.

## Updating

```bash
tiktok-cloud --update
```

Before anything else, the update refreshes every component the tool relies on, so downloads keep working when TikTok changes something. It then clones a fresh, temporary copy of this repo, reinstalls `tiktok-cloud` from it, and removes the temporary copy afterward, so you always end up on the latest version without any leftover files.

If your version is too old to have `--update`, update once by hand:

```bash
git clone https://github.com/pembri/tiktok-cloud-cli && cd tiktok-cloud-cli && chmod +x install.sh && ./install.sh
```

## Uninstall

```bash
tiktok-cloud --remove
```

This will remove:
- The `tiktok-cloud` command
- The install record
- The yt-dlp cache

You'll also be asked whether to keep or remove the packages the installer added on top of what was already on your device (for example `ffmpeg`, `deno`, or `yt-dlp` if they weren't installed before). Keeping them is the safe default if you plan to reinstall later or use them for something else. If `ytcloud` is also installed, these shared packages are always kept.

Your downloaded files in `/sdcard/Download/tiktok-cloud` are **never** deleted. The folder is only removed when it is completely empty.

## Notes

- Put links in quotes, or use the `Input URL :` prompt. Links containing `&` or `?` can be misread by the terminal.
- Only single videos are downloaded, not whole profiles or playlists.
- Photo slideshows, private videos and login-required content cannot be downloaded.
- If downloads fail with errors about a JS runtime, cookies or `HTTP 403`, run `tiktok-cloud --update`.
- This tool uses [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [FFmpeg](https://ffmpeg.org/) as its core engines.

## License

For personal use. Please respect content owners' copyright when downloading or redistributing media.
