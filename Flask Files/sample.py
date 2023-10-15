import pandas as pd

styles_df = pd.read_csv('pak.csv')
color_styles = pd.read_csv('colorStyles.csv')

type = 'Dress Shirts'
category = 'Men'
color = 'Sky Blue'
season = 'Fall'

print(type)
print(category)
print(color)
print(season)
# Define a mapping of product types to corresponding types to find
type_mapping = {
    'T-Shirts': ['Jeans'],
    'Dress Shirts': ['Trousers'],
    'Casual Shirts': ['Jeans', 'Trousers'],
    'Dress Pants': ['Shirts'],
    'Jeans': ['Tshirts'],
    'Shorts': ['Shorts'], 
    'Suits': ['Suits']
}

typeToFind = []  # Initialize the list of types to find
colorsToFind = []  # Initialize the list of colors to find

# Check if the type is in the type_mapping
if type in type_mapping:
    typeToFind.extend(type_mapping[type])
    
print(typeToFind)

shirts = []
pants = []
watches = []
shoes = []
shirt_colors_new = []

pant_colors_new = []

# Search for color in color_styles.csv based on type
if type in ['T-Shirts', 'Dress Shirts', 'Casual Shirts']:
    shirts = color_styles[color_styles['top'] == color]
    watches_colors = shirts['watches']
    watches = watches_colors.tolist()
    shoes_colors = shirts['shoes']
    shoes = shoes_colors.tolist()
    pant_colors = shirts['bottom']
    pant_colors_new = pant_colors.tolist()
    
elif type in ['Dress Pants', 'Jeans', 'Shorts']:
    pants = color_styles[color_styles['bottom'] == color]
    watches_colors = pants['watches']
    watches = watches_colors.tolist()
    shoes_colors = pants['shoes']
    shoes = shoes_colors.tolist() 
    shirt_colors = pants['top']
    shirt_colors_new = shirt_colors.tolist()
            
shoes_links = []
watches_links = []


shoes_links_dict = {}  # Initialize the dictionary for shoes links
watches_links_dict = {}
links_dict = {}
print(shirt_colors_new)# Initialize the dictionary for links
print(pant_colors_new)

if type in ['T-Shirts', 'Dress Shirts', 'Casual Shirts']:
    print('helo')
    print(category, typeToFind, color)
    links = styles_df[
                (styles_df['category'] == category) &
                (styles_df['type'].isin(typeToFind)) &
                (styles_df['color'].isin(pant_colors_new)) &
                (styles_df['season'] == season) 
    ]['imageUrl'].tolist()
    print('helo2')
    print(links)
    # Reset the links_dict for shi  rts
    links_dict = {}

    for color, link in zip(shirts, links):
        if color not in links_dict:
            links_dict[color] = link
    links = list(links_dict.values())  
    print(links)  
    
elif type in ['Dress Pants', 'Jeans', 'Shorts']:
    links = styles_df[
                (styles_df['category'] == category) &
                (styles_df['type'].isin(typeToFind)) &
                (styles_df['color'].isin(shirt_colors_new)) &
                (styles_df['season'] == season) 
    ]['imageUrl'].tolist()
    
    # Reset the links_dict for pants
    links_dict = {}
    
    for color, link in zip(pants, links):
        if color not in links_dict:
            links_dict[color] = link
    links = list(links_dict.values())
    
    

watches_links = styles_df[
    (styles_df['category'] == category) & 
    (styles_df['type'] == 'Watches') & 
    (styles_df['color'].isin(watches)) &
    (styles_df['season'] == season)
]['imageUrl'].tolist()
shoes_links = styles_df[
    (styles_df['category'] == category) & 
    (styles_df['type'] == 'Casual Shoes') & 
    (styles_df['color'].isin(shoes)) &
    (styles_df['season'] == season)
]['imageUrl'].tolist()

# Create dictionaries to store the first link for each color
watches_links_dict = {}
shoes_links_dict = {}

# Iterate through the watches links and store the first link for each color
for color, link in zip(watches, watches_links):
    if color not in watches_links_dict:
        watches_links_dict[color] = link

# Iterate through the shoes links and store the first link for each color
for color, link in zip(shoes, shoes_links):
    if color not in shoes_links_dict:
        shoes_links_dict[color] = link

# Convert the dictionaries to lists
watches_links = list(watches_links_dict.values())
shoes_links = list(shoes_links_dict.values())


n_colors = ['Black', 'White', 'Grey', 'Brown']
if not links:
    for c in n_colors: 
        links_colors = styles_df[(styles_df['category'] == category) &
                        (styles_df['type'].isin(typeToFind)) &
                        (styles_df['color'] == c) &
                        (styles_df['season'] == season)
        ]['imageUrl'].tolist()
        if links_colors: 
            links.append(links_colors[0])

if not watches_links:
    print('In NOt')
    for color in n_colors:
        print(color)
        watches_colors = styles_df[
            (styles_df['category'] == category) & 
            (styles_df['type'] == 'Watches') & 
            (styles_df['color'] == color) 
    ]['imageUrl'].tolist()
    if watches_colors:
        print('heeeeeeeeeeeeelo')
        watches_links.append(watches_colors[0])

if not shoes_links:
    for c in n_colors:
        links_colors = styles_df[
            (styles_df['category'] == category) & 
            (styles_df['type'] == 'Casual Shoes') & 
            (styles_df['color'] == c)
    ]['imageUrl'].tolist()
    if links_colors: 
            shoes_links.append(links_colors[0])          
            
print(shirts)
print(pants)
print(watches_links)
print('--------------------------------------------------------------------------------------------------------------------------------------------------------')
print(shoes_links)
print('-------------------------------------------------------------------------------------------------------------------------------------------')
print(links)

filtered_df = styles_df[styles_df['imageUrl'].isin(watches_links)]
product_list = filtered_df.to_dict(orient='records')

print('----------------------------------------------------------------------------------------------------------------------------------------------')
print(product_list);