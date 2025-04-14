# Terra Mobile - Harita Uygulaması

## Proje Özeti
Terra Mobile, Flutter kullanarak geliştirilen bir mobil harita uygulamasıdır. Uygulama, kullanıcıların gerçek zamanlı konum takibi yapmasına ve geçmiş rotalarını kaydetmesine olanak tanır. MVVM (Model-View-ViewModel) mimarisi kullanılarak geliştirilmiştir.

<img src="https://github.com/user-attachments/assets/4926953c-9f99-43a7-a9f0-706ab54d37a9" width="120" height="240" /> 
<img src="https://github.com/user-attachments/assets/2be9faaf-842d-4962-ae4b-93d6ad9bdd9a" width="120" height="240" />
<img src="https://github.com/user-attachments/assets/5baf73ec-8b50-4179-aec3-1d822cb5af20" width="120" height="240" />

<img src="https://github.com/user-attachments/assets/baa82f27-2f44-4439-8b23-ed9be64abcea" width="120" height="240" />
<img src="https://github.com/user-attachments/assets/dd183f71-337e-4aa2-a27d-a0ba3a58c05c" width="120" height="240" />
<img src="https://github.com/user-attachments/assets/196d2961-aeac-4d65-9b46-ef08e801a69d" width="120" height="240" />

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
   YOUR API KEY
   ```
5. **Simülatör veya Cihazda Çalıştırma**: Uygulamayı çalıştırmak için aşağıdaki komutu kullanın.
   ```bash
   flutter run
   ```

## Kullanım
- Uygulama açıldığında, harita üzerinde mevcut konumunuzu göreceksiniz.
- "Rotayı Başlat" butonuna tıklayarak konum takibini başlatabilirsiniz.
- Geçmiş rotalarınızı görüntülemek için uygulama içindeki ilgili bölümü kullanabilirsiniz.
