# VPS Hardening (Hetzner CX33, Ubuntu 24.04, 138.199.214.5)

ทำเมื่อ 2026-09-30 ผ่าน SSH key เท่านั้น

1. `apt full-upgrade`, `unattended-upgrades` (security, เปิดใช้ผ่าน `/etc/apt/apt.conf.d/20auto-upgrades`), reboot
2. timezone `Asia/Bangkok`
3. user `tua` (กลุ่ม sudo, `/etc/sudoers.d/90-tua` = NOPASSWD เพราะไม่มี password), authorized_keys คัดลอกจาก root (700/600)
4. `/etc/ssh/sshd_config.d/00-hardening.conf`: PasswordAuthentication no, KbdInteractiveAuthentication no, PermitRootLogin no, PubkeyAuthentication yes, MaxAuthTries 3
   - `50-cloud-init.conf` ตั้ง PasswordAuthentication yes แต่ไฟล์ `00-` ถูกอ่านก่อน (ค่าแรกชนะ) — ยืนยันด้วย `sshd -T`
   - ตรวจ `sshd -t` แล้ว `systemctl reload ssh` (คง session เดิม), backup `/etc/ssh/sshd_config.bak`
   - ทดสอบ: tua เข้าได้, root และ password ถูกปฏิเสธ
5. ufw: default deny incoming / allow outgoing / allow 22/tcp
6. fail2ban `/etc/fail2ban/jail.d/sshd.local`: maxretry 5, bantime 1h, findtime 10m
7. Docker Engine + compose plugin (official apt repo), tua อยู่กลุ่ม docker, `/etc/docker/daemon.json` log json-file 10m x 3

## ข้อควรระวัง
- Docker ข้าม ufw → ทุก port ใน compose ต้อง bind `127.0.0.1:` เท่านั้น
- ตรวจ: `sudo ss -tlnp` ต้องเห็น 0.0.0.0 เฉพาะ :22
