# Bật Firebase thật

App hiện chạy **offline** (`FlavorConfig.firebaseTemporarilyDisabled = true`):
in-memory datasources + `FakeAuthDataSource` (tài khoản demo
`admin@vimes.local` / `123456`). Mọi luồng — đăng nhập, nhập phiếu, ghi sổ tồn
kho, thẻ kho — chạy đủ mà không cần Firebase.

Để chuyển sang Firebase thật:

## 1. Đăng nhập lại Firebase CLI (token trong máy đã hết hạn)

```bash
firebase login --reauth
```

## 2. Sinh `lib/firebase_options.dart`

```bash
dart pub global activate flutterfire_cli
cd /Users/doducdoanh/StudioProjects/vimes_inventory
flutterfire configure \
  --project=<firebase-project-id> \
  --out=lib/firebase_options.dart \
  --platforms=android,ios \
  --yes
```

Lệnh này cũng tạo `android/app/google-services.json` và
`ios/Runner/GoogleService-Info.plist` (đã có mẫu ignore trong `.gitignore`).

## 3. Bật Authentication + Firestore trên Firebase Console

- **Authentication → Sign-in method → Email/Password → Enable.**
- Tạo trước vài tài khoản khớp seed (hoặc bất kỳ), ví dụ:
  `admin@vimes.local` / `123456`.
- **Firestore Database → Create database** (production mode).
- Deploy rules + indexes:
  ```bash
  firebase deploy --only firestore:rules,firestore:indexes
  ```
  (`firestore.rules` + `firestore.indexes.json` ở gốc repo.)

> **Lưu ý về `users/{uid}`:** rules `isAdmin()` đọc `users/$(uid).role`. Sau khi
> tạo tài khoản admin trên Console, thêm 1 document `users/<uid-admin>` với
> `{ role: 'admin', organizationId: 'org-vimes', ... }` để có quyền ghi master
> data. Hoặc tạm nới rule master data cho mọi user đăng nhập khi seed lần đầu.

## 4. Bật cờ trong code

`lib/core/flavors/flavor_config.dart`:

```dart
static const bool firebaseTemporarilyDisabled = false;
```

Chạy lại app. Khi `organizations` còn rỗng, `MasterDataSeeder.seedIfEmpty()`
tự nạp toàn bộ seed (VIMES, phòng ban, user, kho, nhóm, ĐVT, vật tư) với doc id
cố định — chạy lại không nhân đôi.

## 5. Kiểm tra

```bash
flutter run -t lib/main_dev.dart
```

- Màn đăng nhập → nhập tài khoản đã tạo ở bước 3.
- Lập 1 phiếu nhập kho → Firestore có `warehouse_receipts/{id}` (kèm mảng
  `items`), `receipt_numbers/{số}`, `stock_ledger/*`, `inventory_stock/{wh}__{item}`.
- Màn **Tồn kho** / **Thẻ kho** đọc từ Firestore.
