import { Router, Response } from "express";
import { prisma } from "../index";
import { authenticateToken, AuthRequest } from "../middleware/auth";
import { createTodoSchema, updateTodoSchema } from "../types/schemas";

const router = Router();

// Apply authentication middleware to all routes
router.use(authenticateToken);

// Get all todos for the authenticated user
router.get("/", async (req: AuthRequest, res: Response, next) => {
  try {
    const {
      completed,
      priority,
      sortBy = "createdAt",
      sortOrder = "desc",
    } = req.query;

    const where: any = {
      userId: req.user!.id,
    };

    if (completed !== undefined) {
      where.completed = completed === "true";
    }

    if (priority) {
      where.priority = priority;
    }

    const todos = await prisma.todo.findMany({
      where,
      orderBy: {
        [sortBy as string]: sortOrder === "asc" ? "asc" : "desc",
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    res.json({ todos });
  } catch (error) {
    next(error);
  }
});

// Get a specific todo
router.get("/:id", async (req: AuthRequest, res: Response, next) => {
  try {
    const { id } = req.params;

    const todo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.user!.id,
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    if (!todo) {
      return res.status(404).json({ error: "Todo not found" });
    }

    res.json({ todo });
  } catch (error) {
    next(error);
  }
});

// Create a new todo
router.post("/", async (req: AuthRequest, res: Response, next) => {
  try {
    const data = createTodoSchema.parse(req.body);

    const todo = await prisma.todo.create({
      data: {
        ...data,
        dueDate: data.dueDate ? new Date(data.dueDate) : null,
        userId: req.user!.id,
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    res.status(201).json({
      message: "Todo created successfully",
      todo,
    });
  } catch (error) {
    next(error);
  }
});

// Update a todo
router.put("/:id", async (req: AuthRequest, res: Response, next) => {
  try {
    const { id } = req.params;
    const data = updateTodoSchema.parse(req.body);

    // Check if todo exists and belongs to the user
    const existingTodo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.user!.id,
      },
    });

    if (!existingTodo) {
      return res.status(404).json({ error: "Todo not found" });
    }

    const updateData: any = { ...data };
    if (data.dueDate !== undefined) {
      updateData.dueDate = data.dueDate ? new Date(data.dueDate) : null;
    }

    const todo = await prisma.todo.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    res.json({
      message: "Todo updated successfully",
      todo,
    });
  } catch (error) {
    next(error);
  }
});

// Delete a todo
router.delete("/:id", async (req: AuthRequest, res: Response, next) => {
  try {
    const { id } = req.params;

    // Check if todo exists and belongs to the user
    const existingTodo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.user!.id,
      },
    });

    if (!existingTodo) {
      return res.status(404).json({ error: "Todo not found" });
    }

    await prisma.todo.delete({
      where: { id },
    });

    res.json({ message: "Todo deleted successfully" });
  } catch (error) {
    next(error);
  }
});

// Toggle todo completion
router.patch("/:id/toggle", async (req: AuthRequest, res: Response, next) => {
  try {
    const { id } = req.params;

    // Check if todo exists and belongs to the user
    const existingTodo = await prisma.todo.findFirst({
      where: {
        id,
        userId: req.user!.id,
      },
    });

    if (!existingTodo) {
      return res.status(404).json({ error: "Todo not found" });
    }

    const todo = await prisma.todo.update({
      where: { id },
      data: {
        completed: !existingTodo.completed,
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });

    res.json({
      message: "Todo status updated successfully",
      todo,
    });
  } catch (error) {
    next(error);
  }
});

export default router;
