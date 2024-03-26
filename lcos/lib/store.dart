String? email;
var blogPost = [];

List<bool> isChecked = [false, false, false];

int tsk1 = 0;
int tsk2 = 0;
int bonu = 0;

Map<String, dynamic> dailyTasks = {
};

Map<String, String> activitydesc = {
  "travel":
      "The transportation sector is one of the largest contributors to anthropogenic U.S. greenhouse gas (GHG) emissions. According to the Inventory of U.S. Greenhouse Gas Emissions and Sinks 1990–2021 (the national inventory that the U.S. prepares annually under the United Nations Framework Convention on Climate Change), transportation accounted for the largest portion (29%) of total U.S. GHG emissions in 2021.",
  "food":
      "Food accounts for 10-30% of a household’s carbon footprint, typically a higher portion in lower-income households. Meat products have larger carbon footprints per calorie than grain or vegetable",
  "shopping":
      "A study suggested that, online shopping tends to generate fewer carbon dioxide (CO2) emissions. A long-lasting investment looks like it has high emissions, even though it balances up over time",
  "fuel":
      "Greenhouse gas emissions from transportation primarily come from burning fossil fuel for our cars, trucks, ships, trains, and planes. Over 90% of the fuel used for transportation is petroleum based"
};

Map<String, String> activityAvatar = {
  "travel": "assets/lottie/car.json",
  "food": "assets/lottie/food.json",
  "shopping": "assets/lottie/shopping.json",
  "fuel": "assets/lottie/fuel.json"
};

Map<String, List<String>> dayWise = {
  "travel": [
    'Try car pooling',
    'Use public transport',
    'Try Cycling to workplace',
    'Maintainece of vehicle',
    'Use Natural Gas resources',
    'Use 2-wheeler while travelling solo',
    'Try work from home'
  ],
  "food": [
    'Reduce your food waste',
    'Reduce meat consumption',
    'Try organic food',
    'Replace meat with vegan',
    'Share your food',
    'Try home organic farming',
    'Spread awareness to others',
  ],
  "shopping": [
    'Look for eco evidence',
    'Shop local',
    'Practice patience with delivery',
    'Avoid the returns trap',
    'Repair Over Replace',
    'Buy Refurbished',
    'Avoid Same-Day Delivery',
  ],
  "fuel": [
    'Pick the least-polluting, most efficient vehicle that meets your needs',
    'Electric vehicles (EVs) offer a low-carbon alternative',
    'Biking and Walking',
    'Public Transportation',
    'Vehicle maintaince',
    'Less frequent air travels',
    'Having Petrol partner',
  ]
};
