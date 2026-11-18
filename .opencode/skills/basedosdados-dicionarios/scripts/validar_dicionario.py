#!/usr/bin/env python3
"""Valida se um arquivo baixado é realmente um dicionário/layout oficial.

Detecta páginas HTML de erro no lugar de PDF/XLS, calcula hash e permite registrar
a origem em REGISTRO.csv.

Uso:
    python .../validar_dicionario.py rag_corpus/dicionarios/RAIS_vinculos_layout2020.xls
    python .../validar_dicionario.py arquivo --url https://... --registrar
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

MAGIC = [
    (b"%PDF", "pdf"),
    (b"\xd0\xcf\x11\xe0", "xls-ole"),
    (b"PK\x03\x04", "zip-xlsx"),
    (b"\x1f\x8b", "gzip"),
]
HTML_PISTAS = (b"<!doctype html", b"<html", b"<!DOCTYPE html")


def detectar(caminho: Path) -> tuple[str, str]:
    cabecalho = caminho.read_bytes()[:4096]
    baixo = cabecalho.lower()
    for assinatura, tipo in MAGIC:
        if cabecalho.startswith(assinatura):
            return tipo, ""
    if any(pista.lower() in baixo for pista in HTML_PISTAS):
        titulo = "?"
        m = re.search(rb"(?is)<title[^>]*>(.*?)</title>", cabecalho)
        if m:
            titulo = m.group(1).decode("utf-8", "ignore").strip()[:80]
        return "html", f"arquivo é HTML (possível página de erro/redirecionamento): {titulo}"
    if b";" in cabecalho[:2000] or b"," in cabecalho[:2000]:
        return "texto-tabular", ""
    return "desconhecido", "assinatura de arquivo não reconhecida"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("arquivos", nargs="+")
    ap.add_argument("--url", default="")
    ap.add_argument("--registrar", action="store_true")
    ap.add_argument("--registro", default="rag_corpus/dicionarios/REGISTRO.csv")
    args = ap.parse_args()

    resultados = []
    falhou = False
    for nome in args.arquivos:
        caminho = Path(nome)
        if not caminho.exists():
            resultados.append({"arquivo": nome, "status": "ausente"})
            falhou = True
            continue
        tipo, problema = detectar(caminho)
        digest = hashlib.sha256(caminho.read_bytes()).hexdigest()
        valido = problema == ""
        if tipo == "html":
            valido = False
        resultados.append(
            {
                "arquivo": caminho.as_posix(),
                "tipo": tipo,
                "bytes": caminho.stat().st_size,
                "sha256": digest,
                "valido": valido,
                "problema": problema,
                "url": args.url,
            }
        )
        falhou = falhou or not valido
        print(
            f"[{'OK' if valido else 'FALHA'}] {caminho} — {tipo}, {caminho.stat().st_size} bytes"
            + (f" — {problema}" if problema else "")
        )

    if args.registrar:
        registro = Path(args.registro)
        registro.parent.mkdir(parents=True, exist_ok=True)
        novo = not registro.exists()
        with registro.open("a", encoding="utf-8", newline="") as f:
            campos = ["data_utc", "arquivo", "tipo", "bytes", "sha256", "valido", "url"]
            escritor = csv.DictWriter(f, fieldnames=campos)
            if novo:
                escritor.writeheader()
            for r in resultados:
                escritor.writerow(
                    {
                        "data_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                        "arquivo": r.get("arquivo", ""),
                        "tipo": r.get("tipo", ""),
                        "bytes": r.get("bytes", ""),
                        "sha256": r.get("sha256", ""),
                        "valido": r.get("valido", False),
                        "url": r.get("url", ""),
                    }
                )
        print(f"Registrado em {registro}")

    print(json.dumps(resultados, ensure_ascii=False, indent=2) if len(resultados) > 1 else "")
    return 1 if falhou else 0


if __name__ == "__main__":
    raise SystemExit(main())
