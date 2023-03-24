'use strict';
const express = require('express')

const os = require('os')
const PORT = process.env.PORT || 8080
const hostname = os.hostname()

const app = express();
app.get('/', async (req, res) => res.json({ hostname }))
app.get('/health-check', async (req, res) => res.json({ message: 'OK' }))
app.listen(PORT, () => console.log(`Listening on ${ PORT }`))
