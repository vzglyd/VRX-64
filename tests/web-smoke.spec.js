const { test, expect } = require('@playwright/test');

test('web smoke: loading slide loads and runs 5 frames', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));

  const baseUrl = process.env.VRX64_SMOKE_BASE_URL ?? 'http://localhost:8080';
  await page.goto(`${baseUrl}/VRX-64-web/web-preview/smoke-test.html`);
  await page.waitForFunction(() => window.__vrx64_smoke !== undefined, { timeout: 10_000 });

  const result = await page.evaluate(() => window.__vrx64_smoke);
  expect(errors, 'unexpected JS page errors').toHaveLength(0);
  expect(result.ok, result.error ?? 'no error detail').toBe(true);
});
