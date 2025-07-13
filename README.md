# dano

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# DANO - Akıllı Sosyal Danışmanlık Platformu v2.0

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-orange.svg)](https://firebase.google.com)

DANO, kullanıcıların anonim olarak, belirli kriterlere göre filtreledikleri diğer kullanıcılardan birebir tavsiye alabilecekleri modern ve akıllı bir sosyal danışmanlık uygulamasıdır.

## 1. Proje Vizyonu ve Felsefesi
- **Amaç:** Günlük hayattaki karar anlarında, güvenli, anonim ve samimi bir ortamda, doğru profildeki kişilerden tavsiye almayı sağlamak.
- **Ayırt Edici Özellik (USP):** DANO, herkese açık bir forum değildir. Temel büyüsü, soruların, akıllı bir eşleştirme algoritması ile filtrelere uyan en doğru kişiye **özel olarak atanmasıdır.** Odak noktası; hız, kişisel etkileşim ve mahremiyettir.
- **Uygulama Kişiliği:** Modern, güvenilir, minimalist, akıllı ve samimi.

## 2. Teknik Mimarisi
- **Ön Yüz (Frontend):** Flutter (v3+)
- **Arka Yüz (Backend):** Google Firebase Suite
  - **Authentication:** E-posta/Şifre ve Google ile Giriş.
  - **Cloud Firestore:** Ana veritabanı (Bölge: `europe-west3`).
  - **Cloud Functions:** Sunucu taraflı mantık (Eşleştirme, Bildirim, Oyunlaştırma).
  - **Cloud Messaging (FCM):** Anlık bildirimler.
- **Tasarım Sistemi:** `lib/core/theme/app_theme.dart` dosyasında tanımlanan, `Inter` veya `Poppins` yazı tipini kullanan, modern bir karanlık tema (`DanoTheme.darkTheme`).

## 3. Kurulum ve Hızlı Başlangıç

### Gerekli Araçlar
- Flutter SDK (v3+)
- Node.js (v18+ - Cloud Functions için)
- Firebase CLI (`npm install -g firebase-tools`)
- Xcode ve/veya Android Studio

### Kurulum Adımları
1. Projeyi klonlayın (`git clone`).
2. Ana klasöre gidin (`cd dano`).
3. Flutter bağımlılıklarını kurun (`flutter pub get`).
4. Cloud Functions bağımlılıklarını kurun (`cd functions` ve `npm install`).

### Gerekli Yapılandırma Dosyaları (Güvenlik nedeniyle repo'da bulunmaz)
- `dano/android/app/google-services.json`
- `dano/ios/Runner/GoogleService-Info.plist`
- `dano/functions/service-account-key.json`

## 4. Firestore Veri Modeli ve Şeması

### `users` (koleksiyon)
| Alan | Tip | Açıklama |
|---|---|---|
| `email` | String | Kullanıcının e-posta adresi. |
| `nickname` | String | Kullanıcının seçtiği, benzersiz takma ad. |
| `gender` | String | "Kadın" veya "Erkek". |
| `sehir` | String | Yaşadığı şehir. |
| `birthDate` | Timestamp | Doğum tarihi. |
| `points` | Number | Oyunlaştırma puanı. |
| `hasCompletedOnboarding`| Boolean | Yeni kullanıcı rehberini tamamlayıp tamamlamadığı. |
| `fcmToken` | String | Anlık bildirim için cihaz token'ı. |
| `createdAt` | Timestamp | Kayıt olma zamanı. |

### `questions` (koleksiyon)
| Alan | Tip | Açıklama |
|---|---|---|
| `askerId` | String | Soruyu soranın UID'si. |
| `questionText` | String | Sorunun metni. |
| `timestamp` | Timestamp | Sorulma zamanı. |
| `status` | String | "yanit_bekliyor", "yanitlandi", "kapandi". |
| `filters` | Map | `{ "minAge": 25, "maxAge": 40, "gender": "Kadın", "city": "İzmir" }` |

### `users/{userId}/inbox` (alt-koleksiyon)
- `matchQuestionToUsers` fonksiyonu tarafından, kullanıcıya atanan soruların kopyasını tutar.

### `questions/{questionId}/answers` (alt-koleksiyon)
| Alan | Tip | Açıklama |
|---|---|---|
| `responderId` | String | Cevabı verenin UID'si. |
| `answerText` | String | Cevabın metni. |
| `timestamp` | Timestamp | Cevaplanma zamanı. |
| `rating` | Number | Soru sahibi tarafından verilen 1-5 arası puan. |

### `chats` (koleksiyon)
| Alan | Tip | Açıklama |
|---|---|---|
| `participants` | Array<String> | Sohbete katılan iki kullanıcının UID listesi. |
| `isApproved` | Boolean | Cevap verenin sohbeti onaylayıp onaylamadığı. |
| `lastMessageAt` | Timestamp | En son mesajın zamanı (listeleme için). |
| `questionId` | String | Sohbetin hangi soru üzerine başladığı. |

- **`chats/{chatId}/messages` (alt-koleksiyon):** Her bir mesajı (`senderId`, `text`, `timestamp`) tutar.

## 5. Geliştirme Kuralları
- **UI/UX:** Tüm arayüzler, `app_theme.dart` içindeki merkezi temaya uymalıdır.
- **Hata Yönetimi:** Tüm asenkron çağrılar `try-catch` blokları içinde olmalıdır.
- **State Yönetimi:** Lokal state için `StatefulWidget` ve `setState` kullanılır.
- **Dil:** Kullanıcıya dönük tüm metinler **Türkçe** olmalıdır. Kod yorumları ve değişken adları **İngilizce** olmalıdır.