import { expect, test, type Page } from '@playwright/test';

// ------------------------------------------------------------------ dados (preços em centavos)
const PRODUTOS = {
  P001: { nome: 'Camiseta Essencial', preco: 5990 },
  P004: { nome: 'Boné Aba Curva', preco: 4990 },
  P005: { nome: 'Mochila Urbana 20L', preco: 10000 },
  P006: { nome: 'Kit 3 Pares de Meias', preco: 2990 },
} as const;
type Id = keyof typeof PRODUTOS;
type Itens = Partial<Record<Id, number>>;

const CUPOM = 'BEMVINDO10';

// ------------------------------------------------------------------ vitrine (HTML fornecido)
const botaoAdicionar = (page: Page, id: Id) =>
  page
    .locator(`article[aria-labelledby="nome-${id}"]`)
    .getByRole('button', { name: 'Adicionar ao carrinho' });

async function adicionar(page: Page, id: Id, vezes = 1) {
  for (let i = 0; i < vezes; i++) await botaoAdicionar(page, id).click();
}

async function irParaCarrinho(page: Page) {
  // Clica no link/botão do carrinho (sem goto, para não perder o estado do carrinho).
  await page
    .getByRole('link', { name: /^(?!.*adicionar).*carrinho/i })
    .or(page.getByRole('button', { name: /^(?!.*adicionar).*carrinho/i }))
    .first()
    .click();
}

async function abrirCarrinhoCom(page: Page, itens: Itens) {
  await page.goto('/');
  for (const [id, qtd] of Object.entries(itens) as [Id, number][])
    await adicionar(page, id, qtd);
  await irParaCarrinho(page);
}

// ------------------------------------------------------------------ carrinho (suposições)
const centavosDe = (texto: string): number | null => {
  const m = texto.match(/R\$\s*(\d{1,3}(?:\.\d{3})*|\d+),(\d{2})/);
  return m ? Number(m[1].replace(/\./g, '')) * 100 + Number(m[2]) : null;
};

/** Sobe do rótulo até o ancestral mais próximo que contém valor em R$ (ou "grátis"). */
const linha = (page: Page, rotulo: RegExp) =>
  page
    .getByText(rotulo)
    .first()
    .locator('xpath=ancestor-or-self::*')
    .filter({ hasText: /R\$|gr[aá]tis/i })
    .last();

async function aplicarCupom(page: Page, codigo: string) {
  await page
    .getByRole('textbox', { name: /cupom/i })
    .or(page.getByPlaceholder(/cupom/i))
    .first()
    .fill(codigo);
  await page
    .getByRole('button', { name: /aplicar/i })
    .first()
    .click();
}

type Resumo = {
  subtotal: number | null;
  desconto: number | null;
  frete: number | null;
  total: number | null;
};

async function lerResumo(page: Page): Promise<Resumo> {
  const valor = async (rotulo: RegExp) =>
    (await page.getByText(rotulo).count()) === 0
      ? null
      : centavosDe(await linha(page, rotulo).innerText());

  const desconto =
    (await page.getByText(/^\s*desconto/i).count()) === 0
      ? 0
      : await valor(/^\s*desconto/i);

  let frete: number | null = null;
  if ((await page.getByText(/^\s*frete/i).count()) > 0) {
    const texto = await linha(page, /^\s*frete/i).innerText();
    frete = /gr[aá]tis/i.test(texto) ? 0 : centavosDe(texto);
  }
  return {
    subtotal: await valor(/^\s*subtotal/i),
    desconto,
    frete,
    total: await valor(/^\s*total/i),
  };
}

/** Aguarda (com retry) o resumo conter os valores esperados, em centavos. */
async function esperarResumo(page: Page, esperado: Partial<Resumo>) {
  const chaves = Object.keys(esperado) as (keyof Resumo)[];
  await expect
    .poll(
      async () => {
        const r = await lerResumo(page);
        return Object.fromEntries(chaves.map((k) => [k, r[k]]));
      },
      { message: 'valores do resumo do carrinho', timeout: 7_000 },
    )
    .toEqual(esperado);
}

async function quantidadeNoCarrinho(page: Page, id: Id): Promise<number> {
  const texto = await page
    .locator(`output[aria-label="Quantidade de ${PRODUTOS[id].nome}"]`)
    .innerText();
  return Number(texto);
}

// ================================================================== testes
test('@CA01 cupom BEMVINDO10 aplica 10% de desconto sobre o subtotal', async ({
  page,
}) => {
  await abrirCarrinhoCom(page, { P005: 1 }); // R$ 100,00
  await aplicarCupom(page, CUPOM);
  await esperarResumo(page, {
    subtotal: 10000,
    desconto: 1000,
    frete: 1990,
    total: 10990,
  });
});

test('@CA03 cupom inexistente exibe "Cupom inválido." e não aplica desconto', async ({
  page,
}) => {
  await abrirCarrinhoCom(page, { P005: 1 }); // R$ 100,00
  await aplicarCupom(page, 'CUPOMFALSO');
  await expect(
    page.getByText('Cupom inválido.', { exact: true }),
  ).toBeVisible();
  await esperarResumo(page, { desconto: 0, frete: 1990, total: 11990 });
});

test('@CA10 permite 5 unidades do mesmo produto e bloqueia a 6ª', async ({
  page,
}) => {
  await page.goto('/');
  await adicionar(page, 'P001', 5);
  await botaoAdicionar(page, 'P001').click({ force: true });
  await expect(page.locator('#aviso-P001')).toContainText('5');
  await irParaCarrinho(page);
  expect(await quantidadeNoCarrinho(page, 'P001')).toBe(5);
});
