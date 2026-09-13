const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

async function capture() {
  const chromePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
  const chrome = spawn(chromePath, [
    '--headless=new',
    '--remote-debugging-port=9224',
    '--disable-gpu',
    '--no-sandbox',
    '--window-size=412,915'
  ]);

  for (let i = 0; i < 20; i++) {
    await new Promise(r => setTimeout(r, 400));
    try {
      const res = await fetch('http://localhost:9224/json');
      const targets = await res.json();
      if (targets.length > 0) {
        const page = targets.find(t => t.type === 'page') || targets[0];
        const ws = new WebSocket(page.webSocketDebuggerUrl);

        ws.addEventListener('open', () => {
          ws.send(JSON.stringify({ id: 1, method: 'Page.enable' }));
          ws.send(JSON.stringify({ id: 2, method: 'Runtime.enable' }));
          ws.send(JSON.stringify({ id: 3, method: 'Log.enable' }));
          ws.send(JSON.stringify({ id: 4, method: 'Page.navigate', params: { url: 'http://localhost:8080' } }));
        });

        ws.addEventListener('message', (e) => {
          try {
            const msg = JSON.parse(e.data);
            if (msg.method === 'Runtime.consoleAPICalled') {
              console.log('[BROWSER LOG]', msg.params.args.map(a => a.value || JSON.stringify(a)).join(' '));
            } else if (msg.method === 'Runtime.exceptionThrown') {
              console.error('[BROWSER EXCEPTION]', JSON.stringify(msg.params.exceptionDetails));
            }
          } catch(err) {}
        });

        // Wait 7 seconds for full render
        await new Promise(r => setTimeout(r, 7000));

        ws.send(JSON.stringify({ id: 99, method: 'Page.captureScreenshot', params: { format: 'png' } }));

        ws.addEventListener('message', (e) => {
          const msg = JSON.parse(e.data);
          if (msg.id === 99) {
            const base64Data = msg.result.data;
            const targetPath = "C:\\Users\\K Manikandan\\.gemini\\antigravity\\brain\\888b8819-acaf-435f-975d-adfa285793c5\\app_screenshot.png";
            fs.writeFileSync(targetPath, Buffer.from(base64Data, 'base64'));
            console.log('SCREENSHOT SAVED TO:', targetPath);
            chrome.kill();
            process.exit(0);
          }
        });
        return;
      }
    } catch (e) {}
  }
}

capture();
