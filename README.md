# Ascent
![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/4o3F/Ascent/total)
![Discord](https://img.shields.io/discord/1180781478951530537?color=5865F2&label=40EF's Cafe&logo=discord&logoColor=white")
A tool for retrieving wish link from Mihoyo games on Android with single device, no Root or PC required.

**Please give me a star if you like this tool**

Thanks to @Mirai0009 for the excellent [guide](https://gist.github.com/Mirai0009/8615e52e09083de9c0ea2dc00dc62ea8), if you still have problems, please raise a issue or join our [Discord](https://discord.com/invite/6v6HEUaRWk) for support.

Supported:

+ Xiaomi
+ Honor
+ Samsung
+ Vivo/iQOO (Only Android 14, other versions need interaction with customer service)
+ ....mostly all brands

Not supported:

+ ~~Vivo/iQOO~~
+ ~~Samsung~~(Fixed by V2)
+ Huawei/Honor(No wireless debug available, requires PC to enable)

Ascent mainly simulates the ADB wireless debug pairing and connect protocol, thus filtering out the wish history URL from the WebView log of Unity. For tech details, please refer to [my blog post](https://403f.cafe/p/adb-tls-protocol/).



## Build

1. Make sure you have Flutter and Rust installed
2. Simply run `flutter build apk`, it should auto configure everything



[![Stargazers over time](https://starchart.cc/4o3F/Ascent.svg?variant=adaptive)](https://starchart.cc/4o3F/Ascent)