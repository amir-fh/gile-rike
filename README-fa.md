# Marzban روی Render

دیپلوی پنل Marzban روی Render.com با یک پورت HTTP (بدون نیاز به VPS).

## معماری

```
کاربر ──HTTPS:443──▶ Render (اتمام TLS) ──HTTP──▶ nginx :10000
                                                     ├── مسیر WS ──▶ Xray VLESS+WS (127.0.0.1:8001)
                                                     └── بقیه    ──▶ پنل Marzban (127.0.0.1:8000)
```

## فایل‌ها

| فایل | کار |
|---|---|
| `Dockerfile` | ایمیج رسمی Marzban + nginx |
| `start.sh` | ساخت کانفیگ nginx از متغیرهای `$PORT` و `$WS_PATH` و اجرای Marzban |
| `nginx.conf.template` | قالب روتر مسیر (WS → Xray، بقیه → پنل) |
| `xray_config.json` | اینباند VLESS+WS روی پورت داخلی 8001 (کاربران به‌صورت خودکار از دیتابیس تزریق می‌شوند) |

## متغیرهای محیطی در Render

| متغیر | مثال | توضیح |
|---|---|---|
| `SUDO_USERNAME` | `admin` | نام کاربری مدیر کل |
| `SUDO_PASSWORD` | (رمز قوی) | رمز مدیر کل |
| `WS_PATH` | `/my-ws-123` | مسیر مخفی WebSocket (فقط حروف/عدد/خط تیره) |
| `SQLALCHEMY_DATABASE_URL` | `mysql+pymysql://user:pass@host:3306/db?ssl_verify_cert=false&ssl_verify_identity=false` | اختیاری — برای ماندگاری داده‌ها (پیش‌فرض SQLite پاک‌شدنی است) |
| `XRAY_SUBSCRIPTION_URL_PREFIX` | `https://YOUR-APP.onrender.com` | پیشوند لینک‌های سابسکریشن |

بعد از بالا آمدن سرویس، داخل پنل: **تنظیمات → هاست‌ها** برای اینباند `VLESS-WS` مقادیر زیر را ثبت کنید تا لینک‌های کانفیگ درست ساخته شوند:

- Address: `YOUR-APP.onrender.com` — Port: `443` — Security: `tls` — Path: همان مقدار `WS_PATH`

## نکته‌ها

- پلن رایگان Render بعد از ۱۵ دقیقه بی‌ترافیکی می‌خوابد؛ با سرویس keep-alive (مثل UptimeRobot) بیدار نگه دارید.
- پهنای باند پلن رایگان حدود ۱۰۰ گیگابایت در ماه است.
- ویرایش کانفیگ Xray از داخل پنل بعد از هر ری‌استارت از بین می‌رود؛ کانفیگ را فقط از طریق این فایل‌ها تغییر دهید.
