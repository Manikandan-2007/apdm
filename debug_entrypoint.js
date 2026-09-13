const { spawn } = require('child_process');

async function debug() {
  const chromePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
  const chrome = spawn(chromePath, [
    '--headless=new',
    '--remote-debugging-port=9225',
    '--disable-gpu',
    '--no-sandbox'
  ]);

  for (let i = 0; i < 20; i++) {
    await new Promise(r => setTimeout(r, 400));
    try {
      const res = await fetch('http://localhost:9225/json');
      const targets = await res.json();
      if (targets.length > 0) {
        const page = targets[0];
        const ws = new WebSocket(page.webSocketDebuggerUrl);

        ws.addEventListener('open', () => {
          ws.send(JSON.stringify({ id: 1, method: 'Network.enable' }));
          ws.send(JSON.stringify({ id: 2, method: 'Runtime.enable' }));
          ws.send(JSON.stringify({ id: 3, method: 'Page.enable' }));
          ws.send(JSON.stringify({ id: 4, method: 'Page.navigate', params: { url: 'http://localhost:8080' } }));
        });

        ws.addEventListener('message', (e) => {
          const msg = JSON.parse(e.data);
          if (msg.method === 'Network.responseReceived') {
            const url = msg.params.response.url;
            const status = msg.params.response.status;
            const mime = msg.params.response.mimeType;
            console.log(`[NET] ${status} ${mime} ${url}`);
          } else if (msg.method === 'Network.loadingFailed') {
            console.error(`[NET FAILED] ${msg.params.errorText} ${msg.params.canceled ? '(canceled)' : ''}`);
          } else if (msg.method === 'Runtime.exceptionThrown') {
            console.error('[EXCEPTION]', msg.params.exceptionDetails);
          } else if (msg.method === 'Runtime.consoleAPICalled') {
            console.log('[CONSOLE]', msg.params.type, msg.params.args.map(a => a.value).join(' '));
          }
        });

        await new Promise(r => setTimeout(r, 10000));

        ws.send(JSON.stringify({
          id: 50,
          method: 'Runtime.evaluate',
          params: {
            expression: `({
              scripts: Array.from(document.querySelectorAll('script')).map(s => s.src),
              hasLoader: !!window._flutter?.loader,
              mainJsLoaded: typeof window.$dart_dart2js_compiled_main_is_loaded
            })`,
            returnByValue: true
          }
        }));

        ws.addEventListener('message', (e) => {
          const msg = JSON.parse(e.data);
          if (msg.id === 50) {
            console.log('\nSTATE:', JSON.stringify(msg.result.result.value, null, 2));
            chrome.kill();
            process.exit(0);
          }
        });
        return;
      }
    } catch(e) {}
  }
}

debug();
