# Ascent
> WARNING: This application is still under development, please raise an issue for any problem you've encountered

A tool for retrieving wish link from Mihoyo games on Android with a single device

By compling adb to ARM and changing some of it's functions to make it runnable on Android, this application enabled you to directly pair and connect your devices's wireless debugging.

While this application focus on being a tool for Mihoyo game wish link retrieve, the same process can also be useful for other Android applications that need adb shell access to start, such as Ice Box,etc. 

Fork and PR are welcomed ;)

### Docs
#### Generate dart binding for rust code
```shell
flutter_rust_bridge_codegen -r native/src/api.rs -d lib/native/bridge_generated.dart --llvm-path=D:\SOFTWARE\LLVM
```