import app from "./app";

// DATABASE_URL is required — check early and exit gracefully if missing.
if (!process.env["DATABASE_URL"]) {
  console.error(
    "Error: DATABASE_URL environment variable is not set.\n" +
      "Please add it to your .env file and try again.",
  );
  process.exit(1);
}

// PORT defaults to 3000 if not specified in the environment / .env file.
const rawPort = process.env["PORT"] ?? "3000";
const port = Number(rawPort);

if (Number.isNaN(port) || port <= 0) {
  console.error(`Error: Invalid PORT value: "${rawPort}"`);
  process.exit(1);
}

app.listen(port, "0.0.0.0", () => {
  console.log(`Server listening on http://0.0.0.0:${port} (Accessible via http://10.0.2.2:${port} on Android Emulator)`);
});
