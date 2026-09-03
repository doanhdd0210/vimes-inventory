# VIMES Inventory — Phiếu nhập kho

Dev-test deliverable: entry form for a **Phiếu nhập kho – Mẫu 01‑VT**
(Thông tư 200/2014/TT‑BTC) inside a small inventory app.

Stack: **Flutter** · **Clean Architecture** + **MVVM** (the BLoC is the ViewModel) ·
**flutter_bloc** · **go_router** · **get_it** · **dartz** · **Cloud Firestore**
(wiring complete; the app ships in offline mode so it runs with zero setup).

---

## Quick start

```bash
flutter pub get
flutter test          # 80 tests
flutter run           # == flutter run -t lib/main_dev.dart
```

The app runs **offline** out of the box (`FlavorConfig.firebaseTemporarilyDisabled = true`):
`FakeAuthDataSource` + in-memory repositories seeded with demo master data. No
Firebase project access needed.

**Demo accounts** (password `123456`, email is pre-filled on the login screen):

| Email | Vai trò |
|---|---|
| `admin@vimes.local` | quản trị |
| `thukho@vimes.local` | thủ kho |
| `ketoan@vimes.local` | kế toán |

Đăng nhập → **Lập phiếu nhập kho** (wizard 3 bước) → phiếu được lưu và ghi sổ
tồn kho; xem lại ở **Danh sách phiếu**, **Tồn kho**, **Thẻ kho**.

---

## Bài test — làm ở đâu

| Yêu cầu | Vị trí |
|---|---|
| 1. Thiết kế bảng dữ liệu | [`docs/db_schema.md`](docs/db_schema.md) — 11 bảng (DDL, FK, index, posting bình quân gia quyền, đồng thời) + ánh xạ sang collection Firestore |
| 2. Thiết kế màn hình nhập | `features/warehouse_receipt/presentation/` — wizard 3 bước, validate từng bước |
| 3. Nhập + lưu dữ liệu | `.../domain/usecases/create_warehouse_receipt.dart` → `.../data/` — 1 transaction: lưu phiếu + chống trùng số + ghi `stock_ledger` + `inventory_stock` |
| 4. Unit test | `test/` — 80 test (rules, entity/model, data source, bloc, stock posting, weighted-average) |

Kiến trúc + so sánh với dự án tham chiếu: [`docs/architecture_review.md`](docs/architecture_review.md).
Bật Firebase thật: [`docs/firebase_setup.md`](docs/firebase_setup.md).

---

## Architecture

```
lib/
├── bootstrap.dart          # composition root: binding, flavor, (Firebase), DI, error zone, runApp
├── app.dart                # VimesApp — MaterialApp.router + ThemeCubit
├── main.dart / main_{dev,staging,prod}.dart   # flavor entry points (Dart-level flavors)
├── firebase_options.dart   # real options for project vimes-inventory-doanhdd
│
├── core/                   # cross-feature building blocks
│   ├── constants/          # AppConstants, AssetPaths, FirestoreCollections
│   ├── data/ · domain/     # generic CrudDataSource<E> / CrudRepository<E> (kills per-catalog boilerplate)
│   ├── di/                 # injection_container.dart — get_it locator (`sl`)
│   ├── error/              # Exception (data) ↔ Failure (domain)
│   ├── extensions/ · helpers/ · utils/
│   ├── firebase/           # FirebaseBootstrap.ensureInitialized()
│   ├── flavors/            # Flavor enum + FlavorConfig
│   ├── router/             # AppRoute enum + AppRouter (go_router, redirect guard)
│   ├── storage/            # LocalStorage (shared_preferences) + SecureStorage
│   ├── theme/              # colors / text / spacing / radius / durations / AppTheme / ThemeCubit
│   └── usecase/            # UseCase<T,P>, NoParams
│
└── features/<feature>/     # auth · master_data · stock · warehouse_receipt
    ├── data/               # datasources (Firestore + in-memory) · models · repositories impl
    ├── domain/             # entities · repositories (abstract) · usecases
    └── presentation/       # bloc/ (bloc + event + state + view-model data) · ui/ (pages + widgets)
```

**Dependency rule:** `presentation → domain ← data`. `domain` imports nothing
from `data` / `presentation` / Flutter / Firebase (grep-verified). `core` is
depended on by everything and depends on nothing feature-specific.

**MVVM:** the BLoC *is* the ViewModel — exposes an immutable `state`, receives
events, orchestrates use cases. The View renders `state` and dispatches events;
it never touches a repository or use case.

---

## Quality gates

```bash
flutter analyze                                          # 0 issues
flutter test                                             # 80 pass
dart format --output=none --set-exit-if-changed .
```

---

## Firebase

Everything for Cloud Firestore + Firebase Auth is wired (datasources,
`runTransaction` stock posting, `MasterDataSeeder`, `firestore.rules`,
`firebase_options.dart`, native config) and was verified against the live
project `vimes-inventory-doanhdd`. To switch from offline to live:

1. `lib/core/flavors/flavor_config.dart` → `firebaseTemporarilyDisabled = false`.
2. Enable Email/Password auth + create an account in the Firebase console.
3. `firebase deploy --only firestore:rules,firestore:indexes`.

Full steps: [`docs/firebase_setup.md`](docs/firebase_setup.md).
Firestore has no `CREATE TABLE` — collections appear on first write; the 7 master
collections are auto-seeded on first sign-in, the 4 transaction collections
(`warehouse_receipts`, `receipt_numbers`, `stock_ledger`, `inventory_stock`)
materialise when the first phiếu is saved.

---

## Branches

| Branch | Nội dung |
|---|---|
| `main` | Clean-architecture base skeleton. |
| `vimes-dev` | Bài test: DB schema, form nhập, lưu + ghi sổ, unit test. **← nhánh chấm bài.** |
