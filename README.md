# Bachelor-PoC: Azure Modulkonzept mit Terraform

Terraform-Modulkonzept für ein Multi-Region-Setup in Azure (Resource Groups, Netzwerk, VPN-Gateway, Storage/Azure Files mit Private Endpoint, VM). Jede Tochtergesellschaft/Region ist eine eigene Umgebung unter `environments/`, die dieselben Module aus `modules/` mit eigenen Werten aufruft. `environments/north-america/` ist vollständig durchgetestet, `environments/india/` zeigt dieselbe Struktur für eine zweite Region (VPN-Gateway/VM dort bewusst auskommentiert, siehe unten).

Diese README sowie ein Teil der Fehlersuche beim Debugging entstanden mit Unterstützung von [Claude Code](https://claude.com/claude-code) (Anthropic).

## Vorbereitungen

- Terraform (~1.x) und Azure CLI installiert, `az login` gemacht
- `terraform.tfvars` in der jeweiligen Umgebung anlegen (siehe `terraform.tfvars.example` in `environments/north-america/`)
- Passwort für die VM als Env-Var setzen, **nicht** in eine Datei schreiben:
  ```bash
  export TF_VAR_admin_password="<sicheres Passwort>"
  ```
  Mindestens 12 Zeichen, 3 von 4 Kategorien (Groß/Klein/Ziffer/Sonderzeichen), sonst bricht `apply` ab.

## Deployment

```bash
cd environments/north-america
terraform init
terraform plan    # Kontrolle: Anzahl/Art der Ressourcen, keine ungewollten Replace-Aktionen
terraform apply
```
Resource Groups, Netzwerk und Storage sind in wenigen Minuten fertig, das VPN-Gateway allein braucht 30–45 Min. Terminal so lange offen lassen, bis „Apply complete" steht. Danach `terraform destroy`, sobald fertig getestet ist – das Gateway kostet laufend (siehe unten).

## Point-to-Site VPN – Zertifikate

Das Gateway ist auf Zertifikats-Auth konfiguriert. Zertifikate liegen in `environments/<env>/certs/` (nicht in Git, siehe `.gitignore`).

```bash
cd environments/north-america/certs
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 3650 \
  -subj "/CN=PoCRootCA" \
  -addext "basicConstraints=critical,CA:TRUE" \
  -addext "keyUsage=critical,keyCertSign,cRLSign" \
  -out rootCA.pem

openssl genrsa -out client.key 2048
openssl req -new -key client.key -subj "/CN=PoCClient" -out client.csr
openssl x509 -req -in client.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial \
  -days 365 -sha256 \
  -extfile <(printf "subjectAltName=DNS:PoCClient\nextendedKeyUsage=clientAuth\nbasicConstraints=CA:FALSE\nkeyUsage=digitalSignature,keyEncipherment\n") \
  -out client.crt

openssl x509 -in rootCA.pem -outform der | base64 | tr -d '\n' > rootCA.der.base64
```

Wichtig: auf macOS **nicht** `/usr/bin/openssl` nehmen (das ist LibreSSL und baut Zertifikate ohne die nötigen Extensions), sondern `brew install openssl@3` und den vollen Pfad nutzen. Unter Linux ist meist schon ein aktuelles OpenSSL Standard. Unter Windows über WSL, Git Bash oder mit `winget install OpenSSL` ausführen.

Mehr dazu: [Generate and export certificates for P2S – Linux/OpenSSL](https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-certificates-linux-openssl)

## VPN-Client (getestet unter macOS)

Diese Anleitung ist am Testrechner (macOS) entstanden, deshalb die folgenden Schritte macOS-spezifisch. Der Azure VPN Client unterstützt dort nur Entra-ID-Login, keine Zertifikate. Für Zertifikats-Auth braucht es einen normalen OpenVPN-Client: [TunnelBlick](https://tunnelblick.net/downloads.html), aktuelle stabile Version reicht.

Unter Windows funktioniert Zertifikats-Auth direkt mit dem Azure VPN Client oder OpenVPN Client 2.x, unter Linux mit OpenVPN oder dem Azure VPN Client (Ubuntu). Beides ist in Microsofts Doku unten mit eigenem Reiter beschrieben, das Grundprinzip (Zertifikat + Key in die Config einfügen) ist überall gleich.

```bash
az network vnet-gateway vpn-client generate -g rg-na-network -n gw-na-vpn -o tsv > url.txt
curl -o vpnclient.zip "$(cat url.txt)"
unzip vpnclient.zip
```
(Braucht ein fertig deploytes Gateway, geht erst wenn `apply` durch ist.)

`OpenVPN/vpnconfig.ovpn` öffnen, Inhalt von `client.crt` zwischen `<cert>`/`</cert>` einfügen, Inhalt von `client.key` zwischen `<key>`/`</key>`. Azure trägt hier keinen DNS-Server ein (siehe nächster Abschnitt), das per Hand nachtragen:
```
dhcp-option DNS 10.204.9.4
```
direkt unter der Zeile `dev tun`. Profil doppelklicken, in TunnelBlick importieren.

Wichtig: Azure unterstützt OpenVPN 2.6 noch nicht. Tunnelblick bringt mehrere OpenVPN-Versionen mit und lässt einen pro Profil wählen – in Tunnelblick unter *VPN Details → Konfiguration auswählen → Settings-Tab → OpenVPN-Version* auf **2.5** stellen (nicht 2.6). Falls 2.5 dort nicht auswählbar ist, alternativ in der `.ovpn`-Datei die Zeile `disable-dco` ergänzen (offizieller Workaround von Microsoft für 2.6).

Falls der Mac bereits manuell feste DNS-Server hat (System­einstellungen → Netzwerk → WLAN → Details → DNS): TunnelBlick überschreibt die aus Sicherheitsgründen nicht automatisch. Dann in *VPN Details → Konfiguration → Advanced* den Haken **„Allow changes to manually-set network settings"** setzen und neu verbinden.

Anleitung dazu direkt bei Microsoft: [P2S VPN clients – macOS OpenVPN](https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-vpn-client-certificate-openvpn-mac)

## DNS für VPN-Clients (Private Endpoint auflösen)

Die Private DNS Zone (`privatelink.file.core.windows.net`) beantwortet nur der interne Azure-DNS-Dienst `168.63.129.16`, und der ist nur aus dem VNet heraus erreichbar – ein P2S-Client bekommt ihn nicht automatisch.

`168.63.129.16` ist keine zufällige oder umgebungsspezifische Adresse, sondern eine von Microsoft fest vergebene, weltweit identische IP („WireServer") – dieselbe in jeder Region, jeder Subscription, jedem Tenant. Sie ist der Kanal, über den u.a. der VM-Agent mit der Azure-Plattform kommuniziert; DNS-Auflösung für VNets ohne eigenen DNS-Server ist nur eine von mehreren Aufgaben dieser Adresse ([Microsoft Learn: Azure IP Address 168.63.129.16](https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16)).

Deshalb übernimmt `dc-01` zusätzlich die Rolle des DNS-Servers fürs VNet:

- DNS-Serverrolle auf `dc-01` installiert, Weiterleitung an `168.63.129.16` eingerichtet (`Set-DnsServerForwarder`)
- VNet (`modules/network`, Variable `dns_servers`) zeigt auf die feste IP von `dc-01` (`local.dc_private_ip`, aktuell `10.204.9.4`)
- Diese IP wird von Azure automatisch an P2S-Clients gepusht – nur eben nicht in der OpenVPN-`.ovpn`-Datei (Azure-Lücke, siehe oben), in `azurevpnconfig.xml`/`VpnSettings.xml` im selben Paket steht sie korrekt drin

So in einer Firma: Die Domain Controller sind ohnehin DNS-Server und bekommen eine bedingte Weiterleitung für `file.core.windows.net` an den internen Azure-DNS. Für VPN-Clients ohne eigenen Domain Controller vor Ort nimmt man stattdessen einen [Azure DNS Private Resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview) (verwalteter Dienst, ca. 180 $/Monat pro Inbound-Endpoint – hier aus Kostengründen nicht umgesetzt).

Die DNS-Rolle wurde für den PoC manuell in der VM eingerichtet, nicht über Terraform (kein Custom-Script-Extension-Schritt im `virtual-machine`-Modul). Nach einem `destroy`/neuem `apply` fehlt sie wieder und müsste erneut eingerichtet werden.

## Auf die VM zugreifen

Die VM hat keine öffentliche IP, Zugriff geht nur über die stehende VPN-Verbindung (siehe oben). Verbindung zu `10.204.9.4`, Benutzer `azureadmin`, Passwort das oben gesetzte `TF_VAR_admin_password`.

RDP-Client: macOS → **Windows App** (App Store, früher „Microsoft Remote Desktop"); Windows → integriert, `mstsc` bzw. „Remotedesktopverbindung"; Linux → z.B. Remmina oder `xfreerdp`.

## Azure Files testen

Storage-Account hat `public_network_access_enabled = false` und einen Private Endpoint + Private DNS Zone – Files sind nur aus dem VNet (bzw. per VPN) erreichbar, von außen nicht.

**Portal, ohne CLI:** Storage Account → *Datenspeicher → Dateifreigaben* → Freigabe auswählen → *Verbinden* → Betriebssystem wählen, Laufwerksbuchstabe, Authentifizierung „Speicherkontoschlüssel" → *Skript anzeigen*. Das Skript direkt übernehmen:
- **Windows:** PowerShell-Skript in der VM ausführen (bindet als Laufwerk ein, z.B. `net use Z: ...`).
- **macOS:** Finder → `Cmd+K` → `smb://<storage-account>.file.core.windows.net/<share>`, Name = Storage-Account-Name, Passwort = Key.
- **Linux:** `sudo mount -t cifs //<storage-account>.file.core.windows.net/<share> /mnt/<ziel> -o username=<storage-account>,password=<key>,serverino`.

Den Key selbst gibt es unter *Sicherheit + Netzwerk → Zugriffsschlüssel*. Die Freigabe im Portal durchsuchen geht nicht, weil der Browser über den öffentlichen Endpoint zugreift.

**Per CLI**, Storage-Key ziehen (Owner-Rolle auf der Subscription reicht, kein Tenant-Admin nötig):
```bash
az storage account keys list -g rg-na-storage -n stanafiles01 --query "[0].value" -o tsv
```
RBAC-Rollen wie „Storage File Data SMB Share Contributor" kann man sich als Owner zwar selbst zuweisen, beim SMB-Mount greifen sie aber nur zusammen mit identitätsbasierter Authentifizierung (AD DS, Entra Kerberos oder Entra Domain Services). Die ist in einem Studenten-Tenant nicht möglich (Admin Consent für eine neue App-Registrierung fehlt), deshalb läuft der Mount über den Key.

In einer Firma würde man die Freigaben nicht händisch pro Nutzer verbinden, sondern per **Group Policy** (Laufwerkszuordnung über GPP „Drive Maps", gekoppelt an AD-Gruppen) automatisch ausrollen. Das manuelle Verbinden hier ersetzt diesen Schritt nur für den PoC.

## Getestet

| Test | Ergebnis |
|---|---|
| P2S-Verbindung mit Client-Zertifikat | IP aus `172.16.201.0/24` erhalten |
| VM ohne Public IP nur per VPN erreichbar (RDP) | erreichbar |
| Private DNS Zone löst im VNet auf private IP auf | bestätigt |
| DNS-Forwarder auf `dc-01` löst für VPN-Clients auf | bestätigt |
| SMB-Zugriff auf Freigaben über Private Endpoint (intern) | Dateien ablegen/lesen funktioniert |
| Zugriff von außen (kein VPN, öffentlicher Endpoint) | verweigert, trotz gültigem Key |

## Bekannte Einschränkungen (Azure for Students)

- VM-Größen sind je nach Subscription und Region unterschiedlich freigeschaltet – vor dem Deployment prüfen mit:
  ```bash
  az vm list-skus -l <region> --size <sku> --all --query "[].restrictions" -o table
  ```
- Zusätzlich gibt es eine Policy, die erlaubte Regionen für die Subscription auf eine feste Liste einschränkt (unabhängig von den SKU-Restriktionen oben). Welche Regionen erlaubt sind:
  ```bash
  az policy assignment list --disable-scope-strict-match --query "[?displayName=='Allowed resource deployment regions'].parameters.listOfAllowedLocations.value" -o tsv
  ```
  `north-america` läuft aktuell in **Spain Central** – nicht wegen der geografischen Nähe, sondern weil dort (anders als z.B. Germany West Central) die günstige B-Serie für diese Subscription nicht gesperrt ist.
- Gesamt-vCPU-Quota liegt bei 6 pro Region – für den PoC reicht das locker.
- VPN-Gateway kostet laufend (Gateway ~0,20 $/h, VM ~0,05 $/h) und braucht 30–45 Min zum Deployen – Terminal offen lassen bis „Apply complete", nicht abbrechen. Nach dem Test mit `terraform destroy` wieder abbauen.
