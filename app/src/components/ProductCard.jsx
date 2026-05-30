import React, { useState } from "react";
import "./ProductCard.css";
const fmtInr = n => n.toLocaleString("en-IN");
function Stars({ r }) {
  return <span className="stars">{[1,2,3,4,5].map(i=><span key={i} style={{opacity:i<=Math.round(r)?1:.2}}>★</span>)}</span>;
}
export default function ProductCard({ product:p, qty, onAdd, onIncrease, onDecrease, animIndex }) {
  const [imgErr, setImgErr] = useState(false);
  const fallback = `https://placehold.co/250x250/0a2010/4ade80?text=${encodeURIComponent(p.name.split(" ")[0])}`;
  return (
    <div className="product-card" style={{animationDelay:`${animIndex*.038}s`}}>
      <div className="card-img-wrap">
        <img className="card-img" src={imgErr?fallback:p.img} alt={p.name} loading="lazy" onError={()=>setImgErr(true)}/>
        {p.badge&&<span className={`card-badge ${p.badge.includes("🏆")?"card-badge--special":""}`}>{p.badge}</span>}
      </div>
      <div className="card-body">
        <div className="card-name" title={p.name}>{p.name}</div>
        <div className="card-unit">{p.unit}</div>
        <div className="card-desc">{p.desc}</div>
        <div className="card-rating"><Stars r={p.rating}/><span className="rating-score">{p.rating}</span><span className="rating-count">({p.reviews.toLocaleString()})</span></div>
        <div className="card-footer">
          <div className="card-price"><span className="price-label">MRP</span><span className="price-value">{fmtInr(p.price)}</span></div>
          {qty===0
            ?<button className="btn-add" onClick={()=>onAdd(p)}>+</button>
            :<div className="qty-control">
               <button className="qty-btn" onClick={()=>onDecrease(p.id)}>−</button>
               <span className="qty-num">{qty}</span>
               <button className="qty-btn" onClick={()=>onIncrease(p.id)}>+</button>
             </div>
          }
        </div>
      </div>
    </div>
  );
}
