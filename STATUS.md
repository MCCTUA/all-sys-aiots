# STATUS — 2026-09-30

## เสร็จแล้ว
- STEP 1: VPS hardening ครบ (ดู docs/hardening.md), reboot ผ่าน
- STEP 2: compose ใช้ได้ทั้ง Mac/VPS — port 127.0.0.1, secret จาก .env, pin version, healthcheck, postgres สำหรับ n8n, fastapi starter, HA/NPM/cloudflared อยู่ profile `extra`
- STEP 3: deploy ขึ้น /opt/learn, 7 service healthy, ไม่มี port 0.0.0.0 นอกจาก :22, reboot แล้วกลับมาเอง
- Mac: prune build cache + image (volume ไม่แตะ)

## Image ที่ pin
mosquitto 2.0.22 · influxdb 2.7.12 · node-red 5.0.7 · postgres 16.15-alpine · n8n 2.42.1 · grafana 13.2.3 · fastapi (build เอง, python 3.12.14, fastapi 0.142.2) · extra: HA 2026.9.4, NPM 2.16.0, cloudflared 2026.9.3

## ค้าง / ต้องตัดสินใจ
- **hash bcrypt ตัวอย่างอยู่ใน git history (commit ecc2c1b) และ repo เป็น PUBLIC** — ไม่ตรงกับ .env ปัจจุบันของ Mac หรือ VPS; ยังไม่ rewrite history (รอตัดสินใจ)
- TODO: ตั้ง password + ACL ให้ Mosquitto (ปิด `allow_anonymous`) ก่อนเปิดให้ ESP32 ต่อจากภายนอก
- cloudflared บน VPS: ต้องสร้าง tunnel ใหม่ (ห้ามใช้ token เดียวกับ Mac)
- n8n เดิมบน Mac ใช้ SQLite (ข้อมูลใน volume n8n_data ไม่ถูกย้ายไป Postgres) — flows ใน `flows/` import ใหม่ได้
- ตั้ง datasource InfluxDB ใน Grafana เอง (ตาม README)
- ไม่มี backup อัตโนมัติของ volume

## ขั้นต่อไป
1. ตัดสินใจเรื่อง history rewrite / เปลี่ยน hash ตัวอย่าง
2. Mosquitto auth + TLS, backup cron (pg_dump, influx backup)
3. เพิ่ม fastapi endpoint จริง / เชื่อม n8n
