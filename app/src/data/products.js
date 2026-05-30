const B = "https://img.spoonacular.com/ingredients_250x250";
const PRODUCTS = [
  // Sabzi & Fruits
  {id:1,  name:"Aloo (Potatoes)",        cat:"sabzi",    price:35,  unit:"1 kg",    rating:4.7,reviews:12403,badge:"Farm Fresh",  img:`${B}/potatoes-yukon-gold.jpg`, desc:"Premium Agra potatoes for sabzi & fry"},
  {id:2,  name:"Tamatar (Tomatoes)",     cat:"sabzi",    price:28,  unit:"500 g",   rating:4.6,reviews:9812, badge:"Juicy",        img:`${B}/tomato.jpg`,              desc:"Vine-ripened Nashik tomatoes"},
  {id:3,  name:"Palak (Spinach)",        cat:"sabzi",    price:20,  unit:"250 g",   rating:4.8,reviews:6723, badge:"Organic",      img:`${B}/spinach.jpg`,             desc:"Tender farm-cut palak, washed & ready"},
  {id:4,  name:"Pyaaz (Onion)",          cat:"sabzi",    price:42,  unit:"1 kg",    rating:4.5,reviews:15001,badge:null,           img:`${B}/red-onion.jpg`,           desc:"Nasik red onions, low pungency"},
  {id:5,  name:"Dhaniya Patta",          cat:"sabzi",    price:10,  unit:"100 g",   rating:4.9,reviews:4321, badge:"Fresh Cut",    img:`${B}/fresh-coriander.jpg`,     desc:"Fresh coriander leaves, aromatic"},
  {id:6,  name:"Kela (Bananas)",         cat:"sabzi",    price:49,  unit:"dozen",   rating:4.8,reviews:11200,badge:"Popular",      img:`${B}/bananas.jpg`,             desc:"Sweet Robusta bananas from Jalgaon"},
  {id:7,  name:"Aam (Alphonso Mango)",   cat:"sabzi",    price:149, unit:"500 g",   rating:4.9,reviews:8900, badge:"🏆 Premium",   img:`${B}/mango.jpg`,               desc:"GI-tagged Ratnagiri Alphonso mangoes"},
  {id:8,  name:"Adrak (Ginger)",         cat:"sabzi",    price:22,  unit:"200 g",   rating:4.7,reviews:5432, badge:null,           img:`${B}/ginger.jpg`,              desc:"Himachali fresh ginger, full aroma"},
  {id:9,  name:"Lahsun (Garlic)",        cat:"sabzi",    price:18,  unit:"100 g",   rating:4.7,reviews:8743, badge:null,           img:`${B}/garlic.jpg`,              desc:"Fresh garlic bulbs, strong flavour"},
  {id:10, name:"Bhindi (Okra)",          cat:"sabzi",    price:38,  unit:"500 g",   rating:4.5,reviews:4102, badge:null,           img:`${B}/okra.jpg`,                desc:"Tender okra, perfect for sabzi"},
  {id:11, name:"Gajar (Carrots)",        cat:"sabzi",    price:30,  unit:"500 g",   rating:4.7,reviews:6231, badge:"Vitamin A",    img:`${B}/carrots.jpg`,             desc:"Crunchy orange carrots from Punjab"},
  {id:12, name:"Gobhi (Cauliflower)",    cat:"sabzi",    price:45,  unit:"each",    rating:4.6,reviews:5120, badge:null,           img:`${B}/cauliflower.jpg`,         desc:"White firm cauliflower, no spots"},
  {id:13, name:"Seb (Apple)",            cat:"sabzi",    price:120, unit:"1 kg",    rating:4.8,reviews:9340, badge:"Himachali",    img:`${B}/apple.jpg`,               desc:"Crisp Shimla Royal Delicious apples"},
  {id:14, name:"Nimbu (Lemon)",          cat:"sabzi",    price:15,  unit:"6 pcs",   rating:4.7,reviews:11200,badge:null,           img:`${B}/lemon.jpg`,               desc:"Juicy Kagzi lemons, high juice content"},
  // Dairy
  {id:15, name:"Full Cream Milk",        cat:"dairy",    price:68,  unit:"1 litre", rating:4.8,reviews:34000,badge:"Bestseller",   img:`${B}/milk.jpg`,                desc:"Amul full cream milk, India's favourite"},
  {id:16, name:"Fresh Paneer",           cat:"dairy",    price:89,  unit:"200 g",   rating:4.9,reviews:18700,badge:"Soft & Fresh", img:`${B}/mozzarella.jpg`,          desc:"Soft homestyle paneer, same-day made"},
  {id:17, name:"White Butter (Makkhan)", cat:"dairy",    price:55,  unit:"100 g",   rating:4.8,reviews:22100,badge:null,           img:`${B}/butter.jpg`,              desc:"Amul real white butter, unsalted"},
  {id:18, name:"Dahi (Set Curd)",        cat:"dairy",    price:45,  unit:"400 g",   rating:4.7,reviews:14500,badge:"Probiotic",    img:`${B}/plain-yogurt.jpg`,        desc:"Set curd from A2 cow milk"},
  {id:19, name:"Cheese Slices",          cat:"dairy",    price:99,  unit:"200 g",   rating:4.7,reviews:12000,badge:null,           img:`${B}/cheddar-cheese.jpg`,      desc:"Amul processed cheese slices"},
  {id:20, name:"Eggs (Free Range)",      cat:"dairy",    price:95,  unit:"12 pcs",  rating:4.9,reviews:28000,badge:"Free Range",   img:`${B}/egg.jpg`,                 desc:"Brown free-range eggs, protein-rich"},
  // Atta & Rice
  {id:21, name:"Whole Wheat Atta",       cat:"atta",     price:299, unit:"5 kg",    rating:4.9,reviews:56000,badge:"No.1 Brand",   img:`${B}/flour.jpg`,               desc:"Aashirvaad MP gehun atta for daily roti"},
  {id:22, name:"Basmati Rice",           cat:"atta",     price:189, unit:"1 kg",    rating:4.8,reviews:21000,badge:"Aged 2yr",     img:`${B}/rice.jpg`,                desc:"Dehradun basmati, long grain fragrant"},
  {id:23, name:"Rolled Oats",            cat:"atta",     price:149, unit:"500 g",   rating:4.7,reviews:13400,badge:"High Fibre",   img:`${B}/rolled-oats.jpg`,         desc:"Quaker rolled oats for healthy breakfast"},
  {id:24, name:"Sooji (Semolina)",       cat:"atta",     price:48,  unit:"500 g",   rating:4.6,reviews:6200, badge:null,           img:`${B}/semolina.jpg`,            desc:"Fine sooji for halwa & upma"},
  // Masala & Oil
  {id:25, name:"MDH Garam Masala",       cat:"masala",   price:85,  unit:"100 g",   rating:4.9,reviews:43000,badge:"Iconic",       img:`${B}/cardamom.jpg`,            desc:"The original MDH blend since 1919"},
  {id:26, name:"Haldi Powder",           cat:"masala",   price:45,  unit:"200 g",   rating:4.8,reviews:12000,badge:"Pure",         img:`${B}/turmeric.jpg`,            desc:"Erode Lakadong turmeric, 5% curcumin"},
  {id:27, name:"Desi Cow Ghee",          cat:"masala",   price:399, unit:"500 ml",  rating:4.8,reviews:31000,badge:"A2 Cow Ghee",  img:`${B}/ghee.jpg`,                desc:"Patanjali bilona cow ghee, traditional"},
  {id:28, name:"Sunflower Oil",          cat:"masala",   price:175, unit:"1 litre", rating:4.6,reviews:19500,badge:null,           img:`${B}/vegetable-oil.jpg`,       desc:"Fortune lite & healthy sunflower oil"},
  {id:29, name:"Lal Mirchi Powder",      cat:"masala",   price:55,  unit:"200 g",   rating:4.7,reviews:9300, badge:"Kashmiri",     img:`${B}/chili-powder.jpg`,        desc:"Kashmiri red chilli, colour not heat"},
  {id:30, name:"Jeera (Cumin Seeds)",    cat:"masala",   price:40,  unit:"100 g",   rating:4.8,reviews:8900, badge:null,           img:`${B}/cumin.jpg`,               desc:"Whole cumin seeds for tadka & biryani"},
  // Snacks
  {id:31, name:"Haldiram's Bhujia",      cat:"snacks",   price:60,  unit:"150 g",   rating:4.9,reviews:67000,badge:"All-Time Fav", img:`${B}/potato-chips.jpg`,        desc:"The iconic Bikaner sev bhujia"},
  {id:32, name:"Parle-G Biscuits",       cat:"snacks",   price:10,  unit:"82 g",    rating:4.8,reviews:89000,badge:"Classic",      img:`${B}/shortbread-cookies.jpg`,  desc:"World's largest-selling biscuit"},
  {id:33, name:"Lay's Magic Masala",     cat:"snacks",   price:20,  unit:"52 g",    rating:4.7,reviews:45000,badge:"Spicy 🌶️",    img:`${B}/potato-chips.jpg`,        desc:"India's No.1 flavour"},
  {id:34, name:"Roasted Peanuts",        cat:"snacks",   price:45,  unit:"200 g",   rating:4.6,reviews:15000,badge:"High Protein", img:`${B}/peanuts.jpg`,             desc:"Salted roasted peanuts, great snack"},
  {id:35, name:"Dark Chocolate 70%",     cat:"snacks",   price:99,  unit:"80 g",    rating:4.9,reviews:18000,badge:"70% Cocoa",    img:`${B}/dark-chocolate.jpg`,      desc:"Amul 70% dark chocolate"},
  // Beverages
  {id:36, name:"Tata Tea Gold",          cat:"beverages",price:299, unit:"500 g",   rating:4.9,reviews:52000,badge:"Premium",      img:`${B}/tea-bags.jpg`,            desc:"Bold Assam blend for the perfect chai"},
  {id:37, name:"Bru Instant Coffee",     cat:"beverages",price:189, unit:"200 g",   rating:4.7,reviews:23000,badge:null,           img:`${B}/coffee.jpg`,              desc:"Roast & ground South Indian coffee"},
  {id:38, name:"Tropicana Mango",        cat:"beverages",price:99,  unit:"1 litre", rating:4.6,reviews:18000,badge:"No Added Sugar",img:`${B}/orange-juice.jpg`,       desc:"Real mango juice, Alphonso variety"},
  {id:39, name:"Tender Coconut Water",   cat:"beverages",price:45,  unit:"330 ml",  rating:4.8,reviews:9800, badge:"Natural",      img:`${B}/coconut-water.jpg`,       desc:"Fresh tender coconut water, chilled"},
  // Dal & Pulses
  {id:40, name:"Toor Dal (Arhar)",       cat:"pulses",   price:139, unit:"1 kg",    rating:4.8,reviews:22000,badge:"Gujarat Grade", img:`${B}/lentils.jpg`,            desc:"Gujarat premium arhar toor dal"},
  {id:41, name:"Chana Dal",              cat:"pulses",   price:115, unit:"1 kg",    rating:4.7,reviews:14500,badge:null,           img:`${B}/chickpeas.jpg`,           desc:"Split Bengal gram, great for tadka"},
  {id:42, name:"Moong Dal (Dhuli)",      cat:"pulses",   price:129, unit:"1 kg",    rating:4.9,reviews:17800,badge:"Easy Digest",  img:`${B}/mung-beans.jpg`,          desc:"Washed green gram, light & nutritious"},
  {id:43, name:"Rajma (Kashmiri)",       cat:"pulses",   price:169, unit:"1 kg",    rating:4.9,reviews:21000,badge:"Premium",      img:`${B}/kidney-beans.jpg`,        desc:"Small Kashmiri rajma, creamy texture"},
  {id:44, name:"Masoor Dal (Red)",       cat:"pulses",   price:95,  unit:"1 kg",    rating:4.7,reviews:13200,badge:null,           img:`${B}/lentils-red.jpg`,         desc:"Red lentils, quick cook"},
  // Personal Care
  {id:45, name:"Dove Body Wash",         cat:"personal", price:199, unit:"250 ml",  rating:4.8,reviews:19000,badge:"Moisturising", img:`${B}/body-lotion.jpg`,         desc:"Gentle cleansing with ¼ moisturising cream"},
  {id:46, name:"Colgate Strong Teeth",   cat:"personal", price:59,  unit:"200 g",   rating:4.8,reviews:42000,badge:"Enamel Guard", img:`${B}/peppermint.jpg`,          desc:"Strengthens enamel with active calcium"},
  {id:47, name:"Dettol Hand Wash",       cat:"personal", price:99,  unit:"250 ml",  rating:4.9,reviews:38000,badge:"99.9% Germs",  img:`${B}/water.jpg`,               desc:"Original antibacterial liquid hand wash"},
  // Cleaning
  {id:48, name:"Vim Dishwash Bar",       cat:"cleaning", price:35,  unit:"200 g",   rating:4.7,reviews:23000,badge:"Lemon",        img:`${B}/lemon.jpg`,               desc:"Lemon active bar, removes grease fast"},
  {id:49, name:"Surf Excel Matic",       cat:"cleaning", price:299, unit:"1 kg",    rating:4.8,reviews:31000,badge:"Front Load",   img:`${B}/corn-flour.jpg`,          desc:"Front load detergent, tough stain removal"},
  {id:50, name:"Tissue Paper Rolls",     cat:"cleaning", price:199, unit:"6 rolls", rating:4.7,reviews:16000,badge:"Soft 3-ply",   img:`${B}/white-rice-flour.jpg`,    desc:"Soft 3-ply tissue rolls"},
  // Frozen
  {id:51, name:"Amul Vanilla Ice Cream", cat:"frozen",   price:99,  unit:"500 ml",  rating:4.8,reviews:21000,badge:"Creamy",       img:`${B}/vanilla-ice-cream.jpg`,   desc:"Rich creamy vanilla ice cream"},
  {id:52, name:"McCain Crispy Fries",    cat:"frozen",   price:149, unit:"420 g",   rating:4.7,reviews:14000,badge:"Oven Ready",   img:`${B}/french-fries.jpg`,        desc:"Golden crispy potato fries"},
  {id:53, name:"Green Peas (Frozen)",    cat:"frozen",   price:79,  unit:"500 g",   rating:4.6,reviews:8700, badge:"IQF",          img:`${B}/peas.jpg`,                desc:"Individually quick-frozen green peas"},
  {id:54, name:"Maggi 2-Min Noodles",    cat:"frozen",   price:14,  unit:"70 g",    rating:4.9,reviews:98000,badge:"Iconic",       img:`${B}/ramen.jpg`,               desc:"The original masala noodles since 1983"},
  // Bread
  {id:55, name:"Britannia White Bread",  cat:"bread",    price:45,  unit:"400 g",   rating:4.7,reviews:34000,badge:"Fresh Daily",  img:`${B}/white-bread.jpg`,         desc:"Soft white sandwich bread"},
  {id:56, name:"Pav (Dinner Rolls)",     cat:"bread",    price:30,  unit:"6 pcs",   rating:4.8,reviews:22000,badge:"Soft",         img:`${B}/dinner-yeast-rolls.jpg`,  desc:"Soft Mumbai-style pav for bhaji"},
  {id:57, name:"Croissants",             cat:"bread",    price:55,  unit:"2 pcs",   rating:4.6,reviews:9800, badge:"Flaky",        img:`${B}/croissants.jpg`,          desc:"Flaky butter croissants, fresh baked"},
  {id:58, name:"Brown Bread",            cat:"bread",    price:55,  unit:"400 g",   rating:4.7,reviews:18000,badge:"Wholegrain",   img:`${B}/whole-wheat-bread.jpg`,   desc:"Whole wheat brown bread, high fibre"},
];
export default PRODUCTS;
