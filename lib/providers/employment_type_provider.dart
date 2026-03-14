import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/employment_type_model.dart';
import '../services/employment_type_service.dart';

final employmentTypeServiceProvider =
    Provider<EmploymentTypeService>((_) => EmploymentTypeService());

final employmentTypesProvider =
    FutureProvider<List<EmploymentTypeModel>>((ref) {
  return ref.read(employmentTypeServiceProvider).getEmploymentTypes();
});
