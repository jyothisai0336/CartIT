import React from "react";
import CATEGORIES from "../data/categories";
import "./Sidebar.css";
const fmtInr = n => n.toLocaleString("en-IN");
export default function Sidebar({ category, onCategory, maxPrice, onMaxPrice, countFor }) {
  return (
    <aside className="sidebar">
      <div className="glass-panel sidebar-panel">
        <div className="panel-title">Categories</div>
        {CATEGORIES.map(c=>(
          <button key={c.id} className={`cat-btn ${category===c.id?"active":""}`} onClick={()=>onCategory(c.id)}>
            <span className="cat-icon">{c.icon}</span>
            <span className="cat-label">{c.label}</span>
            <span className="cat-count">{countFor(c.id)}</span>
          </button>
        ))}
      </div>
      <div className="glass-panel sidebar-panel">
        <div className="panel-title">Max Price</div>
        <div className="price-row"><span>₹10</span><span className="price-val">₹{fmtInr(maxPrice)}</span></div>
        <input type="range" min={10} max={400} step={5} value={maxPrice} onChange={e=>onMaxPrice(Number(e.target.value))}/>
      </div>
    </aside>
  );
}
