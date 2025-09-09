한국어 | **[English](README.EN.md)** | **[中文](README.md)** | **[日本語](README.JA.md)** 


<p align="center">
<img src="/_media/egglogo.png" alt="NoLet" title="NoLet" width="100"/>
</p>


> [!IMPORTANT]
>
>- 프로젝트의 일부 코드는 [Bark](https://github.com/Finb/Bark)에서 가져왔습니다
>
> - 마크다운 스타일링 (완료)
> - 자동 벨소리 변환 (완료)
> - 메시지 내용 읽기 (베타) (완료)

# NoLet 무자서
![IOS](https://img.shields.io/badge/IPhone-16+-ff69b4.svg) ![IOS](https://img.shields.io/badge/IPad-16+-ff69b4.svg) ![Markdown](https://img.shields.io/badge/gcm-markdown-green.svg)
### Apple 기기에 맞춤형 알림을 보낼 수 있는 iOS 애플리케이션입니다.
[<img src="https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/fc/78/a0/fc78a0ee-dc6b-00d9-85be-e74c24b2bcb5/AppIcon-85-220-0-4-2x.png/512x0w.webp" alt="NoLet App" height="45"> ](https://testflight.apple.com/join/PMPaM6BR)
[<img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="NoLet App" height="40">](https://apps.apple.com/us/app/NoLet/id6615073345)

|Markdown|Avatar And Image|
|-------|--------|
|<img src="/_media/markdown.gif" width="350">|<img src="/_media/avatarAndImage.gif" width="350">|
  
## App Introduction

NoLet 무자서는 간단한 URL 요청을 통해 iOS 기기로 알림을 보낼 수 있는 앱입니다. 다음과 같은 특징이 있습니다:

- **간편한 사용법**: HTTP 요청만으로 알림 전송 가능
- **고급 사용자 정의**: 제목, 부제목, 본문, 소리, 진동 등 사용자 정의 가능
- **마크다운 지원**: 알림 내에서 리치 텍스트 형식 지원
- **이미지 전송**: URL을 통한 이미지 전송 가능
- **자동화 연동**: 단축어, IFTTT, Zapier 등과 쉽게 연동
- **개인정보 보호**: 서버에 개인 데이터를 저장하지 않고 엔드투엔드 알림 전달
- **오픈소스 프로젝트**: 자체 호스팅 서버 옵션 제공
- **엔드투엔드 암호화**: 메시지 보안 보호

## 목차

- [문서](#문서)
- [사용 방법](#사용-방법)
- [매개변수](#매개변수)
- [Safari/Chrome 확장 프로그램](#safarichrome-확장-프로그램)
- [자주 묻는 질문](#자주-묻는-질문)
  - [푸시가 실패할 경우 어떻게 해야 하나요?](#푸시가-실패할-경우-어떻게-해야-하나요)
  - [NoLet 무자서를 자동화 도구와 함께 사용하려면 어떻게 해야 하나요?](#NoLet-무자서를-자동화-도구와-함께-사용하려면-어떻게-해야-하나요)
  - [푸시 키를 보호하려면 어떻게 해야 하나요?](#푸시-키를-보호하려면-어떻게-해야-하나요)
  - [엔드투엔드 암호화](#엔드투엔드-암호화)
  - [자체 호스팅 서버](#자체-호스팅-서버)
  - [배터리 및 데이터 사용량은 어떻게 되나요?](#배터리-및-데이터-사용량은-어떻게-되나요)
- [프로젝트에서 사용된 타사 라이브러리](#프로젝트에서-사용된-타사-라이브러리)

## 이슈 피드백 텔레그램 그룹
[NoLet 피드백 그룹](https://t.me/NoLet_app)

## 문서
[문서 보기](https://wzs.app/docs)


## 빠른 시작

### 푸시 키 얻기

1. App Store에서 "NoLet 무자서" 앱을 다운로드하고 설치합니다
2. 앱을 열고 초기 설정을 완료합니다
3. 메인 화면에 표시된 푸시 키를 복사합니다

### 첫 번째 푸시 보내기

푸시 키를 얻은 후, 다음 형식으로 URL 요청을 보낼 수 있습니다:

```
https://wzs.app/당신의키/메시지내용
```

### 요청 형식

#### GET 요청

브라우저에서 접속:
```
https://wzs.app/당신의키/제목/본문
```

curl 명령어 사용:
```bash
curl "https://wzs.app/당신의키/제목/본문"
```

#### POST 요청

폼 형식:
```bash
curl -X POST \
  -d "title=제목" \
  -d "body=본문" \
  "https://wzs.app/당신의키"
```

JSON 형식:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"title":"제목", "body":"본문"}' \
  "https://wzs.app/당신의키"
```

## 요청 매개변수

### 기본 매개변수

| 매개변수 | 설명 | 예시 |
| --- | --- | --- |
| title | 알림 제목 | `title=중요 공지` |
| body | 알림 본문 | `body=이것은 알림 내용입니다` |
| subtitle | 알림 부제목 | `subtitle=상세 정보` |

### 특수 기능 매개변수

| 매개변수 | 설명 | 예시 |
| --- | --- | --- |
| level | 알림 중요도(active: 일반, timeSensitive: 시간 민감, passive: 수동적) | `level=timeSensitive` |
| badge | 앱 배지 수 | `badge=1` |
| group | 알림 그룹화 | `group=업무` |
| isArchive | 알림을 보관할지 여부(1: 보관) | `isArchive=1` |

### 상호작용 매개변수

| 매개변수 | 설명 | 예시 |
| --- | --- | --- |
| autoCopy | 알림을 열 때 자동으로 복사할 내용 | `autoCopy=복사될 텍스트` |
| copy | 알림을 탭할 때 복사할 내용 | `copy=복사될 텍스트` |
| url | 알림을 탭할 때 열 URL | `url=https://example.com` |

### 미디어 매개변수

| 매개변수 | 설명 | 예시 |
| --- | --- | --- |
| sound | 알림 소리(default: 기본, alarm: 알람, bell: 벨) | `sound=alarm` |
| icon | 알림 아이콘 | `icon=https://example.com/icon.png` |
| image | 이미지 URL | `image=https://example.com/image.jpg` |
| markdown | 마크다운 형식 내용 | `markdown=# 제목\n내용` |

### 기타 기능 매개변수

| 매개변수 | 설명 | 예시 |
| --- | --- | --- |
| ttl | 메시지 보존 일수 | `ttl=7` |
| call | 30초 동안 반복적으로 소리 재생(1: 활성화) | `call=1` |
| ciphertext | 암호화된 푸시 메시지 | `ciphertext=암호화된내용` |

### 사용 예시

```bash
# 기본 알림 전송
https://wzs.app/yourkey/중요알림/여기에 내용을 입력하세요

# 마크다운 형식 알림
https://wzs.app/yourkey/?markdown=%23%20제목%0A%2A%2A굵은%20글씨%2A%2A%0A%2A기울임%2A

# 이미지가 포함된 알림
https://wzs.app/yourkey/이미지알림?image=https://example.com/image.jpg

# 시간 민감 알림 설정
https://wzs.app/yourkey/긴급알림?level=timeSensitive
```

## 브라우저 확장 프로그램

### Safari 확장 프로그램

* Safari 확장 프로그램은 별도로 설치할 필요가 없으며, 앱과 함께 제공됩니다
* iOS 기기에서 앱을 열고, 설정 페이지로 이동한 다음, Safari 확장 프로그램을 활성화하기 위한 안내를 따르세요
* 활성화되면 브라우징 중에 직접 콘텐츠를 기기로 공유할 수 있습니다

### Chrome 확장 프로그램

* [Chrome 확장 프로그램 설치](https://chromewebstore.google.com/detail/NoLet/gadgoijjifgnbeehmcapjfipggiijeej)
* 설치 후, 확장 프로그램 아이콘을 클릭하고 푸시 키를 입력하여 구성합니다
* 현재 페이지, 선택한 텍스트 또는 이미지를 원클릭으로 기기에 보낼 수 있습니다
* Instagram과 같은 웹사이트에서 이미지를 직접 휴대폰으로 보내는 데 특히 적합합니다



## 자주 묻는 질문

### 푸시가 실패할 경우 어떻게 해야 하나요?

1. 기기가 인터넷에 연결되어 있는지 확인하세요
2. 푸시 키가 올바른지 확인하세요
3. 앱이 실행 중이거나 백그라운드에 있는지 확인하세요
4. 알림 권한이 활성화되어 있는지 확인하세요
5. 자동화 도구를 사용하는 경우 URL이 올바르게 형식화되었는지 확인하세요

### NoLet 무자서를 자동화 도구와 함께 사용하려면 어떻게 해야 하나요?

1. 앱에서 푸시 키를 가져옵니다
2. 키를 사용하여 푸시 URL을 구성합니다: `https://wzs.app/당신의키/메시지`
3. 자동화 도구(단축어, IFTTT, Zapier 등)에 URL을 추가합니다
4. 자동화를 테스트하여 올바르게 작동하는지 확인합니다

### 푸시 키를 보호하려면 어떻게 해야 하나요?

푸시 키는 기기에 알림을 보내는 데 필요한 유일한 자격 증명입니다. 보호하려면:

1. 푸시 키를 공개적으로 공유하지 마세요
2. 스크립트나 자동화에서 사용할 때는 환경 변수 사용을 고려하세요
3. 키가 유출되었다고 의심되는 경우 앱 설정에서 재생성할 수 있습니다
4. 민감한 정보에는 엔드투엔드 암호화 기능을 사용하세요

### 엔드투엔드 암호화

NoLet 무자서는 민감한 메시지를 위한 엔드투엔드 암호화를 지원합니다:

1. **지원 상태**: 최신 버전의 앱에서 사용 가능
2. **암호화 효과**: 메시지 내용은 발신자와 수신자만 읽을 수 있습니다
3. **설정 방법**: 앱 설정에서 암호화 키를 설정하고, `ciphertext` 매개변수를 사용하여 암호화된 메시지 전송
4. **적용 시나리오**: 비밀번호, 개인 정보, 기밀 데이터 등 높은 보안이 필요한 정보 전송에 적합

### 자체 호스팅 서버

NoLet 무자서는 자체 호스팅 서버를 지원합니다:

1. **서버 코드**: [GitHub](https://github.com/neo-app/NoLet-server)에서 공개된 서버 코드를 사용할 수 있습니다
2. **멀티플랫폼**: Node.js, Python, Go 등 다양한 언어로 서버 구현 가능
3. **Docker 지원**: 컨테이너화된 배포를 지원하여 클라우드 제공업체나 VPS에서 쉽게 배포 가능
4. **설정 방법**: 앱 설정에서 자체 호스팅 서버의 URL을 설정할 수 있습니다

### 배터리 및 데이터 사용량은 어떻게 되나요?

NoLet 무자서는 배터리 및 데이터 사용량을 효율적으로 관리하도록 설계되었습니다:

1. 앱은 Apple의 푸시 알림 서비스를 사용하며, 이는 배터리 수명에 최적화되어 있습니다
2. 푸시를 적극적으로 수신하지 않을 때는 백그라운드 활동이 최소화됩니다
3. 데이터 사용량은 매우 적으며, 일반적으로 푸시당 몇 KB에 불과합니다

## 프로젝트에서 사용된 서드파티 라이브러리

* [Defaults](https://github.com/sindresorhus/Defaults)
* [QRScanner](https://github.com/mercari/QRScanner)
* [GRDB](https://github.com/groue/GRDB.swift.git)
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
* [Kingfisher](https://github.com/onevcat/Kingfisher)
* [OpenAI](https://github.com/MacPaw/OpenAI)
* [Splash](https://github.com/AugustDev/Splash)
* [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui)