const COUPONS = {
  SABZI50: {
    description: "₹50 off on Sabzi above ₹199",
    apply: (subtotal) => (subtotal >= 199 ? 50 : 0),
    minOrder: 199,
  },
  DAIRY3: {
    description: "Free cheapest item on 2+ dairy products",
    apply: (_subtotal, cart) => {
      const dairy = cart.filter((i) => i.cat === "dairy");
      if (dairy.length >= 2) {
        const cheapest = [...dairy].sort((a, b) => a.price - b.price)[0];
        return cheapest ? cheapest.price : 0;
      }
      return 0;
    },
    minOrder: 0,
  },
  MASALA20: {
    description: "20% off entire order",
    apply: (subtotal) => Math.round(subtotal * 0.2),
    minOrder: 0,
  },
};
export default COUPONS;
