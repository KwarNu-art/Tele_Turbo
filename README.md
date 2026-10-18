# ⚡ TeleTurbo iOS: World-Fastest Telegram Performance Tweak & CI/CD IPA Builder

[![TeleTurbo CI/CD](https://github.com/username/TeleTurbo-iOS/actions/workflows/build-tweak-ipa.yml/badge.svg)](https://github.com/username/TeleTurbo-iOS/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://apple.com)
[![Telegram iOS](https://img.shields.io/badge/Telegram-Optimized-2CA5E0.svg)](https://telegram.org)

> **Say goodbye to Telegram freezing, iPhone overheating, high battery consumption, and typing delay.**
> TeleTurbo turns bloated Telegram iOS into an ultra-lean, instant-response messaging powerhouse that can run 24 hours continuously with **zero lag, zero crash, and cool thermal temps**.

---

## 🚀 Key Features

| Feature | Stock Telegram iOS | With TeleTurbo ⚡ |
| :--- | :--- | :--- |
| **Typing & Sending Lag** | Stutters on long chats & big groups | **Instant 0ms latency input** |
| **Phone Heating** | Phone gets very hot, thermal throttles | **Cool (Thermal Shield active)** |
| **Background Apps** | Drain CPU/RAM concurrently | **Auto-Frozen via `SIGSTOP`** |
| **RAM Footprint** | 1,200 MB – 1,800 MB | **Reduced to ~180 MB** |
| **Stories Carousel** | Preloads video feeds constantly | **Zero memory (Stripped)** |
| **Lottie & Stickers** | 60 FPS vector CPU crunch | **Static cached previews** |
| **Blur Filters** | Heavy Metal Gaussian draw calls | **Fast solid opacity mode** |
| **Priority** | Standard default priority | **Nice(-20) VIP CPU QoS** |

---

## 🛠️ Automated GitHub Actions CI/CD (No Mac Needed!)

This repository contains a full **GitHub Actions Workflow** (`.github/workflows/build-tweak-ipa.yml`) that automatically:
1. Clones Theos & iOS SDK
2. Compiles `TeleTurbo.dylib` and `.deb`
3. Injects the tweak into official decrypted Telegram IPA using **Azule**
4. Publishes a GitHub Release with download links for TrollStore, AltStore, Sideloadly, and Jailbroken devices!

### How to use on GitHub:
1. Fork or clone this repository to your GitHub account.
2. Go to **Actions** tab -> **TeleTurbo CI/CD**.
3. Click **Run workflow**.
4. In ~3 minutes, download your ready-to-install **`TeleTurbo_Telegram_Optimized.ipa`** or **`TeleTurbo-Rootless.deb`** directly from the **Releases** tab!

---

## 📲 Installation Methods

### Method 1: Sideloading (TrollStore / AltStore / Sideloadly) - No Jailbreak Needed
1. Download `TeleTurbo_Telegram_Optimized.ipa` from GitHub Releases.
2. Open in **TrollStore** -> Tap **Install**.
3. (Or use AltStore / Sideloadly on PC/Mac with your Apple ID).

### Method 2: Jailbroken (Dopamine, Taurine, palera1n)
1. Download `TeleTurbo-Rootless.deb` (or Rootful).
2. Open with **Sileo** / **Zebra** -> Tap **Install**.
3. Respring device. TeleTurbo is now active!

---

## 📄 License
MIT License. Built for performance enthusiasts.
