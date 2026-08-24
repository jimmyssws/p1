const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8085;
const PUBLIC_DIR = __dirname;
const SOUNDS_DIR = path.join(__dirname, '..', 'sounds');

const MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.css': 'text/css',
    '.js': 'application/javascript',
    '.wav': 'audio/wav',
    '.svg': 'image/svg+xml',
    '.json': 'application/json'
};

const server = http.createServer((req, res) => {
    let reqUrl = req.url.split('?')[0];
    
    // Status API
    if (reqUrl === '/api/status') {
        res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
        res.end(JSON.stringify({
            status: 'online',
            server_ip: '100.68.81.79',
            game_port: 9999,
            map: '80x90m Buyuk Miting Meydani',
            online_npcs: 45
        }));
        return;
    }

    // Serve audio from sounds directory
    if (reqUrl.startsWith('/sounds/')) {
        const soundFile = path.join(SOUNDS_DIR, path.basename(reqUrl));
        if (fs.existsSync(soundFile)) {
            res.writeHead(200, { 'Content-Type': 'audio/wav' });
            fs.createReadStream(soundFile).pipe(res);
            return;
        }
    }

    // Serve HTML/assets
    let filePath = reqUrl === '/' ? path.join(PUBLIC_DIR, 'index.html') : path.join(PUBLIC_DIR, reqUrl);
    if (!fs.existsSync(filePath)) {
        filePath = path.join(PUBLIC_DIR, 'index.html');
    }

    const ext = path.extname(filePath);
    const mime = MIME_TYPES[ext] || 'text/plain';

    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404);
            res.end('Not Found');
            return;
        }
        res.writeHead(200, { 'Content-Type': mime });
        res.end(data);
    });
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`Game Web Portal running at http://0.0.0.0:${PORT}`);
});
