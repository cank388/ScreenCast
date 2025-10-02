# ScreenCast

iOS uygulaması ile Android TV'ye ekran yansıtma ve medya cast etme.

## Özellikler

### 1. AirPlay (Ekran Yansıtma)
- Android TV'de **AirScreen** veya benzeri bir AirPlay alıcısı uygulaması kurulu olmalı
- Uygulamada "AirPlay" butonuna tıklayıp cihazı seçin
- iPhone ekranınız Android TV'ye yansıtılır

### 2. ReplayKit (Tam Ekran Yayını)
- "Ekranı Yayınla" butonu sistem broadcast seçicisini açar
- `ScreenCastBroadcastUpload` extension'ı ile canlı yayın yapılabilir
- Extension içinde RTMP/RTP/WebRTC encoder bağlanarak yayın sunucusuna gönderilebilir

### 3. Google Cast (Chromecast)
- Android TV'de "Chromecast built-in" olmalı
- "Chromecast" butonuna tıklayıp cihaz seçin
- "Örnek Videoyu Oynat" ile test HLS videosu oynatılır
- `CastMediaController` ile kendi medyanızı cast edebilirsiniz

## Kurulum

1. CocoaPods bağımlılıklarını yükleyin:
   ```bash
   pod install
   ```

2. `ScreenCast.xcworkspace` dosyasını açın (`.xcodeproj` değil)

3. Broadcast Extension hedefini kurmak için:
   - Xcode > File > New > Target > Broadcast Upload Extension
   - Target adı: `ScreenCastBroadcastUpload`
   - Mevcut `SampleHandler.swift` dosyasını hedef klasöre taşıyın

4. Build ve Run

## Gereksinimler

- iOS 14.0+
- Xcode 16.0+
- CocoaPods
- Android TV (AirScreen app veya Chromecast built-in)

## Notlar

- Local network izni ilk açılışta istenir (Bonjour/Chromecast için)
- Mikrofon izni broadcast extension için opsiyoneldir
- Bridging Header Google Cast SDK için otomatik yapılandırılmıştır

## Kullanım

### AirPlay ile Yansıtma
1. Android TV'de AirScreen uygulamasını başlatın
2. iOS cihazınızda AirPlay butonuna tıklayın
3. TV'nizi seçin

### Chromecast ile Cast
1. Chromecast butonuna tıklayıp TV'nizi seçin
2. "Örnek Videoyu Oynat" veya kendi medyanızı gönderin

### Broadcast Upload Extension
1. Extension hedefini Xcode'da oluşturun
2. `SampleHandler.swift` içinde encoder/uploader entegrasyonunu yapın
3. "Ekranı Yayınla" ile extension'ı başlatın

