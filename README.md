# Dream Live (Weirdcore / Dreamcore hub prototype)

Birinchi shaxsdan (FPS) 3D dreamcore/liminal-space dunyo. Bu — katta o'yinning
birinchi qismi: markaziy xab (hub), undan uzoqda ko'rinadigan 4 ta lokatsiya
(plyaj, sirk, qizil shahar, korporatsiya minorasi) va boshida tushuntiruvchi
shoumen.

## Boshqaruv

- **Telefonda**: chap ekran yarmi = virtual joystik (yurish), o'ng yarmi =
  barmoq bilan surish = kamerani aylantirish, pastki o'ng tugma = sakrash.
- **Kompyuterda (Godot Editor ichida sinash uchun)**: W/A/S/D — yurish,
  sichqoncha — qarash (bosing, keyin sichqoncha "ushlanadi"), Space — sakrash.

## Tezkor tekshirish (eng oson yo'l)

1. https://godotengine.org/download dan **Godot 4.3** ni yuklab oling
   (bepul, o'rnatish shart emas, faqat ishga tushiriladigan fayl).
2. Godot'ni oching -> "Import" -> shu papkadagi `project.godot` faylini
   tanlang.
3. Yuqorida **Play** (uchburchak) tugmasini bosing — dunyo kompyuteringizda
   ochiladi, sichqoncha/klaviatura bilan yurib ko'rishingiz mumkin.

## Android APK olish

Eng qulay yo'l — shu papkadagi `codemagic.yaml` orqali Codemagic.io'da
(xuddi Elektron Hamyon loyihasidagi kabi): GitHub'ga yuklang, Codemagic'da
"Dream Live - Android" workflow'ni ishga tushiring, oxirida `build/*.apk`
Artifacts bo'limida paydo bo'ladi.

## Loyihada nima bor

- `scripts/Main.gd` — butun dunyo shu yerda kod orqali quriladi: osmon,
  tuman, yorug'lik, 4 ta uzoqdagi lokatsiya, shoumen, ekran boshqaruvlari,
  kirish dialogi.
- `scripts/Player.gd` — birinchi shaxs harakat kontrolleri.
- `scenes/Main.tscn` — start sahnasi (deyarli bo'sh, faqat skriptni yuklaydi).

## Keyingi qadamlar (kengaytirish)

Hozir 4 ta lokatsiya faqat uzoqdan ko'rinadi (landmark sifatida). Keyingi
bosqichlarda ularning har birini alohida, to'liq o'ynaladigan sahna qilib
qo'shish mumkin:
- Plyaj — ochiq maydon, quvish mexanikasi.
- Sirk — yopiq joy, jumboqlar.
- Qizil shahar + minora — parkur (sakrash, tirmashish).

Har birini alohida so'rang — bittalab, tekshirib-tekshirib qo'shamiz.
