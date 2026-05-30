import React from "react";
import "./Toast.css";
export default function Toast({ message }) {
  if (!message) return null;
  return <div className="toast-wrap"><div className="toast-inner"><span className="toast-dot"/>{message}</div></div>;
}
