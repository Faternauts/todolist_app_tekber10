# FocusBuddy

FocusBuddy adalah aplikasi to-do list berbasis Flutter yang dirancang untuk membantu pengguna tetap fokus dan terorganisir, terutama bagi individu dengan ADHD atau yang mudah terdistraksi.

Aplikasi ini mengusung pendekatan one-task focus, sehingga pengguna diarahkan untuk mengerjakan satu tugas dalam satu waktu. Setiap tugas dapat dipecah menjadi langkah-langkah kecil (task breakdown) agar lebih ringan dan mudah dimulai.

Dengan UI yang sederhana dan minim distraksi, FocusBuddy berfokus pada pengurangan cognitive load dan peningkatan produktivitas. Aplikasi ini juga memanfaatkan OpenAI-powered smart features, seperti automatic task breakdown, untuk membantu pengguna menangani tugas yang kompleks.

## Main Features

| Fitur             | Deskripsi                                                                               |
| ----------------- | --------------------------------------------------------------------------------------- |
| Add to do list    | Tambah tugas baru dengan task breakdown otomatis (langkah-langkah kecil, ADHD-friendly) |
| Lihat to do list  | Daftar tugas dengan status ongoing, missed, completed                                   |
| Delete to do list | Hapus tugas yang tidak relevan                                                          |
| Update to do list | Edit judul, deskripsi, deadline, prioritas, status                                      |
| Lihat/Edit tema   | Pilihan tema terang/gelap, ganti warna utama                                            |
| Edit profile      | Ubah nama, foto, dan data profil pengguna                                               |
| Focus Mode        | Mode fokus satu tugas, timer, dan checklist langkah-langkah                             |

---

## Folder Structure

```
├── lib/
│   ├── config/           # Supabase & env configuration
│   ├── constants/        # Global constants (theme, etc)
│   ├── models/           # Model data (Task, UserProfile)
│   ├── providers/        # State management (Provider)
│   ├── screens/          # Main views/screens
│   ├── services/         # Service/helper (Supabase, AI, etc)
│   └── widgets/          # Custom reusable widgets
├── assets/               # Image/icon assets
├── fonts/                # Custom fonts
├── images/               # Images & SVGs
├── test/                 # Unit/widget tests
├── supabase_schema.sql   # Supabase database schema
├── SUPABASE_SETUP.md     # Supabase setup guide
├── pubspec.yaml          # Dependency configuration
└── ...
```

---

## Main Screens Explanation

- **Onboarding:** Pengenalan aplikasi, fitur, dan navigasi awal.
- **Sign Up / Sign In:** Registrasi dan login akun Supabase.
- **Home:** Daftar tugas, filter status, pencarian, dan akses ke fitur utama.
- **Add/Edit Task:** Form tambah/edit tugas, breakdown langkah, deadline, prioritas.
- **Detail Task (Focus Mode):** Mode fokus satu tugas, timer, checklist langkah.
- **Profile:** Lihat dan edit profil, statistik tugas, hapus akun, logout.
- **Theme Settings:** Pilihan tema terang/gelap dan warna utama.

---

## Installation Guide

1. **Clone repository**
   ```bash
   git clone https://github.com/username/todolist_app_tekber10.git
   cd todolist_app_tekber10
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Setup file environment**
   - Salin file `.env.example` menjadi `.env` dan isi dengan OPENAI_API_KEY
4. **Setup Supabase (opsional):**
   - Buat project di [Supabase](https://supabase.com/)
   - Jalankan SQL di `supabase_schema.sql` pada Supabase SQL Editor.
   - Update URL & anon key di file `lib/config/supabase_config.dart` dan `.env`.
   - Default admin: email `admin@test.com`, password `admin123` (lihat SUPABASE_SETUP.md).

### Running on Android/iOS

```bash
flutter run
```

### Running on Web

```bash
flutter run -d chrome
```

---

## Technologies & Dependencies

- [Flutter](https://flutter.dev/) 3.4+
- [Supabase](https://supabase.com/) (auth, database)
- [Provider](https://pub.dev/packages/provider) (state management)
- [intl](https://pub.dev/packages/intl) (format tanggal)
- [shared_preferences](https://pub.dev/packages/shared_preferences) (local storage)
- [image_picker](https://pub.dev/packages/image_picker) (foto profil)
- [flutter_svg](https://pub.dev/packages/flutter_svg) (SVG asset)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (env config)

---

## Important Notes

- Untuk login admin default, gunakan email `admin@test.com` dan password `admin123` (lihat SUPABASE_SETUP.md).
- Semua data tugas tersimpan di tabel `notes` Supabase (bukan `tasks`).
- Pastikan sudah setup Supabase sesuai instruksi jika ingin backend sendiri.

---

## Author

Developed by **Kelompok 10**

---

## License

MIT License
