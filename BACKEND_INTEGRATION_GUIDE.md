# Backend Integration Guide - Finwise Flutter App

## Overview
The Finwise Flutter application has been refactored to support backend integration while maintaining offline functionality. The architecture now follows a professional client-server pattern with JWT authentication.

## Changes Completed

### 1. ✅ HTTP Dependency Added
**File:** `pubspec.yaml`
- Added `http: ^1.2.1` to dependencies
- Enables HTTP communication with Django backend

### 2. ✅ Centralized API Service Created
**File:** `lib/services/api_service.dart`
**Features:**
- Singleton pattern for unified HTTP client management
- Base URL configuration (currently `http://localhost:8000/api`)
- Automatic Authorization header injection with JWT token
- Common headers management (Content-Type, Accept)
- Error handling with custom `ApiException` class
- Methods for GET, POST, PUT, DELETE requests
- Token storage and retrieval from SharedPreferences using `auth.token` key
- Refresh token support ready for implementation

**Key Methods:**
```dart
Future<void> setToken(String token)           // Store JWT
String? getToken()                             // Retrieve JWT
Future<void> clearToken()                      // Clear on logout
Future<http.Response> get(String endpoint)    // GET requests
Future<http.Response> post(url, body)         // POST requests
Future<http.Response> put(url, body)          // PUT requests
Future<http.Response> delete(String endpoint) // DELETE requests
```

### 3. ✅ AuthService Refactored for JWT
**File:** `lib/services/auth_service.dart`
**Changes:**
- Removed local password storage (passwords NO LONGER stored in SharedPreferences)
- Added `userId` field to `AuthUser` model
- Integrated JWT token management via ApiService
- Demo account credentials still supported: `1234@gmail.com` / `1234`
- Token restored on app launch from SharedPreferences
- All auth methods have TODO comments for backend API integration

**Updated AuthUser Model:**
```dart
class AuthUser {
  final String userId;      // NEW: Backend user ID
  final String email;
  final String fullName;
}
```

**Methods Ready for Backend Integration:**
- `login()` - Currently checks demo account, ready for `POST /auth/login/`
- `signUp()` - Ready for `POST /auth/signup/`
- `logout()` - Ready for `POST /auth/logout/`
- `updateProfile()` - Ready for `PUT /api/user/profile/`

### 4. ✅ TransactionService Refactored
**File:** `lib/services/transaction_service.dart`
**Architecture:**
- Integrated with ApiService for backend communication
- Maintains local cache in SharedPreferences for offline support
- All methods have fallback to local storage if backend is unavailable
- Graceful degradation: If backend fails, app uses cached data

**Methods Ready for Backend Integration:**
```
POST   /api/transactions/add/      - Create transaction
GET    /api/transactions/list/     - Fetch all transactions
PUT    /api/transactions/<id>/     - Update transaction
DELETE /api/transactions/<id>/     - Delete transaction
```

**Storage Key Pattern:** `transactions.{email}` (for local cache)

### 5. ✅ BudgetService Refactored
**File:** `lib/services/budget_service.dart`
**Architecture:**
- Same pattern as TransactionService
- Local cache with offline fallback support
- Monthly income tracking ready for backend sync

**Methods Ready for Backend Integration:**
```
POST /api/budgets/set/   - Set budget/income
GET  /api/budgets/list/  - Retrieve budget
```

**Storage Key Pattern:** `budget.{email}` (for local cache)

### 6. ✅ CategoryService Refactored
**File:** `lib/services/category_service.dart`
**Architecture:**
- Same pattern as Transaction/Budget services
- Default categories auto-initialized for new users
- Icon names stored as strings for JSON serialization

**Methods Ready for Backend Integration:**
```
GET    /api/categories/list/   - Fetch categories
POST   /api/categories/add/    - Create category
PUT    /api/categories/<id>/   - Update category
DELETE /api/categories/<id>/   - Delete category
```

## Implementation Guide for Backend Team

### Phase 1: Authentication Setup (Required First)

**Backend Endpoints Needed:**
```
POST /auth/login/
  Request:  { "email": "string", "password": "string" }
  Response: { "access": "jwt_token", "refresh": "token", "user": {...} }

POST /auth/signup/
  Request:  { "full_name": "string", "email": "string", "password": "string" }
  Response: { "access": "jwt_token", "refresh": "token", "user": {...} }

POST /auth/logout/
  Request:  {}
  Response: { "message": "Logged out" }

PUT /api/user/profile/
  Headers: Authorization: Bearer <token>
  Request:  { "full_name": "string", "email": "string", "password": "string" }
  Response: { "access": "new_jwt_token", "user": {...} }
```

### Phase 2: Uncomment Backend Integration

Once backend endpoints are ready:

1. **In `lib/services/auth_service.dart`** - Uncomment auth method implementations
2. **In `lib/services/transaction_service.dart`** - Uncomment transaction CRUD endpoints
3. **In `lib/services/budget_service.dart`** - Uncomment budget endpoints
4. **In `lib/services/category_service.dart`** - Uncomment category endpoints

All TODO comments mark exact locations and expected endpoints.

### Phase 3: Configuration

Update API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-backend-url:8000/api';
```

## Demo Account (Testing)

The app still supports the demo account:
- **Email:** `1234@gmail.com`
- **Password:** `1234`
- **Name:** `soha`
- **User ID:** `demo_user_001`

This allows testing without backend while development continues.

## JWT Token Handling

**Storage:** SharedPreferences key `auth.token`
**Used in:** All protected API requests with `Authorization: Bearer <token>` header
**Managed by:** ApiService automatically
**Storage Format:** Plain text in SharedPreferences (TODO: add encryption for production)

## Offline Support

All services maintain a local cache:
- **Transactions:** Stored under `transactions.{email}` key
- **Budget:** Stored under `budget.{email}` key
- **Categories:** Stored under `categories.{email}` key

If backend is unavailable, the app seamlessly uses cached data.

## Error Handling

ApiService throws `ApiException` for:
- 401 Unauthorized (token expired)
- 403 Forbidden (access denied)
- 404 Not Found
- 500 Server Error
- Network errors

All services catch these exceptions and fallback to local storage.

## Email vs User ID (Important!)

⚠️ **Current State:** Frontend still uses email as storage key for backward compatibility
⚠️ **Migration Needed:** Once backend provides user IDs, refactor to use:
```dart
String _storageKey(String userId) => 'transactions.$userId';
```

## Next Steps

1. ✅ **Frontend:** Ready for integration
2. ⏳ **Backend Team:** 
   - Set up authentication endpoints (JWT, refresh tokens)
   - Create transaction CRUD endpoints
   - Create budget endpoints
   - Create category endpoints
   - Ensure proper CORS headers for Flutter web/mobile
3. ✅ **Frontend:** Uncomment backend calls once endpoints are live
4. ⏳ **Testing:** Full integration testing with real backend

## API Response Format Expected

All endpoints should return JSON. Examples:

**Login Response:**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "user-uuid-1234",
    "email": "user@example.com",
    "full_name": "John Doe"
  }
}
```

**Transactions List Response:**
```json
{
  "transactions": [
    {
      "id": "tx-1234",
      "title": "Lunch",
      "category": "Food",
      "amount": -500.50,
      "dateTime": "2024-02-11T12:30:00Z",
      "description": "At restaurant"
    }
  ]
}
```

## Files Modified Summary

| File | Changes |
|------|---------|
| `pubspec.yaml` | Added http dependency |
| `lib/services/api_service.dart` | Created - HTTP client |
| `lib/services/auth_service.dart` | Refactored for JWT + backend integration |
| `lib/services/transaction_service.dart` | API integration + offline fallback |
| `lib/services/budget_service.dart` | API integration + offline fallback |
| `lib/services/category_service.dart` | API integration + offline fallback |

## Support for Backend Friend

This document can be shared directly with the Django backend team. All TODO comments in the code indicate exactly where backend API calls should be implemented. The pattern is consistent across all services, making implementation straightforward.
