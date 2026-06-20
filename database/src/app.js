// Central Application Server Engine
const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

// Enable standard middleware to parse incoming JSON payloads
app.use(express.json());

// 1. Health-Check Endpoint (Used for verification during production deployment)
app.get('/api/health', (req, res) => {
    res.status(200).json({
        status: "ACTIVE",
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
        environment: "sandbox_runtime"
    });
});

// 2. Mock Transaction Routing Endpoint (Validates system payload parsing)
app.post('/api/transactions/initialize', (req, res) => {
    const { initiator_id, counterparty_id, amount_cfa } = req.body;

    if (!initiator_id || !counterparty_id || !amount_cfa) {
        return res.status(400).json({ error: "Missing required transactional validation parameters." });
    }

    res.status(201).json({
        message: "Transaction structural validation complete.",
        transaction_token: crypto.randomUUID ? crypto.randomUUID() : "mock-token-hash",
        payload: { initiator_id, counterparty_id, amount_cfa, status: "initialized" }
    });
});

// Execute Runtime Listener
app.listen(PORT, () => {
    console.log(`[SERVER ACTIVE] Core engine executing on runtime port: ${PORT}`);
});