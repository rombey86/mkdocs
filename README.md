# IT-Virtuoso Knowledge Base

![Build Status](https://github.com/DEIN-USERNAME/DEIN-REPO/actions/workflows/ci.yml/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![MkDocs](https://img.shields.io/badge/built%20with-MkDocs-udp)

Der Quellcode für [it-virtuoso.de](https://it-virtuoso.de).

Diese Seite dient als meine **digitale Visitenkarte** und **technische Knowledge Base**. Hier dokumentiere ich Lösungen, Snippets und Konfigurationen aus meinem Alltag als Linux-Administrator und IT-Allrounder.

## 🛠 Tech Stack

Das Projekt folgt dem "Docs as Code" Ansatz:
* **Engine:** [MkDocs](https://www.mkdocs.org/) (Static Site Generator)
* **Theme:** [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
* **Hosting:** GitHub Pages
* **CI/CD:** GitHub Actions (Automatisches Build & Deploy bei Push)

## 📂 Struktur

```text
.
├── .github/workflows/   # CI/CD Pipeline Konfiguration
├── docs/                # Content (Markdown Dateien)
│   ├── index.md         # Startseite / Visitenkarte
│   ├── linux/           # Linux & Server Administration
│   └── container/       # Docker & Kubernetes
├── mkdocs.yml           # Hauptkonfiguration
└── requirements.txt     # Python Abhängigkeiten