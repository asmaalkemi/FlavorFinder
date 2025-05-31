let allRecipes = [];
let currentUser = JSON.parse(localStorage.getItem('currentUser')) || null;
let currentRecipeId;
let activeFilters = new Set();
let searchTimeout;

// DOM Elements
const appView = document.getElementById('appView');
const recipeFullView = document.getElementById('recipeFullView');
const recipeGrid = document.getElementById('recipeGrid');
const searchInput = document.getElementById('searchInput');
const searchBtn = document.getElementById('searchBtn');
const addRecipeBtn = document.getElementById('addRecipeBtn');
const loginBtn = document.getElementById('loginBtn');
const registerBtn = document.getElementById('registerBtn');
const userGreeting = document.getElementById('userGreeting');

// Animation Constants
const TRANSITION_DURATION = 400; // ms

window.searchRecipes = function() {
    const input = document.getElementById('searchInput').value.trim();
    const suggestionsDatalist = document.getElementById('ingredientSuggestions');
    const searchInputElem = document.getElementById('searchInput'); // Get the input element

    if (!input) {
        displayRecipes(allRecipes);
        updateSearchSuggestions([]);
        clearSuggestion(); // Clear any previous suggestion
        return;
    }

    const searchTerms = input.toLowerCase()
        .split(',')
        .map(term => term.trim())
        .filter(term => term);

    let correctedTerms = [];
    let suggestion = ""; // To hold the suggestion message

    searchTerms.forEach(term => {
        const correction = getBestMatch(term, Object.values(ingredientCorrections));
        if (correction) {
            correctedTerms.push(correction.toLowerCase());
            if (correction.toLowerCase() !== term.toLowerCase()) {
                suggestion = `Did you mean "${correction}"?`;
            }
        } else {
            correctedTerms.push(term.toLowerCase());
        }
    });

    // --- Display Suggestion ---
    displaySuggestion(suggestion);

    const filtered = allRecipes.filter(recipe => {
        if (!recipe.ingredients) return false;

        const ingredientsList = recipe.ingredients.toLowerCase().split(',').map(ing => ing.trim());

        return correctedTerms.every(term =>
            ingredientsList.some(ingredient => ingredient.includes(term))
        );
    });

    displayRecipes(filtered.length ? filtered : []);

    if (filtered.length === 0) {
        recipeGrid.innerHTML = `<div class="no-results"><h3>No recipes found</h3><p>Try different ingredients</p></div>`;
    }

    const allIngredients = allRecipes.reduce((acc, recipe) => {
        if (recipe.ingredients) {
            recipe.ingredients.split(',').forEach(ing => {
                const trimmedIng = ing.trim().toLowerCase();
                if (!acc.includes(trimmedIng)) {
                    acc.push(trimmedIng);
                }
            });
        }
        return acc;
    }, []);

    const filteredSuggestions = allIngredients.filter(ingredient =>
        ingredient.startsWith(input.toLowerCase()) && !searchTerms.includes(ingredient)
    );
    updateSearchSuggestions(filteredSuggestions.slice(0, 5));
};


function levenshteinDistance(a, b) {
    if (a.length === 0) return b.length;
    if (b.length === 0) return a.length;

    let matrix = [];
    for (let i = 0; i <= b.length; i++) {
        matrix[i] = [i];
    }
    for (let j = 0; j <= a.length; j++) {
        matrix[0][j] = j;
    }

    for (let i = 1; i <= b.length; i++) {
        for (let j = 1; j <= a.length; j++) {
            if (b.charAt(i - 1) === a.charAt(j - 1)) {
                matrix[i][j] = matrix[i - 1][j - 1];
            } else {
                matrix[i][j] = Math.min(
                    matrix[i - 1][j - 1] + 1,
                    Math.min(matrix[i][j - 1] + 1, matrix[i - 1][j] + 1)
                );
            }
        }
    }
    return matrix[b.length][a.length];
}

function getBestMatch(term, options) {
    let bestMatch = null;
    let lowestDistance = Infinity;

    for (const option of options) {
        const distance = levenshteinDistance(term, option);
        if (distance < lowestDistance && distance < 3) { // Adjust the '3' threshold as needed
            lowestDistance = distance;
            bestMatch = option;
        }
    }

    return bestMatch;
}


function displaySuggestion(suggestionText) {
    let suggestionDiv = document.getElementById('searchSuggestion');
    if (!suggestionDiv) {
        suggestionDiv = document.createElement('div');
        suggestionDiv.id = 'searchSuggestion';
        searchInputElem.parentNode.insertBefore(suggestionDiv, searchInputElem.nextSibling);
    }
    suggestionDiv.textContent = suggestionText;
    suggestionDiv.style.display = suggestionText ? 'block' : 'none';
}

function clearSuggestion() {
    const suggestionDiv = document.getElementById('searchSuggestion');
    if (suggestionDiv) {
        suggestionDiv.textContent = '';
        suggestionDiv.style.display = 'none';
    }
}


const ingredientCorrections = {
    onion: 'onion',
    tomato: 'tomato',
    potato: 'potato',
    chicken: 'chicken',
    beef: 'beef',
    carrot: 'carrot',
    cheese: 'cheese',
};



document.addEventListener('DOMContentLoaded', () => {
   // showLoadingSkeletons();
    loadRecipes();
    checkAuthStatus();
    
    // Enhanced search with debouncing
    searchInput.addEventListener('input', () => {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(window.searchRecipes, 300);
    });
    
    searchBtn.addEventListener('click', window.searchRecipes);
    searchInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') window.searchRecipes();
    });
    
    
    addRecipeBtn.addEventListener('click', showRecipeForm);
    loginBtn.addEventListener('click', () => showModal('loginModal'));
    registerBtn.addEventListener('click', () => showModal('registerModal'));
    
    document.querySelectorAll('.close').forEach(btn => {
        btn.addEventListener('click', () => hideModal(btn.closest('.modal').id));
    });
    
    document.getElementById('loginForm').addEventListener('submit', (e) => {
        e.preventDefault();
        login();
    });
    
    document.getElementById('registerForm').addEventListener('submit', (e) => {
        e.preventDefault();
        register();
    });
    
    document.getElementById('recipeForm').addEventListener('submit', submitRecipe);

    // Image search
//    document.getElementById('imageSearchBtn').addEventListener('click', () => {
     //   document.getElementById('imageUpload').click();
  //  });
    
   
});


async function loadRecipes() {
    try {
        const response = await fetch('get_recipes.php');
        allRecipes = await response.json();
        displayRecipes(allRecipes);
    } catch (error) {
        console.error('Error loading recipes:', error);
        showRecipeErrorState();
    }
}


function showRecipeErrorState() {
    recipeGrid.innerHTML = `
        <div class="error-state">
            <h3>Failed to load recipes</h3>
            <button onclick="loadRecipes()">Try Again</button>
        </div>
    `;
}

function displayRecipes(recipes) {
    recipeGrid.innerHTML = recipes.length 
        ? recipes.map(recipe => `
            <div class="recipe-card" data-id="${recipe.id}">
                <div class="recipe-img" style="background-image: url('${recipe.image || 'placeholder.jpg'}')"></div>
                <div class="recipe-content">
                    <h3>${recipe.name}</h3>
                    <div class="recipe-meta">
                       <span>${calculateTotalTime(recipe.prep_time, recipe.cook_time)} mins</span>
                        <span class="badge">${recipe.difficulty || 'Medium'}</span>
                    </div>
                    <div class="ingredients">
                        ${recipe.ingredients.split(',').slice(0, 4).join(', ')}...
                    </div>
                </div>
            </div>
        `).join('')
        : `<div class="no-results"><h3>No recipes found</h3><p>Try different ingredients</p></div>`;
    
    document.querySelectorAll('.recipe-card').forEach(card => {
        card.addEventListener('click', () => showRecipeDetails(card.dataset.id));
    });
}


async function showRecipeDetails(id) {
    currentRecipeId = id;
    
    // Prepare full view container
    recipeFullView.innerHTML = `
        <div class="loading-spinner">
            <div class="spinner"></div>
            <p>Loading recipe...</p>
        </div>
    `;
    
    // Animate entrance
    appView.style.display = 'none';
    recipeFullView.style.display = 'block';
    setTimeout(() => recipeFullView.classList.add('active'), 10);
    
    try {
        const [recipe, nutrition] = await Promise.all([
            fetch(`get_recipe.php?id=${id}`).then(r => r.json()),
            fetch(`nutrition.php?id=${id}`).then(r => r.json())
        ]);
        
        renderFullRecipeView(recipe, nutrition);
        
    } catch (error) {
        console.error('Error loading recipe:', error);
        showRecipeDetailsErrorState(id);
    }
}

function renderFullRecipeView(recipe, nutrition) {
    recipeFullView.innerHTML = `
        <button id="backBtn" class="back-button">
            <svg width="24" height="24" viewBox="0 0 24 24">
                <path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/>
            </svg>
            Back to Recipes
        </button>
        
        <div class="recipe-hero" style="background-image: url('${recipe.image || 'placeholder.jpg'}')"></div>
        
        <div class="recipe-content">
            <h1>${recipe.name}</h1>
            ${recipe.description ? `<p>${recipe.description}</p>` : ''}
            
            <div class="nutrition-facts">
                <h3>Nutrition Facts</h3>
                <div class="macros">
                    <div data-tooltip="Total calories">
                        <span>${nutrition?.calories || 'N/A'}</span>
                        <small>Calories</small>
                    </div>
                    <div data-tooltip="Protein content">
                        <span>${nutrition?.protein || 'N/A'}g</span>
                        <small>Protein</small>
                    </div>
                    <div data-tooltip="Carbohydrates">
                        <span>${nutrition?.carbs || 'N/A'}g</span>
                        <small>Carbs</small>
                    </div>
                    <div data-tooltip="Fats">
                        <span>${nutrition?.fats || 'N/A'}g</span>
                        <small>Fats</small>
                    </div>
                </div>
                <div class="nutrition-bars">
                    <div class="bar protein" style="width: ${(nutrition?.protein || 0) / 50 * 100}%"></div>
                    <div class="bar carbs" style="width: ${(nutrition?.carbs || 0) / 200 * 100}%"></div>
                    <div class="bar fats" style="width: ${(nutrition?.fats || 0) / 70 * 100}%"></div>
                </div>
            </div>
            
            <div class="details-grid">
                <div class="ingredients-section">
                    <h3>Ingredients</h3>
                    <ul class="ingredients-list">
                        ${recipe.ingredients.split(',').map((ing, i) => `
                            <li>
                                <input type="checkbox" id="ing-${i}">
                                <label for="ing-${i}">${ing.trim()}</label>
                            </li>
                        `).join('')}
                    </ul>
                </div>
                
                <div class="instructions-section">
                    <h3>Instructions</h3>
                    <ol class="instructions-list">
                        ${recipe.instructions.split('\n').filter(step => step.trim()).map(step => `
                            <li>${step.trim()}</li>
                        `).join('')}
                    </ol>
                </div>
            </div>
            
            <div class="interaction-section">
                <div class="rating-widget">
                    <h3>Rate this recipe</h3>
                    <div class="stars">
                        ${[1,2,3,4,5].map(i => `
                            <span class="star" data-value="${i}">★</span>
                        `).join('')}
                    </div>
                </div>
                
                <div class="comment-section">
                    <h3>Comments</h3>
                    <div id="commentsList"></div>
                    <textarea placeholder="Share your thoughts..."></textarea>
                    <button id="submitComment">Post Comment</button>
                </div>
            </div>
        </div>
    `;
    
    // Setup interactive elements
    setupBackButton();
    setupImageZoom();
    setupRatingWidget();
    setupCommentSystem();
    setupIngredientCheckboxes();
}

function showRecipeDetailsErrorState(id) {
    recipeFullView.innerHTML = `
        <div class="error-state">
            <h3>Failed to load recipe</h3>
            <button onclick="showRecipeDetails('${id}')">Try Again</button>
        </div>
    `;
}

// ======================
// INTERACTIVE ELEMENTS
// ======================

function setupBackButton() {
    const backBtn = document.getElementById('backBtn');
    backBtn.addEventListener('click', () => {
        recipeFullView.classList.remove('active');
        setTimeout(() => {
            recipeFullView.style.display = 'none';
            appView.style.display = 'block';
        }, TRANSITION_DURATION);
    });
}

function setupImageZoom() {
    const hero = document.querySelector('.recipe-hero');
    if (!hero) return;
    
    hero.addEventListener('click', () => {
        hero.classList.toggle('zoomed');
        document.body.classList.toggle('no-scroll', hero.classList.contains('zoomed'));
    });
}

function setupRatingWidget() {
    document.querySelectorAll('.star').forEach(star => {
        star.addEventListener('click', async function() {
            const rating = parseInt(this.dataset.value);
            if (currentUser) {
                await submitRating(currentRecipeId, rating);
            } else {
                await submitAnonymousRating(currentRecipeId, rating);
            }
            highlightStars(rating);
        });
        
        star.addEventListener('mouseenter', () => {
            const value = parseInt(star.dataset.value);
            highlightStars(value);
        });
        
        star.addEventListener('mouseleave', () => {
            const currentRating = document.querySelector('.star.active');
            if (!currentRating) return;
            highlightStars(parseInt(currentRating.dataset.value));
        });
    });
}

function highlightStars(upTo) {
    document.querySelectorAll('.star').forEach((star, i) => {
        star.classList.toggle('active', i < upTo);
        star.classList.toggle('hovered', i < upTo);
    });
}

function setupCommentSystem() {
    const submitBtn = document.getElementById('submitComment');
    if (!submitBtn) return;
    
    submitBtn.addEventListener('click', submitComment);
    loadComments();
}

function setupIngredientCheckboxes() {
    document.querySelectorAll('.ingredients-list input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener('change', (e) => {
            const label = e.target.nextElementSibling;
            label.classList.toggle('checked', e.target.checked);
        });
    });
}


async function submitRating(recipeId, rating) {
    try {
        const response = await fetch('rate_recipe.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                recipe_id: recipeId,
                rating: rating,
                user_id: currentUser?.id,
                is_anonymous: false
            })
        });
        
        const result = await response.json();
        if (!result.success) throw new Error(result.message || 'Rating failed');
        
        showAlert('Rating submitted!', 'success');
        return true;
    } catch (error) {
        console.error("Rating failed:", error);
        showAlert(error.message || 'Failed to save rating', 'error');
        return false;
    }
}

async function submitAnonymousRating(recipeId, rating) {
    try {
        const response = await fetch('rate_recipe.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                recipe_id: recipeId,
                rating: rating,
                is_anonymous: true
            })
        });
        
        const result = await response.json();
        if (!result.success) throw new Error(result.message || 'Rating failed');
        
        showAlert('Rating submitted as guest', 'info');
        return true;
    } catch (error) {
        console.error("Anonymous rating failed:", error);
        showAlert(error.message || 'Failed to submit rating', 'error');
        return false;
    }
}


async function submitComment() {
    const commentTextarea = document.querySelector('.comment-section textarea');
    if (!commentTextarea) return;
    
    const text = commentTextarea.value.trim();
    if (!text) {
        showAlert('Please enter a comment', 'error');
        return;
    }

    if (text.length < 5) {
        showAlert('Comment must be at least 5 characters long', 'error');
        return;
    }

    try {
        const response = await fetch('submit_comment.php', {
            method: 'POST',
            headers: { 
                'Content-Type': 'application/json',
                'Accept': 'application/json'
            },
            body: JSON.stringify({
                recipe_id: currentRecipeId,
                user_id: currentUser?.id || null,
                comment: text,
                is_anonymous: !currentUser,
                guest_name: currentUser ? null : 'Anonymous Guest'
            })
        });
        
        // Check if the response is ok
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const result = await response.json();
        console.log('Server response:', result); // Debug log
        
        if (result.success) {
            commentTextarea.value = '';
            showAlert(result.message || 'Comment posted successfully!', 'success');
            loadComments(); // Reload comments to show the new one
        } else {
            throw new Error(result.message || 'Comment submission failed');
        }
    } catch (error) {
        console.error('Comment error:', error);
        showAlert(error.message || 'Failed to post comment', 'error');
    }
}
async function loadComments() {
    try {
        const res = await fetch(`get_comments.php?recipe_id=${currentRecipeId}`);
        const comments = await res.json();
        
        const commentsList = document.getElementById('commentsList');
        if (!commentsList) return;
        
        commentsList.innerHTML = comments.length ? comments.map(comment => `
            <div class="comment ${comment.is_anonymous ? 'anonymous' : ''}">
                <div class="comment-header">
                    <strong>${comment.display_name}</strong>
                    <small>${new Date(comment.created_at).toLocaleString()}</small>
                    ${!comment.is_anonymous && comment.user_id == currentUser?.id ? `
                        <button class="delete-comment" data-id="${comment.id}">×</button>
                    ` : ''}
                </div>
                <p>${comment.comment}</p>
            </div>
        `).join('') : '<p>No comments yet. Be the first to comment!</p>';
        
        
        document.querySelectorAll('.delete-comment').forEach(btn => {
            btn.addEventListener('click', () => deleteComment(btn.dataset.id));
        });
    } catch (error) {
        console.error('Load comments error:', error);
        showAlert('Failed to load comments', 'error');
    }
}

async function deleteComment(commentId) {
    if (!confirm('Are you sure you want to delete this comment?')) return;
    
    try {
        const response = await fetch('delete_comment.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                comment_id: commentId,
                user_id: currentUser.id
            })
        });
        
        const result = await response.json();
        if (result.success) {
            showAlert('Comment deleted', 'success');
            loadComments();
        } else {
            showAlert(result.message || 'Failed to delete comment', 'error');
        }
    } catch (error) {
        console.error('Delete comment error:', error);
        showAlert('Failed to delete comment', 'error');
    }
}

    function checkAuthStatus() {
        if (currentUser) {
            loginBtn.style.display = 'none';
            registerBtn.style.display = 'none';
            userGreeting.style.display = 'flex';
            
            // Add admin link if user is admin
            const adminLink = currentUser.is_admin 
                ? `<a href="admin.php" class="admin-link">Admin Panel</a>` 
                : '';
                
            userGreeting.innerHTML = `
                <span>Hi, ${currentUser.username}</span>
                ${adminLink}
                <button id="logoutBtn">Logout</button>
            `;
            
            addRecipeBtn.style.display = 'flex';
            document.getElementById('logoutBtn').addEventListener('click', logout);
        } else {
            loginBtn.style.display = 'flex';
            registerBtn.style.display = 'flex';
            userGreeting.style.display = 'none';
            addRecipeBtn.style.display = 'none';
        }
    }

async function login() {
    const username = document.getElementById('loginUsername').value.trim();
    const password = document.getElementById('loginPassword').value;
    
    if (!username || !password) {
        showAlert('Please enter both fields', 'error');
        return;
    }

    try {
        const response = await fetch('auth.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'login',
                username,
                password
            }),




            credentials: 'include'
        });
        
        const result = await response.json();
        
        if (result.success) {
            currentUser = result.user;
            localStorage.setItem('currentUser', JSON.stringify(currentUser));
            checkAuthStatus();
            hideModal('loginModal');
            showAlert(`Welcome back, ${username}!`, 'success');
        } else {
            showAlert(result.message || 'Login failed', 'error');
        }
    } catch (error) {
        console.error('Login error:', error);
        showAlert('Network error', 'error');
    }
} 
async function register() {
    const username = document.getElementById('regUsername').value.trim();
    const email = document.getElementById('regEmail').value.trim();
    const password = document.getElementById('regPassword').value;
    
    if (!username || !email || !password) {
        showAlert('Please fill all fields', 'error');
        return;
    }

    try {
        const response = await fetch('auth.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                action: 'register',
                username,
                email,
                password
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            currentUser = result.user;
            localStorage.setItem('currentUser', JSON.stringify(currentUser));
            checkAuthStatus();
            hideModal('registerModal');
            showAlert('Registration successful!', 'success');
        } else {
            showAlert(result.message || 'Registration failed', 'error');
        }
    } catch (error) {
        console.error('Register error:', error);
        showAlert('Network error', 'error');
    }
}

function logout() {
    fetch('session.php', { method: 'DELETE',
         credentials: 'include'
     })
        .then(() => {
            currentUser = null;
            localStorage.removeItem('currentUser');
            checkAuthStatus();
            showAlert('Logged out', 'success');
        })
        .catch(err => {
            console.error('Logout error:', err);
            showAlert('Logout failed', 'error');
        });
}


function showRecipeForm() {
    if (!currentUser) {
        showModal('authModal');
        return;
    }
    
    showModal('recipeFormModal');
}

document.getElementById('recipeForm').addEventListener('submit', async (e) => {
    e.preventDefault(); // Prevent default form submission

    // Check if a user is logged in
    if (!currentUser) {
        showAlert('Please login to submit recipes');
        return;
    }




    try {
        const response = await fetch('submit_recipe.php', {
            method: 'POST',
            body: formData // Directly send the FormData object.
                          // The browser will automatically set the correct
                          // 'Content-Type' header (multipart/form-data).
                          // DO NOT manually set 'Content-Type' here.
        });

        const result = await response.json(); // Assuming your PHP always returns JSON

        if (result.success) {
            showAlert('Recipe added successfully!', 'success');
            hideModal('recipeFormModal'); // Hide the recipe submission modal
            e.target.reset(); // Clear the form fields
            loadRecipes();    // Reload recipes to show the new one
        } else {
            showAlert(result.message || 'Failed to add recipe');
        }
    } catch (error) {
        showAlert('Network error. Please try again.');
        console.error('Recipe submission error:', error);
    }
});


function calculateTotalTime(prepTime, cookTime) {
    const prep = parseInt(prepTime) || 0;
    const cook = parseInt(cookTime) || 0;
    return prep + cook;
}


function showModal(id) {
    const modal = document.getElementById(id);
    modal.style.display = 'block';
    setTimeout(() => modal.classList.add('show'), 10);
}

function hideModal(id) {
    const modal = document.getElementById(id);
    modal.classList.remove('show');
    setTimeout(() => modal.style.display = 'none', 300);
}

window.addEventListener('click', (e) => {
    if (e.target.classList.contains('modal') && !e.target.classList.contains('ingredient-modal')) {
        hideModal(e.target.id);
    }
});




window.showAlert = function(message, type) {
    // Create alert element if it doesn't exist
    let alertEl = document.getElementById('alertBox');
    if (!alertEl) {
        alertEl = document.createElement('div');
        alertEl.id = 'alertBox';
        document.body.appendChild(alertEl);
    }
    
    // Set alert type and message
    alertEl.className = `alert ${type}`;
    alertEl.textContent = message;
    alertEl.style.display = 'block';
    
    // Auto-hide after a few seconds
    setTimeout(() => {
        alertEl.style.opacity = '0';
        setTimeout(() => {
            alertEl.style.display = 'none';
            alertEl.style.opacity = '1';
        }, 500);
    }, 3000);
}; 
