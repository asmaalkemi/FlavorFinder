// filters.js
document.addEventListener('DOMContentLoaded', () => {
    const filterBtns = document.querySelectorAll('.filter-btn');
    
    filterBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        // Toggle active state
        btn.classList.toggle('active');
        
        // Get all active filters
        const activeFilters = Array.from(document.querySelectorAll('.filter-btn.active'))
          .map(b => b.dataset.filter);
        
        // Apply filters
        filterRecipes(activeFilters);
      });
    });
  });
  
  function filterRecipes(activeFilters) {
    const recipeCards = document.querySelectorAll('.recipe-card');
    
    recipeCards.forEach(card => {
      const matchesAll = activeFilters.every(filter => {
        // Check each filter type
        if (filter === 'quick') {
          const timeText = card.querySelector('.recipe-meta span').textContent;
          const totalTime = parseInt(timeText) || 0;
          return totalTime < 20;
        }
        else if (filter === 'veg') {
          const ingredients = card.querySelector('.ingredients').textContent.toLowerCase();
          return !ingredients.includes('chicken') && 
                 !ingredients.includes('beef') && 
                 !ingredients.includes('fish');
        }
        else if (filter === 'protein') {
          const ingredients = card.querySelector('.ingredients').textContent.toLowerCase();
          return ingredients.includes('chicken') || 
                 ingredients.includes('eggs') || 
                 ingredients.includes('beans');
        }
        else if (filter === 'gluten-free') { // NEW GLUTEN-FREE LOGIC
          const ingredients = card.querySelector('.ingredients').textContent.toLowerCase();
          // This is a basic check. You'd ideally have a more comprehensive list of gluten-containing ingredients.
          const glutenIngredients = ['wheat', 'barley', 'rye', 'flour', 'bread', 'pasta', 'soy sauce']; 
          return !glutenIngredients.some(glutenIng => ingredients.includes(glutenIng));
        }
        return true;
      });
      
      card.style.display = matchesAll ? 'block' : 'none';
    });
  }