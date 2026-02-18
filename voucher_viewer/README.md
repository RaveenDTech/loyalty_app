# Voucher status viewer (demo)

A standalone web page for **non–app users** to view voucher status (Valid / Expired) using a URL that carries voucher data as JSON.

## How to open

- **Local:** Open `index.html` in a browser, or run a simple server, e.g.  
  `python3 -m http.server 8080` then visit `http://localhost:8080/voucher_viewer/`
- **Demo link:** On the page, use “Open with sample voucher (demo)” to see a sample Valid voucher.

## URL format (share from app)

Voucher data can be passed in the URL in two ways:

### 1. Base64-encoded JSON (`data` param)

```
https://yoursite.com/voucher_viewer/?data=<base64-encoded-json>
```

Example JSON (matches app `Voucher.toJson()`):

```json
{
  "voucherCode": "DSI-FASH-2024-001",
  "vendorName": "DSI Fashion Store",
  "amount": 5000,
  "status": "active",
  "purchasedAt": "2024-02-17T10:00:00.000Z",
  "expiresAt": "2025-02-17T10:00:00.000Z",
  "redeemedAt": null
}
```

- `status`: `"active"` | `"redeemed"` | `"expired"` → page shows **Valid** or **Expired** / **Redeemed**.
- Encode this JSON with base64 and put it in the `data` query parameter.

### 2. JSON in query string (`voucher` param)

```
https://yoursite.com/voucher_viewer/?voucher=<url-encoded-json>
```

Same JSON as above, URL-encoded and passed as the `voucher` parameter.

## Sharing from the Flutter app (demo)

When generating a share message or link:

1. Build a map from your `Voucher` (e.g. `voucher.toJson()`).
2. Encode: `base64 = base64Encode(utf8.encode(jsonEncode(map)))`.
3. Build URL: `https://your-domain.com/voucher_viewer/?data=$base64`.
4. Share that URL (e.g. with `share_plus` or in the voucher image text).

Recipients open the link in any browser and see the voucher status without the app.

## Redeem button & Google Sheet (status database)

The page can show a **Redeem** button and keep status in sync with a **Google Sheet** (Column A = Voucher code, Column B = Status). When one user redeems, the sheet is updated and everyone sees the new status when they load or refresh the page.

### 1. Sheet layout

- **Column A:** Voucher code  
- **Column B:** Status (`active`, `redeemed`, `expired`, etc.)  
- Row 1 can be a header row (e.g. "Voucher code", "Status"); data starts from row 2.

Ensure each voucher code that can be redeemed exists in the sheet (e.g. add rows when vouchers are created in your app).

### 2. Deploy the Apps Script backend

1. Open [Google Apps Script](https://script.google.com) and create a new project.
2. Paste the contents of `GoogleAppsScript_SheetBackend.js` into `Code.gs`.
3. Set `SHEET_ID` in the script to your sheet ID (from the sheet URL: `https://docs.google.com/spreadsheets/d/SHEET_ID/edit`).  
   Your sheet ID: `1xAth9uoefcjKcKZbg9M2QaoFFhCyAtkYkAd6Z1u85DI`
4. If your first row is **not** a header, set `DATA_START_ROW = 1` in the script.
5. **Deploy** the script: **Deploy** > **New deployment** > **Web app**.
   - **Execute as:** Me  
   - **Who has access:** Anyone  
6. Copy the **Web app URL** (e.g. `https://script.google.com/macros/s/AKfycbz.../exec`).

### 3. Connect the voucher viewer

In `index.html`, set `SHEET_SCRIPT_URL` to the Web app URL you copied:

```javascript
const SHEET_SCRIPT_URL = 'https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec';
```

After that:

- On load, the page fetches the current status from the sheet (by voucher code) and shows Valid / Expired / Redeemed.
- If the voucher is **Valid**, a **Redeem voucher** button is shown.
- On **Redeem**, the script updates the sheet (sets Status to `redeemed`) and the page re-renders as Redeemed.
- Anyone opening the same voucher link later will see the updated status from the sheet.
