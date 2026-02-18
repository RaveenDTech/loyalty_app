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
