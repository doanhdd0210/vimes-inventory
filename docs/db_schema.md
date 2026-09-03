# Database schema — Quản lý tồn kho / Phiếu nhập kho (Mẫu số 01‑VT)

Reference: Thông tư 200/2014/TT‑BTC, form *Phiếu nhập kho*.

VIMES cần hệ **quản lý tồn kho**, chức năng đầu tiên là nhập phiếu nhập kho. Vì
vậy schema gồm: master data phiếu tham chiếu tới, bản thân phiếu, và bản ghi tồn
kho mà phiếu cập nhật.

## Tổng quan — 11 bảng

| # | Bảng | Tiếng Việt | Vai trò |
|---|---|---|---|
| 1 | `organizations` | Đơn vị | master — dòng "Đơn vị:" |
| 2 | `departments` | Bộ phận | master — dòng "Bộ phận:" (cây, thuộc `organizations`) |
| 3 | `users` | Tài khoản / nhân sự | đăng nhập + là người giao / lập phiếu / thủ kho / kế toán trưởng |
| 4 | `warehouses` | Kho | master — "Nhập tại kho … địa điểm" |
| 5 | `item_categories` | Nhóm sản phẩm | master — phân loại `items` (cây) |
| 6 | `units_of_measure` | Đơn vị tính | master — cột D |
| 7 | `items` | Sản phẩm / vật tư, hàng hoá | master — cột B (tên/quy cách), cột C (mã số) |
| 8 | `warehouse_receipts` | Phiếu nhập kho | chứng từ — phần header |
| 9 | `warehouse_receipt_items` | Chi tiết phiếu nhập | chứng từ — các dòng (A/B/C/D/1/2/3/4) |
| 10 | `stock_ledger` | Thẻ kho (sổ chi tiết) | append‑only, mọi lần nhập/xuất/điều chỉnh — nguồn sự thật của tồn |
| 11 | `inventory_stock` | Tồn kho hiện tại | snapshot số dư theo `warehouse × item`, cập nhật cùng transaction với `stock_ledger` |

**Đã bỏ:** `partners` (Mẫu 01‑VT không có dòng "Nhà cung cấp"; "người giao" và
"của …" đã đủ) · `accounts` (Nợ/Có lưu mã TK dạng text) · `employees` (gộp vào
`users` — người ký = một tài khoản).

**Tồn kho — dùng cách C:** `stock_ledger` (lịch sử bất biến) + `inventory_stock`
(số dư đọc nhanh), ghi trong **một transaction**. Đối chiếu định kỳ
`SUM(stock_ledger.quantity) == inventory_stock.quantity_on_hand`.

---

## 1. Relational model (PostgreSQL)

Quy ước: `id bigint GENERATED ALWAYS AS IDENTITY` (surrogate); mã nghiệp vụ có
`UNIQUE`; tiền `numeric(18,2)`, số lượng `numeric(18,3)`; thời gian `timestamptz`
theo UTC; `created_at` / `updated_at` mọi bảng; xoá mềm bằng `is_active` ở master.

### 1. `organizations` — Đơn vị

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` |
| `name` | varchar(255) | no | |
| `tax_code` | varchar(20) | yes | MST |
| `address` | varchar(255) | yes | |
| `phone` | varchar(20) | yes | |
| `is_active` | boolean | no | `DEFAULT true` |

### 2. `departments` — Bộ phận

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `organization_id` | bigint | no | FK → `organizations(id)` `ON DELETE RESTRICT` |
| `code` | varchar(20) | no | `UNIQUE (organization_id, code)` |
| `name` | varchar(255) | no | |
| `parent_id` | bigint | yes | FK → `departments(id)` `ON DELETE SET NULL` — cây |
| `is_active` | boolean | no | `DEFAULT true` |

### 3. `users` — Tài khoản / nhân sự

Với Firebase: xác thực do **Firebase Auth** lo; bảng/collection này lưu hồ sơ +
vai trò, khoá theo Auth UID. Cột `password_hash` chỉ dùng khi tự quản lý auth
(hướng Node/Postgres).

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK (Postgres) / Auth UID (Firestore) |
| `organization_id` | bigint | no | FK → `organizations(id)` |
| `department_id` | bigint | yes | FK → `departments(id)` `ON DELETE SET NULL` |
| `username` | varchar(50) | no | `UNIQUE` |
| `email` | varchar(255) | yes | `UNIQUE` (partial `WHERE email IS NOT NULL`) |
| `password_hash` | varchar(255) | yes | null khi dùng Firebase Auth |
| `full_name` | varchar(255) | no | tên hiển thị, in lên chữ ký phiếu |
| `position` | varchar(100) | yes | chức danh (thủ kho, kế toán trưởng…) |
| `role` | varchar(20) | no | `admin` \| `warehouse_keeper` \| `accountant` \| `staff` \| `viewer`. `DEFAULT 'staff'` |
| `is_active` | boolean | no | `DEFAULT true` |

### 4. `warehouses` — Kho

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `organization_id` | bigint | no | FK → `organizations(id)` |
| `code` | varchar(20) | no | `UNIQUE (organization_id, code)` |
| `name` | varchar(255) | no | |
| `location` | varchar(255) | yes | "địa điểm" |
| `keeper_user_id` | bigint | yes | FK → `users(id)` `ON DELETE SET NULL` — thủ kho mặc định |
| `is_active` | boolean | no | `DEFAULT true` |

### 5. `item_categories` — Nhóm sản phẩm

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` |
| `name` | varchar(255) | no | |
| `parent_id` | bigint | yes | FK → `item_categories(id)` `ON DELETE SET NULL` |
| `is_active` | boolean | no | `DEFAULT true` |

### 6. `units_of_measure` — Đơn vị tính

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(20) | no | `UNIQUE` (e.g. `CAI`, `KG`, `M`) |
| `name` | varchar(50) | no | "cái", "kg", "mét" |

### 7. `items` — Sản phẩm / vật tư, hàng hoá

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `code` | varchar(50) | no | **Mã số** (cột C). `UNIQUE` |
| `name` | varchar(500) | no | **Tên, nhãn hiệu, quy cách** (cột B) |
| `specification` | varchar(500) | yes | quy cách / phẩm chất chi tiết |
| `category_id` | bigint | yes | FK → `item_categories(id)` `ON DELETE SET NULL` |
| `uom_id` | bigint | no | FK → `units_of_measure(id)` `ON DELETE RESTRICT` — ĐVT gốc (cột D) |
| `default_unit_price` | numeric(18,2) | yes | đơn giá tham khảo. `CHECK (>= 0)` |
| `min_stock` | numeric(18,3) | yes | định mức tồn tối thiểu (cảnh báo) |
| `is_active` | boolean | no | `DEFAULT true` |

### 8. `warehouse_receipts` — Phiếu nhập kho (header)

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `receipt_number` | varchar(30) | no | **Số** phiếu. `UNIQUE` |
| `receipt_date` | date | no | Ngày … tháng … năm |
| `organization_id` | bigint | no | FK → `organizations(id)` — Đơn vị |
| `department_id` | bigint | yes | FK → `departments(id)` `ON DELETE RESTRICT` — Bộ phận |
| `debit_account` | varchar(20) | yes | Nợ (mã TK, text) |
| `credit_account` | varchar(20) | yes | Có (mã TK, text) |
| `deliverer_user_id` | bigint | no | FK → `users(id)` `ON DELETE RESTRICT` — Họ và tên người giao |
| `reference_doc_number` | varchar(50) | yes | "Theo … số …" |
| `reference_doc_date` | date | yes | "… ngày … tháng … năm …" |
| `reference_doc_issuer` | varchar(255) | yes | "… của …" |
| `warehouse_id` | bigint | no | FK → `warehouses(id)` `ON DELETE RESTRICT` — Nhập tại kho |
| `warehouse_location` | varchar(255) | yes | địa điểm — snapshot lúc lập phiếu |
| `attached_document_count` | int | no | Số chứng từ gốc kèm theo. `DEFAULT 0`, `CHECK (>= 0)` |
| `total_amount` | numeric(18,2) | no | Cộng — dẫn xuất. `CHECK (>= 0)` |
| `total_amount_in_words` | varchar(500) | yes | Tổng số tiền (viết bằng chữ) — dẫn xuất |
| `preparer_user_id` | bigint | yes | FK → `users(id)` — Người lập phiếu |
| `storekeeper_user_id` | bigint | yes | FK → `users(id)` — Thủ kho |
| `chief_accountant_user_id` | bigint | yes | FK → `users(id)` — Kế toán trưởng |
| `status` | varchar(16) | no | `draft` \| `posted` \| `cancelled`. `DEFAULT 'draft'` |
| `posted_at` | timestamptz | yes | thời điểm ghi sổ tồn kho |
| `version` | int | no | optimistic lock. `DEFAULT 1` |
| `created_by` | bigint | yes | FK → `users(id)` — audit |

### 9. `warehouse_receipt_items` — Chi tiết phiếu

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `receipt_id` | bigint | no | FK → `warehouse_receipts(id)` `ON DELETE CASCADE` |
| `line_no` | int | no | STT (A). `CHECK (>= 1)`, `UNIQUE (receipt_id, line_no)` |
| `item_id` | bigint | no | FK → `items(id)` `ON DELETE RESTRICT` |
| `name` | varchar(500) | no | cột B — snapshot lúc lập phiếu |
| `code` | varchar(50) | yes | cột C — snapshot |
| `uom_id` | bigint | no | FK → `units_of_measure(id)` |
| `unit` | varchar(30) | no | cột D — snapshot |
| `quantity_doc` | numeric(18,3) | yes | cột 1 — theo chứng từ. `CHECK (>= 0)` |
| `quantity_actual` | numeric(18,3) | no | cột 2 — thực nhập. `CHECK (> 0)` |
| `unit_price` | numeric(18,2) | no | cột 3. `CHECK (>= 0)` |
| `amount` | numeric(18,2) | no | cột 4. `CHECK (amount = round(quantity_actual * unit_price, 2))` |

### 10. `stock_ledger` — Thẻ kho (append‑only)

Bảng **chung cho mọi chứng từ kho** (nhập / xuất / điều chỉnh / chuyển kho).
`quantity` có dấu: `+` nhập, `−` xuất.

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint IDENTITY | no | PK |
| `organization_id` | bigint | no | FK → `organizations(id)` |
| `warehouse_id` | bigint | no | FK → `warehouses(id)` |
| `item_id` | bigint | no | FK → `items(id)` |
| `movement_type` | varchar(16) | no | `receipt` \| `issue` \| `adjust` \| `transfer` |
| `quantity` | numeric(18,3) | no | có dấu (+nhập / −xuất) |
| `unit_cost` | numeric(18,2) | no | giá vốn dòng. `CHECK (>= 0)` |
| `value` | numeric(18,2) | no | `= round(quantity * unit_cost, 2)` (có dấu) |
| `balance_qty_after` | numeric(18,3) | no | tồn SL sau bút toán |
| `balance_value_after` | numeric(18,2) | no | giá trị tồn sau bút toán |
| `avg_cost_after` | numeric(18,2) | no | đơn giá bình quân sau bút toán |
| `source_table` | varchar(32) | no | e.g. `warehouse_receipt_items` |
| `source_id` | bigint | no | id dòng chứng từ gốc |
| `moved_at` | timestamptz | no | thường = `receipt_date`. `DEFAULT now()` |
| `posted_by` | bigint | yes | FK → `users(id)` |
| — | | | `UNIQUE (source_table, source_id)` — mỗi dòng chứng từ ghi sổ đúng 1 lần (idempotent) |

### 11. `inventory_stock` — Tồn kho hiện tại (snapshot)

| Column | Type | Null | Notes |
|---|---|---|---|
| `organization_id` | bigint | no | FK → `organizations(id)` |
| `warehouse_id` | bigint | no | PK phần 1, FK → `warehouses(id)` |
| `item_id` | bigint | no | PK phần 2, FK → `items(id)` |
| `quantity_on_hand` | numeric(18,3) | no | `DEFAULT 0`, `CHECK (>= 0)` |
| `stock_value` | numeric(18,2) | no | giá trị tồn. `DEFAULT 0`, `CHECK (>= 0)` |
| `avg_cost` | numeric(18,2) | no | `= round(stock_value / quantity_on_hand, 2)` khi qty > 0, ngược lại 0 |
| `last_movement_at` | timestamptz | yes | |
| `updated_at` | timestamptz | no | |
| — | | | PK `(warehouse_id, item_id)` |

---

## 2. Ghi sổ tồn kho khi lưu phiếu (bình quân gia quyền)

Toàn bộ trong **một transaction**:

```
kiểm receipt_number chưa tồn tại
INSERT warehouse_receipts (status = 'posted', posted_at = now())
FOR mỗi dòng phiếu:
    INSERT warehouse_receipt_items → line
    SELECT * FROM inventory_stock
      WHERE (warehouse_id, item_id) = (receipt.warehouse_id, line.item_id)
      FOR UPDATE                                  -- khoá dòng tồn, chống race
    old_qty  := coalesce(inv.quantity_on_hand, 0)
    old_val  := coalesce(inv.stock_value, 0)
    in_qty   := line.quantity_actual
    in_val   := line.amount                       -- = qty * unit_price
    new_qty  := old_qty + in_qty
    new_val  := old_val + in_val
    new_avg  := new_qty > 0 ? round(new_val / new_qty, 2) : 0
    INSERT stock_ledger (
      movement_type = 'receipt', quantity = +in_qty, unit_cost = line.unit_price,
      value = +in_val, balance_qty_after = new_qty, balance_value_after = new_val,
      avg_cost_after = new_avg,
      source_table = 'warehouse_receipt_items', source_id = line.id,
      moved_at = receipt.receipt_date)            -- UNIQUE(source_table, source_id) ⇒ idempotent
    UPSERT inventory_stock
      SET quantity_on_hand = new_qty, stock_value = new_val, avg_cost = new_avg,
          last_movement_at = receipt.receipt_date
COMMIT
```

- **Huỷ phiếu đã `posted`** = ghi các bút toán đảo trong `stock_ledger`
  (`quantity` âm, `movement_type = 'adjust'`), `status := 'cancelled'`. Không xoá.
- **Sửa đồng thời**: `UPDATE warehouse_receipts … WHERE id = $1 AND version = $2`;
  0 dòng → `409 Conflict`.
- **Trùng số phiếu**: `UNIQUE(receipt_number)` + idempotency key ở API create.

---

## 3. Indexes

```
UNIQUE  organizations(code)
UNIQUE  departments(organization_id, code)          ·  departments(parent_id)
UNIQUE  users(username)  ·  users(email) WHERE email IS NOT NULL
        users(organization_id, department_id)
UNIQUE  warehouses(organization_id, code)
UNIQUE  item_categories(code)                        ·  item_categories(parent_id)
UNIQUE  units_of_measure(code)
UNIQUE  items(code)
        items(category_id)  ·  items(uom_id)  ·  items(name text_pattern_ops)   -- tìm theo tên

UNIQUE  warehouse_receipts(receipt_number)
        warehouse_receipts(receipt_date DESC)
        warehouse_receipts(warehouse_id, receipt_date DESC)
        warehouse_receipts(organization_id, status)
        warehouse_receipts(deliverer_user_id)
        warehouse_receipt_items(receipt_id)          -- lấy dòng của 1 phiếu
        warehouse_receipt_items(item_id)             -- lịch sử 1 vật tư

        stock_ledger(warehouse_id, item_id, moved_at)   -- dựng lại thẻ kho
        stock_ledger(organization_id, moved_at)
UNIQUE  stock_ledger(source_table, source_id)
-- inventory_stock: PK (warehouse_id, item_id) đủ cho tra cứu tồn
        inventory_stock(item_id)
```

---

## 4. Cloud Firestore mapping (bản Flutter đang chạy)

Firestore không join, ghi 1 document là atomic → mỗi master 1 collection, phiếu
là 1 document nhúng mảng `items`, tồn kho tách riêng.

```
organizations/{id}        { code, name, taxCode, address, phone, isActive }
departments/{id}          { organizationId, code, name, parentId, isActive }
users/{authUid}           { organizationId, departmentId, username, email,
                            fullName, position, role, isActive }
warehouses/{id}           { organizationId, code, name, location,
                            keeperUserId, isActive }
item_categories/{id}      { code, name, parentId, isActive }
units_of_measure/{id}     { code, name }
items/{id}                { code, name, specification, categoryId, uomId,
                            defaultUnitPrice, minStock, isActive }

warehouse_receipts/{id}   { receiptNumber, receiptDate, organizationId,
                            departmentId, debitAccount, creditAccount,
                            delivererUserId, referenceDocNumber/Date/Issuer,
                            warehouseId, warehouseLocation,
                            attachedDocumentCount, totalAmount,
                            totalAmountInWords, preparerUserId,
                            storekeeperUserId, chiefAccountantUserId,
                            status, postedAt, version, createdBy,
                            createdAt, updatedAt,
                            items: [ { lineNo, itemId, name, code, unit, uomId,
                                       quantityDoc, quantityActual,
                                       unitPrice, amount } ] }

receipt_numbers/{number}  { receiptId, createdAt }        -- mirror, enforce UNIQUE

stock_ledger/{id}         { organizationId, warehouseId, itemId, movementType,
                            quantity, unitCost, value, balanceQtyAfter,
                            balanceValueAfter, avgCostAfter, sourceCollection,
                            sourceId, movedAt, postedBy }
inventory_stock/{warehouseId}__{itemId}
                          { organizationId, warehouseId, itemId,
                            quantityOnHand, stockValue, avgCost,
                            lastMovementAt, updatedAt }
```

`runTransaction` khi lưu phiếu: **đọc trước, ghi sau** —
1. read `receipt_numbers/{number}` (phải chưa tồn tại)
2. read `inventory_stock/{wh}__{item}` cho từng dòng
3. tính số dư + `avgCost` mới
4. `set` `warehouse_receipts/{id}` + `receipt_numbers/{number}`
5. mỗi dòng: `set` `stock_ledger/{id}` + `set (merge)` `inventory_stock/{wh}__{item}`

Giới hạn: 1 transaction ≤ 500 ghi; 1 phiếu N dòng = `2 + 2N` ghi, `1 + N` đọc.

| Ràng buộc quan hệ | Tương đương Firestore |
|---|---|
| `UNIQUE(receipt_number)` | mirror doc `receipt_numbers/{number}` kiểm trong transaction |
| `amount` / `total_amount` CHECK | tính ở domain + Security Rules |
| FK (`warehouseId`, `itemId`, `delivererUserId`…) | lưu id; toàn vẹn kiểm ở app + Rules (`exists(/…/warehouses/$(id))`) |
| FK `ON DELETE CASCADE` (lines) | lines nằm trong document cha |
| optimistic `version` | field `version` / precondition `updatedAt` trong `runTransaction` |
| `SELECT … FOR UPDATE` khi ghi tồn | `runTransaction` đọc–tính–ghi `inventory_stock` + `stock_ledger` cùng lúc |
| index quan hệ | `firestore.indexes.json` (composite) |

---

## 5. Trạng thái hiện thực

| Bảng | Code |
|---|---|
| `organizations`, `departments`, `users`, `warehouses`, `item_categories`, `units_of_measure`, `items` | ✅ feature `master_data` — generic `CrudRepository<E>` + Firestore / in-memory + seed. Màn "Danh mục" xem được |
| `warehouse_receipts` + `warehouse_receipt_items` | ✅ embedded doc, header **tham chiếu id** (organizationId / departmentId / warehouseId / delivererUserId / preparer·storekeeper·chiefAccountant UserId) + tên snapshot. Form dùng **dropdown**, dòng vật tư chọn `Item` → tự điền tên/mã/ĐVT/đơn giá |
| `stock_ledger`, `inventory_stock` | ✅ feature `stock`. Lưu phiếu → `runTransaction` ghi phiếu + `receipt_numbers` + `stock_ledger` + `inventory_stock` (bình quân gia quyền, idempotent). Màn "Tồn kho" + "Thẻ kho" xem được. Đường offline dùng `InMemoryStockStore` chung |

Đã có: đăng nhập (Firebase Auth email/password, có `FakeAuthDataSource` cho offline;
router redirect `/login` khi chưa auth).

Ngoài phạm vi bài test: sửa/xoá phiếu, phiếu xuất kho, rule phân quyền theo `role`
(hiện Firestore chạy DEMO rule `allow read, write: if request.auth != null`; bản
rule theo `role` để sẵn dạng comment trong `firestore.rules`).
