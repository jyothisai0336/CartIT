const BASE_IMG = "https://img.spoonacular.com/ingredients_250x250";
const DEALS = [
  { id:1, title:"Sabzi Saver",   desc:"Flat ₹50 off on Sabzi above ₹199",  bg:"linear-gradient(135deg,#0f4d1e,#1a8f3c)", img:`${BASE_IMG}/spinach.jpg`,  code:"SABZI50"  },
  { id:2, title:"Dairy Dhamaka", desc:"Buy 2 get 1 free on all Dairy",      bg:"linear-gradient(135deg,#1a2f6b,#2166c4)", img:`${BASE_IMG}/milk.jpg`,     code:"DAIRY3"   },
  { id:3, title:"Masala Magic",  desc:"20% off on all Masala & Spices",     bg:"linear-gradient(135deg,#6b1a00,#d94500)", img:`${BASE_IMG}/turmeric.jpg`, code:"MASALA20" },
];
export default DEALS;
