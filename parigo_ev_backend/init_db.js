require("dotenv").config();

const { initDb, pool } = require("./db");

async function initializeDatabase() {
  try {
    console.log("Initializing database...");

    await initDb();

    console.log("Database initialization completed successfully.");

    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error("Database initialization failed:", error);

    await pool.end();
    process.exit(1);
  }
}

initializeDatabase();
