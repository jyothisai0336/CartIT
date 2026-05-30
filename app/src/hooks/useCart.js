import { useState, useCallback } from "react";
export default function useCart() {
  const [cart, setCart] = useState([]);
  const addItem     = useCallback((p) => setCart(prev => { const ex=prev.find(i=>i.id===p.id); return ex?prev.map(i=>i.id===p.id?{...i,qty:i.qty+1}:i):[...prev,{...p,qty:1}]; }), []);
  const increaseQty = useCallback((id) => setCart(prev => prev.map(i=>i.id===id?{...i,qty:i.qty+1}:i)), []);
  const decreaseQty = useCallback((id) => setCart(prev => { const it=prev.find(i=>i.id===id); return it.qty===1?prev.filter(i=>i.id!==id):prev.map(i=>i.id===id?{...i,qty:i.qty-1}:i); }), []);
  const removeItem  = useCallback((id) => setCart(prev => prev.filter(i=>i.id!==id)), []);
  const clearCart   = useCallback(() => setCart([]), []);
  const totalItems  = cart.reduce((s,i)=>s+i.qty, 0);
  const subtotal    = cart.reduce((s,i)=>s+i.price*i.qty, 0);
  return { cart, totalItems, subtotal, addItem, increaseQty, decreaseQty, removeItem, clearCart };
}
