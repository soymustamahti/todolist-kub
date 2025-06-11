import { useState } from "react";
import { Plus, Search } from "lucide-react";
import { useTodos } from "@/hooks/useTodos";
import Button from "@/components/Button";
import Input from "@/components/Input";
import LoadingSpinner from "@/components/LoadingSpinner";
import TodoList from "@/components/TodoList";
import TodoForm from "@/components/TodoForm";
import TodoFilters, { Filters } from "@/components/TodoFilters";

export default function DashboardPage() {
  const [showForm, setShowForm] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [filters, setFilters] = useState<Filters>({
    completed: undefined,
    priority: undefined,
    sortBy: "createdAt",
    sortOrder: "desc",
  });

  const { data, isLoading, error } = useTodos(filters);

  const filteredTodos =
    data?.todos.filter(
      (todo) =>
        todo.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
        todo.description?.toLowerCase().includes(searchQuery.toLowerCase())
    ) || [];

  const stats = {
    total: data?.todos.length || 0,
    completed: data?.todos.filter((todo) => todo.completed).length || 0,
    pending: data?.todos.filter((todo) => !todo.completed).length || 0,
  };

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600">Failed to load todos. Please try again.</p>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">My Todos</h1>
        <div className="flex flex-wrap gap-4 text-sm text-gray-600">
          <span>
            Total: <strong>{stats.total}</strong>
          </span>
          <span>
            Completed: <strong>{stats.completed}</strong>
          </span>
          <span>
            Pending: <strong>{stats.pending}</strong>
          </span>
        </div>
      </div>

      <div className="mb-6 flex flex-col sm:flex-row gap-4">
        <div className="flex-1 relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            placeholder="Search todos..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
        <TodoFilters filters={filters} onFiltersChange={setFilters} />
        <Button
          onClick={() => setShowForm(true)}
          className="flex items-center gap-2"
        >
          <Plus className="h-4 w-4" />
          Add Todo
        </Button>
      </div>

      {showForm && (
        <div className="mb-6">
          <TodoForm onClose={() => setShowForm(false)} />
        </div>
      )}

      {isLoading ? (
        <div className="flex justify-center py-12">
          <LoadingSpinner size="lg" />
        </div>
      ) : (
        <TodoList todos={filteredTodos} />
      )}
    </div>
  );
}
