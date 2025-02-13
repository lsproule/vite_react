import React from "react";
import { Response } from "express";
import { renderToPipeableStream } from "react-dom/server";

type Props<K extends PropertyKey, V = unknown> = [K, V]


export async function render(componentName: string, props: Props<any, any>, res: Response) {

  const module = await import(`@/ssr-components/${componentName}.jsx`);
  const Component = module.default;

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

