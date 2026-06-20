-- Core Relational Database Layout Initialization
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Drop existing tables if re-running migrations
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. Master User Profiles Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_identifier TEXT UNIQUE, -- Formatted tracking index for payment queries (e.g., MoMo/OM records)
    account_status TEXT DEFAULT 'active' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Core Escrow/Transaction Ledger Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    initiator_id UUID REFERENCES users(id) ON DELETE RESTRICT NOT NULL,
    counterparty_id UUID REFERENCES users(id) ON DELETE RESTRICT NOT NULL,
    fiat_amount_cfa NUMERIC(12, 2) NOT NULL CHECK (fiat_amount_cfa > 0),
    escrow_status TEXT DEFAULT 'initialized' NOT NULL CHECK (escrow_status IN ('initialized', 'funded', 'in_transit', 'settled', 'disputed')),
    network_reference_hash TEXT UNIQUE, -- For validation against third-party processing receipts
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexing for high-velocity lookups on transactional states
CREATE INDEX idx_transactions_status ON transactions(escrow_status);
CREATE INDEX idx_users_phone ON users(phone_identifier);