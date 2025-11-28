# Setup Supabase Integration

## ✅ Yang Sudah Dilakukan:

### 1. **Auto-Login**
- App otomatis login dengan akun admin saat dibuka
- Email: `admin@test.com`
- Password: `admin123`
- User ID: `9c9ad190-a3b5-4aff-a8c3-d6fd64a950ce`

### 2. **Task Provider - Terhubung ke Supabase**
Semua operasi CRUD sekarang menggunakan Supabase:
- ✅ **Load Tasks** - Fetch dari database berdasarkan user_id
- ✅ **Add Task** - Insert task baru ke database
- ✅ **Update Task** - Update task yang sudah ada
- ✅ **Delete Task** - Hapus task dari database
- ✅ **Mark as Completed** - Update status task menjadi completed

### 3. **File Struktur:**
```
lib/
├── config/
│   └── supabase_config.dart      # Konfigurasi URL, keys, dan credentials
├── services/
│   └── supabase_service.dart     # Helper untuk akses Supabase client
└── providers/
    └── task_provider.dart         # Provider dengan integrasi Supabase
```

## 📋 Langkah Setup Database:

1. **Buka Supabase Dashboard** → SQL Editor
2. **Copy & Paste** isi file `supabase_schema.sql`
3. **Run** SQL tersebut untuk membuat:
   - Tabel `tasks`
   - Indexes untuk performa
   - Row Level Security (RLS) policies

## 🚀 Cara Menggunakan:

### Load Tasks:
```dart
await taskProvider.loadTasks(); // Sudah otomatis di main.dart
```

### Add Task:
```dart
final task = Task(
  id: uuid.v4(),
  title: 'Belajar Flutter',
  description: 'Belajar Supabase integration',
  deadline: DateTime.now().add(Duration(days: 7)),
  createdAt: DateTime.now(),
);
await taskProvider.addTask(task);
```

### Update Task:
```dart
await taskProvider.updateTask(taskId, updatedTask);
```

### Delete Task:
```dart
await taskProvider.deleteTask(taskId);
```

### Mark as Completed:
```dart
await taskProvider.markAsCompleted(taskId);
```

## 🔒 Security:
- Row Level Security (RLS) aktif
- User hanya bisa lihat/edit task mereka sendiri
- Authenticated dengan JWT token dari Supabase

## 📝 Notes:
- Untuk production, pindahkan credentials ke environment variables
- Saat ini masih auto-login untuk development
- Nanti bisa ditambah halaman login yang proper
