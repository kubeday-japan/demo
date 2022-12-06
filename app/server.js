'use strict';

//app from https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
const express = require('express');

const PORT = 8080;
const HOST = '0.0.0.0';

const app = express();

app.get('/', (req, res) => 
{
  res.send('Hello World\n');
});

app.get('/crash', (req, res) => 
{
  setTimeout(() => { throw new Error('crashed...')}, 555);
  res.send('crashing...\n');
});

app.listen(PORT, HOST, () => 
{
  console.log(`Running on http://${HOST}:${PORT}`);
});
