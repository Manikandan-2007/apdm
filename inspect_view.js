const { spawn } = require('child_process');

async function test() {
  const chromePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
  const chrome = spawn(chromePath, [
    '--headless=new',
    '--remote-debugging-port=9223',
    '--disable-gpu',
    '--no-sandbox',
    'http://localhost:8080'
  ]);

  for (let i = 0; i < 20; i++) {
    await new Promise(r => setTimeout(r, 400));
    try {
      const res = await fetch('http://localhost:9223/json');
      const targets = await res.json();
      if (targets.length > 0) {
        const page = targets.find(t => t.type === 'page') || targets[0];
        const ws = new WebSocket(page.webSocketDebuggerUrl);
        ws.addEventListener('open', () => {
          ws.send(JSON.stringify({ id: 1, method: 'Runtime.enable' }));
          ws.send(JSON.stringify({ id: 2, method: 'Page.enable' }));
          ws.send(JSON.stringify({ id: 3, method: 'Page.navigate', params: { url: 'http://localhost:8080' } }));
        });

        ws.addEventListener('message', async (e) => {
          const msg = JSON.parse(e.data);
          if (msg.method === 'Runtime.consoleAPICalled') {
            console.log('[LOG]', msg.params.args.map(a => a.value || JSON.stringify(a)).join(' '));
          }
        });

        // Wait 7s
        await new Promise(r => setTimeout(r, 7000));

        ws.send(JSON.stringify({
          id: 100,
          method: 'Runtime.evaluate',
          params: {
            expression: `({
              viewRect: document.querySelector('flutter-view')?.getBoundingClientRect(),
              canvasRect: document.querySelector('flt-glass-pane')?.shadowRoot?.querySelector('canvas')?.getBoundingClientRect(),
              bodyDisplay: window.getComputedStyle(document.body).display
            })`,
            returnByValue: true
          }
        }));

        ws.addEventListener('message', (e) => {
          const msg = JSON.parse(e.data);
          if (msg.id === 100) {
            console.log('VIEW INSPECTION:', JSON.stringify(msg.result?.result?.value || msg.result, null, 2));
            chrome.kill();
            process.exit(0);
          }
        });
        return;
      }
    } catch (err) {}
  }
}

test();
