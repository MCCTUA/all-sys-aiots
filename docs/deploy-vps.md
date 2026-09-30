# Deploy ขึ้น VPS

## Deploy / อัปเดต
```
scripts/deploy.sh --dry-run   # ดูรายการไฟล์ก่อน
scripts/deploy.sh             # rsync -> /opt/learn แล้ว docker compose up -d --build
```
- rsync ไม่ส่ง `.env`, `.git`, `node_modules`, data dir; `--delete` ไม่ลบ `.env` บน VPS (ถูก exclude)
- image ที่ build เอง (`fastapi`) build บน VPS (Mac = arm64, VPS = amd64)
- extras (Home Assistant / NPM / cloudflared): `docker compose --profile extra up -d`

## .env บน VPS
- `/opt/learn/.env` (chmod 600) สร้างจาก `.env.example` + `openssl rand` — ห้าม cat/commit
- รหัสผ่าน Node-RED (plaintext) อยู่ที่ `/home/tua/nodered-admin-login.txt` (600)
- Grafana/InfluxDB/Postgres password อยู่ใน `.env` — อ่านเฉพาะค่าที่ต้องใช้ เช่น `grep ^GRAFANA_ADMIN_PASSWORD /opt/learn/.env`
- InfluxDB init เฉพาะ volume ว่าง: แก้ค่าใน .env ภายหลังไม่มีผล

## SSH tunnel
Mac รัน Docker Desktop ที่ bind port เดิมอยู่ จึงใช้ local port ชดเชย (+10000):

| Service | VPS (127.0.0.1) | Local (Mac) |
|---|---|---|
| Node-RED | 1880 | 11880 |
| n8n | 5678 | 15678 |
| Grafana | 3000 | 13000 |
| InfluxDB | 8086 | 18086 |
| FastAPI | 8000 | 18000 |
| MQTT / WS | 1883 / 9001 | 11883 / 19001 |

One-liner:
```
ssh -N -L 11880:127.0.0.1:1880 -L 15678:127.0.0.1:5678 -L 13000:127.0.0.1:3000 \
    -L 18086:127.0.0.1:8086 -L 18000:127.0.0.1:8000 -L 11883:127.0.0.1:1883 tua@138.199.214.5
```
`~/.ssh/config`:
```
Host learn-vps
  HostName 138.199.214.5
  User tua
  IdentityFile ~/.ssh/id_ed25519
  ServerAliveInterval 30
  LocalForward 11880 127.0.0.1:1880
  LocalForward 15678 127.0.0.1:5678
  LocalForward 13000 127.0.0.1:3000
  LocalForward 18086 127.0.0.1:8086
  LocalForward 18000 127.0.0.1:8000
  LocalForward 11883 127.0.0.1:1883
  LocalForward 19001 127.0.0.1:9001
```
ใช้: `ssh -N learn-vps` แล้วเปิด http://localhost:11880 ฯลฯ

## Rollback
- โค้ด/compose: `git checkout <commit> -- .` แล้ว `scripts/deploy.sh`
- ตรวจ: `ssh tua@… 'cd /opt/learn && docker compose ps && docker compose logs --tail=50 <svc>'`
- หยุด: `docker compose down` (ไม่ลบ volume) — **ห้าม** `down -v` ถ้าไม่ต้องการลบข้อมูล
- backup volume ก่อนเสี่ยง: `docker run --rm -v <vol>:/d -v $PWD:/b alpine tar czf /b/<vol>.tgz -C /d .`
