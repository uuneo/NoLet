日本語 | **[English](README.EN.md)** | **[中文](README.md)** | **[한국어](README.KO.md)**

<p align="center">
<img src="/_media/egglogo.png" alt="NoLet" title="NoLet" width="100"/>
</p>

> [!IMPORTANT]
>
>- プロジェクトの一部のコードは [Bark](https://github.com/Finb/Bark) から派生しています
>
> - Markdown スタイリング（完了）
> - 着信音の自動変換（完了）
> - メッセージ内容の読み上げ（ベータ版）（完了）


# NoLet 無字書
<table>
  <tr>
    <th style="border: none;"><strong>NoLet iOS</strong></th>
    <td style="border: none;"><img src="https://img.shields.io/badge/Xcode-16.2-blue?logo=Xcode&logoColor=white" alt="Firefox-iOS"></td>
    <td style="border: none;"><img src="https://img.shields.io/badge/Swift-5.10-red?logo=Swift&logoColor=white" alt="Firefox-iOS"></td>
    <td style="border: none;"><img src="https://img.shields.io/badge/iOS-16.0+-green?logo=apple&logoColor=white" alt="Firefox-iOS"></td>
  </tr>
</table>

### Apple デバイスにカスタム通知をプッシュできる iOS アプリケーション

| TestFlight |App Store|
|-------|--------|
|[<img src="https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/fc/78/a0/fc78a0ee-dc6b-00d9-85be-e74c24b2bcb5/AppIcon-85-220-0-4-2x.png/512x0w.webp" alt="NoLet App" height="45"> ](https://testflight.apple.com/join/PMPaM6BR) | [<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="NoLet App" height="40">](https://apps.apple.com/us/app/id6615073345)|


|Markdown|Avatar And Image|
|-------|--------|
|<img src="/_media/markdown.gif" width="350">|<img src="/_media/avatarAndImage.gif" width="350">|
  
## App Introduction

NoLet 無字書は、シンプルなURLリクエストを通じてiOSデバイスに通知を送信できるアプリです。以下の特徴があります：

- **シンプルな使用方法**: HTTPリクエストを送信するだけで通知を配信
- **高度なカスタマイズ**: タイトル、サブタイトル、本文、サウンド、バイブレーションなどをカスタマイズ可能
- **Markdownサポート**: 通知内でリッチテキスト形式をサポート
- **画像送信**: URLを通じて画像を送信可能
- **自動化との連携**: ショートカット、IFTTT、Zapierなどと簡単に連携
- **プライバシー重視**: サーバーに個人データを保存せず、エンドツーエンドの通知配信
- **オープンソースプロジェクト**: 自己ホスト型サーバーオプション付き
- **エンドツーエンド暗号化**: メッセージのセキュリティ保護

## 問題フィードバック Telegram グループ
[NoLet フィードバックグループ](https://t.me/PushToMe)

## 目次

- [詳細ドキュメント](#詳細ドキュメント)
- [クイックスタート](#クイックスタート)
- [リクエストパラメータ](#リクエストパラメータ)
- [使用例](#使用例)
- [ブラウザ拡張機能](#ブラウザ拡張機能)
- [よくある質問](#よくある質問)
  - [プッシュが失敗した場合はどうすればよいですか？](#プッシュが失敗した場合はどうすればよいですか)
  - [NoLet 無字書を自動化ツールで使用するには？](#NoLet-無字書を自動化ツールで使用するには)
  - [プッシュキーを保護するには？](#プッシュキーを保護するには)
  - [エンドツーエンド暗号化](#エンドツーエンド暗号化)
  - [自己ホスト型サーバー](#自己ホスト型サーバー)
  - [バッテリーとデータ使用量について](#バッテリーとデータ使用量について)
- [プロジェクトで使用されているサードパーティライブラリ](#プロジェクトで使用されているサードパーティライブラリ)

## 詳細ドキュメント
[ドキュメントを表示](https://docs.wzs.app/)


## クイックスタート

### プッシュキーの取得

1. App Storeから「NoLet 無字書」アプリをダウンロードしてインストールします
2. アプリを開き、初期設定を完了します
3. メイン画面に表示されるプッシュキーをコピーします

### 最初のプッシュを送信

プッシュキーを取得したら、以下の形式でURLリクエストを送信できます：

```
https://wzs.app/あなたのキー/メッセージ内容
```

### リクエスト形式

#### GET リクエスト

ブラウザでアクセス：
```
https://wzs.app/あなたのキー/タイトル/本文
```

curlコマンドを使用：
```bash
curl "https://wzs.app/あなたのキー/タイトル/本文"
```

#### POST リクエスト

フォーム形式：
```bash
curl -X POST \
  -d "title=タイトル" \
  -d "body=本文" \
  "https://wzs.app/あなたのキー"
```

JSON形式：
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"title":"タイトル", "body":"本文"}' \
  "https://wzs.app/あなたのキー"
```

## リクエストパラメータ

### 基本パラメータ

| パラメータ | 説明 | 例 |
| --- | --- | --- |
| title | 通知のタイトル | `title=重要なお知らせ` |
| body | 通知の本文 | `body=これは通知の内容です` |
| subtitle | 通知のサブタイトル | `subtitle=詳細情報` |

### 特殊機能パラメータ

| パラメータ | 説明 | 例 |
| --- | --- | --- |
| level | 通知の重要度（active: 通常、timeSensitive: 時間敏感、passive: 受動的） | `level=timeSensitive` |
| badge | アプリのバッジ数 | `badge=1` |
| group | 通知のグループ化 | `group=仕事` |
| isArchive | 通知をアーカイブするかどうか（1: アーカイブする） | `isArchive=1` |

### インタラクションパラメータ

| パラメータ | 説明 | 例 |
| --- | --- | --- |
| autoCopy | 通知を開いたときに自動的にコピーする内容 | `autoCopy=コピーされるテキスト` |
| copy | 通知をタップしたときにコピーする内容 | `copy=コピーされるテキスト` |
| url | 通知をタップしたときに開く URL | `url=https://example.com` |

### メディアパラメータ

| パラメータ | 説明 | 例 |
| --- | --- | --- |
| sound | 通知音（default: デフォルト、alarm: アラーム、bell: ベル） | `sound=alarm` |
| icon | 通知のアイコン | `icon=https://example.com/icon.png` |
| image | 画像の URL | `image=https://example.com/image.jpg` |
| markdown | Markdown 形式の内容 | `markdown=# タイトル\n内容` |

### その他の機能パラメータ

| パラメータ | 説明 | 例 |
| --- | --- | --- |
| ttl | メッセージの保持日数 | `ttl=7` |
| call | 30秒間音声を繰り返し再生（1: 有効） | `call=1` |
| ciphertext | 暗号化されたプッシュメッセージ | `ciphertext=暗号化テキスト` |

## 使用例

### 基本的なプッシュ

```
https://wzs.app/あなたのキー/これは基本的なプッシュです
```

### タイトルと内容を含むプッシュ

```
https://wzs.app/あなたのキー/プッシュタイトル/プッシュ内容
```

### 完全な形式のプッシュ

```
https://wzs.app/あなたのキー/タイトル/サブタイトル/内容
```

### カスタムパラメータを含むプッシュ

```
https://wzs.app/あなたのキー/重要なお知らせ?level=timeSensitive&sound=alarm&group=仕事
```

### Markdown内容の送信

```
https://wzs.app/あなたのキー/?title=Markdownの例&markdown=%23%20タイトル%0A%0A-%20リスト項目1%0A-%20リスト項目2%0A%0A%60%60%60%0Aコードブロック%0A%60%60%60
```

### 画像の送信

```
https://wzs.app/あなたのキー/画像プッシュ?image=https://example.com/image.jpg
```

## ブラウザ拡張機能

### Safari拡張機能

* Safari拡張機能は別途インストールする必要がなく、アプリに付属しています
* iOSデバイスでアプリを開き、設定ページに移動して、Safari拡張機能を有効にするためのプロンプトに従ってください
* 有効にすると、ブラウジング中に直接コンテンツをデバイスに共有できます

### Chrome拡張機能

* [Chrome拡張機能をインストール](https://chromewebstore.google.com/detail/NoLet/gadgoijjifgnbeehmcapjfipggiijeej)
* インストール後、拡張機能アイコンをクリックしてプッシュキーを入力して設定します
* 現在のページ、選択したテキスト、または画像をワンクリックでデバイスに送信できます
* InstagramなどのWebサイトから画像を直接携帯電話に送信するのに特に適しています



## よくある質問

### プッシュが失敗した場合はどうすればよいですか？

1. デバイスがインターネットに接続されているか確認してください
2. プッシュキーが正しいか確認してください
3. アプリが実行中またはバックグラウンドにあることを確認してください
4. 通知許可が有効になっているか確認してください
5. 自動化ツールを使用している場合は、URLが正しく形式化されていることを確認してください

### NoLet 無字書を自動化ツールで使用するには？

1. アプリからプッシュキーを取得します
2. キーを使用してプッシュURLを構築します：`https://wzs.app/あなたのキー/メッセージ`
3. 自動化ツール（ショートカット、IFTTT、Zapierなど）にURLを追加します
4. 自動化をテストして正しく動作することを確認します

### プッシュキーを保護するには？

プッシュキーは、デバイスに通知を送信するために必要な唯一の認証情報です。保護するには：

1. プッシュキーを公開しないでください
2. スクリプトや自動化で使用する場合は、環境変数の使用を検討してください
3. キーが漏洩した疑いがある場合は、アプリの設定で再生成できます
4. 機密情報にはエンドツーエンド暗号化機能を使用してください

### エンドツーエンド暗号化

NoLet 無字書は、機密性の高いメッセージのためのエンドツーエンド暗号化をサポートしています：

1. **サポート状況**: 最新バージョンのアプリで利用可能
2. **暗号化効果**: メッセージ内容は送信者と受信者のみが読むことができます
3. **設定方法**: アプリの設定で暗号化キーを設定し、`ciphertext`パラメータを使用して暗号化されたメッセージを送信
4. **適用シナリオ**: パスワード、個人情報、機密データなど、高いセキュリティが必要な情報の送信に最適

### 自己ホスト型サーバー

NoLet 無字書は自己ホスト型サーバーをサポートしています：

1. **サーバーコード**: [GitHub](https://github.com/neo-app/NoLet-server)で公開されているサーバーコードを使用できます
2. **マルチプラットフォーム**: Node.js、Python、Goなど、さまざまな言語でのサーバー実装が可能
3. **Dockerサポート**: コンテナ化されたデプロイメントをサポートし、クラウドプロバイダーやVPSでの展開が容易
4. **設定方法**: アプリの設定で自己ホスト型サーバーのURLを設定できます

### バッテリーとデータ使用量について

NoLet 無字書はバッテリーとデータ使用量を効率的に管理するように設計されています：

1. アプリはAppleのプッシュ通知サービスを使用しており、バッテリー寿命に最適化されています
2. プッシュを積極的に受信していない場合、バックグラウンドアクティビティは最小限です
3. データ使用量は非常に少なく、通常はプッシュごとに数KBのみです

## プロジェクトで使用されているサードパーティライブラリ

* [Defaults](https://github.com/sindresorhus/Defaults)
* [QRScanner](https://github.com/mercari/QRScanner)
* [GRDB](https://github.com/groue/GRDB.swift.git)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [Kingfisher](https://github.com/onevcat/Kingfisher)
* [OpenAI](https://github.com/MacPaw/OpenAI)
* [Splash](https://github.com/AugustDev/Splash)
* [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui)

