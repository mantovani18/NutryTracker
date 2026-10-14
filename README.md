# NutriTrack

Aplicativo mobile-first para registrar alimentação, pesagens e atividades físicas. A interface está preparada para Vercel e Supabase e funciona em modo local enquanto as credenciais não são configuradas.

## Rodar localmente

```bash
npm install
npm run dev
```

Validação de produção:

```bash
npm run build
npm run preview
```

## Supabase

1. Crie um projeto no Supabase.
2. No SQL Editor, execute `supabase/migrations/001_initial.sql`.
3. Copie `.env.example` para `.env` e preencha:

```env
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=sua-chave-publica
```

A migration cria perfis, pesagens, refeições e atividades, índices, trigger de perfil e RLS por usuário. Nunca use `service_role` no frontend.

## Deploy na Vercel

1. Suba o repositório para o GitHub.
2. Importe-o na Vercel.
3. Use `npm run build` e `dist` como output directory.
4. Cadastre `VITE_SUPABASE_URL` e `VITE_SUPABASE_PUBLISHABLE_KEY` nas variáveis da Vercel.
5. Em Supabase > Authentication > URL Configuration, adicione a URL publicada.

`vercel.json` já contém o rewrite necessário para a navegação SPA.

## Estado atual

Dashboard, diário, calendário, evolução, formulários de refeição/peso/atividade, cálculo MET e persistência local estão implementados. A camada `src/lib/supabase.ts` e a migration estão prontas; a próxima etapa é ligar autenticação e as operações CRUD dos componentes às tabelas Supabase, substituindo o armazenamento local quando as credenciais estiverem disponíveis.

O app diferencia perda observada nas pesagens de estimativas nutricionais e de atividade. Não transforma calorias em promessa de perda de gordura.

## Catálogo de alimentos

O arquivo `src/data/foodCatalog.json` contém os alimentos extraídos das páginas internas da tabela EndocrinoSaude, incluindo pães, carnes, aves, massas, leguminosas, sopas, pratos caseiros, salgados, sanduíches, chocolates, verduras, legumes, frutas, castanhas, peixes, frutos do mar, embutidos, queijos, gorduras, iogurtes, cereais, bolachas, pizzas e outras categorias da fonte.

Para atualizar os dados quando a tabela original mudar:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\scrape-food-catalog.ps1
```

Cada item preserva a categoria, a medida, o peso da porção, as calorias e a fonte. A seleção de `g`, `kg` ou `unidade` converte a quantidade usando o peso da porção importada.
