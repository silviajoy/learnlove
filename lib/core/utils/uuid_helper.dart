import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String generateUuid() => _uuid.v4();
