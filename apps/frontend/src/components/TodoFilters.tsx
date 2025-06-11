import { Filter } from "lucide-react";

export interface Filters {
  completed?: boolean;
  priority?: string;
  sortBy: string;
  sortOrder: "asc" | "desc";
}

interface TodoFiltersProps {
  filters: Filters;
  onFiltersChange: (filters: Filters) => void;
}

export default function TodoFilters({
  filters,
  onFiltersChange,
}: TodoFiltersProps) {
  const updateFilter = (key: keyof Filters, value: any) => {
    onFiltersChange({ ...filters, [key]: value });
  };

  return (
    <div className="flex items-center gap-2">
      <Filter className="h-4 w-4 text-gray-400" />

      <select
        value={
          filters.completed === undefined
            ? "all"
            : filters.completed
              ? "completed"
              : "pending"
        }
        onChange={(e) => {
          const value = e.target.value;
          updateFilter(
            "completed",
            value === "all" ? undefined : value === "completed"
          );
        }}
        className="text-sm rounded-md border border-gray-300 px-2 py-1"
      >
        <option value="all">All</option>
        <option value="pending">Pending</option>
        <option value="completed">Completed</option>
      </select>

      <select
        value={filters.priority || "all"}
        onChange={(e) => {
          const value = e.target.value;
          updateFilter("priority", value === "all" ? undefined : value);
        }}
        className="text-sm rounded-md border border-gray-300 px-2 py-1"
      >
        <option value="all">All Priorities</option>
        <option value="HIGH">High</option>
        <option value="MEDIUM">Medium</option>
        <option value="LOW">Low</option>
      </select>

      <select
        value={`${filters.sortBy}-${filters.sortOrder}`}
        onChange={(e) => {
          const [sortBy, sortOrder] = e.target.value.split("-");
          updateFilter("sortBy", sortBy);
          updateFilter("sortOrder", sortOrder as "asc" | "desc");
        }}
        className="text-sm rounded-md border border-gray-300 px-2 py-1"
      >
        <option value="createdAt-desc">Newest First</option>
        <option value="createdAt-asc">Oldest First</option>
        <option value="title-asc">Title A-Z</option>
        <option value="title-desc">Title Z-A</option>
        <option value="priority-desc">Priority High-Low</option>
        <option value="dueDate-asc">Due Date</option>
      </select>
    </div>
  );
}
