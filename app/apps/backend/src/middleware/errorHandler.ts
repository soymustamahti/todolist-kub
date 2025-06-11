import { Request, Response, NextFunction } from "express";

export const errorHandler = (
  error: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error("Error:", error);

  if (error.code === "P2002") {
    return res.status(400).json({
      error: "A record with this information already exists",
    });
  }

  if (error.code === "P2025") {
    return res.status(404).json({
      error: "Record not found",
    });
  }

  if (error.name === "ValidationError") {
    return res.status(400).json({
      error: "Validation failed",
      details: error.errors,
    });
  }

  res.status(500).json({
    error: "Internal server error",
    message:
      process.env.NODE_ENV === "development"
        ? error.message
        : "Something went wrong",
  });
};
