import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Starting database seed...");

  // Create demo user
  const hashedPassword = await bcrypt.hash("password123", 12);

  const user = await prisma.user.upsert({
    where: { email: "demo@example.com" },
    update: {},
    create: {
      email: "demo@example.com",
      name: "Demo User",
      password: hashedPassword,
    },
  });

  console.log("👤 Created demo user:", user.email);

  // Create demo todos
  const todos = await Promise.all([
    prisma.todo.create({
      data: {
        title: "Complete project setup",
        description:
          "Set up the monorepo with React frontend and Express backend",
        priority: "HIGH",
        completed: true,
        userId: user.id,
      },
    }),
    prisma.todo.create({
      data: {
        title: "Implement CRUD operations",
        description:
          "Add create, read, update, and delete functionality for todos",
        priority: "HIGH",
        completed: false,
        userId: user.id,
      },
    }),
    prisma.todo.create({
      data: {
        title: "Add user authentication",
        description: "Implement JWT-based authentication system",
        priority: "MEDIUM",
        completed: true,
        userId: user.id,
      },
    }),
    prisma.todo.create({
      data: {
        title: "Design beautiful UI",
        description: "Create a modern and responsive user interface",
        priority: "MEDIUM",
        completed: false,
        dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
        userId: user.id,
      },
    }),
    prisma.todo.create({
      data: {
        title: "Write documentation",
        description: "Document the API and setup instructions",
        priority: "LOW",
        completed: false,
        userId: user.id,
      },
    }),
  ]);

  console.log(`📝 Created ${todos.length} demo todos`);
  console.log("✅ Database seeded successfully!");
}

main()
  .catch((e) => {
    console.error("❌ Error seeding database:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
