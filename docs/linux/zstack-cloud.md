# ZStack Cloud — Eigene IaaS-Plattform auf KVM-Basis

**ZStack** ist eine Open-Source-IaaS-Plattform (Infrastructure-as-a-Service), die auf KVM-basierten Hypervisoren aufbaut und vergleichsweise schlanke Architektur mit dem Ziel verfolgt, Self-Service-Cloud-Infrastruktur für Rechenzentren und private Clouds bereitzustellen. Das Projekt ist unter [GPL-3.0](https://github.com/ZSvirt/zsvirt/blob/main/LICENSE) lizensiert und wird auf GitHub von der ZSvirt-Community entwickelt.

> **Link:** [github.com/ZSvirt/zsvirt](https://github.com/ZSvirt/zsvirt) | [zstack-cloud.com](https://www.zstack-cloud.com/) | [zsvirt.io](https://zsvirt.io/)

---

## Was ist ZStack?

ZStack liefert die Kernelemente einer Cloud-Infrastruktur:

- **Compute:** Verwaltung von VMs über KVM/Hyperviserelemente
- **Storage:** Primary Storage (z.B. lokale KVM-Images) und Secondary Storage (ISO-Images, Template-Storage)
- **Networking:** VLAN-basierte Netzwerksegmentierung, Flat Network, Router/Security-Groups
- **Konsolen- und API-Zugriff:** Webui-Konsole, REST-API für Automatisierung
- **Multi-Tenancy:** Isolierung per Account/Tenant — relevant für Service-Provider und größere Umgebungen

Im Unterschied zu OpenStack ist der Ansatz weniger modular und schwerer — ZStack zielt auf eine monolithischere, aber damit leichter deploybare Architektur ab.

---

## Architektur (vereinfacht)

Die Plattform gliedert sich grob in:

```
┌─────────────────────────────────────────────────────┐
│                    Management Plane                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ Console  │  │   API    │  │   Management DB   │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Primary    │     │ Secondary   │     │   Hypervisor│
│  Storage    │     │   Storage   │     │    Node(s)  │
│  (KVM-Img)  │     │  (ISO/Tmpl) │     │   (KVM)     │
└─────────────┘     └─────────────┘     └─────────────┘
```

- **Hypervisor-Node:** KVM-Host mit libvirt, bridges, Storage-Pools
- **Management-Node:** ZStack-Daemon(s), Verarbeitung von API-Requests, Orchestration
- **Storage-Pools:** Primary Storage für VM-Images (kann direkt auf Hypervisor-Localdisk oder NAS laufen), Secondary Storage für ISO-Images und Templates

---

## Deployment-Ansätze

### Minimal-Deployment (Single-Node für Testing)

Für ein Test-Lab lässt sich ZStack auf einem einzelnen KVM-fähigen Host betreiben. Die Management-Komponente und mindestens ein Storage-Pool werden auf demselben System eingerichtet.

Voraussetzungen auf dem Host:

- Linux (Ubuntu/RHEL-kompatibel je nach Release-Notes)
- KVM + libvirt installiert, Bridge-Interface konfiguriert
- Grundlegende Netzwerk-Konfiguration (Flat Network oder VLAN-fähige Bridges)
- DNS-Reachability für die Verwaltungs-IP (wird vom Management-Service genutzt)

### Produktions-Deployment (Multi-Node)

Für eine produktionsreife Installation werden typischerweise getrennte Rollen verwendet:

1. **Management-Server:** ZStack Control Plane, mit hauptlastfähiger Datenbank (oft MySQL/MariaDB)
2. **Hypervisor-Hosts:** mindestens zwei für Hochverfügbarkeit von Workloads
3. **Storage-Hosts:** Separate Primary/Secondary Storage — je nach Use-Case NAS/SAN oder lokale Storage

Die genaue Konfigurierung hängt stark von der ZStack-Version und der gewählten Architektur-Dokumentation ab — Release-Notes und offizielle Docs sind primär über [zstack-cloud.com](https://www.zstack-cloud.com/) und das GitHub-Repo verfügbar.

---

## Kernfunktionen im Überblick

| Funktion | Beschreibung |
|---|---|
| **Self-Service-Konsole** | Webui für Endnutzer zur VM-Erstellung, -verwaltung, Template-Auswahl |
| **REST-API** | Automatisierung von VM-Lifecycle, Networking, Storage — relevant für CI/CD-Integration |
| **Template-Management** | Vorab konfigurierte VM-Images (Linux-Distributionen, Windows je nach Support-Status) |
| **Netzwerk-Isolation** | VLAN-basierte Tenant-Netze, Security-Groups für Firewall-Regeln auf VM-Ebene |
| **Snapshot/Backup-Funktionen** | Einzelne VM-Snapshots, ggf. Volume-basierte Snapshots (abhängig von Storage-Plug-in) |
| **Multi-Tenancy** | Account-Trennung mit Ressourcen-Quoten |

---

## Integration mit externen Systemen

ZStack bietet (je nach Version und Plugin-Support):

- **Identity-Integration:** LDAP/Active Directory für Benutzer-Auth (Plugin-basiert)
- **Storage-Plugins:** Unterstützung unterschiedlicher Storage-Backends über Plugin-Architektur
- **Netzwerk-Plugins:** Integration mit externen Switch/VLAN-Konzepten über Network-Plugins

---

## Wann macht ZStack Sinn?

### Gute Einsatzfälle

- **Private Cloud für größere Umgebungen** (Rechenzentrum, mehrere Rechenzentrums-Nodes)
- **Service-Provider**, die Self-Service-IaaS für Kunden anbieten wollen
- **Migration von VMware/Proxmox-basierten Umgebungen** — ZStack unterstützt VM-Migration-Themen (siehe GitHub-Topics: `vmware-migration`)
- **Lab/Umgebung für Cloud-Expertise** — gute Lernplattform für IaaS-Konzepte

### Weniger geeignet für

- **Single-Server-Setup** mit nur wenigen VMs — hier sind Proxmox oder einfache KVM-Manager oft pragmatischer
- **Minimal-Ressourcen-Hosts** — ZStack bringt Management-Overhead mit
- **Umgebungen ohne KVM-Unterstützung** (z.B. reine Container-Native-Strategie ohne Hypervisor-Bedarf)

---

## Vergleich: ZStack vs. Alternativen

| Kriterium | ZStack | Proxmox VE | OpenStack |
|---|---|---|---|
| **Architektur** | Monolithischer Management-Ansatz, Plugins für Erweiterung | Debian-basiert, integriertes WebUI, KVM + LXC | Sehr modular, viele Komponenten, komplex |
| **Betriebsaufwand** | Mittel (leichteres Deployment als OpenStack) | Niedrig (Single-Node einfach, Cluster erfordert Pflege) | Hoch (Multi-Service-Architektur, Wartung intensiver) |
| **Community/Umsetzung** | 1.7k GitHub-Stars, wachsende Community | Sehr starke Community, Enterprise-Erfolg | Sehr breit, aber komplex in der Praxis |
| **Lizenz** | GPL-3.0 | AGPL-3.0 (Open-Source) + Enterprise-Option | Apache-2.0 (komponentenweise) |
| **Sprache** | Java-basiert (Management-Plattform) | Perl/Python für Management, Debian-basiert | Python |

---

## Praktische Überlegungen vor dem Einsatz

1. **Hardware-Voraussetzung prüfen:** ZStack erfordert KVM-fähige Hosts mit ausreichend RAM/CPU für Management + Workloads. Bei kleinen Lab-Setups lohnt sich eine Test-Instanz vor Produktions-Einsatz.
2. **Netzwerk-Design:** VLAN-basierte Tenant-Isolation erfordert switch-seitige Konfiguration — ohne VLAN-fähige Infrastruktur bleibt die Isolation eingeschränkt.
3. **Storage-Strategie:** Primary Storage-Performance beeinflusst VM-Leistung direkt. Lokale Storage auf SSD/NVMe für Performance, Netzwerk-Storage (NFS/iSCSI) für Multi-Node-Shared-Storage.
4. **Backup-Strategie:** VM-Snapshots sind nicht ersetzt für Backups — eigenständige Backup-Lösung für Production-Deployment empfohlen.
5. **Upgrade-Pfad prüfen:** Version-Upgrades in Cloud-Infrastruktur-Plattformen können komplex sein — in Lab-Testing validieren, bevor Production-Node betroffen ist.

---

## Ressourcen & Weiterführendes

| Resource | Link |
|---|---|
| GitHub-Repo | [github.com/ZSvirt/zsvirt](https://github.com/ZSvirt/zsvirt) |
| Offizielle Website | [zstack-cloud.com](https://www.zstack-cloud.com/) |
| Community/Info | [zsvirt.io](https://zsvirt.io/) |
| Dokumentation | Über die offizielle Website und GitHub Wiki verfügbar |
| Discord-Community | [discord.com/invite/KHsw63z9xA](https://discord.com/invite/KHsw63z9xA) |

---

## Fazit

ZStack ist eine Open-Source-IaaS-Plattform, die KVM-basierte Virtualisierung in einen Self-Service-Cloud-Kontext einbettet. Für Linux-Administratoren und Infrastruktur-Teams, die über reine Single-Host-Lösungen hinauswachsen wollen, bietet sie einen interessanten Alternative-Pfad zwischen schlanker Self-Hosting-Lösung und großem OpenStack-System.

Die Entscheidung für oder gegen ZStack sollte auf Use-Case, Skalierungsanforderungen und verfügbarer Netzwerk/Storage-Infrastruktur basieren.

---

*Fragen oder Feedback? kontaktiere mich über [GitHub](https://github.com/rombey86) oder schreibe einen Kommentar unten.*
