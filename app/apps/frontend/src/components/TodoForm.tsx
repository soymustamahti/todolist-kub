import { useForm } from "react-hook-form";
import { X, Calendar } from "lucide-react";
import { Todo, CreateTodoData, UpdateTodoData } from "@/types";
import { useCreateTodo, useUpdateTodo } from "@/hooks/useTodos";
import Button from "./Button";
import Input from "./Input";
import LoadingSpinner from "./LoadingSpinner";

interface TodoFormProps {
  todo?: Todo;
  onClose: () => void;
}

export default function TodoForm({ todo, onClose }: TodoFormProps) {
  const isEditing = !!todo;
  const createMutation = useCreateTodo();
  const updateMutation = useUpdateTodo();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<CreateTodoData | UpdateTodoData>({
    defaultValues: todo
      ? {
          title: todo.title,
          description: todo.description || "",
          priority: todo.priority,
          dueDate: todo.dueDate
            ? new Date(todo.dueDate).toISOString().slice(0, 16)
            : "",
        }
      : {
          priority: "MEDIUM",
        },
  });

  const onSubmit = async (data: CreateTodoData | UpdateTodoData) => {
    try {
      // Clean up empty strings for optional fields
      const cleanedData = {
        ...data,
        dueDate: data.dueDate === "" ? undefined : data.dueDate,
        description: data.description === "" ? undefined : data.description,
      };

      if (isEditing) {
        await updateMutation.mutateAsync({
          id: todo.id,
          data: cleanedData as UpdateTodoData,
        });
      } else {
        await createMutation.mutateAsync(cleanedData as CreateTodoData);
      }
      onClose();
    } catch (error) {
      // Error is handled by the mutation
    }
  };

  const isLoading = createMutation.isLoading || updateMutation.isLoading;

  return (
    <div className="bg-white rounded-lg border p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-medium text-gray-900">
          {isEditing ? "Edit Todo" : "Create New Todo"}
        </h3>
        <Button
          variant="ghost"
          size="sm"
          onClick={onClose}
          className="h-8 w-8 p-0"
        >
          <X className="h-4 w-4" />
        </Button>
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
        <div>
          <label
            htmlFor="title"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Title *
          </label>
          <Input
            id="title"
            placeholder="Enter todo title"
            {...register("title", {
              required: "Title is required",
              maxLength: {
                value: 255,
                message: "Title must be less than 255 characters",
              },
            })}
          />
          {errors.title && (
            <p className="mt-1 text-sm text-red-600">{errors.title.message}</p>
          )}
        </div>

        <div>
          <label
            htmlFor="description"
            className="block text-sm font-medium text-gray-700 mb-1"
          >
            Description
          </label>
          <textarea
            id="description"
            rows={3}
            placeholder="Enter todo description (optional)"
            className="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            {...register("description")}
          />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label
              htmlFor="priority"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Priority
            </label>
            <select
              id="priority"
              className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              {...register("priority")}
            >
              <option value="LOW">Low</option>
              <option value="MEDIUM">Medium</option>
              <option value="HIGH">High</option>
            </select>
          </div>

          <div>
            <label
              htmlFor="dueDate"
              className="block text-sm font-medium text-gray-700 mb-1"
            >
              Due Date
            </label>
            <div className="relative">
              <Input
                id="dueDate"
                type="datetime-local"
                {...register("dueDate")}
              />
              <Calendar className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
            </div>
          </div>
        </div>

        <div className="flex justify-end gap-3 pt-4">
          <Button variant="outline" onClick={onClose} disabled={isLoading}>
            Cancel
          </Button>
          <Button type="submit" disabled={isLoading}>
            {isLoading ? (
              <LoadingSpinner size="sm" />
            ) : isEditing ? (
              "Update Todo"
            ) : (
              "Create Todo"
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}
