import 'package:flutter/material.dart';
import '../../viewmodel/map_view_model.dart';
import 'package:intl/intl.dart';

class RouteHistoryScreen extends StatelessWidget {
  final MapViewModel viewModel;

  const RouteHistoryScreen({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Rotalar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (viewModel.historicalRoutes.isEmpty) {
            return const Center(
              child: Text('Henüz kaydedilmiş rota bulunmuyor.'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.historicalRoutes.length,
            itemBuilder: (context, index) {
              final route = viewModel.historicalRoutes[index];
              final startTime = DateTime.parse(route['start_time'] as String);
              final endTime = route['end_time'] != null 
                  ? DateTime.parse(route['end_time'] as String)
                  : null;
              final totalDistance = (route['total_distance'] as num?)?.toDouble() ?? 0.0;
              final duration = route['duration'] as int? ?? 0;
              final averageSpeed = (route['average_speed'] as num?)?.toDouble() ?? 0.0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(startTime),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (endTime != null)
                        Text('Bitiş: ${DateFormat('HH:mm').format(endTime)}'),
                      const SizedBox(height: 4),
                      Text('Mesafe: ${totalDistance.toStringAsFixed(2)} km'),
                      Text('Süre: ${Duration(seconds: duration).inMinutes} dakika'),
                      Text('Ortalama Hız: ${averageSpeed.toStringAsFixed(2)} km/s'),
                    ],
                  ),
                  onTap: () {
                    viewModel.selectRoute(route['id'] as int);
                    viewModel.showSelectedRoute();
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
