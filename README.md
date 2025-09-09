  
中文 ｜ **[English](README.EN.md)** | **[日本語](README.JA.md)** | **[한국어](README.KO.md)**

<p align="center">

<img src="/_media/egglogo.png" alt="NoLet" title="NoLet" width="100"/>

</p>



> [!IMPORTANT]
>
>- 项目部分代码来自 [Bark ](https://github.com/Finb/Bark)
>
> - Markdown 样式（已完成）
> - 铃声自动转换 （已完成）
> - 朗读消息内容(测试版) （已完成）

  
# NoLet 无字书

<table>
  <tr>
    <th style="border: none;"><strong>NoLet iOS</strong></th>
    <td style="border: none;"><img src="https://img.shields.io/badge/Xcode-16.2-blue?logo=Xcode&logoColor=white" alt="NoLet App"></td>
    <td style="border: none;"><img src="https://img.shields.io/badge/Swift-5.10-red?logo=Swift&logoColor=white" alt="NoLet App"></td>
    <td style="border: none;"><img src="https://img.shields.io/badge/iOS-16.0+-green?logo=apple&logoColor=white" alt="NoLet App"></td>
  </tr>
</table>

### 是一款 iOS 应用程序，可让您将自定义通知推送到您的苹果设备

| TestFlight |App Store|
|-------|--------|
|[<img src="https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/fc/78/a0/fc78a0ee-dc6b-00d9-85be-e74c24b2bcb5/AppIcon-85-220-0-4-2x.png/512x0w.webp" alt="NoLet App" height="45"> ](https://testflight.apple.com/join/PMPaM6BR) | [<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="NoLet App" height="40">](https://apps.apple.com/us/app/id6615073345)|

  
|Markdown|Avatar And Image|
|-------|--------|
|<img src="/_media/markdown.gif" width="350">|<img src="/_media/avatarAndImage.gif" width="350">|
  

## 应用介绍

NoLet 无字书 是一款强大的iOS推送工具，让你能够从任何设备向iPhone/iPad发送自定义通知。无论是服务器监控、脚本自动化还是日常提醒，NoLet 无字书都能满足你的需求。

主要特点：
- 简单易用的API，支持多种请求方式
- Markdown渲染支持，让推送内容更丰富
- 自定义铃声、图标和图片
- 多种通知级别，包括时效性和关键通知
- 浏览器扩展支持，一键分享网页内容
- 低功耗设计，对电池影响极小
- 项目开源，可自建服务器
- 消息支持端到端加密

## 问题反馈与支持

如有任何问题或建议，欢迎加入我们的Telegram群组：

[NoLet 无字书反馈群](https://t.me/PushToMe)

  
  

## 目录

- [应用介绍](#应用介绍)
- [问题反馈与支持](#问题反馈与支持)
- [快速开始](#快速开始)
- [请求参数详解](#请求参数详解)
- [使用示例](#使用示例)
- [浏览器扩展](#浏览器扩展)
- [常见问题解答](#常见问题解答)
  - [推送失败怎么办？](#推送失败怎么办)
  - [如何在自动化工具中使用？](#如何在自动化工具中使用)
  - [如何保护我的推送密钥？](#如何保护我的推送密钥)
  - [端到端加密](#端到端加密)
  - [自建服务器](#自建服务器)
  - [电量和数据使用](#电量和数据使用)
- [项目中使用的第三方库](#项目中使用的第三方库)

## 详细文档

更多详细信息和高级用法，请查看我们的[完整文档](https://sunvc.github.io)

  

## 快速开始

### 1. 获取你的推送密钥

1. 下载并安装 NoLet 无字书 应用
2. 打开应用，在主界面可以看到你的专属推送密钥（key）
3. 点击复制按钮获取完整的测试URL



### 2. 发送你的第一条推送

#### URL格式

NoLet 无字书支持以下几种URL格式：

```
https://wzs.app/:key/:body
https://wzs.app/:key/:title/:body
https://wzs.app/:key/:title/:subtitle/:body
```

其中：
- `:key` - 你的专属推送密钥
- `:title` - 推送标题（可选）
- `:subtitle` - 推送副标题（可选）
- `:body` - 推送内容

#### 请求方式

##### GET 请求

直接在浏览器中访问URL即可发送推送：

```
https://wzs.app/your_key/这是推送内容
https://wzs.app/your_key/这是标题/这是内容
```

也可以使用curl命令：

```sh
curl https://wzs.app/your_key/推送内容?group=分组&copy=复制
```

> **注意**：手动拼接参数到URL时，请注意特殊字符需要进行URL编码，否则可能导致推送失败。

##### POST 请求

使用POST请求可以避免URL编码问题，更适合复杂内容：

```sh
curl -X POST https://wzs.app/your_key \
     -d'body=推送内容&title=推送标题&group=分组'
```

##### JSON格式

还支持JSON格式的POST请求：

```sh
curl -X "POST" "https://wzs.app/your_key" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "body": "推送内容",
  "title": "推送标题",
  "sound": "alarm",
  "group": "测试",
  "url": "https://wzs.app"
}'
```



## 请求参数详解

支持的参数列表，具体效果可在APP内预览。所有参数兼容多种写法，例如：`SubTitle` / `subTitle` / `subtitle` / `sub_title` / `sub-title`

### 基本参数

| 参数 | 说明 | 示例 |
| ----- | ----------- | ----------- |
| id | UUID，传入相同id会覆盖原有消息 | `id=123e4567-e89b-12d3-a456-426614174000` |
| title | 推送标题 | `title=会议提醒` |
| subtitle | 推送副标题 | `subtitle=产品讨论会` |
| body | 推送内容<br>*也支持 content/message/data/text 作为别名* | `body=请准时参加下午3点的会议` |

### 特殊功能参数

| 参数 | 说明 | 示例 |
| ----- | ----------- | ----------- |
| markdown | 渲染Markdown格式内容<br>*支持简写 md* | `markdown=## 标题\n- 列表项1\n- 列表项2` |
| level | 推送中断级别：<br>• **active** (1)：默认值，立即亮屏显示通知<br>• **timeSensitive** (2)：时效性通知，可在专注状态下显示<br>• **passive** (0)：仅添加到通知列表，不亮屏提醒<br>• **critical** (3-10)：重要提醒，可在专注或静音模式下提醒<br>*数字可替代文本值，3-10的数值同时设置音量* | `level=timeSensitive`<br>或<br>`level=2` |
| volume | critical模式下的音量，取值范围0-10 | `volume=8` |

### 交互参数

| 参数 | 说明 | 示例 |
| ----- | ----------- | ----------- |
| call | 长提醒，类似微信电话通知 | `call=1` |
| badge | 推送角标，按照未读数计算 | `badge=5` |
| autoCopy | 自动复制功能（iOS 16+） | `autoCopy=1` |
| copy | 指定复制的内容，不传则复制整个推送内容 | `copy=会议链接：https://meet.com/123` |
| url | 点击推送时跳转的URL，支持URL Scheme和Universal Link | `url=https://example.com`<br>或<br>`url=tel:10086` |

### 媒体参数

| 参数 | 说明 | 示例 |
| ----- | ----------- | ----------- |
| sound | 设置推送铃声，应用内可设置默认铃声 | `sound=alarm` |
| image | 传入图片地址，接收后自动下载缓存 | `image=https://example.com/photo.jpg` |
| saveAlbum | 自动保存到相册 | `saveAlbum=1` |
| icon | 设置自定义图标，图标自动缓存，支持上传云图标 | `icon=https://example.com/icon.png` |
| icon | 支持emoji | `icon=🐲` <img src="/_media/example-emoji.png" alt="NoLet App" height="60">  |
| icon | 支持单文字和背景颜色(可选) | `icon=服ff0000` <img src="/_media/example-word.png" alt="NoLet App" height="60"> |


### 其他功能参数

| 参数 | 说明 | 示例 |
| ----- | ----------- | ----------- |
| group | 对消息进行分组，推送将按组显示在通知中心<br>也可在历史消息列表中选择查看不同群组 | `group=工作` |
| ttl | 消息保存天数 | `ttl=7` |

## 使用示例

### 基础推送

```
https://wzs.app/your_key/这是一条基础推送
```

### 带标题和内容的推送

```
https://wzs.app/your_key/推送标题/推送内容
```

### 完整格式推送

```
https://wzs.app/your_key/标题/副标题/内容
```

### 带自定义参数的推送

```
https://wzs.app/your_key/重要通知?level=timeSensitive&sound=alarm&group=工作
```

### 发送Markdown内容

```
https://wzs.app/your_key/?title=Markdown示例&markdown=%23%20标题%0A%0A-%20列表项1%0A-%20列表项2%0A%0A%60%60%60%0A代码块%0A%60%60%60
```

### 发送图片

```
https://wzs.app/your_key/图片推送?image=https://example.com/image.jpg
```


## 浏览器扩展

### Safari扩展

* Safari扩展无需单独安装，App自带
* 在iOS设备上打开App后，进入设置页面，按照提示启用Safari扩展
* 启用后，浏览网页时可以直接分享内容到你的设备

### Chrome扩展

* [安装Chrome扩展](https://chromewebstore.google.com/detail/NoLet/gadgoijjifgnbeehmcapjfipggiijeej)
* 安装后点击扩展图标，输入你的推送密钥进行配置
* 支持一键发送当前页面、选中文本或图片到你的设备
* 特别适合将Instagram等网站的图片直接发送到手机

## 常见问题解答

### 推送失败怎么办？

1. **检查网络连接**：确保你的设备和服务器都能正常连接到互联网
2. **验证推送密钥**：确认使用的是正确的推送密钥
3. **URL编码问题**：如果推送内容包含特殊字符（如空格、&、#等），请确保正确进行URL编码，或改用POST请求
4. **服务器状态**：查看[文档网站](https://sunvc.github.io)了解服务器状态

### 如何在自动化工具中使用？

NoLet 无字书非常适合与各种自动化工具集成：

* **Shortcuts/快捷指令**：创建快捷指令发送推送通知
* **IFTTT**：设置触发器自动发送推送
* **自动化脚本**：在Python、Shell等脚本中使用curl发送推送
* **监控系统**：将NoLet 无字书集成到服务器监控系统，接收重要事件通知

### 如何保护我的推送密钥？

* 不要在公开场合分享你的推送密钥
* 定期在App中重置推送密钥
* 对于重要通知，使用端到端加密功能

### 端到端加密

* NoLet 无字书支持端到端加密，确保消息内容只有你能查看
* 加密消息在传输和存储过程中都无法被第三方解密
* 在应用设置中可以轻松配置加密选项
* 适用于发送敏感信息和保护隐私

### 自建服务器

* NoLet 无字书支持自建服务器，保证数据隐私和安全
* 服务器代码开源：[NoLetServer](https://github.com/sunvc/NoLetServer)
* 自建服务器支持多平台部署（Windows、macOS、Linux等）
* 支持Docker容器化部署，便于维护和升级

### 电量和数据使用

* NoLet 无字书设计为低功耗运行，对电池影响极小
* 推送数据量很小，不会消耗大量网络流量
* 如果使用图片推送功能，建议在WiFi环境下使用

  

## 项目中使用的第三方库

* [Defaults](https://github.com/sindresorhus/Defaults)
* [QRScanner](https://github.com/mercari/QRScanner)
* [GRDB](https://github.com/groue/GRDB.swift.git)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [Kingfisher](https://github.com/onevcat/Kingfisher)
* [OpenAI](https://github.com/MacPaw/OpenAI)
* [Splash](https://github.com/AugustDev/Splash)
* [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui)