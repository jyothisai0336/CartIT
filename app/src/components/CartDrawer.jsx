import React, { useState } from "react";
import COUPONS from "../data/coupons";
import "./CartDrawer.css";
const fmtInr = n => n.toLocaleString("en-IN");
const DELIVERY_THRESHOLD = 499;
const DELIVERY_FEE = 40;
export default function CartDrawer({ cart, onClose, onIncrease, onDecrease, onRemove }) {
  const [couponCode, setCouponCode] = useState("");
  const [discount, setDiscount] = useState(0);
  const [couponMsg, setCouponMsg] = useState(null);
  const subtotal   = cart.reduce((s,i)=>s+i.price*i.qty, 0);
  const delivery   = subtotal>=DELIVERY_THRESHOLD ? 0 : DELIVERY_FEE;
  const total      = Math.max(0, subtotal-discount+delivery);
  const totalItems = cart.reduce((s,i)=>s+i.qty, 0);
  function applyCoupon() {
    const code = couponCode.trim().toUpperCase();
    const coupon = COUPONS[code];
    if (!coupon) { setDiscount(0); setCouponMsg({ok:false,msg:"✗ Invalid coupon code"}); return; }
    const saved = coupon.apply(subtotal, cart);
    if (saved===0 && coupon.minOrder>subtotal) { setCouponMsg({ok:false,msg:`✗ Min order ₹${coupon.minOrder} required`}); return; }
    setDiscount(saved);
    setCouponMsg({ok:true, msg:`✓ Saved ₹${fmtInr(saved)}!`});
  }
  return (
    <div className="cart-overlay" onClick={e=>e.target===e.currentTarget&&onClose()}>
      <div className="cart-drawer">
        <div className="drawer-header">
          <div className="drawer-title">🛒 Your Cart <span className="drawer-count">{totalItems} items</span></div>
          <button className="btn-close" onClick={onClose}>✕</button>
        </div>
        <div className="drawer-items">
          {cart.length===0
            ?<div className="cart-empty"><div className="empty-emoji">🛒</div><h3>Khaali hai abhi!</h3><p>Add some fresh groceries to get started!</p></div>
            :cart.map(item=>(
              <div className="cart-item" key={item.id}>
                <img className="cart-item-img" src={item.img} alt={item.name} onError={e=>e.target.src=`https://placehold.co/52x52/0a2010/4ade80?text=?`}/>
                <div className="cart-item-info">
                  <div className="cart-item-name">{item.name}</div>
                  <div className="cart-item-unit">{item.unit}</div>
                  <div className="cart-item-price">{fmtInr(item.price*item.qty)}</div>
                </div>
                <div className="cart-item-actions">
                  <button className="btn-remove" onClick={()=>onRemove(item.id)}>🗑</button>
                  <div className="qty-control">
                    <button className="qty-btn" onClick={()=>onDecrease(item.id)}>−</button>
                    <span className="qty-num">{item.qty}</span>
                    <button className="qty-btn" onClick={()=>onIncrease(item.id)}>+</button>
                  </div>
                </div>
              </div>
            ))
          }
        </div>
        {cart.length>0&&(
          <div className="drawer-footer">
            <div className="coupon-row">
              <input className="coupon-input" placeholder="Coupon (SABZI50, MASALA20…)" value={couponCode} onChange={e=>setCouponCode(e.target.value)} onKeyDown={e=>e.key==="Enter"&&applyCoupon()}/>
              <button className="btn-apply" onClick={applyCoupon}>Apply</button>
            </div>
            {couponMsg&&<div className="coupon-msg" style={{color:couponMsg.ok?"#4ade80":"#ff6b6b"}}>{couponMsg.msg}</div>}
            <div className="summary">
              <div className="summary-row"><span>Subtotal</span><span>₹{fmtInr(subtotal)}</span></div>
              {discount>0&&<div className="summary-row summary-row--discount"><span>🎉 Discount</span><span>−₹{fmtInr(discount)}</span></div>}
              <div className="summary-row"><span>Delivery</span><span>{delivery===0?<span className="free-tag">FREE ✓</span>:`₹${delivery}`}</span></div>
              {delivery>0&&<div className="free-hint">Add <span>₹{fmtInr(DELIVERY_THRESHOLD-subtotal)}</span> more for free delivery</div>}
              <div className="summary-row summary-row--total"><span>Total</span><span>₹{fmtInr(total)}</span></div>
            </div>
            <button className="btn-checkout">🔒 &nbsp;Secure Checkout — ₹{fmtInr(total)}</button>
          </div>
        )}
      </div>
    </div>
  );
}
