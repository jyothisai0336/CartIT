import React from "react";
import DEALS from "../data/deals";
import "./DealsStrip.css";
export default function DealsStrip() {
  return (
    <div className="deals-strip">
      {DEALS.map(d=>(
        <div key={d.id} className="deal-tile" style={{background:d.bg}}>
          <img className="deal-img" src={d.img} alt={d.title} onError={e=>e.target.style.display="none"}/>
          <div><div className="deal-title">{d.title}</div><div className="deal-desc">{d.desc}</div></div>
          <div className="deal-code">{d.code}</div>
        </div>
      ))}
    </div>
  );
}
