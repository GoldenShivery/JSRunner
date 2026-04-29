# JS Runner — Powerful JavaScript for Shortcuts

Adds a "Run JavaScript" action to the iOS Shortcuts app.
Run any JS code, call APIs with fetch(), parse JSON, and pass results back to your shortcuts.

---

## What you get in Shortcuts

### 1. Run JavaScript
Run any JavaScript code block. Pass in a value as `INPUT`, return a result with `return`.

**Example — process some text:**
```js
const words = INPUT.split(' ')
return words.reverse().join(' ')
```

**Example — call an API:**
```js
const res = fetch('https://api.coinbase.com/v2/prices/BTC-USD/spot')
const data = res.json()
return data.data.amount + ' USD'
```

**Example — manipulate JSON:**
```js
const obj = JSON.parse(INPUT)
obj.timestamp = new Date().toISOString()
return JSON.stringify(obj, null, 2)
```

### 2. Evaluate JS Expression
Quick one-liner evaluation.
- `Math.round(3.7)` → `4`
- `new Date().toISOString()` → current date/time
- `'hello world'.toUpperCase()` → `HELLO WORLD`

### 3. Fetch URL with JavaScript
Fetch a URL and process the response with JS. Great for APIs.

---

## How to install (Windows guide)

### Step 1 — Put this code on GitHub

1. Go to **github.com** and create a free account
2. Click **New repository** → name it `JSRunner` → set to Public → click Create
3. Click **uploading an existing file**
4. Drag and drop ALL the files from this folder into the GitHub upload page
5. Make sure to upload the folders too (JSRunner folder, .github folder)
6. Click **Commit changes**

### Step 2 — Let GitHub build your IPA (free!)

1. In your repo, click the **Actions** tab
2. You should see a workflow running called **Build IPA**
3. Wait ~5 minutes for it to finish (green checkmark = done)
4. Click on the finished workflow → scroll down → download **JSRunner-IPA**
5. Unzip it — you now have `JSRunner.ipa`

### Step 3 — Install on your iPhone with Sideloadly (Windows)

1. Download **Sideloadly** from sideloadly.io (free, Windows)
2. Install it and open it
3. Plug your iPhone into your PC with a USB cable
4. Drag `JSRunner.ipa` into Sideloadly
5. Enter your **Apple ID** (free account is fine)
6. Click **Start**
7. On your iPhone: go to **Settings → VPN & Device Management**
   → tap your Apple ID → tap **Trust**
8. Open the **JSRunner** app once to activate it

### Step 4 — Use it in Shortcuts!

1. Open the **Shortcuts** app
2. Create a new shortcut
3. Search for **"Run JavaScript"** or **"JS Runner"**
4. The actions will appear — drag them in!

---

## Re-signing (every 7 days with free Apple ID)

Free Apple accounts expire app installs after 7 days. To refresh:
1. Just plug your phone back into Sideloadly
2. Click Start again with the same IPA
3. Done — another 7 days

**To avoid this:** Install via **TrollStore** if your iPhone is on iOS 14–16.6.1.
Check compatibility at: https://ios.cfw.guide/installing-trollstore/

---

## Supported JavaScript features

- ✅ All standard JS (ES2020+)
- ✅ `fetch(url, options)` — HTTP requests (GET, POST, headers, body)
- ✅ `JSON.parse()` / `JSON.stringify()`
- ✅ `console.log()` — output appears after result
- ✅ `btoa()` / `atob()` — base64 encode/decode
- ✅ `Math`, `Date`, `Array`, `Object`, `String`, `RegExp`
- ✅ `INPUT` variable — value passed in from Shortcuts
- ✅ `return` — sends value back to Shortcuts
- ❌ `setTimeout` / `setInterval` (not supported)
- ❌ DOM APIs (no browser, this is pure JS)
