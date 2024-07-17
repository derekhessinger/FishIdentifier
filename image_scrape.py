import os
import requests
import time

# Function to create a directory if it doesn't exist
def create_directory(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)

# Function to download an image from a URL and save it to a directory
def download_image(url, save_dir, file_name):
    response = requests.get(url)
    if response.status_code == 200:
        with open(os.path.join(save_dir, file_name), 'wb') as file:
            file.write(response.content)

# iNaturalist API endpoint for taxa search
api_url = 'https://api.inaturalist.org/v1/taxa'
params = {
    'q': 'freshwater fish',  # Search query for freshwater species
    'rank': 'species',
    'per_page': 50  # Number of species to fetch (adjust as needed)
}

response = requests.get(api_url, params=params)
data = response.json()

# Directory to save images
save_directory = 'freshwater_species_images'
create_directory(save_directory)

l = ['Largemouth Bass', 'Smallmouth Bass', 'Brook Trout', 'Rainbow Trout', 'Striped Bass', 'Brown Trout', 'Northern Pike', 'Pickerel', 'Croppie',
    'Sunfish', 'Bluegill', 'Lake Trout', 'Sturgeon', 'Muskie']

for name in l:
    # iNaturalist API endpoint for taxa search
    api_url = 'https://api.inaturalist.org/v1/taxa'
    params = {
        'q': name,  # Search query for freshwater species
        'rank': 'species',
        'per_page': 50  # Number of species to fetch (adjust as needed)
    }

    response = requests.get(api_url, params=params)
    data = response.json()

    super_directory = os.path.join(save_directory, name)
    create_directory(super_directory)

    for species in data['results']:
        time.sleep(1)
        print("Current species: ", species['name'])
        species_name = species['name']
        species_id = species['id']
        
        # Create a directory for each species
        species_directory = os.path.join(super_directory, species_name)
        create_directory(species_directory)
        
        # Fetch observation photos for each species
        observations_url = f'https://api.inaturalist.org/v1/observations'
        params = {
            'taxon_id': species_id,
            'per_page': 500,  # Number of observations to fetch (adjust as needed)
            'order_by': 'votes',  # Order by most voted images
            'order': 'desc'
        }
        
        obs_response = requests.get(observations_url, params=params)
        obs_data = obs_response.json()
        
        for i, observation in enumerate(obs_data['results']):
            if 'photos' in observation and len(observation['photos']) > 0:
                photo_url = observation['photos'][0]['url'].replace('square', 'large')
                download_image(photo_url, species_directory, f'{species_name}_{i}.jpg')
        print("Finished with",  i, "photos")

print('Images downloaded successfully!')
