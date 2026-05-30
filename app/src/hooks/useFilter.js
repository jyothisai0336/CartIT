import { useState, useMemo } from "react";
import PRODUCTS from "../data/products";
export default function useFilter() {
  const [category, setCategory] = useState("all");
  const [search,   setSearch]   = useState("");
  const [sort,     setSort]     = useState("popular");
  const [maxPrice, setMaxPrice] = useState(400);
  const filtered = useMemo(() => {
    let list = PRODUCTS.filter(p => {
      const mCat   = category==="all"||p.cat===category;
      const mSearch= p.name.toLowerCase().includes(search.toLowerCase())||p.desc.toLowerCase().includes(search.toLowerCase());
      const mPrice = p.price<=maxPrice;
      return mCat&&mSearch&&mPrice;
    });
    switch(sort) {
      case "price-asc":  return [...list].sort((a,b)=>a.price-b.price);
      case "price-desc": return [...list].sort((a,b)=>b.price-a.price);
      case "rating":     return [...list].sort((a,b)=>b.rating-a.rating);
      default:           return [...list].sort((a,b)=>b.reviews-a.reviews);
    }
  }, [category, search, sort, maxPrice]);
  const countFor = (id) => id==="all"?PRODUCTS.length:PRODUCTS.filter(p=>p.cat===id).length;
  return { category, setCategory, search, setSearch, sort, setSort, maxPrice, setMaxPrice, filtered, countFor };
}
