# Architecture review — vimes_inventory vs. reference projects

Reviewed against **fcarmobile / "hapycar"** (in-house project) and three widely-cited
Flutter architectures:

| Ref | What it is |
|---|---|
| **Flutter official "Compass App"** | `flutter/samples` — Google's canonical app-architecture sample |
| **Very Good Ventures (Very Good CLI)** | the `bloc` team's production template |
| **Reso Coder TDD Clean Architecture** | the reference most Flutter "clean architecture" repos copy |

---

## 1. How fcarmobile is laid out

```
lib/
  config/       base/ (BaseCubit, RootScreen, rx)  resources/  routes/router.dart  themes/
  data/         di/module.dart      network/ (interceptors)   request/  response/  result/ (Result union)
                repository_impl/repository_impl.dart   services/ (retrofit client)
  domain/       env/  firebase/  locals/ (logger, preferences)  model/   repository/repository.dart
  presentation/ <feature>/ { cubit/ , ui/ , widget/ }
  widgets/      shared widgets grouped by kind
  utils/        constants/  extensions/
```

### What fcarmobile does well (worth keeping / already have)
- **`presentation/<feature>/{cubit, ui, widget}`** — flat, predictable, one shape for every screen.
  Our `presentation/<feature>/{bloc, ui}` is the same idea (we fold feature-widgets into `ui/`).
- **`data/{request, response, result}`** — DTOs in/out kept separate from domain models; a
  `Result` success/error union. We have the equivalent: `data/models` + `dartz` `Either<Failure,T>`.
- **`domain/locals`** — logger + preferences in one place. We have `core/helpers/app_logger` +
  `core/storage/*`.

### What fcarmobile does that we should **not** copy
| fcarmobile | Why it hurts | What we do instead |
|---|---|---|
| DI via GetX `Get.find()` **called inside** cubits/repos | hidden dependencies, cubits can't be unit-tested without a live locator | constructor injection; `get_it` only wires the graph at the edge |
| **one** `Repository` mixin + **one** `RepositoryImpl` (~970 lines, ~60 methods) | every feature depends on everything; merge-conflict magnet | one repository per feature under `features/<f>/domain/repositories` |
| **no use-case layer** — cubits call the god-repo directly | business rules leak into UI state code | `domain/usecases` (+ pure `WarehouseReceiptRules` that the tests hit directly) |
| state = mutable public fields on the cubit (`userName`, `password`…), `State` classes are empty markers | no time-travel, `buildWhen`/`Equatable` can't work, races | immutable `state` + `copyWith` + `props` |
| routing = `onGenerateRoute` switch + `Map<String,dynamic> args` (`args?['id'] ?? ''`) | stringly-typed, no compile-time check | `go_router` typed routes + redirect guard |
| `BaseCubit` carries a second `BehaviorSubject<StateLayout>` next to bloc state | two sources of truth for "loading/error/empty" | the one `status` enum inside each state |

**Net:** fcarmobile is "cubit-per-feature + service-locator + monolithic repo". Our layering is
closer to the official sample and VGV, and is materially easier to test (78 tests, no locator boot).

---

## 2. Where the reference architectures agree, and where we stand

| Concern | Compass App | VGV | Reso Coder | **vimes_inventory** | Verdict |
|---|---|---|---|---|---|
| top split | `ui / domain / data` | feature-first, repos in packages | `core + features/<f>/{data,domain,presentation}` | `core + features/<f>/{data,domain,presentation}` | ✅ matches Reso Coder |
| cross-cutting | `config/ utils/ routing/` | `bootstrap.dart` + `l10n/` | `core/` | `core/` (14 focused sub-folders, none empty) | ✅ standard |
| result type | `Result` sealed | `Either` / typed failures | `Either<Failure,T>` | `Either<Failure,T>` + `ResultFuture<T>` typedef | ✅ |
| presentation | `view_model + widgets` | `bloc + view + widgets` | `bloc + pages + widgets` | `bloc + ui` (per your call: "UI + bloc folder thôi") | ✅ your explicit preference |
| use-cases | `domain/use_cases` | optional | `domain/usecases` callable class | `domain/usecases` + generic CRUD to kill boilerplate | ✅ |
| DI | `MultiProvider` | `RepositoryProvider` | `get_it` | `get_it`, grouped per feature | ✅ |

**Only real inconsistency in our tree:** the four features don't use the *same* sub-folders.

```
auth/data/                → flat            (2 files)
master_data/data/models/  → models/ only
stock/data/models/        → models/ only  + loose domain/weighted_average.dart
warehouse_receipt/data/   → datasources/ + models/ + repositories/   (full)
```

That unevenness is what reads as "chưa chuẩn". Two consistent end-states:

- **Option A — shallow (fcarmobile-style).** Every feature: `data/` (flat), `domain/` (flat),
  `presentation/{bloc,ui}`. Sub-folders only when a kind reaches ~4+ files. Least nesting,
  matches the project you referenced.
- **Option B — strict clean-arch (Reso Coder / official sample).** *Every* feature gets
  `data/{datasources,models,repositories}` + `domain/{entities,repositories,usecases}`, even
  when a folder holds one file. Most "textbook", most nesting.

Recommendation: **Option A** — it matches your house style, your stated "too many folders = kinh",
and drops ~6 folders without losing any layer boundary (the boundary is the `data / domain /
presentation` split, not the leaf folders).

---

## 3. Concrete change list for Option A

1. `warehouse_receipt/data/{datasources,models,repositories}/*` → `warehouse_receipt/data/*`
2. `warehouse_receipt/domain/{entities,repositories,usecases}/*` → `warehouse_receipt/domain/*`
   (keep filenames self-describing: `*_data_source.dart`, `*_model.dart`, `*_repository.dart`,
   `*_repository_impl.dart`, `create_warehouse_receipt.dart`, `warehouse_receipt_rules.dart`)
3. Same flattening for `master_data`, `stock`, `auth`.
4. `stock/domain/weighted_average.dart` already flat — fits.
5. Update imports (mechanical), run `flutter analyze` + `flutter test` (expect 80 green).

No behaviour change, no test-logic change — pure move + import rewrite.

---

## 4. "Có chắc là chuẩn không?" — bằng chứng, không phải cảm giác

"Chuẩn" ở đây đo bằng 2 tiêu chí kiểm chứng được, không phải "nhìn cho đẹp":

### 4.1 Dependency Rule (Clean Architecture — Uncle Bob) được giữ tuyệt đối

Quy tắc: mã nguồn chỉ được phụ thuộc **vào trong** — `presentation → domain ← data`.
Lớp `domain` không được biết gì về Flutter, Firebase, HTTP.

Kiểm chứng bằng `grep` trên repo:

```
domain/ import flutter | cloud_firestore | firebase  → NONE  (domain là pure Dart)
presentation/ import  features/*/data/*              → NONE  (UI chỉ thấy domain)
```

Nghĩa là: đổi Firebase sang REST, hay bỏ Firebase — `domain/` và toàn bộ test business
rule **không phải sửa một dòng**. Đó là mục đích của kiến trúc, và nó đang đúng.

### 4.2 Khớp 1-1 với reference chính thống

| Lớp | Reso Coder (chuẩn "clean-arch" phổ biến nhất) | Flutter team – Compass App (official) | vimes_inventory |
|---|---|---|---|
| chia theo feature, mỗi feature 3 lớp | `features/<f>/{data,domain,presentation}` | `data / domain / ui` (toàn app) | `features/<f>/{data,domain,presentation}` ✅ |
| trả kết quả | `Either<Failure,T>` (dartz) | `Result<T>` sealed | `Either<Failure,T>` + `ResultFuture<T>` ✅ |
| Repository interface ở domain, impl ở data | ✅ | ✅ | ✅ |
| use-case = 1 class callable | `class X implements UseCase` | `domain/use_cases/` | `domain/usecases/` + generic CRUD ✅ |
| state bất biến + Equatable | ✅ (bloc) | `ChangeNotifier` + `Command` | ✅ (bloc + `copyWith` + `props`) |
| DI ở rìa | `get_it` | `MultiProvider` | `get_it`, group theo feature ✅ |
| core dùng chung | `core/{error,network,usecase,util}` | `config/ utils/ routing/` | `core/{error,router,usecase,helpers,...}` ✅ |

Không có mục nào lệch. Cái khác duy nhất — `presentation/{bloc,ui}` thay vì
`{bloc,view,widgets}` — là **do bạn chốt** ("UI + bloc folder thôi"), và nó *gọn hơn*
bản gốc chứ không sai.

### 4.3 Vì sao sub-folder 4 feature lệch nhau KHÔNG phải lỗi kiến trúc

Ranh giới kiến trúc là **bộ 3 `data / domain / presentation`** (Dependency Rule chạy trên
đó). Folder lá bên trong (`datasources/`, `models/`, `entities/`…) chỉ là **cách nhóm file**,
không phải một tầng — nó sinh ra khi số file đủ nhiều để cần nhóm:

```
auth/data/            2 file  → để phẳng
master_data/data/     nhiều model + seeder → tách models/
warehouse_receipt/data/  interface + in-mem + firestore impl + models → tách đủ
```

Đây chính là cách **Compass App** (official) và **Very Good Ventures** làm: tạo folder khi
đếm đủ, không tạo folder rỗng chỉ để cho "đối xứng". Ép mọi feature cùng số folder (Option B)
là *thêm ceremony*, không phải *thêm chuẩn*.

### 4.4 Payoff đo được

- **80 test pass**, `flutter analyze` sạch.
- Bloc test dựng trực tiếp bằng fake (`ReceiptFormBloc(createWarehouseReceipt: MockCreate(), auth: AuthRepositoryImpl(FakeAuthDataSource()), …)`) — **không cần bootstrap `get_it`**, không cần Firebase. Chỉ làm được điều này khi Dependency Rule đúng.
- `WarehouseReceiptRules.validate()` là hàm thuần → test 1 dòng, không mock gì.

### 4.5 Ngược lại: fcarmobile vi phạm Dependency Rule ở đâu

- `LoginCubit` gọi `Get.find<Repository>()` ngay trong thân class → presentation phụ thuộc
  vào service locator toàn cục, không phải vào abstraction được inject. Test cubit phải boot cả `Get`.
- Không có tầng `domain` cô lập: `domain/repository/repository.dart` import thẳng
  `data/response/*` và cả `presentation/add_my_car/widget/select_car.dart` → domain phụ thuộc
  ngược ra presentation. Đây là vi phạm rõ ràng.
- `RepositoryImpl` 970 dòng gộp mọi feature → không còn ranh giới feature nào.

→ Kết luận: **giữ nguyên kiến trúc hiện tại.** Nó đúng Dependency Rule (kiểm chứng bằng grep),
khớp cả reference cộng đồng lẫn official sample, và trả về được lợi ích thực (80 test không cần
DI/Firebase). fcarmobile là bản để *tránh*, không phải để theo.

