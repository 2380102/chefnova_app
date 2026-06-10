# ChefNova — Recipe Discovery & Management App

A full-stack mobile application built with **Flutter** (frontend) and **Node.js REST API** (backend) that allows users to discover, manage, and organize recipes and ingredients.

---

## Description

ChefNova is a recipe discovery and kitchen management app. Users can browse a curated list of dishes, search recipes, manage a cart for ingredient shopping, and perform full **CRUD operations** on recipes and ingredients through a connected REST API backend.

The app was built in two phases:
- **Phase 1** — UI-first: Home screen, product detail, cart, checkout, login/signup, profile
- **Phase 2** — API integration: Recipe management and ingredient management connected to a Node.js + MySQL backend via REST APIs

---

## Features

- **User Authentication** — Login & Signup screens with form validation
- **Home Screen** — Browse and search dishes with real-time filtering
- **Product Detail** — View full dish info (description, cook time, difficulty, steps)
- **Cart & Checkout** — Add dishes to cart and proceed through checkout flow
- **Profile Management** — View and edit user profile
- **Recipe Management (CRUD)** — Create, read, update, delete recipes via REST API
- **Ingredient Management (CRUD)** — Full ingredient management linked to recipes
- **REST API Integration** — Service layer using `http` package for all API calls
- **Clean Architecture** — Separate models, services, screens, and providers

---

## Technologies Used

| Layer       | Technology                        |
|-------------|-----------------------------------|
| Frontend    | Flutter (Dart)                    |
| State Mgmt  | Provider                          |
| HTTP Client | `http` package                    |
| Backend     | Node.js + Express.js              |
| Database    | MySQL                             |
| API Style   | REST API (JSON)                   |
| IDE         | Android Studio / VS Code          |

---

## Folder Structure

```
lib/
├── data/               # Static sample data
│   ├── accounts_data.dart
│   └── sample_data.dart
├── models/             # Data models
│   ├── dish_model.dart
│   ├── ingredient_model.dart
│   ├── recipe_db_model.dart
│   └── user_model.dart
├── provider/           # State management
│   └── cart_model.dart
├── screens/            # UI screens
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   ├── recipes/
│   │   ├── recipe_list_screen.dart
│   │   └── recipe_form_screen.dart
│   └── ingredients/
│       ├── ingredient_list_screen.dart
│       └── ingredient_form_screen.dart
├── services/           # API service layer
│   ├── recipe_service.dart
│   └── ingredient_service.dart
├── main.dart           # App entry point & routing
└── main_scaffold.dart  # Shared navigation scaffold
```

---

## Setup Instructions

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK
- Android Studio or VS Code
- Android Emulator or physical device
- Node.js backend running locally

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/ChefNova.git
cd ChefNova
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Backend Setup

Make sure your Node.js backend server is running on port `3000`.

The app connects to:
```
http://10.0.2.2:3000/api/   (Android Emulator → localhost)
```

API Endpoints used:
- `GET    /api/recipes`
- `POST   /api/recipes`
- `PUT    /api/recipes/:id`
- `DELETE /api/recipes/:id`
- `GET    /api/ingredients`
- `GET    /api/ingredients/recipe/:id`
- `POST   /api/ingredients`
- `PUT    /api/ingredients/:id`
- `DELETE /api/ingredients/:id`

### 4. Run the App

```bash
flutter run
```

---

## Architecture Overview

The app follows a **layered architecture**:

```
UI (Screens)
    ↓
Service Layer (RecipeService, IngredientService)
    ↓
HTTP Client (http package)
    ↓
REST API (Node.js + Express)
    ↓
Database (MySQL)
```

- **Models** handle JSON serialization/deserialization
- **Services** handle all HTTP communication (GET, POST, PUT, DELETE)
- **Screens** call services and update UI state
- **Provider** manages shared state (cart)

---

## Author

Built as a final project submission for the Mobile App Development course.

**Topic: REST APIs** — Implementation of full CRUD operations using RESTful API design principles with proper HTTP methods, JSON payloads, and status code handling.
