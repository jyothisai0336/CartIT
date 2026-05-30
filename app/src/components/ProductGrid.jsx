import React from "react";
import ProductCard from "./ProductCard";
import "./ProductGrid.css";
export default function ProductGrid({ products, cart, search, sort, onSortChange, onAdd, onIncrease, onDecrease }) {
  return (
    <div className="product-area">
      <div className="grid-toolbar">
        <div className="grid-heading"><span className="grid-count">{products.length}</span> Products{search&&<span className="grid-hint"> for "{search}"</span>}</div>
        <select className="sort-select" value={sort} onChange={e=>onSortChange(e.target.value)}>
          <option value="popular">Most Popular</option>
          <option value="rating">Top Rated</option>
          <option value="price-asc">Price: Low → High</option>
          <option value="price-desc">Price: High → Low</option>
        </select>
      </div>
      {products.length===0
        ?<div className="grid-empty"><div className="empty-icon">🔍</div><h3>Kuch nahi mila!</h3><p>Try different keywords or reset filters</p></div>
        :<div className="product-grid">{products.map((p,i)=><ProductCard key={p.id} product={p} qty={cart.find(c=>c.id===p.id)?.qty||0} onAdd={onAdd} onIncrease={onIncrease} onDecrease={onDecrease} animIndex={i}/>)}</div>
      }
    </div>
  );
}
