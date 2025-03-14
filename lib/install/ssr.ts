import express, { Request, Response } from 'express';
import { createServer as createViteServer } from 'vite';
import React from "react";
import { renderToPipeableStream } from "react-dom/server";
import parse from 'html-react-parser';



const port = process.env.PORT || 4000;

async function startServer() {
  const app = express();

  // Create Vite server in middleware mode.
  const vite = await createViteServer({
    server: { middlewareMode: true },
    appType: 'custom'
  });

  // Use Vite's middleware.
  app.use(vite.middlewares);

  app.use(express.json());

  // SSR render endpoint
  app.post("/render", async (req: Request, res: Response) => {
    try {
      const { component, props } = req.body;
      console.log("props", props)
      render(component, props, res);
    } catch (error) {
      vite.ssrFixStacktrace(error as Error);
      console.error("SSR error:", error);
      res.status(500).send("Internal Server Error");
    }
  });

  app.listen(port, () => console.log(`vite_react_ssr Node server listening on port ${port}`));
}



async function render(componentName: string, props: any, res: Response) {

  const module = await import(`@/ssr-components/${componentName}.tsx`);
  const Component = module.default;
  if (props?.children) {
    props.children = parse(props.children);
  }

  const element = React.createElement(Component, props);

  const streamObj = renderToPipeableStream(element, {
    onShellReady() {
      res.setHeader("Content-Type", "text/html");
      streamObj.pipe(res);
    },
    onShellError(error) {
      console.error("Shell error:", error);
      res.status(500).send("Internal Server Error");
    },
    onError(error) {
      console.error("Streaming error:", error);
    }
  });
}

startServer();


