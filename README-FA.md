# نسخه اصلاح‌شده ArchiSteamFarm برای Railway

## نصب

1. فایل‌ها را جایگزین فایل‌های Repository قبلی کن و Commit/Push بزن.
2. Volume قبلی با Mount Path زیر را نگه دار:

```text
/app/config
```

3. Variables لازم:

```env
ASF_IPC_PASSWORD=یک رمز قوی
BOT1_NAME=Account1
BOT1_LOGIN=نام کاربری Steam
BOT1_PASSWORD=رمز Steam
BOT1_ENABLED=true
REGENERATE_CONFIG=false
```

برای اکانت دوم، متغیرهای BOT2 را نیز اضافه کن.

4. Railway پس از Push باید خودکار Deploy کند. در غیر این صورت Redeploy بزن.
5. Public Domain را روی Target Port برابر 1242 تنظیم کن.

## اگر Volume شامل فایل ناقص قدیمی است

یک‌بار این Variable را بگذار:

```env
REGENERATE_CONFIG=true
```

Deploy موفق که شد، آن را دوباره به `false` برگردان و Redeploy کن.
