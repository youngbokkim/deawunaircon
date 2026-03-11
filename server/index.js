const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'estimates.json');

app.use(cors());
app.use(express.json({ limit: '1mb' }));

function readEstimates() {
  try {
    const data = fs.readFileSync(DATA_FILE, 'utf8');
    return JSON.parse(data);
  } catch (e) {
    if (e.code === 'ENOENT') return [];
    throw e;
  }
}

function writeEstimates(list) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(list, null, 2), 'utf8');
}

// GET /estimates - 목록 조회
app.get('/estimates', (req, res) => {
  try {
    const list = readEstimates();
    res.json(list);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: String(e.message) });
  }
});

// POST /estimates - 저장 (생성 또는 수정)
app.post('/estimates', (req, res) => {
  try {
    const list = readEstimates();
    const body = req.body;
    const id = body.id;
    const index = list.findIndex((e) => e.id === id);
    if (index >= 0) {
      list[index] = body;
    } else {
      list.push(body);
    }
    writeEstimates(list);
    const saved = list.find((e) => e.id === id) || body;
    res.status(200).json(saved);
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: String(e.message) });
  }
});

// DELETE /estimates/:id - 삭제
app.delete('/estimates/:id', (req, res) => {
  try {
    const list = readEstimates().filter((e) => e.id !== req.params.id);
    writeEstimates(list);
    res.status(204).send();
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: String(e.message) });
  }
});

app.listen(PORT, () => {
  console.log(`견적서 API 서버: http://localhost:${PORT}`);
  console.log('  GET  /estimates     - 목록 조회');
  console.log('  POST /estimates     - 저장');
  console.log('  DELETE /estimates/:id - 삭제');
});
