#!/usr/bin/env python3
"""Baixa e valida as fontes listadas em pesquisa/00_protocolo/fontes.csv.

Colunas esperadas no CSV:
    id,titulo,url,destino,nivel,tipo,data_publicacao,observacao

`destino` é relativo à raiz do repositório (ex.: rag_corpus/oficiais/arquivo.pdf).
O download grava também um .meta.json com hash, tamanho e status, e atualiza
pesquisa/00_protocolo/fontes_status.csv.

Uso:
    python .../baixar_fontes.py --listar
    python .../baixar_fontes.py --only mte_manual_rais_2022
    python .../baixar_fontes.py --force
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/126.0 Safari/537.36"
)
MAGIC = [
    (b"%PDF", "pdf"),
    (b"\xd0\xcf\x11\xe0", "xls"),
    (b"PK\x03\x04", "zip/xlsx"),
    (b"\x1f\x8b", "gzip"),
]


def detectar(caminho: Path) -> tuple[str, str]:
    cabecalho = caminho.read_bytes()[:4096]
    for assinatura, tipo in MAGIC:
        if cabecalho.startswith(assinatura):
            return tipo, ""
    baixo = cabecalho.lower()
    if b"<html" in baixo or b"<!doctype html" in baixo:
        return "html", "recebeu HTML (página de erro, paywall ou redirecionamento)"
    return "texto", ""


def baixar(url: str, destino: Path, timeout: int = 120) -> tuple[str, str]:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=timeout) as resposta:
        dados = resposta.read()
        content_type = resposta.headers.get("Content-Type", "")
    destino.parent.mkdir(parents=True, exist_ok=True)
    destino.write_bytes(dados)
    return content_type, ""


def main() -> int:
    raiz = Path(__file__).resolve().parents[4]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--fontes", default=str(raiz / "pesquisa/00_protocolo/fontes.csv"))
    ap.add_argument("--status", default=str(raiz / "pesquisa/00_protocolo/fontes_status.csv"))
    ap.add_argument("--only", action="append", default=[])
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--listar", action="store_true")
    args = ap.parse_args()

    fontes_path = Path(args.fontes)
    if not fontes_path.exists():
        print(f"ERRO: planilha de fontes não encontrada: {fontes_path}", file=sys.stderr)
        return 2

    with fontes_path.open(encoding="utf-8", newline="") as f:
        fontes = [linha for linha in csv.DictReader(f) if linha.get("url")]

    if args.only:
        fontes = [f for f in fontes if f.get("id") in args.only]
    if args.listar:
        for f in fontes:
            print(f"{f.get('id','?'):<38} {f.get('nivel','?'):<2} {f.get('destino','')}")
        return 0

    status_linhas = []
    falhas = 0
    for fonte in fontes:
        destino = raiz / fonte["destino"]
        if destino.exists() and not args.force:
            tipo, problema = detectar(destino)
            ok = problema == ""
            print(f"[pulado] {fonte['id']} já existe ({tipo})")
            status_linhas.append(
                {
                    "id": fonte["id"],
                    "status": "existente" if ok else "invalido",
                    "tipo": tipo,
                    "bytes": destino.stat().st_size,
                    "caminho": fonte["destino"],
                    "erro": problema,
                }
            )
            continue
        if args.dry_run:
            print(f"[dry-run] {fonte['id']} -> {fonte['destino']}")
            continue
        print(f"[baixando] {fonte['id']} …", end="", flush=True)
        try:
            content_type, _ = baixar(fonte["url"], destino)
            tipo, problema = detectar(destino)
            digest = hashlib.sha256(destino.read_bytes()).hexdigest()
            meta = {
                "id": fonte["id"],
                "titulo": fonte.get("titulo", ""),
                "url": fonte["url"],
                "nivel": fonte.get("nivel", ""),
                "tipo_declarado": fonte.get("tipo", ""),
                "tipo_detectado": tipo,
                "content_type": content_type,
                "bytes": destino.stat().st_size,
                "sha256": digest,
                "baixado_em": datetime.now(timezone.utc).isoformat(timespec="seconds"),
            }
            destino.with_suffix(destino.suffix + ".meta.json").write_text(
                json.dumps(meta, ensure_ascii=False, indent=2), encoding="utf-8"
            )
            if problema:
                falhas += 1
                print(f" FALHA — {problema}")
                status_linhas.append(
                    {
                        "id": fonte["id"],
                        "status": "falha",
                        "tipo": tipo,
                        "bytes": meta["bytes"],
                        "caminho": fonte["destino"],
                        "erro": problema,
                    }
                )
            else:
                print(f" OK ({tipo}, {meta['bytes']} bytes)")
                status_linhas.append(
                    {
                        "id": fonte["id"],
                        "status": "baixado",
                        "tipo": tipo,
                        "bytes": meta["bytes"],
                        "caminho": fonte["destino"],
                        "erro": "",
                    }
                )
        except Exception as erro:  # noqa: BLE001
            falhas += 1
            print(f" ERRO — {erro}")
            status_linhas.append(
                {
                    "id": fonte["id"],
                    "status": "erro",
                    "tipo": "",
                    "bytes": "",
                    "caminho": fonte["destino"],
                    "erro": str(erro)[:300],
                }
            )

    if status_linhas:
        status_path = Path(args.status)
        status_path.parent.mkdir(parents=True, exist_ok=True)
        with status_path.open("w", encoding="utf-8", newline="") as f:
            campos = ["id", "status", "tipo", "bytes", "caminho", "erro"]
            escritor = csv.DictWriter(f, fieldnames=campos)
            escritor.writeheader()
            escritor.writerows(status_linhas)
        print(f"\nStatus: {status_path}")

    return 1 if falhas else 0


if __name__ == "__main__":
    raise SystemExit(main())
