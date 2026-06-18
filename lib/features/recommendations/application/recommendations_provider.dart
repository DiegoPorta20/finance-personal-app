import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/recommendation_model.dart';
import '../data/recommendations_repository.dart';

final recommendationsProvider =
    FutureProvider<List<Recommendation>>((ref) async {
  return ref.read(recommendationsRepositoryProvider).getAll();
});
