import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_bloc.dart';
import 'package:aqua_camera/features/camera_gallery/bloc/camera_gallery_event.dart';
import 'package:aqua_camera/features/camera_gallery/data/camera_permission_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/camera_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_gallery_repository.dart';
import 'package:aqua_camera/features/camera_gallery/data/local_media_storage.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/camera_gallery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AquaCameraApp extends StatelessWidget {
  const AquaCameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => LocalMediaStorage()),
        RepositoryProvider<CameraGalleryRepository>(
          create: (context) => LocalGalleryRepository(
            storage: context.read<LocalMediaStorage>(),
          ),
        ),
        RepositoryProvider<CameraRepository>(
          create: (_) => CameraRepositoryImpl(),
        ),
        RepositoryProvider<CameraPermissionRepository>(
          create: (_) => MethodChannelCameraPermissionRepository(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AquaCamera',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007C89)),
          scaffoldBackgroundColor: const Color(0xFFF7FAFA),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color(0xFFF7FAFA),
            foregroundColor: Color(0xFF0F1F24),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
          useMaterial3: true,
        ),
        home: BlocProvider(
          create: (context) => CameraGalleryBloc(
            galleryRepository: context.read<CameraGalleryRepository>(),
          )..add(const LoadLocalPhotosRequested()),
          child: const CameraGalleryPage(),
        ),
      ),
    );
  }
}
