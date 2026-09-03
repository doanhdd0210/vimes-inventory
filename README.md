# VIMES Inventory — Phiếu nhập kho

Dev-test deliverable: entry form for a **Phiếu nhập kho – Mẫu 01‑VT**
(Thông tư 200/2014/TT‑BTC) inside a small inventory app.

Stack: **Flutter** · **Clean Architecture** + **MVVM** (the BLoC is the ViewModel) ·
**flutter_bloc** · **go_router** · **get_it** · **dartz** · **Firebase Auth** +
**Cloud Firestore** (a one-line switch also runs it fully offline — see below).

---

## Quick start

```bash
flutter pub get
flutter test          # 80 tests
flutter run           # == flutter run -t lib/main_dev.dart
```

### Chạy với Firebase (mặc định)

CSDL là **Cloud Firestore**, project `vimes-inventory-doanhdd` (options + native
config đã commit sẵn). Đăng nhập bằng **Firebase Auth (email/password)** — dùng
tài khoản đã tạo trên console:

| Email | Mật khẩu |
|---|---|
| `reviewer@vimes.local` | `Vimes@2026` |

> App không có màn đăng ký. Nếu tài khoản trên không vào được (project bị tạm
> dừng / xoá), xem mục **Offline** bên dưới — chạy đủ chức năng không cần Firebase.

Lần đăng nhập đầu, `MasterDataSeeder` tự nạp 7 collection danh mục. Sau đó:
**Lập phiếu nhập kho** (wizard 3 bước) → phiếu được lưu bằng 1 transaction, ghi
`warehouse_receipts` + `receipt_numbers` + `stock_ledger` + `inventory_stock`;
xem lại ở **Danh sách phiếu**, **Tồn kho**, **Thẻ kho**.

### Chạy offline (không cần Firebase)

`lib/core/flavors/flavor_config.dart` → `firebaseTemporarilyDisabled = true`,
chạy lại. `FakeAuthDataSource` + repo in-memory seed sẵn; login pre-fill
`admin@vimes.local` / `123456` (cả `thukho@`, `ketoan@`). Mọi luồng chạy y hệt.

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

Default CSDL. Everything is wired and deployed for project
`vimes-inventory-doanhdd`: datasources, `runTransaction` stock posting,
`MasterDataSeeder`, `firestore.rules` + `firestore.indexes.json` (deployed),
`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`.
Verified end-to-end on a real device + iOS simulator.

Firestore has **no `CREATE TABLE`** — a collection appears on its first write.
The 7 master collections are auto-seeded on first sign-in; the 4 transaction
collections (`warehouse_receipts`, `receipt_numbers`, `stock_ledger`,
`inventory_stock`) materialise when the first phiếu is saved.
`warehouse_receipt_items` is an embedded `items[]` array, not a collection.

Rules are currently DEMO (`allow read, write: if request.auth != null`); the
role-based production rules are kept as a comment block in `firestore.rules`.
Pointing at another Firebase project: [`docs/firebase_setup.md`](docs/firebase_setup.md).

---

## Branches

| Branch | Nội dung |
|---|---|
| `main` | Clean-architecture base skeleton. |
| `vimes-dev` | Bài test: DB schema, form nhập, lưu + ghi sổ, unit test. **← nhánh chấm bài.** |
