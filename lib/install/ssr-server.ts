import express, { Request, Response } from 'express';
import { createServer as createViteServer } from 'vite';

const port = process.env.PORT || 4000;

async function startServer() {
  const app = express();

  // Create Vite server in middleware mode.
  const vite = await createViteServer({
    server: { middlewareMode: 'ssr' },
    appType: 'custom'
  });

  // Use Vite's middleware.
  app.use(vite.middlewares);

  app.use(express.json());

  // SSR render endpoint
  app.post("/render", async (req: Request, res: Response) => {
    try {
      const { component, props } = req.body;
      // Assume that your SSR entry is at /src/ssr-entry.js.
      const modulePath = "/node/ssr-entry.js";
      const { render } = await vite.ssrLoadModule(modulePath);
      // render() should handle renderToPipeableStream and pipe to res.
      render(component, props, res);
    } catch (error) {
      vite.ssrFixStacktrace(error);
      console.error("SSR error:", error);
      res.status(500).send("Internal Server Error");
    }
  });

  app.listen(port, () => console.log(`vite_react_ssr Node server listening on port ${port}`));
}

startServer();

