# PinCase

PinCase is a HarmonyOS inspiration-board prototype. It provides the product
shell for browsing inspiration, managing boards, and saving local state while
leaving account and content services for a future backend.

## Current capabilities

- Home, Explore, Inbox, and Profile page shells.
- Empty-content states ready for a future content provider.
- Local board creation and saved-item state backed by Preferences.
- Phone and tablet layouts using the Stage model and ArkUI/HDS components.

The repository does not bundle inspiration content or a demo account.

## Current limitations

The following services are not connected:

- Network content loading or a Pinterest API.
- Real account login, following, comments, or notifications backend.
- Image selection/upload and content publishing.
- Cloud sync, cross-device sync, and complete business-data backup.

The system backup extension is only a lifecycle placeholder. Local boards and
saved-item IDs are stored on the device through Preferences and are not a cloud
backup or account service.

## Platform

- HarmonyOS Stage model
- Target and compatible SDK: `6.1.1(24)`
- Devices: `phone`, `tablet`
- Bundle name: `com.PinCase.app`
- Version: `1.0.0` (`1000000`)

## Build

Open the project in DevEco Studio and use the project Build workflow. Configure
signing material locally when a signed HAP is required. Signing credentials and
machine-specific paths must remain outside the public repository.

## Release

The [v1.0.0 Release](https://github.com/Torotar/PinCase/releases/tag/v1.0.0)
includes the unsigned development package:

- [Download `entry-default-unsigned.hap`](https://github.com/Torotar/PinCase/releases/download/v1.0.0/entry-default-unsigned.hap)

This HAP is for development and testing only. It is unsigned and must not be
treated as a production distribution package.

## Project layout

- `AppScope/`: application identity, version, and resources.
- `entry/src/main/ets/pages/`: page-level UI and interaction coordination.
- `entry/src/main/ets/models/`: shared data contracts.
- `entry/src/main/ets/services/`: local persistence and system services.
- `entry/src/main/resources/`: strings, colors, media, and page profiles.
- `entry/src/test/`: local unit-test entry points.
