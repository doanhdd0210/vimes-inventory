# Database schema — Quản lý tồn kho / Phiếu nhập kho (Mẫu số 01‑VT)

Reference: Thông tư 200/2014/TT‑BTC, form *Phiếu nhập kho*.

VIMES asked for an **inventory-management** system whose first function is
capturing goods-receipt notes. So the schema is not just the phiếu — it also
needs the master data the phiếu refers to (kho, vật tư, đơn vị tính, nhà cung
cấp) and the stock records the phiếu updates.

## Table overview

| # | Table | Vietnamese | Role |
|---|---|---|---|
| 1 | `warehouses` | Kho | master — "Nhập tại kho … địa điểm" |
| 2 | `units_of_measure` | Đơn vị tính | master — cột D |
| 3 | `item_categories` | Nhóm vật tư, hàng hoá | master — phân loại `items` |
| 4 | `items` | Danh mục vật tư, hàng hoá | master — cột B (tên/quy cách), cột C (mã số) |
| 5 | `partners` | Nhà cung cấp / người giao | master — "của …", người giao hàng |
| 6 | `warehouse_receipts` | Phiếu nhập kho | chứng từ — phần header |
| 7 | `warehouse_receipt_items` | Chi tiết phiếu nhập | chứng từ — các dòng (A/B/C/D/1/2/3/4) |
| 8 | `stock_ledger` | Thẻ kho (sổ chi tiết) | mọi lần nhập/xuất — nguồn sự thật của tồn kho |
| 9 | `inventory_stock` | Tồn kho hiện tại | snapshot tồn theo `warehouse × item` (đọc nhanh) |

Tables 1–7 store the phiếu and its lookups; 8–9 are the tồn-kho engine
(`stock_ledger` is append-only history, `inventory_stock` is the running
balance the ledger keeps up to date). `employees` and `accounts` (§4) are
optional lookups — the form itself only needs free-text signatures and TK codes.

---

## 1. Relational model (PostgreSQL)

Conventions: surrogate `id bigint GENERATED ALWAYS AS IDENTITY`; business codes
carry a `UNIQUE`; money `numeric(18,2)`, quantity `numeric(18,3)`; timestamps
`timestamptz` in UTC; `created_at` / `updated_at` on every table; soft-delete
via `is_active` on masters.

### 1. `warehouses` — kho

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` |
| `name` | varchar(255) | no | |
| `location` | varchar(255) | yes | "địa điểm" |
| `keeper_name` | varchar(255) | yes | thủ kho mặc định |
| `is_active` | boolean | no | `DEFAULT true` |

### 2. `units_of_measure` — đơn vị tính

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` (e.g. `CAI`, `KG`, `M`) |
| `name` | varchar(50) | no | "cái", "kg", "mét" |

### 3. `item_categories` — nhóm vật tư, hàng hoá

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` |
| `name` | varchar(255) | no | |
| `parent_id` | bigint | yes | FK → `item_categories(id)` — cây nhóm |

### 4. `items` — danh mục vật tư, hàng hoá

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(50) | no | **Mã số** (cột C). `UNIQUE` |
| `name` | varchar(500) | no | **Tên, nhãn hiệu, quy cách** (cột B) |
| `specification` | varchar(500) | yes | quy cách / phẩm chất chi tiết |
| `category_id` | bigint | yes | FK → `item_categories(id)` `ON DELETE SET NULL` |
| `uom_id` | bigint | no | FK → `units_of_measure(id)` `ON DELETE RESTRICT` — ĐVT gốc |
| `default_unit_price` | numeric(18,2) | yes | đơn giá tham khảo. `CHECK (>= 0)` |
| `min_stock` | numeric(18,3) | yes | định mức tồn tối thiểu (cảnh báo) |
| `is_active` | boolean | no | `DEFAULT true` |

### 5. `partners` — nhà cung cấp / người giao

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` |
| `name` | varchar(255) | no | "của …" |
| `tax_code` | varchar(20) | yes | MST |
| `phone` | varchar(20) | yes | |
| `address` | varchar(255) | yes | |
| `is_active` | boolean | no | `DEFAULT true` |

### 6. `warehouse_receipts` — phiếu nhập kho (header)

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `receipt_number` | varchar(30) | no | **Số** phiếu. `UNIQUE` |
| `receipt_date` | date | no | Ngày … tháng … năm |
| `unit_name` | varchar(255) | yes | Đơn vị |
| `department` | varchar(255) | yes | Bộ phận |
| `debit_account` | varchar(20) | yes | Nợ (TK) |
| `credit_account` | varchar(20) | yes | Có (TK) |
| `partner_id` | bigint | yes | FK → `partners(id)` `ON DELETE RESTRICT` |
| `deliverer_name` | varchar(255) | no | Họ và tên người giao (free text, khớp form) |
| `reference_doc_number` | varchar(50) | yes | "Theo … số …" |
| `reference_doc_date` | date | yes | "… ngày … tháng … năm …" |
| `reference_doc_issuer` | varchar(255) | yes | "… của …" |
| `warehouse_id` | bigint | no | FK → `warehouses(id)` `ON DELETE RESTRICT` |
| `attached_document_count` | int | no | Số chứng từ gốc kèm theo. `DEFAULT 0`, `CHECK (>= 0)` |
| `total_amount` | numeric(18,2) | no | Cộng — denormalised. `CHECK (>= 0)` |
| `total_amount_in_words` | varchar(500) | yes | Tổng số tiền (viết bằng chữ) — derived |
| `preparer_name` | varchar(255) | yes | Người lập phiếu |
| `storekeeper_name` | varchar(255) | yes | Thủ kho |
| `chief_accountant_name` | varchar(255) | yes | Kế toán trưởng |
| `status` | varchar(16) | no | `draft` \| `posted`. `DEFAULT 'posted'` |
| `version` | int | no | optimistic lock. `DEFAULT 1` |
| `created_by` | varchar(128) | yes | audit |

### 7. `warehouse_receipt_items` — chi tiết phiếu

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `receipt_id` | bigint | no | FK → `warehouse_receipts(id)` `ON DELETE CASCADE` |
| `line_no` | int | no | STT (A). `CHECK (>= 1)`, `UNIQUE (receipt_id, line_no)` |
| `item_id` | bigint | yes | FK → `items(id)` `ON DELETE RESTRICT` (null = hàng nhập tự do) |
| `name` | varchar(500) | no | cột B — chốt tại thời điểm lập phiếu |
| `code` | varchar(50) | yes | cột C |
| `uom_id` | bigint | yes | FK → `units_of_measure(id)` |
| `unit` | varchar(30) | no | cột D — chốt tại thời điểm lập phiếu |
| `quantity_doc` | numeric(18,3) | yes | cột 1 — theo chứng từ. `CHECK (>= 0)` |
| `quantity_actual` | numeric(18,3) | no | cột 2 — thực nhập. `CHECK (>= 0)` |
| `unit_price` | numeric(18,2) | no | cột 3. `CHECK (>= 0)` |
| `amount` | numeric(18,2) | no | cột 4. `CHECK (amount = round(quantity_actual * unit_price, 2))` |

### 8. `stock_ledger` — thẻ kho (append-only)

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `warehouse_id` | bigint | no | FK → `warehouses(id)` |
| `item_id` | bigint | no | FK → `items(id)` |
| `movement_type` | varchar(16) | no | `receipt` \| `issue` \| `adjust` |
| `source_table` | varchar(32) | no | e.g. `warehouse_receipt_items` |
| `source_id` | bigint | no | FK-by-value về dòng chứng từ |
| `quantity` | numeric(18,3) | no | +nhập / −xuất |
| `unit_cost` | numeric(18,2) | no | giá vốn dòng |
| `balance_after` | numeric(18,3) | no | tồn sau bút toán (chốt trong transaction) |
| `moved_at` | timestamptz | no | `DEFAULT now()` |
| — | | | `UNIQUE (source_table, source_id)` — mỗi dòng chứng từ ghi sổ đúng 1 lần (idempotent) |

### 9. `inventory_stock` — tồn kho hiện tại

| Column | Type | Null | Notes |
|---|---|---|---|
| `warehouse_id` | bigint | no | PK phần 1, FK → `warehouses(id)` |
| `item_id` | bigint | no | PK phần 2, FK → `items(id)` |
| `quantity_on_hand` | numeric(18,3) | no | `DEFAULT 0`, `CHECK (>= 0)` |
| `avg_cost` | numeric(18,2) | no | bình quân gia quyền. `DEFAULT 0` |
| `updated_at` | timestamptz | no | |
| — | | | PK `(warehouse_id, item_id)` |

### Indexes

```
-- masters
UNIQUE  warehouses(code) · units_of_measure(code) · item_categories(code)
UNIQUE  items(code) · partners(code)
        items(category_id) · items(uom_id) · items(name text_pattern_ops)   -- tìm theo tên

-- chứng từ
UNIQUE  warehouse_receipts(receipt_number)
        warehouse_receipts(receipt_date DESC)
        warehouse_receipts(warehouse_id, receipt_date DESC)
        warehouse_receipts(partner_id)
        warehouse_receipt_items(receipt_id)               -- lấy dòng của 1 phiếu
        warehouse_receipt_items(item_id)                  -- lịch sử 1 vật tư

-- tồn kho
        stock_ledger(warehouse_id, item_id, moved_at)     -- dựng lại thẻ kho
UNIQUE  stock_ledger(source_table, source_id)             -- idempotent posting
-- inventory_stock: PK (warehouse_id, item_id) đã đủ cho tra cứu tồn
        inventory_stock(item_id) WHERE quantity_on_hand <= 0   -- cảnh báo hết hàng
```

### Integrity & concurrency

- **Phiếu là 1 aggregate**: header + tất cả dòng ghi trong **một transaction**;
  phiếu 0 dòng bị chặn ở tầng nghiệp vụ.
- **Số tiền dẫn xuất**: `amount` từng dòng và `total_amount` có `CHECK` → dữ
  liệu lệch không bao giờ vào được DB.
- **Trùng chứng từ**: `UNIQUE(receipt_number)` + idempotency key ở API create.
- **Sửa đồng thời**: cột `version` — `UPDATE … WHERE id = $1 AND version = $2`,
  0 dòng → `409 Conflict`.
- **Ghi tồn kho** khi `status` chuyển sang `posted` (cùng transaction):
  1. `SELECT … FROM inventory_stock WHERE (warehouse_id, item_id) = (…) FOR UPDATE`
     (khoá dòng tồn, chống race giữa 2 phiếu cùng vật tư);
  2. tính `balance_after`, `avg_cost` mới (bình quân gia quyền);
  3. `INSERT INTO stock_ledger …` (nếu `(source_table, source_id)` chưa có);
  4. `UPDATE inventory_stock` hoặc `INSERT` nếu chưa có dòng.
- Huỷ phiếu đã `posted` = ghi bút toán đảo trong `stock_ledger`, không xoá.

### DDL sketch (rút gọn cho 8 bảng cốt lõi + tồn kho)

```sql
CREATE TABLE warehouses (
  id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code      varchar(20)  NOT NULL,
  name      varchar(255) NOT NULL,
  location  varchar(255),
  keeper_name varchar(255),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_warehouses_code UNIQUE (code)
);

CREATE TABLE units_of_measure (
  id   bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code varchar(20) NOT NULL,
  name varchar(50) NOT NULL,
  CONSTRAINT uq_uom_code UNIQUE (code)
);

CREATE TABLE item_categories (
  id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code      varchar(20)  NOT NULL,
  name      varchar(255) NOT NULL,
  parent_id bigint REFERENCES item_categories(id) ON DELETE SET NULL,
  CONSTRAINT uq_item_categories_code UNIQUE (code)
);

CREATE TABLE items (
  id                 bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code               varchar(50)  NOT NULL,
  name               varchar(500) NOT NULL,
  specification      varchar(500),
  category_id        bigint REFERENCES item_categories(id) ON DELETE SET NULL,
  uom_id             bigint NOT NULL REFERENCES units_of_measure(id) ON DELETE RESTRICT,
  default_unit_price numeric(18,2) CHECK (default_unit_price >= 0),
  min_stock          numeric(18,3),
  is_active          boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_items_code UNIQUE (code)
);

CREATE TABLE partners (
  id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code     varchar(20)  NOT NULL,
  name     varchar(255) NOT NULL,
  tax_code varchar(20),
  phone    varchar(20),
  address  varchar(255),
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT uq_partners_code UNIQUE (code)
);

CREATE TABLE warehouse_receipts (
  id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  receipt_number          varchar(30)  NOT NULL,
  receipt_date            date         NOT NULL,
  unit_name               varchar(255),
  department              varchar(255),
  debit_account           varchar(20),
  credit_account          varchar(20),
  partner_id              bigint REFERENCES partners(id) ON DELETE RESTRICT,
  deliverer_name          varchar(255) NOT NULL,
  reference_doc_number    varchar(50),
  reference_doc_date      date,
  reference_doc_issuer    varchar(255),
  warehouse_id            bigint       NOT NULL REFERENCES warehouses(id) ON DELETE RESTRICT,
  attached_document_count int          NOT NULL DEFAULT 0 CHECK (attached_document_count >= 0),
  total_amount            numeric(18,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  total_amount_in_words   varchar(500),
  preparer_name           varchar(255),
  storekeeper_name        varchar(255),
  chief_accountant_name   varchar(255),
  status                  varchar(16)  NOT NULL DEFAULT 'posted',
  version                 int          NOT NULL DEFAULT 1,
  created_by              varchar(128),
  created_at timestamptz  NOT NULL DEFAULT now(),
  updated_at timestamptz  NOT NULL DEFAULT now(),
  CONSTRAINT uq_receipt_number UNIQUE (receipt_number)
);

CREATE TABLE warehouse_receipt_items (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  receipt_id      bigint       NOT NULL REFERENCES warehouse_receipts(id) ON DELETE CASCADE,
  line_no         int          NOT NULL CHECK (line_no >= 1),
  item_id         bigint REFERENCES items(id) ON DELETE RESTRICT,
  name            varchar(500) NOT NULL,
  code            varchar(50),
  uom_id          bigint REFERENCES units_of_measure(id),
  unit            varchar(30)  NOT NULL,
  quantity_doc    numeric(18,3) CHECK (quantity_doc >= 0),
  quantity_actual numeric(18,3) NOT NULL CHECK (quantity_actual >= 0),
  unit_price      numeric(18,2) NOT NULL CHECK (unit_price >= 0),
  amount          numeric(18,2) NOT NULL CHECK (amount = round(quantity_actual * unit_price, 2)),
  CONSTRAINT uq_receipt_line UNIQUE (receipt_id, line_no)
);

CREATE TABLE stock_ledger (
  id            bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  warehouse_id  bigint NOT NULL REFERENCES warehouses(id),
  item_id       bigint NOT NULL REFERENCES items(id),
  movement_type varchar(16) NOT NULL,
  source_table  varchar(32) NOT NULL,
  source_id     bigint      NOT NULL,
  quantity      numeric(18,3) NOT NULL,
  unit_cost     numeric(18,2) NOT NULL CHECK (unit_cost >= 0),
  balance_after numeric(18,3) NOT NULL,
  moved_at      timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_ledger_source UNIQUE (source_table, source_id)
);

CREATE TABLE inventory_stock (
  warehouse_id     bigint NOT NULL REFERENCES warehouses(id),
  item_id          bigint NOT NULL REFERENCES items(id),
  quantity_on_hand numeric(18,3) NOT NULL DEFAULT 0 CHECK (quantity_on_hand >= 0),
  avg_cost         numeric(18,2) NOT NULL DEFAULT 0,
  updated_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (warehouse_id, item_id)
);

CREATE INDEX ix_items_category    ON items (category_id);
CREATE INDEX ix_items_name        ON items (name text_pattern_ops);
CREATE INDEX ix_receipts_date     ON warehouse_receipts (receipt_date DESC);
CREATE INDEX ix_receipts_wh_date  ON warehouse_receipts (warehouse_id, receipt_date DESC);
CREATE INDEX ix_receipts_partner  ON warehouse_receipts (partner_id);
CREATE INDEX ix_items_receipt     ON warehouse_receipt_items (receipt_id);
CREATE INDEX ix_items_item        ON warehouse_receipt_items (item_id);
CREATE INDEX ix_ledger_wh_item    ON stock_ledger (warehouse_id, item_id, moved_at);
```

---

## 2. Optional lookups (không bắt buộc cho form)

| Table | Vietnamese | Why optional |
|---|---|---|
| `employees` | Nhân viên (người lập / thủ kho / kế toán trưởng) | Form chỉ cần "Ký, họ tên" → lưu text trên phiếu là đủ; thêm bảng khi cần phân quyền / báo cáo theo người |
| `accounts` | Hệ thống tài khoản kế toán | Nợ/Có hiện lưu mã text; thêm bảng khi cần kiểm tra hợp lệ TK |
| `departments` | Phòng ban / bộ phận | Tách khỏi text `department` khi cần cây tổ chức |

---

## 3. Cloud Firestore mapping (bản Flutter đang chạy)

Firestore không join, ghi 1 document là atomic → mỗi **master** là 1 collection,
**phiếu** là 1 document nhúng mảng `items`, **tồn kho** tách riêng để đọc/ghi
độc lập.

```
warehouses/{id}            { code, name, location, keeperName, isActive }
units_of_measure/{id}      { code, name }
item_categories/{id}       { code, name, parentId }
items/{id}                 { code, name, specification, categoryId, uomId,
                             defaultUnitPrice, minStock, isActive }
partners/{id}              { code, name, taxCode, phone, address, isActive }

warehouse_receipts/{id}    { receiptNumber, receiptDate, warehouseId, partnerId,
                             delivererName, debitAccount, creditAccount,
                             referenceDocNumber/Date/Issuer, attachedDocumentCount,
                             totalAmount, totalAmountInWords,
                             preparerName, storekeeperName, chiefAccountantName,
                             status, createdAt, updatedAt,
                             items: [ { lineNo, itemId, name, code, unit, uomId,
                                        quantityDoc, quantityActual,
                                        unitPrice, amount } ] }

receipt_numbers/{number}   { receiptId, createdAt }      -- mirror, enforce UNIQUE

inventory_stock/{warehouseId}_{itemId}
                           { warehouseId, itemId, quantityOnHand, avgCost, updatedAt }
stock_ledger/{id}          { warehouseId, itemId, movementType,
                             sourceTable, sourceId, quantity, unitCost,
                             balanceAfter, movedAt }
```

| Ràng buộc quan hệ | Tương đương Firestore |
|---|---|
| `UNIQUE(receipt_number)` | transaction kiểm tra `receipt_numbers/{number}` chưa tồn tại rồi tạo cùng lúc với phiếu |
| `amount` / `total_amount` CHECK | tính ở domain (`WarehouseReceiptItem.amount`, `WarehouseReceipt.totalAmount`) + Security Rules |
| FK `warehouse_id`, `item_id` | lưu id tham chiếu; toàn vẹn kiểm ở app + Rules (`exists(/databases/…/warehouses/$(id))`) |
| FK `ON DELETE CASCADE` (lines) | lines nằm trong document cha |
| optimistic `version` | field `version` / precondition `updatedAt` trong `runTransaction` |
| khoá `SELECT … FOR UPDATE` khi ghi tồn | `runTransaction` đọc `inventory_stock/{wh}_{item}` → tính → ghi `stock_ledger` + cập nhật `inventory_stock`, tất cả trong 1 transaction |
| index quan hệ | `firestore.indexes.json`: composite `(warehouseId ASC, receiptDate DESC)` … |

> **Phạm vi bài test:** app hiện thực bảng 1–7 (master + phiếu). `stock_ledger` /
> `inventory_stock` được thiết kế đầy đủ ở đây và để lại ở tầng domain như bước
> tiếp theo (posting tồn kho khi phiếu `posted`).
