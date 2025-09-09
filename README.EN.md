English | **[中文](README.md)** | **[日本語](README.JA.md)** | **[한국어](README.KO.md)**

<p align="center">
<img src="/_media/egglogo.png" alt="NoLet" title="NoLet" width="100"/>
</p>

> [!IMPORTANT]
>
>- Some of the project's code is derived from [Bark](https://github.com/Finb/Bark)
>
> - Markdown styling (Completed)
> - Automatic ringtone conversion (Completed)
> - Message content reading (Beta) (Completed)


# NoLet
<table>
  <tr>
    <th style="border: none;"><strong>NoLet iOS</strong></th>
    <td style="border: none;"><img src="https://img.shields.io/badge/Xcode-16.2-blue?logo=Xcode&logoColor=white" alt="Firefox-iOS"></td>
    <td style="border: none;"><img src="https://img.shields.io/badge/Swift-5.10-red?logo=Swift&logoColor=white" alt="Firefox-iOS"></td>
    <td style="border: none;"><img src="https://img.shields.io/badge/iOS-16.0+-green?logo=apple&logoColor=white" alt="Firefox-iOS"></td>
  </tr>
</table>

### An iOS application that allows you to push custom notifications to your Apple devices.

| TestFlight |App Store|
|-------|--------|
|[<img src="https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/fc/78/a0/fc78a0ee-dc6b-00d9-85be-e74c24b2bcb5/AppIcon-85-220-0-4-2x.png/512x0w.webp" alt="NoLet App" height="45"> ](https://testflight.apple.com/join/PMPaM6BR) | [<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="NoLet App" height="40">](https://apps.apple.com/us/app/id6615073345)|


|Markdown|Avatar And Image|
|-------|--------|
|<img src="/_media/markdown.gif" width="350">|<img src="/_media/avatarAndImage.gif" width="350">|
  


## App Introduction

NoLet is a powerful iOS push tool that allows you to send custom notifications to your iPhone/iPad from any device. Whether it's server monitoring, script automation, or daily reminders, NoLet can meet your needs.

Key features:
- Simple and easy-to-use API, supporting multiple request methods
- Markdown rendering support for richer push content
- Custom ringtones, icons, and images
- Multiple notification levels, including time-sensitive and critical notifications
- Browser extension support for one-click sharing of web content
- Low power design with minimal impact on battery
- Open source project with self-hosted server option
- End-to-end encryption support for messages

## Feedback and Support

For any questions or suggestions, please join our Telegram group:

[NoLet Feedback Group](https://t.me/PushToMe)

## Table of Contents

- [App Introduction](#app-introduction)
- [Feedback and Support](#feedback-and-support)
- [Quick Start](#quick-start)
- [Request Parameters](#request-parameters)
- [Usage Examples](#usage-examples)
- [Browser Extensions](#browser-extensions)
- [FAQ](#faq)
  - [What should I do if the push fails?](#what-should-i-do-if-the-push-fails)
  - [How to use NoLet with automation tools?](#how-to-use-NoLet-with-automation-tools)
  - [How to protect my push key?](#how-to-protect-my-push-key)
  - [End-to-End Encryption](#end-to-end-encryption)
  - [Self-Hosted Server](#self-hosted-server)
  - [Battery and data usage](#battery-and-data-usage)
- [Third-Party Libraries Used in the Project](#third-party-libraries-used-in-the-project)

## Detailed Documentation

For more detailed information and advanced usage, please check our [complete documentation](https://sunvc.github.io)


## Quick Start

### 1. Get Your Push Key

1. Download and install the NoLet app
2. Open the app, and you'll see your unique push key on the main screen
3. Click the copy button to get the complete test URL



### 2. Send Your First Push

#### URL Format

NoLet supports the following URL formats:

```
https://wzs.app/:key/:body
https://wzs.app/:key/:title/:body
https://wzs.app/:key/:title/:subtitle/:body
```

Where:
- `:key` - Your unique push key
- `:title` - Push title (optional)
- `:subtitle` - Push subtitle (optional)
- `:body` - Push content

#### Request Methods

##### GET Request

Simply visit the URL in a browser to send a push:

```
https://wzs.app/your_key/This is the push content
https://wzs.app/your_key/This is the title/This is the content
```

You can also use curl command:

```sh
curl https://wzs.app/your_key/push content?group=group&copy=copy
```

> **Note**: When manually appending parameters to the URL, please ensure special characters are URL encoded, otherwise the push may fail.

##### POST Request

Using POST requests can avoid URL encoding issues and is better for complex content:

```sh
curl -X POST https://wzs.app/your_key \
     -d'body=push content&title=push title&group=group'
```

##### JSON Format

JSON format POST requests are also supported:

```sh
curl -X "POST" "https://wzs.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "body": "push content",
  "title": "push title",
  "sound": "alarm",
  "group": "test",
  "url": "https://wzs.app"
}'
```

## Request Parameters

Supported parameter list, specific effects can be previewed in the APP. All parameters are compatible with multiple writing styles, such as: `SubTitle` / `subTitle` / `subtitle` / `sub_title` / `sub-title`

### Basic Parameters

| Parameter | Description | Example |
| ----- | ----------- | ----------- |
| id | UUID, passing the same id will overwrite the original message | `id=123e4567-e89b-12d3-a456-426614174000` |
| title | Push title | `title=Meeting Reminder` |
| subtitle | Push subtitle | `subtitle=Product Discussion` |
| body | Push content<br>*Also supports content/message/data/text as aliases* | `body=Please attend the meeting at 3pm` |

### Special Function Parameters

| Parameter | Description | Example |
| ----- | ----------- | ----------- |
| markdown | Render Markdown format content<br>*Supports shorthand md* | `markdown=## Title\n- List item 1\n- List item 2` |
| level | Push interruption level:<br>• **active** (1): Default value, immediately lights up screen to display notification<br>• **timeSensitive** (2): Time-sensitive notification, can be displayed during focus mode<br>• **passive** (0): Only adds to notification list, no screen alert<br>• **critical** (3-10): Important alert, can alert during focus or silent mode<br>*Numbers can replace text values, values 3-10 also set volume* | `level=timeSensitive`<br>or<br>`level=2` |
| volume | Volume in critical mode, range 0-10 | `volume=8` |

### Interaction Parameters

| Parameter | Description | Example |
| ----- | ----------- | ----------- |
| call | Long alert, similar to WeChat call notification | `call=1` |
| badge | Push badge, calculated by unread count | `badge=5` |
| autoCopy | Auto copy function (iOS 16+) | `autoCopy=1` |
| copy | Specify content to copy, if not passed, copies the entire push content | `copy=Meeting link: https://meet.com/123` |
| url | URL to jump to when clicking the push, supports URL Scheme and Universal Link | `url=https://example.com`<br>or<br>`url=tel:10086` |

### Media Parameters

| Parameter | Description | Example |
| ----- | ----------- | ----------- |
| sound | Set push ringtone, default ringtone can be set in the app | `sound=alarm` |
| icon | Set custom icon, icons are automatically cached, supports uploading cloud icons | `icon=https://example.com/icon.png` |
| image | Pass in image address, automatically downloaded and cached after receipt | `image=https://example.com/photo.jpg` |

### Other Function Parameters

| Parameter | Description | Example |
| ----- | ----------- | ----------- |
| group | Group messages, pushes will be displayed by group in the notification center<br>You can also choose to view different groups in the message history list | `group=work` |
| ttl | Message retention days | `ttl=7` |

## Usage Examples

### Basic Push

```
https://wzs.app/your_key/This is a basic push
```

### Push with Title and Content

```
https://wzs.app/your_key/Push Title/Push Content
```

### Complete Format Push

```
https://wzs.app/your_key/Title/Subtitle/Content
```

### Push with Custom Parameters

```
https://wzs.app/your_key/Important Notice?level=timeSensitive&sound=alarm&group=work
```

### Sending Markdown Content

```
https://wzs.app/your_key/?title=Markdown Example&markdown=%23%20Title%0A%0A-%20List%20item%201%0A-%20List%20item%202%0A%0A%60%60%60%0ACode%20block%0A%60%60%60
```

### Sending Images

```
https://wzs.app/your_key/Image Push?image=https://example.com/image.jpg
```

## Browser Extensions

### Safari Extension

* Safari extension does not need to be installed separately, it comes with the app
* On your iOS device, open the app, go to the settings page, and follow the prompts to enable the Safari extension
* Once enabled, you can directly share content to your device while browsing

### Chrome Extension

* [Install Chrome Extension](https://chromewebstore.google.com/detail/NoLet/gadgoijjifgnbeehmcapjfipggiijeej)
* After installation, click the extension icon and enter your push key to configure
* Supports one-click sending of current page, selected text, or images to your device
* Especially suitable for sending images from websites like Instagram directly to your phone



## FAQ

### What should I do if the push fails?

1. Check if your device is connected to the internet
2. Verify that the push key is correct
3. Make sure the app is running or in the background
4. Check if the notification permission is enabled
5. If using automation tools, ensure the URL is correctly formatted

### How to use NoLet with automation tools?

1. Get your push key from the app
2. Use the key to construct the push URL: `https://wzs.app/your_key/message`
3. Add the URL to your automation tool (Shortcuts, IFTTT, Zapier, etc.)
4. Test the automation to ensure it works correctly

### How to protect my push key?

Your push key is the only credential needed to send notifications to your device. To protect it:

1. Never share your push key publicly
2. When using in scripts or automation, consider using environment variables
3. If you suspect your key is compromised, you can regenerate it in the app settings
4. Use the end-to-end encryption feature for sensitive information

### End-to-End Encryption

* NoLet supports end-to-end encryption, ensuring that message content can only be viewed by you
* Encrypted messages cannot be decrypted by third parties during transmission and storage
* Encryption options can be easily configured in the app settings
* Ideal for sending sensitive information and protecting privacy

### Self-Hosted Server

* NoLet supports self-hosted servers, ensuring data privacy and security
* Server code is open source: [NoLetServer](https://github.com/sunvc/NoLetServer)
* Self-hosted server supports multi-platform deployment (Windows, macOS, Linux, etc.)
* Supports Docker containerized deployment for easy maintenance and upgrades

### Battery and data usage

NoLet is designed to be efficient with battery and data usage:

1. The app uses Apple's push notification service, which is optimized for battery life
2. Background activity is minimal when not actively receiving pushes
3. Data usage is very low, typically only a few KB per push

## Third-Party Libraries Used in the Project
* [Defaults](https://github.com/sindresorhus/Defaults)
* [QRScanner](https://github.com/mercari/QRScanner)
* [GRDB](https://github.com/groue/GRDB.swift.git)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [Kingfisher](https://github.com/onevcat/Kingfisher)
* [OpenAI](https://github.com/MacPaw/OpenAI)
* [Splash](https://github.com/AugustDev/Splash)
* [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui)