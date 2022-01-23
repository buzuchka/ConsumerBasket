import 'dart:math';

const List<String> shopNames = [
  "Pyaterochka",
  "Diksi",
  "Perekrestok",
  "Ashan",
  "Viktoria",
  "K&B",
  "Vkusvill",
  "Billa",
  "Metro",
  "Vinlab",
  "Lenta",
  "4 Lapi",
  "Ozon",
  "Wildberries",
  "Yandex.Market"
];

int shopName = 0;

const List<String> goodsNames = [
  "Bacon",
  "Beef",
  "Chicken",
  "Duck",
  "Ham",
  "Lamb",
  "Liver",
  "Meat",
  "Mutton",
  "Ox Tongue",
  "Poultry",
  "Sausage",
  "Tenderloin",
  "Turkey",
  "Veal",
  "Venison",
  "Cod",
  "Eel",
  "Grouper",
  "Herring",
  "Mackerel",
  "Pike",
  "Pikeperch",
  "Plaice",
  "Salmon",
  "Sardines",
  "Sole",
  "Sturgeon",
  "Trout",
  "Asparagus",
  "Avocado",
  "Bean Sprout",
  "Beans",
  "Beet",
  "Broccoli",
  "Brussels Sprout",
  "Cabbage",
  "Carrot",
  "Cauliflower",
  "Chard",
  "Chick Pea",
  "Cucumber",
  "Eggplant",
  "Aubergine",
  "Garlic",
  "Kohlrabi",
  "Leek",
  "Lentils",
  "Onion",
  "Pea",
  "Pepper",
  "Potato",
  "Scallion",
  "Spinach",
  "Pumpkin",
  "Squash",
  "Sweet Potato",
  "Turnip",
  "Zucchini",
  "Almond",
  "Apple",
  "Apricot",
  "Banana",
  "Berry",
  "Blackberry",
  "Blueberry",
  "Brazil Nut",
  "Cashew",
  "Cherry",
  "Cranberry",
  "Grape",
  "Grapefruit",
  "Hazelnut",
  "Lemon",
  "Lime",
  "Macadamia",
  "Melon",
  "Orange",
  "Peach",
  "Peanut",
  "Pear",
  "Pecan",
  "Pineapple",
  "Pistachio",
  "Plum",
  "Raspberry",
  "Strawberry",
  "Mandarin",
  "Walnut",
  "Watermelon",
  "Barley",
  "Buckwheat",
  "Grain",
  "Lentil",
  "Pea",
  "Pearl Barley",
  "Rice",
  "Semolina, Manna Groats",
  "Wheat",
  "Butter",
  "Cheese",
  "Condensed Milk",
  "Cottage Cheese",
  "Cream",
  "Cultured Milk Foods",
  "Dried Milk",
  "Eggs",
  "Ice Cream",
  "Kefir",
  "Lactose",
  "Milk",
  "Milk Shake",
  "Sheep Cheese",
  "Sour Cream",
  "Whey",
  "Yogurt",
  "Bagel",
  "Biscuit",
  "Cookie",
  "Box Of Chocolates",
  "Bun",
  "Roll",
  "Butterscotch",
  "Toffee",
  "Cake",
  "Sweet",
  "Candy",
  "Candy Bar",
  "Caramel",
  "Carrot Cake",
  "Cheesecake",
  "Chewing Gum",
  "Chocolate",
  "Chocolate Bar",
  "Cinnamon",
  "Cinnamon Roll",
  "Cracker",
  "Croissant",
  "Cupcake",
  "Custard",
  "Danish Pastry",
  "Dessert",
  "Flan",
  "Fritter",
  "Frosting",
  "Frozen Yogurt",
  "Gelato, Ice Cream",
  "Gingerbread",
  "Granola",
  "Honey",
  "Jam",
  "Jelly",
  "Lollipop",
  "Maple Syrup",
  "Marmalade",
  "Marshmallow",
  "Muffin",
  "Nougat",
  "Oatmeal Cookie",
  "Pancake",
  "Peanut Butter",
  "Popcorn",
  "Canned Fruit",
  "Pretzel",
  "Pudding",
  "Pumpkin Pie",
  "Sponge Cake",
  "Strudel",
  "Sugar",
  "Toffee",
  "Vanilla",
  "Waffle",
  "Coffee",
  "Juice",
  "Carbonated Water",
  "Sparkling Water",
  "Club Soda",
  "Cream",
  "Hot Chocolate",
  "Iced Tea",
  "Lemonade",
  "Milkshake",
  "Mineral Water",
  "Root Beer",
  "Soda",
  "Soft Drink",
  "Still Water",
  "Tea",
  "Water",
  "Red Wine",
  "White Wine",
  "Rose Wine",
  "Cooler",
  "Beer",
  "Bourbon Whiskey",
  "Champagne",
  "Sparkling Wine",
  "Cocktail",
  "Eggnog",
  "Liqueur",
  "Mulled Wine",
  "Scotch Whiskey",
  "Caffeine Free",
  "Decaf",
  "Diet",
  "Fat Free",
  "Lean",
  "Light",
  "Low Cholesterol",
  "Low Fat",
  "No Preservatives",
  "Cutlet",
  "Bacon And Eggs",
  "Baked Potatoes",
  "Jacket Potatoes",
  "Boiled Rice",
  "Burger",
  "Eggs Over Easy",
  "French Fries",
  "Fried Eggs",
  "Eggs Sunny Side Up",
  "Fried Rice",
  "Grill",
  "Goulash",
  "Hash Browns",
  "Hash Brown Potatoes",
  "Potato Pancakes",
  "Hot Dog",
  "Lasagne",
  "Mashed Potatoes",
  "Noodles",
  "Omelette",
  "Scrambled Eggs",
  "Onion Rings",
  "Pasta",
  "Pizza",
  "Poached Eggs",
  "Porridge",
  "Roast",
  "Roast Goose",
  "Roasted Vegetables",
  "Sandwich",
  "Salad",
  "Soup",
  "Spaghetti Bolognese",
  "Stew",
  "Sirloin Steak",
  "Spare Ribs",
  "Steak",
  "Tempura",
];


const List<String> prefixes = [
  "Super",
  "Mega",
  "Ultra",
  "Extra",
  "Giga",
  "Fantastic",
  "Luxury",
  "VIP",
  "Alternative",
  "Secret",
];

const List<String> postfixes = [
  "[in bottle]",
  "[in box]",
  "[2 in 1]",
  "2000",
  "(alcohol free)",
  "x2",
  "x3",
];



int increaseIndex(List list, int index, [int indexStart = 0]){
  index += 1;
  if(index >= list.length) {
    index = indexStart;
  }
  return index;
}


// List<int> shopsPrefixIndex = [];

bool increasePrefixIndex(List<int> prefixIndex, [int level = 0]){

  if(level >= prefixIndex.length){
    prefixIndex.add(0);
    return false;
  }
  prefixIndex[level] += 1;
  if(prefixIndex[level] >= prefixes.length){
    prefixIndex[level] = 0;
    increasePrefixIndex(prefixIndex, level+1);
    return false;
  }
  return true;
}

String getPrefix(List<int> prefixIndexes){
  List<String> prefixList = [];
  for(var prefixIndex in prefixIndexes){
    prefixList.add(prefixes[prefixIndex]);
  }
  return prefixList.join(" ");
}

String getPostfix(int index){
  if(index != -1){
    return postfixes[index];
  }
  return "";
}


Iterable<String> generateGoodsNames(int length) sync* {
  int currentGoodsIndex = 0;
  List<int> goodsPrefixIndex = [];
  int goodsPostfixIndex = -1;

  while(length > 0 ) {
    length -= 1;

    String prefix = getPrefix(goodsPrefixIndex);
    String name = goodsNames[currentGoodsIndex];
    String postfix = getPostfix(goodsPostfixIndex);

    currentGoodsIndex = increaseIndex(goodsNames, currentGoodsIndex);
    if (currentGoodsIndex == 0) {
      goodsPostfixIndex = increaseIndex(postfixes, goodsPostfixIndex, -1);
      if (goodsPostfixIndex == -1) {
        increasePrefixIndex(goodsPrefixIndex);
      }
    }
    yield "$prefix $name $postfix";
  }
}

Iterable<String> generateShopNames(int length) sync* {
  int currentShopIndex = 0;
  List<int> shopPrefixIndex = [];

  while(length > 0 ) {
    length -= 1;

    String prefix = getPrefix(shopPrefixIndex);
    String name = shopNames[currentShopIndex];

    currentShopIndex = increaseIndex(shopNames, currentShopIndex);
    if(currentShopIndex == 0) {
      increasePrefixIndex(shopPrefixIndex);
    }
    yield "$prefix $name";
  }
}


int getRandomInt(int min, int max){
  if(max <= min){
    return min;
  }
  var random = Random();
  return min + random.nextInt(max-min);
}

Iterable<T> generateRandomSequence<T>(List<T> collection, int minLength, [int? maxLength]) sync*{
  maxLength ??= minLength;
  var random = Random();

  var length = getRandomInt(minLength, maxLength);

  while(length >0){
    length --;
    yield collection[random.nextInt(collection.length)];
  }
}

