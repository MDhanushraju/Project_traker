import 'package:flutter/foundation.dart';

import 'models/team_model.dart';

/// Controller for team list.
class TeamController extends ChangeNotifier {
  final List<TeamModel> _items = [];
  List<TeamModel> get items => List.unmodifiable(_items);
}
