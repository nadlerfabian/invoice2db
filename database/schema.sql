-- Conservative PostgreSQL schema aligned with the SQL already present in the
-- UiPath workflows. Apply only when these tables do not already exist.

CREATE TABLE IF NOT EXISTS EMAILMETADATA (
    mailid SERIAL PRIMARY KEY,
    senderaddress VARCHAR(320),
    subject TEXT,
    receiveddate TIMESTAMP
);

CREATE TABLE IF NOT EXISTS vendors (
    vendorid SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    iban VARCHAR(34),
    createdat TIMESTAMP DEFAULT NOW()
);

-- Existing demo tables may already exist with only some columns. These
-- additive migrations keep rerunning this file safe without dropping data.
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS iban VARCHAR(34);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS createdat TIMESTAMP DEFAULT NOW();

CREATE TABLE IF NOT EXISTS invoices (
    invoiceid SERIAL PRIMARY KEY,
    mailid INTEGER REFERENCES EMAILMETADATA(mailid),
    vendorid INTEGER REFERENCES vendors(vendorid),
    referenceid TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    iban VARCHAR(34),
    status VARCHAR(50) NOT NULL DEFAULT 'SUCCESS',
    createdat TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS invoice_items (
    itemid SERIAL PRIMARY KEY,
    invoiceid INTEGER REFERENCES invoices(invoiceid),
    description TEXT,
    quantity NUMERIC(12, 2),
    amount NUMERIC(12, 2)
);

CREATE TABLE IF NOT EXISTS process_logs (
    logid SERIAL PRIMARY KEY,
    mailid INTEGER,
    invoiceid INTEGER,
    status VARCHAR(50) NOT NULL,
    message TEXT,
    createdat TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_vendors_name ON vendors (LOWER(name));
CREATE INDEX IF NOT EXISTS idx_vendors_iban ON vendors (iban);
CREATE INDEX IF NOT EXISTS idx_invoices_duplicate ON invoices (referenceid, vendorid, amount);
CREATE INDEX IF NOT EXISTS idx_process_logs_createdat ON process_logs (createdat);
