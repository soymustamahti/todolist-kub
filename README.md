# Todo List Monorepo

A full-stack todo list application built with React, Express, and PostgreSQL using Yarn workspaces.

## Features

- 🔐 **Authentication**: JWT-based user authentication
- ✅ **CRUD Operations**: Create, read, update, and delete todos
- 🎯 **Priority Levels**: High, Medium, Low priority todos
- 📅 **Due Dates**: Set and track due dates for todos
- 🔍 **Search & Filter**: Search and filter todos by status, priority, and more
- 📱 **Responsive Design**: Modern UI with Tailwind CSS
- 🗄️ **Database**: PostgreSQL with Prisma ORM
- 🔄 **Migrations**: Database schema migrations
- 🌱 **Seeding**: Sample data for development

## Tech Stack

### Frontend

- React 18
- TypeScript
- Vite
- Tailwind CSS
- React Query
- React Hook Form
- React Router

### Backend

- Node.js
- Express
- TypeScript
- Prisma ORM
- PostgreSQL
- JWT Authentication
- Zod validation

### Development

- Yarn Workspaces
- ESLint
- Prettier

## Prerequisites

- Node.js (v18 or higher)
- Yarn (v1.22 or higher)
- PostgreSQL

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <repository-url>
cd todo-monorepo

# Install dependencies for all workspaces
yarn install
```

### 2. Database Setup

```bash
# Start PostgreSQL service (Ubuntu/Debian)
sudo service postgresql start

# Create database
sudo -u postgres createdb todoapp

# Create user (optional)
sudo -u postgres createuser --interactive
```

### 3. Environment Configuration

```bash
# Copy environment file
cp apps/backend/.env.example apps/backend/.env

# Edit the environment variables
nano apps/backend/.env
```

Update the `DATABASE_URL` in `.env`:

```
DATABASE_URL="postgresql://username:password@localhost:5432/todoapp?schema=public"
```

### 4. Database Migration and Seeding

```bash
# Generate Prisma client
cd apps/backend
yarn db:generate

# Run migrations
yarn migrate

# Seed the database with sample data
yarn seed
```

### 5. Start Development Servers

```bash
# From root directory - starts both frontend and backend
yarn dev

# Or start individually:
# Backend (from root)
yarn workspace backend dev

# Frontend (from root)
yarn workspace frontend dev
```

The application will be available at:

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001

## Available Scripts

### Root Level

- `yarn dev` - Start both frontend and backend in development mode
- `yarn build` - Build all workspaces
- `yarn start` - Start production backend
- `yarn migrate` - Run database migrations
- `yarn seed` - Seed database with sample data

### Backend (`apps/backend`)

- `yarn dev` - Start development server with hot reload
- `yarn build` - Build TypeScript to JavaScript
- `yarn start` - Start production server
- `yarn migrate` - Run Prisma migrations
- `yarn db:generate` - Generate Prisma client
- `yarn db:studio` - Open Prisma Studio
- `yarn seed` - Seed database

### Frontend (`apps/frontend`)

- `yarn dev` - Start Vite development server
- `yarn build` - Build for production
- `yarn preview` - Preview production build

## API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Todos

- `GET /api/todos` - Get all todos (with query filters)
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get specific todo
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Delete todo
- `PATCH /api/todos/:id/toggle` - Toggle todo completion

## Default Credentials

After running the seed script, you can login with:

- **Email**: demo@example.com
- **Password**: password123

## Database Schema

### Users Table

- `id` - Unique identifier
- `email` - User email (unique)
- `name` - User full name (optional)
- `password` - Hashed password
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp

### Todos Table

- `id` - Unique identifier
- `title` - Todo title
- `description` - Todo description (optional)
- `completed` - Completion status
- `priority` - Priority level (LOW, MEDIUM, HIGH)
- `dueDate` - Due date (optional)
- `userId` - Foreign key to user
- `createdAt` - Creation timestamp
- `updatedAt` - Last update timestamp

## Project Structure

```
├── package.json                 # Root package.json with workspaces
├── apps/
│   ├── frontend/               # React frontend application
│   │   ├── src/
│   │   │   ├── components/     # Reusable UI components
│   │   │   ├── pages/          # Page components
│   │   │   ├── hooks/          # Custom React hooks
│   │   │   ├── services/       # API service functions
│   │   │   ├── context/        # React context providers
│   │   │   ├── types/          # TypeScript type definitions
│   │   │   └── utils/          # Utility functions
│   │   └── package.json
│   └── backend/                # Express backend application
│       ├── src/
│       │   ├── routes/         # API route handlers
│       │   ├── middleware/     # Express middleware
│       │   ├── types/          # TypeScript schemas
│       │   └── utils/          # Utility functions
│       ├── prisma/
│       │   └── schema.prisma   # Database schema
│       └── package.json
└── packages/                   # Shared packages (if any)
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.
