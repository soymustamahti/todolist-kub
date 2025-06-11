import { api } from "./api";
import { AuthData, RegisterData, AuthResponse, User } from "@/types";

export const authService = {
  async login(data: AuthData): Promise<AuthResponse> {
    const response = await api.post("/auth/login", data);
    return response.data;
  },

  async register(data: RegisterData): Promise<AuthResponse> {
    const response = await api.post("/auth/register", data);
    return response.data;
  },

  async getCurrentUser(): Promise<{ user: User }> {
    const response = await api.get("/auth/me");
    return response.data;
  },

  logout() {
    localStorage.removeItem("token");
    localStorage.removeItem("user");
  },
};
