# AquaCamera

Тестовое задание "Камера" для Aquafon.

Реализовал: Дерябин Георгий

AquaCamera — Flutter-приложение для iOS, которое делает фотографии через камеру устройства и сохраняет их только во внутреннюю локальную галерею приложения.

## Возможности

- Запрос разрешения только на камеру.
- Съёмка фото через пакет `camera`.
- Сохранение файлов во внутреннюю директорию приложения.
- Хранение метаданных фотографий в локальном JSON.
- Отображение локальной галереи в виде сетки.
- Полноэкранный просмотр фото.
- Удаление фото из локального хранилища приложения.
- Экран "О приложении" с выводом содержимого `README.md`.

## Ограничения

Приложение не использует системную фотогалерею iOS:

- не открывает фотоплёнку;
- не выбирает изображения из системной галереи;
- не сохраняет снимки в системную галерею;
- не запрашивает `NSPhotoLibraryUsageDescription` и `NSPhotoLibraryAddUsageDescription`.

## Важные файлы

- `lib/main.dart` — входная точка приложения и фиксация портретной ориентации.
- `lib/app/aqua_camera_app.dart` — настройка `MaterialApp`, репозиториев и корневого BLoC.
- `lib/features/camera_gallery/bloc/` — BLoC галереи: загрузка, сохранение, удаление и ошибки.
- `lib/features/camera_gallery/data/camera_permission_repository.dart` — нативный канал для проверки разрешения камеры и открытия настроек iOS.
- `lib/features/camera_gallery/data/camera_repository.dart` — создание `CameraController` и съёмка фото.
- `lib/features/camera_gallery/data/local_media_storage.dart` — директории приложения, JSON-метаданные и файловые операции.
- `lib/features/camera_gallery/data/local_gallery_repository.dart` — сохранение снимка, rollback при ошибках и обновление локальной галереи.
- `lib/features/camera_gallery/data/async_mutex.dart` — последовательный доступ к JSON-метаданным.
- `lib/features/camera_gallery/presentation/camera_gallery_page.dart` — главный экран галереи и сценарий запуска камеры.
- `lib/features/camera_gallery/presentation/camera_capture_page.dart` — экран камеры.
- `lib/features/camera_gallery/presentation/photo_view_page.dart` — полноэкранный просмотр фото.
- `lib/features/about/presentation/about_app_page.dart` — экран "О приложении", который читает этот `README.md`.
- `ios/Runner/AppDelegate.swift` — нативный MethodChannel для камеры и перехода в настройки приложения.
- `ios/Runner/Info.plist` — содержит только `NSCameraUsageDescription`.

## Локальное хранилище

Фотографии сохраняются внутри контейнера приложения:

```text
ApplicationDocumentsDirectory/aqua_camera/images/
```

Метаданные сохраняются в:

```text
ApplicationDocumentsDirectory/aqua_camera/gallery.json
```

В JSON хранится только имя файла, а абсолютный путь восстанавливается через текущую директорию приложения. Это защищает галерею от смены пути контейнера iOS после обновления или восстановления.

## Запуск проверок

```bash
cd /Users/gd/Projects/AquaCamera
flutter pub get
flutter analyze
flutter test
```

## Release-сборка и установка на iPhone

```bash
cd /Users/gd/Projects/AquaCamera
flutter build ios --release
xcrun devicectl device install app --device <device_id> build/ios/iphoneos/Runner.app
```
