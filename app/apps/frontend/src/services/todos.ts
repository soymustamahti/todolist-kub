import { api } from "./api";
import { Todo, CreateTodoData, UpdateTodoData } from "@/types";

export const todoService = {
  async getTodos(params?: {
    completed?: boolean;
    priority?: string;
    sortBy?: string;
    sortOrder?: "asc" | "desc";
  }): Promise<{ todos: Todo[] }> {
    const response = await api.get("/todos", { params });
    return response.data;
  },

  async getTodo(id: string): Promise<{ todo: Todo }> {
    const response = await api.get(`/todos/${id}`);
    return response.data;
  },

  async createTodo(
    data: CreateTodoData
  ): Promise<{ todo: Todo; message: string }> {
    const response = await api.post("/todos", data);
    return response.data;
  },

  async updateTodo(
    id: string,
    data: UpdateTodoData
  ): Promise<{ todo: Todo; message: string }> {
    const response = await api.put(`/todos/${id}`, data);
    return response.data;
  },

  async deleteTodo(id: string): Promise<{ message: string }> {
    const response = await api.delete(`/todos/${id}`);
    return response.data;
  },

  async toggleTodo(id: string): Promise<{ todo: Todo; message: string }> {
    const response = await api.patch(`/todos/${id}/toggle`);
    return response.data;
  },
};
