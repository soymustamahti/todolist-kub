export interface User {
  id: string;
  email: string;
  name?: string;
  createdAt: string;
}

export interface Todo {
  id: string;
  title: string;
  description?: string;
  completed: boolean;
  priority: "LOW" | "MEDIUM" | "HIGH";
  dueDate?: string;
  createdAt: string;
  updatedAt: string;
  userId: string;
  user: User;
}

export interface CreateTodoData {
  title: string;
  description?: string;
  priority?: "LOW" | "MEDIUM" | "HIGH";
  dueDate?: string;
}

export interface UpdateTodoData {
  title?: string;
  description?: string;
  completed?: boolean;
  priority?: "LOW" | "MEDIUM" | "HIGH";
  dueDate?: string | null;
}

export interface AuthData {
  email: string;
  password: string;
}

export interface RegisterData extends AuthData {
  name?: string;
}

export interface AuthResponse {
  message: string;
  user: User;
  token: string;
}
