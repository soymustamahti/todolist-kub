import { useState } from "react";
import { Edit, Trash2, Calendar, MoreVertical } from "lucide-react";
import { Todo } from "@/types";
import { useToggleTodo, useDeleteTodo } from "@/hooks/useTodos";
import { formatDate, formatRelativeTime, getPriorityColor, cn } from "@/utils";
import Button from "./Button";
import TodoForm from "./TodoForm";

interface TodoItemProps {
  todo: Todo;
}

export default function TodoItem({ todo }: TodoItemProps) {
  const [showEdit, setShowEdit] = useState(false);
  const [showMenu, setShowMenu] = useState(false);
  const toggleMutation = useToggleTodo();
  const deleteMutation = useDeleteTodo();

  const handleToggle = () => {
    toggleMutation.mutate(todo.id);
  };

  const handleDelete = () => {
    if (window.confirm("Are you sure you want to delete this todo?")) {
      deleteMutation.mutate(todo.id);
    }
  };

  if (showEdit) {
    return <TodoForm todo={todo} onClose={() => setShowEdit(false)} />;
  }

  return (
    <div
      className={cn(
        "bg-white rounded-lg border p-4 hover:shadow-md transition-shadow",
        todo.completed && "opacity-75"
      )}
    >
      <div className="flex items-start gap-3">
        <button
          onClick={handleToggle}
          className={cn(
            "mt-1 h-5 w-5 rounded border-2 flex items-center justify-center transition-colors",
            todo.completed
              ? "bg-primary border-primary text-white"
              : "border-gray-300 hover:border-primary"
          )}
          disabled={toggleMutation.isLoading}
        >
          {todo.completed && (
            <svg className="h-3 w-3" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                clipRule="evenodd"
              />
            </svg>
          )}
        </button>

        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between">
            <div className="flex-1">
              <h3
                className={cn(
                  "font-medium text-gray-900",
                  todo.completed && "line-through text-gray-500"
                )}
              >
                {todo.title}
              </h3>
              {todo.description && (
                <p
                  className={cn(
                    "text-sm text-gray-600 mt-1",
                    todo.completed && "line-through"
                  )}
                >
                  {todo.description}
                </p>
              )}
            </div>

            <div className="flex items-center gap-2 ml-4">
              <span
                className={cn(
                  "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium border",
                  getPriorityColor(todo.priority)
                )}
              >
                {todo.priority}
              </span>

              <div className="relative">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setShowMenu(!showMenu)}
                  className="h-8 w-8 p-0"
                >
                  <MoreVertical className="h-4 w-4" />
                </Button>

                {showMenu && (
                  <div className="absolute right-0 mt-1 w-32 bg-white rounded-md shadow-lg border z-10">
                    <button
                      onClick={() => {
                        setShowEdit(true);
                        setShowMenu(false);
                      }}
                      className="flex items-center gap-2 w-full px-3 py-2 text-sm text-gray-700 hover:bg-gray-50"
                    >
                      <Edit className="h-4 w-4" />
                      Edit
                    </button>
                    <button
                      onClick={() => {
                        handleDelete();
                        setShowMenu(false);
                      }}
                      className="flex items-center gap-2 w-full px-3 py-2 text-sm text-red-600 hover:bg-red-50"
                      disabled={deleteMutation.isLoading}
                    >
                      <Trash2 className="h-4 w-4" />
                      Delete
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>

          <div className="flex items-center gap-4 mt-3 text-xs text-gray-500">
            <span>Created {formatRelativeTime(todo.createdAt)}</span>
            {todo.dueDate && (
              <span className="flex items-center gap-1">
                <Calendar className="h-3 w-3" />
                Due {formatDate(todo.dueDate)}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Click outside to close menu */}
      {showMenu && (
        <div className="fixed inset-0 z-5" onClick={() => setShowMenu(false)} />
      )}
    </div>
  );
}
