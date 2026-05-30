import React from "react";
import "./Header.css";
export default function Header({ search, onSearch, totalItems, onCartOpen, onLogoClick }) {
  return (
    <header className="header">
      <div className="header-inner">
        <div className="logo" onClick={onLogoClick}>
          <span className="logo-dot">●</span><span className="logo-c">Cart</span><span className="logo-i">It</span><span className="logo-badge">IN</span>
        </div>
        <div className="search-wrap">
          <span className="search-icon">🔍</span>
          <input className="search-input" type="text" placeholder='Search "paneer", "tata tea", "atta"...' value={search} onChange={e=>onSearch(e.target.value)}/>
          {search && <button className="search-clear" onClick={()=>onSearch("")}>✕</button>}
        </div>
        <div className="header-right">
          <div className="pincode-btn">📍 Deliver to <strong>560001</strong></div>
          <button className="cart-btn" onClick={onCartOpen}>
            🛒 Cart {totalItems>0&&<span className="cart-badge">{totalItems}</span>}
          </button>
        </div>
      </div>
    </header>
  );
}
