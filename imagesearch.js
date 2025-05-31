document.addEventListener('DOMContentLoaded', () => {
    const imageSearchBtn = document.getElementById('imageSearchBtn');
    const imageUpload = document.getElementById('imageUpload');
    const searchBtn = document.getElementById('searchBtn');

    imageSearchBtn.addEventListener('click', () => imageUpload.click());
    
    imageUpload.addEventListener('change', async (e) => {
        const file = e.target.files[0];
        if (!file) return;
        
        // Visual feedback
        const originalText = searchBtn.textContent;
        searchBtn.textContent = "Processing...";
        searchBtn.disabled = true;
        
        try {
            const fileName = file.name.toLowerCase();
            
            // Get recipes (using your existing function)
            const recipes = await fetchRecipes(); 
            
            // Find matches
            const matches = recipes.filter(recipe => {
                if (!recipe.image) return false;
                const recipeImageName = recipe.image.split('/').pop().toLowerCase();
                return recipeImageName.includes(fileName.split('.')[0]);
            });
            
            // Display results
            if (matches.length > 0) {
                displayRecipes(matches); // Use your existing function
                showAlert(`Found ${matches.length} matches`, 'success');
            } else {
                showAlert('No matches found', 'info');
            }
        } catch (error) {
            console.error("Search error:", error);
            showAlert('Search failed', 'error');
        } finally {
            searchBtn.textContent = originalText;
            searchBtn.disabled = false;
            e.target.value = '';
        }
    });
    
    async function fetchRecipes() {
        try {
            const response = await fetch('get_recipes.php');
            return await response.json();
        } catch (error) {
            console.error("Failed to fetch recipes:", error);
            return [];
        }
    }
});