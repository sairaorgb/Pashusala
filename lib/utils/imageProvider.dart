String getImagePath(String animalType, String breed) {
  // Define a map for animal types and their corresponding breeds with image paths
  const Map<String, Map<String, String>> animalImages = {
    'Cat': {
      'Ragdoll': 'assets/images/pets/cat/ragdoll.jpeg',
      'Persian': 'assets/images/pets/cat/persian.jpeg',
      'Maine coon': 'assets/images/pets/cat/maincoon.jpeg',
      'Siberian': 'assets/images/pets/cat/siberian.jpeg',
    },
    'Dog': {
      'Bulldog': 'assets/images/pets/dog/bulldog.jpeg',
      'Golden Retriever': 'assets/images/pets/dog/goldenRetriever.jpeg',
      'Husky': 'assets/images/pets/dog/husky.jpeg',
      'Pomenarian': 'assets/images/pets/dog/pomenarian.jpeg',
    },
    'Fish': {
      'Clownfish': 'assets/images/pets/fish/clown.jpeg',
      'Goldfish': 'assets/images/pets/fish/goldfish.jpeg',
      'Siamese': 'assets/images/pets/fish/siamese.jpeg',
    },
  };
  if (animalType != '' && breed != '') {
    // Check if the animalType and breed exist in the map
    if (animalImages.containsKey(animalType) &&
        animalImages[animalType]!.containsKey(breed)) {
      return animalImages[animalType]![breed]!;
      // return 'assets/images/logo.png';
    } else {
      // Return a default image path if the type or breed is not found
      return 'assets/images/logo.png';
    }
  } else {
    return 'assets/images/logo.png';
  }
}
