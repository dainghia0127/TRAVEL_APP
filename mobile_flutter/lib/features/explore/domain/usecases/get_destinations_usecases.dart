import 'package:mobile_flutter/features/explore/domain/entities/destination.dart';
import 'package:mobile_flutter/features/explore/domain/repositories/i_explore_repository.dart';

class GetDomesticDestinationsUseCase {
  final IExploreRepository repository;

  GetDomesticDestinationsUseCase(this.repository);

  Future<List<Destination>> call({String userCountryCode = 'VN'}) {
    return repository.getDomesticDestinations(userCountryCode: userCountryCode);
  }
}

class GetInternationalDestinationsUseCase {
  final IExploreRepository repository;

  GetInternationalDestinationsUseCase(this.repository);

  Future<List<Destination>> call({String userCountryCode = 'VN'}) {
    return repository.getInternationalDestinations(userCountryCode: userCountryCode);
  }
}

class GetDestinationDetailUseCase {
  final IExploreRepository repository;

  GetDestinationDetailUseCase(this.repository);

  Future<Destination?> call(String id) {
    return repository.getDestinationById(id);
  }
}

