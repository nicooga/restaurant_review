# Foody API - Rails Backend

A Ruby on Rails API server for the Foody restaurant review platform, providing authentication, restaurant management, and review functionality.

## Tech Stack

- **Ruby 3.4.5** - Programming language
- **Rails 8.0** - Web framework (API mode)
- **PostgreSQL** - Database
- **Blueprinter** - JSON serialization
- **OliveBranch** - Automatic case conversion (snake_case ↔ camelCase)
- **Docker** - Containerization

## Development Setup

### Prerequisites

- Docker & Docker Compose
- Ruby 3.4.5 (if running locally)
- PostgreSQL (if running locally)

### Getting Started

#### Option 1: Docker Development (Recommended)

1. Start all services:
```bash
docker-compose up -d
```

2. Set up the database:
```bash
docker-compose exec foody_api rails db:create db:migrate db:seed
```

3. The API will be available at `http://localhost:3000`

#### Option 2: Local Development

1. Install Ruby dependencies:
```bash
bundle install
```

2. Set up the database:
```bash
rails db:create db:migrate db:seed
```

3. Start the Rails server:
```bash
rails server
```

## 🚨 Important: Adding New Gems

When adding new Ruby gems in a Docker environment, follow these steps:

### Installing New Gems

1. **Add the gem to Gemfile**:
```ruby
gem 'new-gem-name'
```

2. **Rebuild the container** to install the new gem:
```bash
docker-compose build --no-cache foody_api
```

3. **Restart the container**:
```bash
docker-compose restart foody_api
```

### Alternative: Install in Running Container

If you need to test a gem quickly:

```bash
# Install gem in running container
docker-compose exec foody_api bundle install

# Restart to ensure changes take effect
docker-compose restart foody_api
```

### Why This Is Necessary

Docker containers have isolated gem environments. When you add gems to the Gemfile, the container needs to rebuild its bundle to include the new dependencies.

## Database Management

### Migrations

```bash
# Create a new migration
docker-compose exec foody_api rails generate migration MigrationName

# Run migrations
docker-compose exec foody_api rails db:migrate

# Rollback last migration
docker-compose exec foody_api rails db:rollback
```

### Seeds

```bash
# Run seeds
docker-compose exec foody_api rails db:seed

# Reset database (drop, create, migrate, seed)
docker-compose exec foody_api rails db:reset
```

### Console

```bash
# Rails console
docker-compose exec foody_api rails console

# Database console
docker-compose exec foody_api rails db
```

## API Endpoints

### Authentication

- `POST /session` - Login (returns user + sets session cookie)
- `DELETE /session` - Logout
- `POST /users` - Register (returns user + sets session cookie)
- `GET /me` - Get current user (requires authentication)

### Restaurants

- `GET /restaurants` - List restaurants with filtering and sorting
- `GET /restaurants/:id` - Get restaurant details
- `GET /restaurants/:id/reviews` - Get restaurant reviews

### Reviews

- `POST /restaurants/:id/reviews` - Create a review (requires authentication)

## Request/Response Format

### Case Conversion

The API automatically converts between JSON formats:
- **Incoming requests**: camelCase → snake_case
- **Outgoing responses**: snake_case → camelCase

Send requests with camelCase:
```json
{
  "emailAddress": "user@example.com",
  "maxPrice": 3
}
```

Receive responses in camelCase:
```json
{
  "id": 1,
  "emailAddress": "user@example.com",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### Headers

All requests should include:
```
Content-Type: application/json
Key-Inflection: camel
```

The HTTP client in the frontend automatically sets these headers.

## Authentication

The API uses **session-based authentication** with HTTP-only cookies:

- Sessions are stored in the database
- Cookies are secure in production, non-secure in development
- CORS is configured to allow credentials from the frontend

### Session Management

Sessions include:
- User ID reference
- User agent tracking
- IP address logging
- Automatic cleanup on logout

## Error Handling

The API returns consistent error responses:

```json
{
  "message": "Human-readable error message",
  "errors": ["Detailed validation errors"]
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created
- `401` - Unauthorized (not logged in)
- `404` - Not found
- `422` - Unprocessable entity (validation errors)

## Environment Configuration

### Development (.env)

```env
DATABASE_URL=postgresql://foody_user:password123@localhost:5432/foody_development
RAILS_ENV=development
```

### Docker Environment

Environment variables are configured in `docker-compose.yml` for the PostgreSQL connection.

## Testing

```bash
# Run all tests
docker-compose exec foody_api rspec

# Run specific test
docker-compose exec foody_api rspec spec/requests/restaurants_spec.rb

# Run with coverage
docker-compose exec foody_api rspec --format documentation
```

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb    # Base controller with error handling
│   ├── sessions_controller.rb       # Authentication endpoints
│   ├── users_controller.rb         # User management
│   └── restaurants_controller.rb    # Restaurant and review endpoints
├── models/
│   ├── user.rb                     # User model with authentication
│   ├── restaurant.rb               # Restaurant model with reviews
│   ├── review.rb                   # Review model
│   ├── session.rb                  # Session tracking
│   └── current.rb                  # Current user context
├── blueprints/
│   ├── user_blueprint.rb           # User JSON serialization
│   ├── restaurant_blueprint.rb     # Restaurant JSON serialization
│   └── review_blueprint.rb         # Review JSON serialization
└── controllers/concerns/
    └── authentication.rb           # Authentication logic
```

## Deployment

### Production Environment

- Set `RAILS_ENV=production`
- Configure secure database URL
- Set up SSL certificates
- Enable `force_ssl` in production
- Configure CORS for production domain

### Docker Production

```bash
# Build production image
docker build -t foody-api .

# Run with production database
docker run -e RAILS_ENV=production -e DATABASE_URL=postgresql://... foody-api
```

## Troubleshooting

### Container Won't Start

1. Check logs:
```bash
docker-compose logs foody_api
```

2. Ensure database is running:
```bash
docker-compose ps postgres
```

3. Rebuild container:
```bash
docker-compose build --no-cache foody_api
```

### Database Connection Issues

1. Check PostgreSQL container:
```bash
docker-compose exec postgres psql -U foody_user -d foody_development
```

2. Reset database:
```bash
docker-compose exec foody_api rails db:reset
```

### Gem Installation Issues

Follow the gem installation steps above, ensuring you rebuild the container after adding new gems to the Gemfile.

### CORS Issues

Ensure the frontend URL is added to the CORS configuration in `config/initializers/cors.rb`.