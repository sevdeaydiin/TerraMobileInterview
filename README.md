# Terra Mobile - Harita Uygulaması

## Proje Özeti
Terra Mobile, Flutter kullanarak geliştirilen bir mobil harita uygulamasıdır. Uygulama, kullanıcıların gerçek zamanlı konum takibi yapmasına ve geçmiş rotalarını kaydetmesine olanak tanır. MVVM (Model-View-ViewModel) mimarisi kullanılarak geliştirilmiştir.

## Temel Özellikler
- **Canlı Konum Takibi**: Kullanıcının gerçek zamanlı konumunu harita üzerinde gösterir.
- **Geçmiş Rota Kaydı**: Kullanıcının hareket rotasını kaydeder ve geçmiş rotaları tarih/saat bazlı listeleyerek görselleştirir.
- **Modern Kullanıcı Arayüzü**: Minimalist ve sezgisel bir tasarım sunar.
- **Responsive Tasarım**: Farklı ekran boyutlarına uyum sağlar.

## Kullanılan Teknolojiler
- **Flutter Framework**: Mobil uygulama geliştirme için.
- **Google Maps Flutter SDK**: Harita entegrasyonu için.
- **WebSocket**: Gerçek zamanlı konum güncellemeleri için.
- **SQLite**: Rota verilerini saklamak için.
- **Provider**: MVVM mimarisi için durum yönetimi.

## Kurulum
1. **Gereksinimler**: Flutter SDK'nın yüklü olduğundan emin olun.
2. **Proje Kopyalama**: Projeyi klonlayın veya indirin.
   ```bash
   git clone https://github.com/sevdeaydiin/TerraMobileInterview.git
   ```
3. **Bağımlılıkları Yükleme**: Proje dizinine gidin ve bağımlılıkları yükleyin.
   ```bash
   cd terra_mobile_interview
   flutter pub get
   ```

4. **Google API Key**: 
    ```bash
   AIzaSyCY5fBwejF-Qv0h93Ii7doiWgRxqJ1hB_Y
   ```
5. **Simülatör veya Cihazda Çalıştırma**: Uygulamayı çalıştırmak için aşağıdaki komutu kullanın.
   ```bash
   flutter run
   ```

## Kullanım
- Uygulama açıldığında, harita üzerinde mevcut konumunuzu göreceksiniz.
- "Rotayı Başlat" butonuna tıklayarak konum takibini başlatabilirsiniz.
- Geçmiş rotalarınızı görüntülemek için uygulama içindeki ilgili bölümü kullanabilirsiniz.