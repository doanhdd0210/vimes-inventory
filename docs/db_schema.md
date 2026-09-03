# Database schema — Phiếu nhập kho (Mẫu số 01‑VT)

Reference: Thông tư 200/2014/TT‑BTC, form *Phiếu nhập kho*.

The form is a **header + line-items** document ("một phiếu" = one aggregate).
Two logical tables with a 1—N relationship; below is the relational design first
(the canonical answer to "thiết kế cấu trúc các bảng"), then how it maps to
Cloud Firestore, which is what this Flutter app actually uses.

---

## 1. Relational model (PostgreSQL reference)

### `warehouse_receipts` — phiếu (header)

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | `bigint` GENERATED ALWAYS AS IDENTITY | no | PK (surrogate) |
| `receipt_number` | `varchar(30)` | no | **Số** phiếu. `UNIQUE` |
| `receipt_date` | `date` | no | Ngày … tháng … năm |
| `unit_name` | `varchar(255)` | yes | Đơn vị |
| `department` | `varchar(255)` | yes | Bộ phận |
| `debit_account` | `varchar(20)` | yes | Nợ (TK) |
| `credit_account` | `varchar(20)` | yes | Có (TK) |
| `deliverer_name` | `varchar(255)` | no | Họ và tên người giao |
| `reference_doc_number` | `varchar(50)` | yes | "Theo … số …" |
| `reference_doc_date` | `date` | yes | "… ngày … tháng … năm …" |
| `reference_doc_issuer` | `varchar(255)` | yes | "… của …" |
| `warehouse_name` | `varchar(255)` | no | Nhập tại kho |
| `warehouse_location` | `varchar(255)` | yes | địa điểm |
| `attached_document_count` | `int` | no | Số chứng từ gốc kèm theo. `DEFAULT 0`, `CHECK (>= 0)` |
| `total_amount` | `numeric(18,2)` | no | Cộng — denormalised sum of lines. `CHECK (>= 0)` |
| `total_amount_in_words` | `varchar(500)` | yes | Tổng số tiền (viết bằng chữ) — derived |
| `preparer_name` | `varchar(255)` | yes | Người lập phiếu |
| `storekeeper_name` | `varchar(255)` | yes | Thủ kho |
| `chief_accountant_name` | `varchar(255)` | yes | Kế toán trưởng |
| `status` | `varchar(16)` | no | `draft` \| `posted`. `DEFAULT 'posted'` |
| `version` | `int` | no | optimistic lock. `DEFAULT 1` |
| `created_at` | `timestamptz` | no | `DEFAULT now()` |
| `updated_at` | `timestamptz` | no | `DEFAULT now()`, bumped on update |
| `created_by` | `varchar(128)` | yes | audit |

### `warehouse_receipt_items` — dòng vật tư (lines)

| Column | Type | Null | Notes |
|---|---|---|---|
| `id` | `bigint` IDENTITY | no | PK |
| `receipt_id` | `bigint` | no | FK → `warehouse_receipts(id)` `ON DELETE CASCADE` |
| `line_no` | `int` | no | STT (A). `CHECK (>= 1)`, `UNIQUE (receipt_id, line_no)` |
| `name` | `varchar(500)` | no | Tên, nhãn hiệu, quy cách … (B) |
| `code` | `varchar(50)` | yes | Mã số (C) |
| `unit` | `varchar(30)` | no | Đơn vị tính (D) |
| `quantity_doc` | `numeric(18,3)` | yes | Số lượng — theo chứng từ (1). `CHECK (>= 0)` |
| `quantity_actual` | `numeric(18,3)` | no | Số lượng — thực nhập (2). `CHECK (>= 0)` |
| `unit_price` | `numeric(18,2)` | no | Đơn giá (3). `CHECK (>= 0)` |
| `amount` | `numeric(18,2)` | no | Thành tiền (4). `CHECK (amount = round(quantity_actual * unit_price, 2))` |

### Indexes

- `warehouse_receipts (receipt_number)` — UNIQUE (lookup + dedupe).
- `warehouse_receipts (receipt_date DESC)` — list / report ordering.
- `warehouse_receipts (warehouse_name, receipt_date DESC)` — per-warehouse reports.
- `warehouse_receipt_items (receipt_id)` — FK join (fetch lines of a phiếu).
- `warehouse_receipt_items (code)` — item history across receipts (partial:
  `WHERE code IS NOT NULL`).

### Integrity & concurrency

- Header + all lines are written in **one transaction**; a phiếu with zero lines
  is rejected at the app layer (business rule).
- `total_amount` and each `amount` are derived; the `CHECK` constraints stop
  drifted data from ever being persisted.
- **Duplicate submit**: `UNIQUE (receipt_number)` + an idempotency key on the
  create endpoint.
- **Concurrent edit**: `version` column — `UPDATE … WHERE id = $1 AND version = $2`;
  0 rows → `409 Conflict`.
- **Stock posting** (out of scope here but noted): when a phiếu moves to
  `posted`, the inventory balance update takes `SELECT … FOR UPDATE` on the
  stock row inside the same transaction.

### DDL sketch

```sql
CREATE TABLE warehouse_receipts (
  id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  receipt_number          varchar(30)  NOT NULL,
  receipt_date            date         NOT NULL,
  unit_name               varchar(255),
  department              varchar(255),
  debit_account           varchar(20),
  credit_account          varchar(20),
  deliverer_name          varchar(255) NOT NULL,
  reference_doc_number    varchar(50),
  reference_doc_date      date,
  reference_doc_issuer    varchar(255),
  warehouse_name          varchar(255) NOT NULL,
  warehouse_location      varchar(255),
  attached_document_count int          NOT NULL DEFAULT 0 CHECK (attached_document_count >= 0),
  total_amount            numeric(18,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  total_amount_in_words   varchar(500),
  preparer_name           varchar(255),
  storekeeper_name        varchar(255),
  chief_accountant_name   varchar(255),
  status                  varchar(16)  NOT NULL DEFAULT 'posted',
  version                 int          NOT NULL DEFAULT 1,
  created_at              timestamptz  NOT NULL DEFAULT now(),
  updated_at              timestamptz  NOT NULL DEFAULT now(),
  created_by              varchar(128),
  CONSTRAINT uq_receipt_number UNIQUE (receipt_number)
);

CREATE TABLE warehouse_receipt_items (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  receipt_id      bigint       NOT NULL REFERENCES warehouse_receipts(id) ON DELETE CASCADE,
  line_no         int          NOT NULL CHECK (line_no >= 1),
  name            varchar(500) NOT NULL,
  code            varchar(50),
  unit            varchar(30)  NOT NULL,
  quantity_doc    numeric(18,3) CHECK (quantity_doc >= 0),
  quantity_actual numeric(18,3) NOT NULL CHECK (quantity_actual >= 0),
  unit_price      numeric(18,2) NOT NULL CHECK (unit_price >= 0),
  amount          numeric(18,2) NOT NULL CHECK (amount = round(quantity_actual * unit_price, 2)),
  CONSTRAINT uq_receipt_line UNIQUE (receipt_id, line_no)
);

CREATE INDEX ix_receipts_date       ON warehouse_receipts (receipt_date DESC);
CREATE INDEX ix_receipts_wh_date    ON warehouse_receipts (warehouse_name, receipt_date DESC);
CREATE INDEX ix_items_receipt       ON warehouse_receipt_items (receipt_id);
CREATE INDEX ix_items_code          ON warehouse_receipt_items (code) WHERE code IS NOT NULL;
```

---

## 2. Cloud Firestore mapping (what this app uses)

Firestore has no joins and single-document writes are atomic, so the phiếu is
stored as **one document with an embedded `items` array**. A phiếu has a bounded,
small number of lines (well under the 1 MiB document limit), and it is always
read/written as a whole — the ideal case for embedding.

```
warehouse_receipts (collection)
└── {receiptId} (document)
    ├── receiptNumber: string
    ├── receiptDate: timestamp
    ├── unitName, department, debitAccount, creditAccount: string?
    ├── delivererName: string
    ├── referenceDocNumber: string?, referenceDocDate: timestamp?, referenceDocIssuer: string?
    ├── warehouseName: string, warehouseLocation: string?
    ├── attachedDocumentCount: number
    ├── totalAmount: number                 // derived, stored for list/report
    ├── totalAmountInWords: string          // derived
    ├── preparerName, storekeeperName, chiefAccountantName: string?
    ├── status: 'draft' | 'posted'
    ├── createdAt: timestamp (serverTimestamp)
    ├── updatedAt: timestamp (serverTimestamp)
    └── items: [                            // embedded, ordered by lineNo
        { lineNo, name, code, unit, quantityDoc, quantityActual, unitPrice, amount }
      ]
```

**Rules kept from the relational model**

| Relational | Firestore equivalent |
|---|---|
| `UNIQUE (receipt_number)` | on write, a transaction checks `where('receiptNumber', ==)` is empty, or a mirror doc `receipt_numbers/{number}` is created in the same `runTransaction` |
| `total_amount` / `amount` CHECK | computed in the domain layer (`WarehouseReceipt.totalAmount`, `WarehouseReceiptItem.amount`) before write; enforced again in Firestore Security Rules |
| FK `ON DELETE CASCADE` | items are inside the parent document — deleting it removes them |
| optimistic `version` | `updatedAt` precondition inside `runTransaction`, or a `version` int field |
| `>= 0` CHECKs | Firestore Security Rules (`request.resource.data.items[...].quantityActual >= 0`) + client validation |
| indexes | `receiptDate` single-field (auto) + composite `(warehouseName ASC, receiptDate DESC)` declared in `firestore.indexes.json` |

**Why not a sub-collection for items?** Sub-collections make sense when lines are
numerous, queried independently, or updated in isolation. Here they are neither —
a phiếu is edited and displayed as a unit, and one-document writes give
transactional consistency for free.
