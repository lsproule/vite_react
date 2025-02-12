import React from "react";
import ReactDOM from "react-dom/client";

function hydrateComponents() {
  document.querySelectorAll("[data-react-component]").forEach(async (el) => {
    const componentName = el.getAttribute("data-react-component");
    const props = JSON.parse(el.getAttribute("data-props") || "{}");
    const module = await import(`../components/${componentName}.jsx`);
    const Component = module.default;
    ReactDOM.hydrateRoot(el, <Component {...props} />);
  });
}

document.addEventListener("DOMContentLoaded", hydrateComponents);

