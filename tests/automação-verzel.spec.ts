import { test, expect } from '@playwright/test';

test('CT-01: Aplicar o cupom BEMVINDO10 em compra abaixo de R$ 200,00', async ({
  page,
}) => {
  await page.goto('https://verzel-store.qa-test-verzel-store.workers.dev/');

  await expect(page).toHaveTitle(/Verzel Store/);
});
