import 'package:aqua_camera/features/camera_gallery/data/camera_repository.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/camera_failure_content.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/camera_loading_content.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/camera_preview_view.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/camera_top_bar.dart';
import 'package:aqua_camera/features/camera_gallery/presentation/widgets/capture_bar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  late final CameraRepository _cameraRepository;
  Future<void>? _initializeFuture;
  CameraController? _controller;
  String? _errorMessage;
  String _loadingMessage = 'Подготовка камеры...';
  bool _permissionDenied = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraRepository = context.read<CameraRepository>();
    _initializeFuture = _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    // Камера держит нативные ресурсы. При уходе приложения в фон освобождаем
    // контроллер, а после возврата создаём его заново.
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeFuture = _initializeCamera();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (_errorMessage != null) {
            return CameraFailureContent(
              message: _errorMessage!,
              permissionDenied: _permissionDenied,
              onRetry: _restartCamera,
              onClose: _close,
            );
          }

          final controller = _controller;
          if (snapshot.connectionState != ConnectionState.done ||
              controller == null ||
              !controller.value.isInitialized) {
            return CameraLoadingContent(message: _loadingMessage);
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreviewView(controller: controller),
              CameraTopBar(onClose: _close),
              CaptureBar(isCapturing: _isCapturing, onCapture: _capturePhoto),
            ],
          );
        },
      ),
    );
  }

  Future<void> _initializeCamera() async {
    _errorMessage = null;
    _permissionDenied = false;

    try {
      _setLoadingMessage('Запускаем камеру...');
      final cameras = await _cameraRepository.loadAvailableCameras().timeout(
        const Duration(seconds: 8),
      );
      if (cameras.isEmpty) {
        if (!mounted) {
          return;
        }

        setState(() {
          _errorMessage = 'На устройстве не найдена доступная камера.';
        });
        return;
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = await _cameraRepository.createController(
        selectedCamera,
      );

      if (!mounted) {
        await controller.dispose();
        return;
      }

      final previousController = _controller;
      setState(() {
        _controller = controller;
      });
      await previousController?.dispose();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _permissionDenied = _cameraRepository.isPermissionDenied(error);
        _errorMessage = _cameraRepository.messageForError(error);
      });
    }
  }

  void _setLoadingMessage(String message) {
    if (!mounted || _loadingMessage == message) {
      return;
    }

    setState(() {
      _loadingMessage = message;
    });
  }

  Future<void> _restartCamera() async {
    await _controller?.dispose();
    if (!mounted) {
      return;
    }

    setState(() {
      _controller = null;
      _errorMessage = null;
      _loadingMessage = 'Подготовка камеры...';
      _permissionDenied = false;
      _initializeFuture = _initializeCamera();
    });
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final file = await _cameraRepository.takePicture(controller);
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(CameraCaptureSuccess(file));
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _permissionDenied = _cameraRepository.isPermissionDenied(error);
        _errorMessage = _cameraRepository.messageForError(error);
        _isCapturing = false;
      });
    }
  }

  void _close() {
    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      Navigator.of(context).pop(
        CameraCaptureFailure(errorMessage, permissionDenied: _permissionDenied),
      );
      return;
    }

    Navigator.of(context).pop(const CameraCaptureCancelled());
  }
}
