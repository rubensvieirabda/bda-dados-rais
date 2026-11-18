# Referências para a página de vendas e para o desenho do curso

Documento de trabalho. Serve para duas coisas: registrar **de onde veio cada decisão**
da página `docs/index.html` e listar **o que ainda falta decidir** antes de publicar o curso.

Atualizado em 17/11/2026. Todos os links abaixo foram testados (HTTP 200) nesta data.

---

## 1. Referência-âncora: a página que você mandou

**BR-Dados — Análise de Dados Públicos Brasileiros com R**
<https://rochaviannafj.kpages.online/pagina-de-vendas-4406c28a-e901-4afd-9df1-4a248b6de9c7>

O que ela faz, em ordem:

| # | Bloco | Observação |
| --- | --- | --- |
| 1 | Herói repetido três vezes | headline + subtítulo + CTA "COMPRAR AGORA" |
| 2 | Promessa de transformação | "sair do consumo passivo de dados e passar a produzir análises replicáveis, defensáveis e úteis" |
| 3 | "Ao final você será capaz" | lista de habilidades concretas |
| 4 | "Para quem é" | qualifica e desqualifica |
| 5 | "O que vai aprender" | tópicos, não sumário de aulas |
| 6 | Diferenciais | o que separa de um tutorial de YouTube |
| 7 | Ementa por módulos | cada módulo com nome e conteúdo |
| 8 | Bônus | aumenta valor percebido |
| 9 | Garantia de 7 dias | reduz risco |
| 10 | Instrutor | autoridade |
| 11 | Oferta | R$ 597, via Hotmart |
| 12 | CTA repetido | fecha a página |

**O que vale copiar:** a lógica de transformação ("de → para") e a promessa centrada em
*defensabilidade*, que é exatamente o diferencial deste projeto.
**O que não vale copiar:** repetir o herói três vezes seguidas, porque hoje isso lê como
erro de montagem e não como reforço.

---

## 2. Referências de estrutura

### HeroSpark — anatomia em 12 blocos
<https://herospark.com/guias/pagina-de-vendas>

Guia longo, com 10 modelos anotados por tipo de produto. O modelo **"Curso online
gravado"** propõe: herói com headline de resultado · dor e agitação · mecanismo
(o método nomeado) · o que você vai aprender · prova social em vídeo · oferta com
stack e bônus · ancoragem e preço · garantia · FAQ · CTA final.

> **Decisão para a nossa página:** adotamos o "mecanismo nomeado" (as quatro etapas
> Fonte → Tratamento → Análise → Defesa) porque é o que diferencia um curso de dados
> de uma playlist de tutoriais.

### WithMe — sete seções na ordem da dúvida do comprador
<https://withme.so/blog/pt-br/como-escrever-pagina-de-vendas-curso-online>

A ideia central é útil e econômica: a página responde, nesta ordem, "o que eu vou
receber, é para mim, o que tem dentro, funciona, quanto custa, e se não for para mim,
e o que mais preciso saber". Também recomenda escrever o resultado de cada módulo, não
o tema ("Semana 1: Construa sua base" em vez de "Semana 1: Introdução").

> **Decisão:** cada módulo da nossa página tem um `Entregável:` declarado, justamente
> para não virar sumário.

### Cursio — oito seções e três erros que matam a conversão
<https://cursio.app/blog/pagina-de-ventas-curso-online-guia-completa>

Os três erros listados: começar pelo currículo em vez do resultado; prova social sem
nome, foto e resultado específico; CTA vago ("Saiba mais", "Ver curso").

> **Decisão:** o CTA é sempre a mesma ação ("Quero entrar na turma"), e não usamos
> prova social inventada — usamos placeholders explícitos até existir depoimento real.

### Hotmart — checklist de página de vendas
<https://hotmart.com/pt-br/blog/como-vender-cursos-online>

Lista os elementos esperados: headline, para quem é, o que o aluno vai aprender,
instrutor, depoimentos, preço e condições, FAQ e CTA. Serve como conferência de
completude, não como modelo de copy.

> **Decisão:** cobre todos os itens da lista, exceto depoimentos — que dependem de
> alunos reais.

---

## 3. Referências de copy

### Profa. Renata Correa — AIDA aplicado a curso online
<https://profarenatacorrea.com.br/copy-de-vendas-para-curso-online/>

Estrutura Atenção → Interesse → Desejo → Ação, com fórmulas de headline (lista,
público-alvo, pergunta provocativa, promessa direta) e o papel dos bullets.

> **Decisão:** o herói usa a fórmula de **promessa direta com quebra de objeção** —
> "Você sabe achar o dado. Falta sustentar a conclusão." — porque o público já tem
> acesso ao dado; o gargalo é o método.

### Vonza — cinco layouts de página de curso
<https://vonza.com/blog/online-course-sales-page-examples>

Compara layouts (Standard, Original, Cinematic, Bento, Spotlight) e para quem cada um
serve. Útil quando você quiser trocar a diagramação sem reescrever o texto.

---

## 4. Referências de produto (como cursos de dados se apresentam)

| Referência | O que observar |
| --- | --- |
| **RD Station University — Análise de Dados** <https://university.rdstation.com/course/curso-analise-dados> | FAQ respondendo certificado, carga horária e pré-requisito; "pra quem é" curto e direto |
| **Alura — Inteligência comercial** <https://www.alura.com.br/conteudo/inteligencia-comercial-analise-dados-decisoes-assertivas> | página de curso como aula aberta: o conteúdo vende por si |
| **Xperiun — Vendas com Power BI** <https://xperiun.com/ed/areas/vendas> | foco em "business case" e entregável de portfólio, não em ferramenta |

> **Decisão:** a nossa página vende **entregável** (painel, matriz de eventos, fichas
> de defesa), não "aulas sobre RAIS". É o mesmo movimento do Xperiun.

---

## 5. Matriz: seção da página → por que ela existe

| Seção em `index.html` | Referência que sustenta | Observação |
| --- | --- | --- |
| Herói + CTA | HeroSpark, Renata (AIDA) | headline de resultado, não de produto |
| Faixa de fontes | — | prova de especificidade: mostra que o curso é sobre dado real |
| Dor (3 cartões) | HeroSpark ("dor e agitação") | três erros concretos, não "falta de tempo" |
| Método (4 etapas) | HeroSpark ("mecanismo nomeado") | diferencial do curso |
| O que você vai aprender | KPages, Hotmart | habilidades verificáveis |
| Módulos (5 blocos) | WithMe ("resultado por módulo") | cada módulo com entregável |
| Projeto final | Xperiun (portfólio) | o que a pessoa leva embora |
| Para quem é / não é | KPages, WithMe, Cursio | desqualificar reduz reembolso |
| Instrutor | KPages, Hotmart | autoridade — **placeholder** |
| Oferta | KPages, Hotmart | stack + preço + condições — **placeholder** |
| Garantia 7 dias | KPages, Cursio | CDC, art. 49 |
| FAQ | RD Station, Cursio | objeções reais |
| CTA final | todos | repetição no fim, uma vez só |

---

## 6. O que ainda falta decidir (bloqueia a publicação)

Nenhum destes itens pode ser inventado. Enquanto não houver resposta, o campo fica
como `[preencher]` na página.

**Produto**
- [ ] Formato: gravado, ao vivo ou híbrido? Quantos encontros ao vivo?
- [ ] Carga horária e número de módulos/aulas.
- [ ] Duração do acesso (vitalício, 1 ano, 2 anos).
- [ ] Existe certificado? Com que carga horária e critério?
- [ ] Qual é o pré-requisito real de R/Python? Haverá nivelamento?
- [ ] Plataforma de hospedagem (Hotmart, Kiwify, HeroSpark, Teachable, própria).

**Preço e oferta**
- [ ] Preço à vista e parcelado; existe âncora (valor cheio)?
- [ ] Bônus reais — se não houver, apagar a seção.
- [ ] Política de reembolso além dos 7 dias legais.
- [ ] Data de abertura, fechamento e tamanho da turma.

**Autoridade**
- [ ] Nome, formação, instituição e tempo de experiência.
- [ ] 2 a 3 fatos verificáveis (publicação, projeto, cargo, dado que você produziu).
- [ ] Foto profissional e links (LinkedIn, GitHub, Lattes).

**Prova social**
- [ ] Depoimentos reais de alunos, com nome e autorização de uso.
- [ ] Se for a primeira turma: substituir por prova de método (o repositório público,
      a análise que você já produziu), nunca por depoimento fictício.

**Operação**
- [ ] Domínio e hospedagem da página.
- [ ] Ferramenta de analytics e evento de conversão.
- [ ] E-mail de suporte e prazo de resposta.
- [ ] Termos de uso e política de privacidade (LGPD).
- [ ] CNPJ ou dados do fornecedor no rodapé.

---

## 7. Conformidade mínima

- **Direito de arrependimento:** 7 dias a partir da compra, previsto no art. 49 do
  Código de Defesa do Consumidor. A página já declara isso; a plataforma precisa
  honrar sem atrito.
- **Publicidade:** nenhuma promessa de renda, emprego ou aprovação. Nenhum número de
  aluno, nota ou avaliação sem comprovação.
- **LGPD:** se a página coletar e-mail ou telefone, precisa de base legal, finalidade
  declarada e caminho para exclusão.
- **Direitos de terceiros:** os dados da RAIS, IBGE, MDIC e BCB são públicos, mas as
  marcas e logotipos não podem ser usados como endosso.
- **Licenças do material:** código MIT, conteúdo CC BY 4.0 (já aplicado no repositório).
  Se o curso for pago, decida se o material didático também será CC BY ou se terá
  licença própria — o README público promete CC BY para o texto.

---

## 8. Como editar a página

Arquivo único: `docs/index.html`. Sem build, sem dependência externa. É servido pelo
GitHub Pages a partir do diretório `docs/` no branch `main`.

1. **Campos variáveis:** procure por `class="fill"`. Cada um é um trecho que precisa
   ser preenchido ou removido. Para achar todos:

   ```powershell
   Select-String -Path docs/index.html -Pattern 'class="fill"' |
     ForEach-Object { "$($_.LineNumber): $($_.Line.Trim())" }
   ```

2. **Aviso de rascunho:** apague o bloco `<div class="draft-banner">` e a meta
   `robots` com `noindex, nofollow` no `<head>`.

3. **Depoimentos:** não existe seção de depoimento porque ainda não há depoimento real.
   Quando houver, o lugar natural é entre "Projeto final" e "Para quem é".

4. **Preço:** mantenha idêntico ao da plataforma de pagamento. Divergência entre página
   e checkout é reclamação garantida.

5. **Teste de leitura:** abra no celular. Se o botão de compra não estiver visível sem
   rolar em pelo menos uma dobra, o herói está longo demais.

---

## 9. Próximos passos sugeridos

1. Fechar as decisões da seção 6 — sem elas a página não publica.
2. Escrever a bio do instrutor em fatos, não em adjetivos.
3. Rodar a página com 3 a 5 pessoas do público-alvo e pedir uma coisa só: "depois de
   ler, o que você acha que vai conseguir fazer?". Se a resposta não bater com a
   promessa, o problema é o texto, não o design.
4. Só então ligar tráfego. Página sem tráfego qualificado não testa copy.
