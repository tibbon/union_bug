import IndexPage from "./IndexPage";
import React from "react";
import { createRoot } from "react-dom/client";
import "bootstrap";
import "./application.scss";

document.addEventListener("DOMContentLoaded", () => {
  const rootElement = document.createElement("div");
  document.body.appendChild(rootElement);
  const root = createRoot(rootElement);
  root.render(React.createElement(IndexPage));
});
