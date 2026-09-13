const { spawn } = require('child_process');

async function run() {
  const chromePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
  const chrome = spawn(chromePath, [
    '--headless=new',
    '--remote-debugging-port=9222',
    '--disable-gpu',
    '--no-sandbox',
    'http://localhost:8080'
  ]);

  console.log('Chrome process spawned with PID:', chrome.pid);

  // Wait for remote debugging port
  let targets = null;
  for (let i = 0; i < 20; i++) {
    await new Promise(r => setTimeout(r, 500));
    try {
      const res = await fetch('http://localhost:9222/json');
      targets = await res.json();
      if (targets && targets.length > 0) break;
    } catch (e) {}
  }

  if (!targets || targets.length === 0) {
    console.error('Could not connect to Chrome DevTools port 9222');
    chrome.kill();
    process.exit(1);
  }

  const pageTarget = targets.find(t => t.type === 'page') || targets[0];
  console.log('Target found:', pageTarget.url, pageTarget.webSocketDebuggerUrl);

  const ws = new WebSocket(pageTarget.webSocketDebuggerUrl);

  ws.addEventListener('open', () => {
    console.log('WebSocket connected to DevTools');
    let id = 1;
    ws.send(JSON.stringify({ id: id++, method: 'Runtime.enable' }));
    ws.send(JSON.stringify({ id: id++, method: 'Log.enable' }));
    ws.send(JSON.stringify({ id: id++, method: 'Page.enable' }));
    ws.send(JSON.stringify({ id: id++, method: 'Page.navigate', params: { url: 'http://localhost:8080' } }));
  });

  const logs = [];
  const errors = [];

  ws.addEventListener('message', (event) => {
    try {
      const msg = JSON.parse(event.data);
      if (msg.method === 'Runtime.consoleAPICalled') {
        const text = msg.params.args.map(a => a.value || JSON.stringify(a)).join(' ');
        console.log(`[BROWSER CONSOLE ${msg.params.type}]:`, text);
        logs.push({ type: msg.params.type, text });
      } else if (msg.method === 'Runtime.exceptionThrown') {
        console.error('[BROWSER EXCEPTION]:', msg.params.exceptionDetails);
        errors.push(msg.params.exceptionDetails);
      }
    } catch (e) {}
  });

  // Wait 6 seconds for Flutter to bootstrap and render
  await new Promise(r => setTimeout(r, 6000));

  // Evaluate DOM
  const evalId = 999;
  ws.send(JSON.stringify({
    id: evalId,
    method: 'Runtime.evaluate',
    params: {
      expression: `({
        title: document.title,
        bodyHtml: document.body.innerHTML.substring(0, 500),
        fltGlassPane: !!document.querySelector('flt-glass-pane'),
        flutterView: !!document.querySelector('flutter-view'),
        canvas: document.querySelectorAll('canvas').length
      })`,
      returnByValue: true
    }
  }));

  ws.addEventListener('message', (event) => {
    try {
      const msg = JSON.parse(event.data);
      if (msg.id === evalId) {
        console.log('\n=== DOM INSPECTION RESULT ===');
        console.log(JSON.stringify(msg.params ? msg.params.result : msg.result, null, 2));
        chrome.kill();
        process.exit(0);
      }
    } catch (e) {}
  });

  setTimeout(() => {
    console.log('Inspection timed out, closing...');
    chrome.kill();
    process.exit(0);
  }, 10000);
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
