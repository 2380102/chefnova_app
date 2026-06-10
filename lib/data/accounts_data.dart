// This file is kept for backward compatibility only.
// All authentication is now handled via AuthService (real database).
// This in-memory map is no longer used.
import '../models/user_model.dart';

@Deprecated('Use AuthService instead')
final Map<String, UserModel> registeredAccounts = {};
