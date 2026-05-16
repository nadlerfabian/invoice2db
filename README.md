# Invoice2DB

UiPath Windows project for reading unread Outlook invoice mails, saving PDF attachments, extracting invoice data, validating it, and persisting the result to a PostgreSQL database through an ODBC DSN.

## Setup

1. Create or verify the database tables. If no schema already exists, apply `database/schema.sql`.
2. Configure an ODBC DSN for the database. The default DSN name is `PostgreSQL35W`.
3. Set credentials as environment variables. Do not store passwords in `Config.xlsx`.
4. Review `Config/Config.xlsx`; it documents the required keys and default/runtime environment variable mapping.
5. Open the project in UiPath Studio 25.10.5.0 or compatible Windows profile.

## Runtime Config

The workflows read these environment variables at runtime:

- `INVOICE2DB_DSN`: ODBC DSN name. Defaults to `PostgreSQL35W`.
- `INVOICE2DB_DB_USER_ENVVAR`: Optional name of the env var containing the DB user. Defaults to `INVOICE2DB_DB_USER`.
- `INVOICE2DB_DB_PASSWORD_ENVVAR`: Optional name of the env var containing the DB password. Defaults to `INVOICE2DB_DB_PASSWORD`.
- `INVOICE2DB_MAIL_ACCOUNT`: Outlook account. Leave empty to use Outlook default behavior.
- `INVOICE2DB_MAIL_FOLDER`: Outlook folder. Defaults to `Invoices`.
- `INVOICE2DB_ATTACHMENT_FOLDER`: Saved PDF folder. Defaults to `Data/Attachments`.
- `INVOICE2DB_PROCESSED_FOLDER`: Documented target for processed mails. Defaults to `Data/Processed`.
- `INVOICE2DB_EXCEPTION_FOLDER`: Documented target for exception/manual review mails. Defaults to `Data/Exception`.
- `INVOICE2DB_REPORT_FOLDER`: Report output folder. Defaults to `Data/Reports`.
- `INVOICE2DB_VAT_MANDATORY`: Set to `true` only if VAT/MWST must be present.

## DB Assumptions

The project preserves the existing evidence of `EMAILMETADATA(senderaddress, subject, receiveddate) RETURNING mailid` and a `vendors` table. New persistence uses:

- `EMAILMETADATA`
- `vendors`
- `invoices`
- `invoice_items`
- `process_logs`

SQL uses UiPath Database activities with named parameters where supported. The schema file is PostgreSQL-oriented because the existing workflow used PostgreSQL ODBC and `RETURNING`.

## How To Run

Run `Main.xaml`. It opens the DB connection, checks availability, reads unread invoice mails, saves PDF attachments, extracts invoice fields, validates them, checks duplicates, gets or creates a vendor, inserts the invoice, writes process logs, and builds a run report.

Business exceptions such as `NO_PDF_ATTACHMENT`, `NO_INVOICE_DATA`, `VALIDATION_FAILED`, and `DUPLICATE_INVOICE` are logged and processing continues. A critical DB availability failure stops the run.

## ERP Behavior

No real ERP integration exists in this project. The ERP workflows are implemented as logical vendor lookup/create steps backed by the `vendors` table. Replace `ERP/Erp_FindVendor.xaml` and `ERP/Erp_CreateVendor.xaml` only when a real ERP connector or UI automation flow is available.

## Known Limitations

- Email move/mark-to-folder behavior is documented via configured folders, but this implementation does not move or delete original emails.
- Invoice item insertion is skipped unless a future extractor supplies item rows.
- VAT/MWST is optional unless `INVOICE2DB_VAT_MANDATORY=true`.
- PDF extraction still depends on the existing regex-based `PDF/ExtractInvoiceData.xaml`.
