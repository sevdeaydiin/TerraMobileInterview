import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/constants/app_constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  final _messageController = StreamController<dynamic>.broadcast();
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _pingInterval = Duration(seconds: 30);

  Stream<dynamic> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('İnternet bağlantısı yok');
      }

      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
      _isConnected = true;
      _reconnectAttempts = 0;

      // Mesajları dinle
      _channel?.stream.listen(
        (message) {
          _messageController.add(message);
        },
        onError: (error) {
          _handleError(error);
        },
        onDone: () {
          _handleDisconnect();
        },
        cancelOnError: false,
      );

      _startPingTimer();
    } catch (e) {
      _handleError(e);
    }
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (timer) {
      if (_isConnected) {
        sendMessage('ping');
      }
    });
  }

  Future<void> _handleDisconnect() async {
    _isConnected = false;
    _pingTimer?.cancel();

    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(_reconnectDelay * (_reconnectAttempts + 1), () {
        _reconnectAttempts++;
        connect();
      });
    }
  }

  void _handleError(dynamic error) {
    _isConnected = false;
    _messageController.addError(error);
    _handleDisconnect();
  }

  void sendMessage(dynamic message) {
    if (_isConnected && _channel != null) {
      try {
        _channel!.sink.add(message);
      } catch (e) {
        _handleError(e);
      }
    }
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
