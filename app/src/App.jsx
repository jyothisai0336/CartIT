import React, { useState } from "react";
import useCart   from "./hooks/useCart";
import useToast  from "./hooks/useToast";
import useFilter from "./hooks/useFilter";
import Header      from "./components/Header";
import DealsStrip  from "./components/DealsStrip";
import Sidebar     from "./components/Sidebar";
import ProductGrid from "./components/ProductGrid";
import CartDrawer  from "./components/CartDrawer";
import Toast       from "./components/Toast";
import "./styles/globals.css";
import "./App.css";

export default function App() {
  const [cartOpen, setCartOpen] = useState(false);
  const { cart, totalItems, addItem, increaseQty, decreaseQty, removeItem } = useCart();
  const { toast, showToast } = useToast();
  const { category, setCategory, search, setSearch, sort, setSort, maxPrice, setMaxPrice, filtered, countFor } = useFilter();

  function handleAdd(p) { addItem(p); showToast(`${p.name} added to cart`); }
  function handleRemove(id) { removeItem(id); showToast("Item removed from cart"); }

  return (
    <>
      <div className="bg-mesh"/><div className="bg-orb bg-orb-1"/><div className="bg-orb bg-orb-2"/><div className="bg-orb bg-orb-3"/>
      <div className="app-root">
        <div className="delivery-bar">🚚 Free delivery above <em>₹499</em> &nbsp;·&nbsp; 🕐 Same-day delivery in metro cities &nbsp;·&nbsp; 🇮🇳 India ka apna supermarket</div>
        <Header search={search} onSearch={setSearch} totalItems={totalItems} onCartOpen={()=>setCartOpen(true)} onLogoClick={()=>{setCategory("all");setSearch("");}}/>
        <DealsStrip/>
        <div className="main-layout">
          <Sidebar category={category} onCategory={setCategory} maxPrice={maxPrice} onMaxPrice={setMaxPrice} countFor={countFor}/>
          <ProductGrid products={filtered} cart={cart} search={search} sort={sort} onSortChange={setSort} onAdd={handleAdd} onIncrease={increaseQty} onDecrease={decreaseQty}/>
        </div>
        <footer className="footer">
          <div className="footer-logo">●Cart<span>It</span></div>
          <div className="footer-sub">Fresh groceries · <em>Made in India 🇮🇳</em> · © 2026 CartIt Technologies Pvt. Ltd.</div>
        </footer>
      </div>
      {cartOpen&&<CartDrawer cart={cart} onClose={()=>setCartOpen(false)} onIncrease={increaseQty} onDecrease={decreaseQty} onRemove={handleRemove}/>}
      <Toast message={toast}/>
    </>
  );
}
