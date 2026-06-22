# boro. 🏘️
> Borrow. Lend. Build community.

Boro is a peer-to-peer rental marketplace where people lend and borrow everyday items within their community. Instead of buying expensive items used only occasionally, users can list their items for rent and earn income — while borrowers get affordable access to what they need.

---

## 🏗️ Architecture

```
Flutter App (Dart)
      ↕ HTTP / WebSocket
Django REST Framework (Python)
      ↕ ORM
PostgreSQL + Redis
```

---

## 🧬 OOP Design

| Class | Type | Demonstrates |
|-------|------|-------------|
| `User` | AbstractBaseUser | Abstraction, Encapsulation |
| `LenderProfile` / `BorrowerProfile` | Composition | Polymorphism |
| `RentalTransaction` | Abstract Model | Inheritance |
| `RentalOffer` | Inherits RentalTransaction | Polymorphism |
| `RentalAgreement` | Inherits RentalTransaction | Polymorphism |
| `ReputationScore` | Encapsulated engine | Encapsulation |
| `Item` | Encapsulated state machine | Encapsulation |

---

## 📁 Project Structure

```
boro/
├── backend/                   # Django REST Framework
│   ├── config/                # Settings, URLs, ASGI
│   ├── apps/
│   │   ├── users/             # User, LenderProfile, BorrowerProfile
│   │   ├── items/             # Item, ItemImage, Category
│   │   ├── rentals/           # RentalOffer, RentalAgreement
│   │   ├── reviews/           # Review, ReputationScore
│   │   └── notifications/     # WebSocket notifications
│   ├── requirements.txt
│   └── Dockerfile
├── boro_app/                  # Flutter frontend
│   └── lib/
│       ├── models/            # Dart data models
│       ├── screens/           # 8 UI screens
│       ├── widgets/           # Reusable components
│       ├── services/          # API service layer
│       ├── providers/         # State management
│       └── utils/             # Constants, theme
└── docker-compose.yml
```

---

## 🚀 Getting Started

### Backend

```bash
cd backend
cp .env.example .env
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Using Docker (recommended)

```bash
docker-compose up --build
```

### Flutter App

```bash
cd boro_app
flutter pub get
flutter run
```

> Update `AppConstants.baseUrl` in `lib/utils/constants.dart` to point to your backend.

---

## 📱 Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Login | `/login` | Email + password auth with JWT |
| Register | `/register` | Create new account |
| Home Feed | `/home` | Browse items with search & filters |
| Item Detail | `/item/:id` | Full item info + make offer |
| Negotiation | `/negotiation/:offerId` | Counter-offer chat flow |
| My Rentals | `/rentals` | Borrowing, lending, history tabs |
| Post Item | `/post-item` | List a new item for rent |
| Profile | `/profile` | Stats, reputation, settings |
| Reviews | `/reviews/:userId` | Rating breakdown + comments |

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register/` | Register new user |
| POST | `/api/auth/login/` | Get JWT tokens |
| GET | `/api/auth/me/` | Current user profile |
| GET/POST | `/api/items/` | List / create items |
| GET | `/api/items/:id/` | Item detail |
| GET | `/api/items/categories/` | All categories |
| POST | `/api/rentals/offers/` | Make rental offer |
| POST | `/api/rentals/offers/:id/accept/` | Accept offer |
| POST | `/api/rentals/offers/:id/counter/` | Counter offer |
| GET | `/api/rentals/agreements/` | My agreements |
| GET/POST | `/api/reviews/` | Get / write reviews |
| GET | `/api/reviews/reputation/:userId/` | User reputation |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x (Dart) |
| State Management | Provider |
| Navigation | go_router |
| Backend | Django 4.2 + DRF |
| Auth | JWT (SimpleJWT) |
| Database | PostgreSQL 15 |
| Real-time | Django Channels + Redis |
| API Docs | drf-spectacular (Swagger) |

---

## 🔮 Future Roadmap

- [ ] Real-time chat between lender and borrower
- [ ] Location-based discovery (map view)
- [ ] Push notifications (FCM)
- [ ] In-app payments (bKash/Nagad integration)
- [ ] ID verification for trust badges
- [ ] AI-powered item recommendations

---

Built with ❤️ for the Dhaka community.
