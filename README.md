# Foody - Interview Starting Point

This is a simple development environment for building a food delivery application. It includes a Rails API backend, React frontend, and PostgreSQL database, all running in Docker containers.

## Quick Start

1. **Start the application:**
   ```bash
   docker-compose up
   ```

2. **Access the applications:**
   - **Frontend (React):** http://localhost:5173
   - **Backend (Rails API):** http://localhost:3000
   - **Database (PostgreSQL):** localhost:5432

That's it! All services will start automatically and the database will be created.

## What's Included

- **Rails API** (`foody_api/`) - Ruby on Rails API server on port 3000
- **React Frontend** (`foody_ui/`) - React + TypeScript + Vite on port 5173  
- **PostgreSQL Database** - Running on port 5432

## Database Access

**Credentials:**
- Database: `foody_development`
- Username: `foody_user`
- Password: `password123`
- Host: `localhost` (or `postgres` from within containers)

**Rails console:**
```bash
docker-compose exec foody_api rails console
```

**Database migrations:**
```bash
docker-compose exec foody_api rails db:migrate
```

**Direct database access:**
```bash
docker-compose exec postgres psql -U foody_user -d foody_development
```

## Development

All source code is mounted into the containers, so any changes you make will be immediately reflected:

- Rails API changes are picked up automatically
- React changes trigger hot reload in the browser

## Common Commands

```bash
# Stop all services
docker-compose down

# Restart a specific service
docker-compose restart foody_api

# View logs
docker-compose logs foody_api
docker-compose logs foody_ui

# Install new gems
docker-compose exec foody_api bundle install

# Install new npm packages
docker-compose exec foody_ui npm install package-name
```

## Project Structure

```
foody/
├── foody_api/          # Rails API backend
├── foody_ui/           # React frontend
├── docker-compose.yml  # Docker orchestration
└── README.md          # This file
```

Start building your application by modifying the code in `foody_api/` and `foody_ui/`!