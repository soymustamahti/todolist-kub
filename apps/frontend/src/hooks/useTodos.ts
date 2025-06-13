import { useQuery, useMutation, useQueryClient } from "react-query";
import { toast } from "sonner";
import { todoService } from "@/services/todos";
import { UpdateTodoData } from "@/types";

export function useTodos(params?: {
  completed?: boolean;
  priority?: string;
  sortBy?: string;
  sortOrder?: "asc" | "desc";
}) {
  return useQuery(["todos", params], () => todoService.getTodos(params), {
    staleTime: 30000, // 30 seconds
  });
}

export function useTodo(id: string) {
  return useQuery(["todo", id], () => todoService.getTodo(id), {
    enabled: !!id,
  });
}

export function useCreateTodo() {
  const queryClient = useQueryClient();

  return useMutation(todoService.createTodo, {
    onSuccess: (data) => {
      queryClient.invalidateQueries(["todos"]);
      toast.success(data.message);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || "Failed to create todo");
    },
  });
}

export function useUpdateTodo() {
  const queryClient = useQueryClient();

  return useMutation(
    ({ id, data }: { id: string; data: UpdateTodoData }) =>
      todoService.updateTodo(id, data),
    {
      onSuccess: (data) => {
        queryClient.invalidateQueries(["todos"]);
        queryClient.invalidateQueries(["todo"]);
        toast.success(data.message);
      },
      onError: (error: any) => {
        toast.error(error.response?.data?.error || "Failed to update todo");
      },
    }
  );
}

export function useDeleteTodo() {
  const queryClient = useQueryClient();

  return useMutation(todoService.deleteTodo, {
    onSuccess: (data) => {
      queryClient.invalidateQueries(["todos"]);
      toast.success(data.message);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || "Failed to delete todo");
    },
  });
}

export function useToggleTodo() {
  const queryClient = useQueryClient();

  return useMutation(todoService.toggleTodo, {
    onSuccess: (data) => {
      queryClient.invalidateQueries(["todos"]);
      queryClient.invalidateQueries(["todo"]);
      toast.success(data.message);
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.error || "Failed to toggle todo");
    },
  });
}
