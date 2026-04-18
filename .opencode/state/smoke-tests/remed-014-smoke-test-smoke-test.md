# Smoke Test

## Ticket

- REMED-014

## Overall Result

Overall Result: PASS

## Notes

All detected deterministic smoke-test commands passed.

## Commands

### 1. command override 1

- reason: Explicit smoke-test command override supplied by the caller.
- command: `godot4 --headless --path . --export-debug Android Debug build/android/womanvshorseVA-debug.apk`
- exit_code: 0
- duration_ms: 10194
- missing_executable: none
- failure_classification: none
- blocked_by_permissions: false

#### stdout

~~~~text
Godot Engine v4.6.1.stable.official.14d19694e - https://godotengine.org

Could not find version of build tools that matches Target SDK, using 34.0.0
[   0% ] [90m[1mfirst_scan_filesystem[22m | Started Project initialization (5 steps)[39m[0m
[   0% ] [90m[1mfirst_scan_filesystem[22m | Scanning file structure...[39m[0m
[  16% ] [90m[1mfirst_scan_filesystem[22m | Loading global class names...[39m[0m
[  33% ] [90m[1mfirst_scan_filesystem[22m | Verifying GDExtensions...[39m[0m
[  50% ] [90m[1mfirst_scan_filesystem[22m | Creating autoload scripts...[39m[0m
[  66% ] [90m[1mfirst_scan_filesystem[22m | Initializing plugins...[39m[0m
[  83% ] [90m[1mfirst_scan_filesystem[22m | Starting file scan...[39m[0m
[92m[ DONE ][39m [1mfirst_scan_filesystem[22m
[0m
Could not find version of build tools that matches Target SDK, using 34.0.0
[   0% ] [90m[1mexport[22m | Started Exporting for Android (105 steps)[39m[0m
0 param: --xr_mode_regular
1 param: --xr-mode
2 param: off
3 param: --fullscreen
4 param: --background_color
5 param: #000000
[   0% ] [90m[1mexport[22m | Creating APK...[39m[0m
ADDING: classes.dex
ADDING: classes2.dex
ADDING: classes3.dex
ADDING: classes4.dex
ADDING: lib/arm64-v8a/libc++_shared.so
ADDING: lib/arm64-v8a/libgodot_android.so
ADDING: DebugProbesKt.bin
ADDING: kotlin/annotation/annotation.kotlin_builtins
ADDING: kotlin/collections/collections.kotlin_builtins
ADDING: kotlin/coroutines/coroutines.kotlin_builtins
ADDING: kotlin/internal/internal.kotlin_builtins
ADDING: kotlin/kotlin.kotlin_builtins
ADDING: kotlin/ranges/ranges.kotlin_builtins
ADDING: kotlin/reflect/reflect.kotlin_builtins
Adding application metadata org.godotengine.rendering.method
Adding application metadata org.godotengine.editor.version
Adding feature android.hardware.vulkan.level
Adding feature android.hardware.vulkan.version
ADDING: AndroidManifest.xml
ADDING: res/anim-v21/fragment_fast_out_extra_slow_in.xml
ADDING: res/animator/fragment_close_enter.xml
ADDING: res/animator/fragment_close_exit.xml
ADDING: res/animator/fragment_fade_enter.xml
ADDING: res/animator/fragment_fade_exit.xml
ADDING: res/animator/fragment_open_enter.xml
ADDING: res/animator/fragment_open_exit.xml
ADDING: res/drawable-hdpi-v4/notification_bg_low_normal.9.png
ADDING: res/drawable-hdpi-v4/notification_bg_low_pressed.9.png
ADDING: res/drawable-hdpi-v4/notification_bg_normal.9.png
ADDING: res/drawable-hdpi-v4/notification_bg_normal_pressed.9.png
ADDING: res/drawable-hdpi-v4/notify_panel_notification_icon_bg.png
ADDING: res/drawable-mdpi-v4/notification_bg_low_normal.9.png
ADDING: res/drawable-mdpi-v4/notification_bg_low_pressed.9.png
ADDING: res/drawable-mdpi-v4/notification_bg_normal.9.png
ADDING: res/drawable-mdpi-v4/notification_bg_normal_pressed.9.png
ADDING: res/drawable-mdpi-v4/notify_panel_notification_icon_bg.png
ADDING: res/drawable-v21/notification_action_background.xml
ADDING: res/drawable-v23/compat_splash_screen.xml
ADDING: res/drawable-v23/compat_splash_screen_no_icon_background.xml
ADDING: res/drawable-xhdpi-v4/notification_bg_low_normal.9.png
ADDING: res/drawable-xhdpi-v4/notification_bg_low_pressed.9.png
ADDING: res/drawable-xhdpi-v4/notification_bg_normal.9.png
ADDING: res/drawable-xhdpi-v4/notification_bg_normal_pressed.9.png
ADDING: res/drawable-xhdpi-v4/notify_panel_notification_icon_bg.png
ADDING: res/drawable/compat_splash_screen.xml
ADDING: res/drawable/compat_splash_screen_no_icon_background.xml
ADDING: res/drawable/icon_background.xml
ADDING: res/drawable/notification_bg.xml
ADDING: res/drawable/notification_bg_low.xml
ADDING: res/drawable/notification_icon_background.xml
ADDING: res/drawable/notification_tile_bg.xml
ADDING: res/layout-v21/notification_action.xml
ADDING: res/layout-v21/notification_action_tombstone.xml
ADDING: res/layout-v21/notification_template_custom_big.xml
ADDING: res/layout-v21/notification_template_icon_group.xml
ADDING: res/layout/custom_dialog.xml
ADDING: res/layout/downloading_expansion.xml
ADDING: res/layout/godot_app_layout.xml
ADDING: res/layout/notification_template_part_chronometer.xml
ADDING: res/layout/notification_template_part_time.xml
ADDING: res/layout/splash_screen_view.xml
ADDING: res/layout/status_bar_ongoing_event_progress_bar.xml
ADDING: res/mipmap-anydpi-v26/icon.xml
ADDING: res/mipmap-hdpi-v4/icon.png
ADDING: res/mipmap-hdpi-v4/icon_background.png
ADDING: res/mipmap-hdpi-v4/icon_foreground.png
ADDING: res/mipmap-mdpi-v4/icon.png
ADDING: res/mipmap-mdpi-v4/icon_background.png
ADDING: res/mipmap-mdpi-v4/icon_foreground.png
ADDING: res/mipmap-xhdpi-v4/icon.png
ADDING: res/mipmap-xhdpi-v4/icon_background.png
ADDING: res/mipmap-xhdpi-v4/icon_foreground.png
ADDING: res/mipmap-xxhdpi-v4/icon.png
ADDING: res/mipmap-xxhdpi-v4/icon_background.png
ADDING: res/mipmap-xxhdpi-v4/icon_foreground.png
ADDING: res/mipmap-xxxhdpi-v4/icon.png
ADDING: res/mipmap-xxxhdpi-v4/icon_background.png
ADDING: res/mipmap-xxxhdpi-v4/icon_foreground.png
ADDING: res/mipmap/icon.png
ADDING: res/mipmap/icon_background.png
ADDING: res/mipmap/icon_foreground.png
ADDING: res/xml/godot_provider_paths.xml
ADDING: resources.arsc
[   0% ] [90m[1mexport[22m | Adding files...[39m[0m
[  97% ] [90m[1mexport[22m | Aligning APK...[39m[0m
[  98% ] [90m[1mexport[22m | Signing debug APK...[39m[0m
Could not find version of build tools that matches Target SDK, using 34.0.0
Signing binary using: 
/home/rowan/horseshooter/android_sdk/build-tools/34.0.0/apksigner sign --verbose --ks <REDACTED> --ks-pass pass:<REDACTED> --ks-key-alias <REDACTED> /home/rowan/womanvshorseVA/build/android/womanvshorseVA-debug.apk
Signed

[  99% ] [90m[1mexport[22m | Verifying APK...[39m[0m
[92m[ DONE ][39m [1mexport[22m
[0m
~~~~

#### stderr

~~~~text
ERROR: No project icon specified. Please specify one in the Project Settings under Application -> Config -> Icon
   at: load_icon_refs (platform/android/export/export_plugin.cpp:1891)
cannot connect to daemon at tcp:5037: Connection refused
~~~~
