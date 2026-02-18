/**
 * Google Apps Script: Voucher status backend using a Google Sheet.
 *
 * SETUP:
 * 1. Open https://script.google.com and create a new project.
 * 2. Replace the SHEET_ID below with your sheet ID (from the sheet URL).
 *    Sheet URL format: https://docs.google.com/spreadsheets/d/SHEET_ID/edit
 *    Your sheet ID: 1xAth9uoefcjKcKZbg9M2QaoFFhCyAtkYkAd6Z1u85DI
 * 3. Paste this entire file into Code.gs, save.
 * 4. Deploy: Deploy > New deployment > Type: Web app.
 *    - Execute as: Me
 *    - Who has access: Anyone (so the voucher page can call it)
 * 5. Copy the Web app URL and set it in voucher_viewer/index.html as SHEET_SCRIPT_URL.
 *
 * SHEET LAYOUT:
 * - Column A: Voucher code
 * - Column B: Status (e.g. active, redeemed, expired)
 * - Row 1 can be headers (script skips row 0 when matching by code; adjust if you use headers).
 */

const SHEET_ID = '1xAth9uoefcjKcKZbg9M2QaoFFhCyAtkYkAd6Z1u85DI';
const COL_CODE = 1;   // A = Voucher code
const COL_STATUS = 2; // B = Status
const DATA_START_ROW = 2; // 2 = row 1 is header (Voucher code, Status); use 1 if no header

function doGet(e) {
  const params = e && e.parameter ? e.parameter : {};
  const action = (params.action || '').toLowerCase();
  const code = (params.code || '').trim();
  const callback = params.callback || 'callback';

  let result = { error: 'Invalid request' };

  if (!code) {
    result = { error: 'Missing voucher code' };
    return jsonp(callback, result);
  }

  try {
    const spreadsheet = SpreadsheetApp.openById(SHEET_ID);
    const sheet = spreadsheet.getSheets()[0];
    const lastRow = Math.max(sheet.getLastRow(), 1);
    const range = sheet.getRange(DATA_START_ROW, COL_CODE, lastRow, COL_STATUS);
    const values = range.getValues();

    if (action === 'status') {
      const status = getStatusForCode(values, code);
      result = { status: status };
    } else if (action === 'redeem') {
      const rowIndex = findRowIndex(values, code);
      if (rowIndex === -1) {
        // Code not in sheet: append new row so status is stored for future loads
        const nextRow = lastRow + 1;
        sheet.getRange(nextRow, COL_CODE).setValue(code);
        sheet.getRange(nextRow, COL_STATUS).setValue('redeemed');
        result = { ok: true, status: 'redeemed' };
      } else {
        const sheetRow = DATA_START_ROW + rowIndex;
        sheet.getRange(sheetRow, COL_STATUS).setValue('redeemed');
        result = { ok: true, status: 'redeemed' };
      }
    } else {
      result = { error: 'Unknown action. Use action=status or action=redeem' };
    }
  } catch (err) {
    result = { error: String(err.message || err) };
  }

  return jsonp(callback, result);
}

function getStatusForCode(values, code) {
  const row = findRowIndex(values, code);
  if (row === -1) return 'active';
  const cell = (values[row][COL_STATUS - 1] || '').toString().trim().toLowerCase();
  return cell || 'active';
}

function findRowIndex(values, code) {
  const want = (code || '').toString().trim();
  for (let i = 0; i < values.length; i++) {
    const cell = (values[i][COL_CODE - 1] || '').toString().trim();
    if (cell === want) return i;
  }
  return -1;
}

function jsonp(callback, data) {
  const body = callback + '(' + JSON.stringify(data) + ');';
  return ContentService.createTextOutput(body)
    .setMimeType(ContentService.MimeType.JAVASCRIPT);
}
