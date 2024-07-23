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
    'per_page': 200  # Number of species to fetch (adjust as needed)
}

response = requests.get(api_url, params=params)
data = response.json()

# Directory to save images
save_directory = '/content/drive/My Drive/freshwater_species_images_new'
create_directory(save_directory)

latin_names = [
    "Micropterus salmoides",  # Largemouth Bass
    "Micropterus dolomieu",   # Smallmouth Bass
    "Salvelinus fontinalis",  # Brook Trout
    "Oncorhynchus mykiss",    # Rainbow Trout
    "Morone saxatilis",       # Striped Bass
    "Salmo trutta",           # Brown Trout
    "Esox lucius",            # Northern Pike
    "Esox niger",             # Pickerel
    "Pomoxis",                # Croppie (Pomoxis annularis or Pomoxis nigromaculatus)
    "Lepomis",                # Sunfish (genus name; specific species name depends on type)
    "Lepomis macrochirus",    # Bluegill
    "Salvelinus namaycush",   # Lake Trout
    "Acipenser",              # Sturgeon (genus name; specific species name depends on type)
    "Esox masquinongy"        # Muskie
    ]

for name in latin_names:
    # iNaturalist API endpoint for taxa search
    api_url = 'https://api.inaturalist.org/v1/taxa'
    params = {
        'q': name,  # Search query for freshwater species
        'rank': 'species',
        'per_page': 5  # Number of species to fetch (adjust as needed)
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

        # Replace the existing observation fetching code with this:
        page = 1
        max_pages = 5  # Adjust this to control how many pages to fetch
        total_photos = 0
        max_photos = 1000  # Set this to your desired number of photos per species

        while page <= max_pages and total_photos < max_photos:
            params = {
                'taxon_id': species_id,
                'per_page': 200,  # Max allowed per page
                'order_by': 'votes',
                'order': 'desc',
                'page': page
            }
            obs_response = requests.get(observations_url, params=params)
            obs_data = obs_response.json()
            
            for i, observation in enumerate(obs_data['results']):
                if 'photos' in observation and len(observation['photos']) > 0:
                    photo_url = observation['photos'][0]['url'].replace('square', 'large')
                    file_name = f'{species_name}_{total_photos}.jpg'
                    download_image(photo_url, species_directory, file_name)
                    print(f"Downloaded photo {total_photos + 1} for {species_name}")
                    total_photos += 1
                    
                    if total_photos >= max_photos:
                        break
            
            page += 1
            time.sleep(1)  # Be nice to the API

        print(f'Downloaded {total_photos} images for {species_name}')
