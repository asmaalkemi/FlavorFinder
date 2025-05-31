// Add this with your other DOM elements
const luckyBtn = document.getElementById('luckyBtn');

// Add this with your other event listeners
luckyBtn.addEventListener('click', showRandomRecipe);

function showRandomRecipe() {
  if (allRecipes.length === 0) {
    showAlert('No recipes available', 'error');
    return;
  }
  
  const randomIndex = Math.floor(Math.random() * allRecipes.length);
  const randomRecipe = allRecipes[randomIndex];
  showRecipeDetails(randomRecipe.id);
  
  // Optional animation
  luckyBtn.style.transform = 'rotate(5deg)';
  setTimeout(() => { luckyBtn.style.transform = 'rotate(0)'; }, 300);
}