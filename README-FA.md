# اجرای ArchiSteamFarm روی Railway

این پوشه آماده‌ی Deploy است و از ایمیج رسمی ArchiSteamFarm استفاده می‌کند.

## سریع‌ترین روش

1. فایل ZIP را Extract کن و محتویات پوشه را در یک Repository خصوصی GitHub قرار بده.
2. در Railway گزینه **New Project → Deploy from GitHub repo** را بزن و Repository را انتخاب کن.
3. در سرویس Railway وارد **Variables** شو و حداقل این متغیرها را اضافه کن:

```env
ASF_IPC_PASSWORD=یک_رمز_خیلی_قوی
BOT1_LOGIN=نام_کاربری_استیم
BOT1_PASSWORD=رمز_استیم
```

برای اکانت دوم:

```env
BOT2_LOGIN=نام_کاربری_اکانت_دوم
BOT2_PASSWORD=رمز_اکانت_دوم
```

4. در Railway یک **Volume** به همین سرویس اضافه کن و Mount Path را دقیقاً این بگذار:

```text
/app/config
```

5. در بخش **Networking** یک Public Domain بساز و Target Port را روی `1242` تنظیم کن.
6. دامنه را باز کن و با مقدار `ASF_IPC_PASSWORD` وارد ASF-ui شو.

## Steam Guard

در اولین ورود ممکن است ASF کد Steam Guard بخواهد. در ASF-ui وارد بخش Console/Commands شو و ورودی درخواست‌شده را برای Bot وارد کن. بعد از ورود موفق، Login Key داخل Volume ذخیره می‌شود و معمولاً در Restartهای بعدی دوباره رمز لازم نیست.

نمونه فرمان‌های ورودی ASF:

```text
input Account1 SteamGuard CODE
input Account1 TwoFactorAuthentication CODE
```

نام `Account1` همان `BOT1_NAME` است.

## امنیت

- Repository را Private نگه دار.
- فایل `.env` را Commit نکن.
- رمزها را فقط در Railway Variables قرار بده.
- `ASF_IPC_PASSWORD` را حداقل 20 کاراکتر انتخاب کن.
- Volume را حذف نکن؛ Login Key و تنظیمات پایدار آنجاست.
- بعد از ساخته‌شدن فایل‌ها، `REGENERATE_CONFIG=false` بماند.
- برای تغییر رمز Steam ذخیره‌شده، متغیر را عوض کن، موقتاً `REGENERATE_CONFIG=true` بگذار، Deploy کن و سپس دوباره آن را `false` کن.

## نکته درباره Playtime

ASF بازی‌ها را واقعاً نصب یا رندر نمی‌کند. کار اصلی آن مدیریت Botهای Steam و Farming کارت‌هاست. استفاده از هر قابلیت automation باید مطابق قوانین Steam و قوانین بازی مربوطه باشد.
