# Terra Mobile Interview - Harita Uygulaması PRD

## Proje Özeti
Bu proje, Flutter kullanarak geliştirilen, canlı konum takibi ve geçmiş rota kaydı yapabilen bir mobil harita uygulamasıdır. MVVM (Model-View-ViewModel) mimarisi kullanılarak geliştirilecektir.

## Temel Özellikler

### 1. Harita Ekranı ve Canlı Konum Takibi
- Kullanıcının gerçek zamanlı konumunu harita üzerinde gösterme
- WebSocket ile sürekli konum güncellemesi
- Başlangıç merkez noktası: Konya [37.872669888420376, 32.49263157763532]
- Haritayı kullanıcı konumuna otomatik odaklama
- Zoom kontrolü ve harita etkileşimleri

### 2. Rota Yönetimi
- Kullanıcının hareket rotasını gerçek zamanlı kaydetme
- SQLite veritabanında rota verilerini saklama
- Geçmiş rotaları tarih/saat bazlı listeleme
- Seçilen geçmiş rotayı harita üzerinde görselleştirme

### 3. Kullanıcı Arayüzü
- Modern ve minimalist tasarım
- Kolay erişilebilir geçmiş rota listesi
- Sezgisel navigasyon kontrolleri
- Responsive tasarım

## Teknik Gereksinimler

### 1. Kullanılacak Teknolojiler
- Flutter Framework
- Google Maps Flutter SDK
- WebSocket için web_socket_channel
- SQLite için sqflite
- MVVM mimarisi için provider

### 2. Mimari Yapı (MVVM)
#### Model
- Konum verileri modeli
- Rota verileri modeli
- Veritabanı modeli

#### View
- Harita ekranı
- Rota listesi ekranı
- Ayarlar ekranı

#### ViewModel
- Harita kontrolcüsü
- Konum servisi
- Rota yöneticisi
- WebSocket yöneticisi

### 3. Veritabanı Yapısı
- Rota tablosu
  - ID
  - Başlangıç zamanı
  - Bitiş zamanı
  - Koordinat listesi
  - Mesafe
  - Süre

### 4. API ve Servisler
- WebSocket bağlantısı
- Google Maps servisleri
- Konum servisleri

## Kalite Gereksinimleri
- Temiz ve okunabilir kod
- Unit test coverage
- Widget testleri
- Modüler yapı
- Yeniden kullanılabilir bileşenler
- Hata yönetimi
- Bellek optimizasyonu

## Performans Gereksinimleri
- Minimum gecikme süresi ile konum güncellemesi
- Veritabanı işlemlerinde optimize performans
- Harita render performansı optimizasyonu
- Pil tüketimi optimizasyonu

## Güvenlik Gereksinimleri
- Konum verilerinin güvenli saklanması
- WebSocket bağlantı güvenliği
- API anahtarlarının güvenli yönetimiPassword:Password:

## Test Gereksinimleri
- Unit testler
- Widget testler
- Integration testler
- Manuel testler
  - Konum takibi doğruluğu
  - Rota kayıt doğruluğu
  - UI/UX testleri
