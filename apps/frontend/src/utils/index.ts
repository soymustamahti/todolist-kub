import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";
import {
  format,
  formatDistanceToNow,
  isToday,
  isTomorrow,
  isYesterday,
} from "date-fns";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatDate(date: string | Date) {
  const dateObj = typeof date === "string" ? new Date(date) : date;

  if (isToday(dateObj)) {
    return "Today";
  }

  if (isTomorrow(dateObj)) {
    return "Tomorrow";
  }

  if (isYesterday(dateObj)) {
    return "Yesterday";
  }

  return format(dateObj, "MMM d, yyyy");
}

export function formatRelativeTime(date: string | Date) {
  const dateObj = typeof date === "string" ? new Date(date) : date;
  return formatDistanceToNow(dateObj, { addSuffix: true });
}

export function getPriorityColor(priority: "LOW" | "MEDIUM" | "HIGH") {
  switch (priority) {
    case "HIGH":
      return "text-red-600 bg-red-50 border-red-200";
    case "MEDIUM":
      return "text-yellow-600 bg-yellow-50 border-yellow-200";
    case "LOW":
      return "text-green-600 bg-green-50 border-green-200";
    default:
      return "text-gray-600 bg-gray-50 border-gray-200";
  }
}
