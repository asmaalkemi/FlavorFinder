// Recipe Validation Script with Enhanced ML Features
class RecipeValidator {
    constructor() {
        this.model = null;
        this.initialized = false;
        this.featureNames = [
            'ingredient_count',
            'instruction_count',
            'avg_ingredient_length',
            'avg_instruction_length',
            'has_verbs',
            'has_measurements',
            'has_temperature',
            'has_time',
            'ingredient_instruction_ratio',
            'name_presence'
        ];
    }

    async init() {
        if (this.initialized) return true;
        
        try {
            console.log("Loading recipe validation model...");
            
            // 1. Load pre-trained model (if available)
            try {
                const modelUrl = 'model/recipe_model/model.json';
                this.model = await tf.loadLayersModel(modelUrl);
                console.log("Loaded pre-trained model");
            } catch (e) {
                console.log("No pre-trained model found, creating new one");
                this.model = this.createModel();
                await this.trainWithSampleData();
            }

            this.initialized = true;
            return true;
        } catch (error) {
            console.error("Model initialization failed:", error);
            return false;
        }
    }

    createModel() {
        const model = tf.sequential();
        
        model.add(tf.layers.dense({
            inputShape: [this.featureNames.length],
            units: 32,
            activation: 'relu'
        }));
        
        model.add(tf.layers.dropout({rate: 0.2}));
        
        model.add(tf.layers.dense({
            units: 16,
            activation: 'relu'
        }));
        
        model.add(tf.layers.dense({
            units: 1,
            activation: 'sigmoid'
        }));
        
        model.compile({
            optimizer: tf.train.adam(0.001),
            loss: 'binaryCrossentropy',
            metrics: ['accuracy']
        });
        
        return model;
    }

    async trainWithSampleData() {
        // Enhanced sample data
        const sampleData = this.generateSampleData(100); // 100 samples
        
        const xs = tf.tensor2d(sampleData.map(d => d.features));
        const ys = tf.tensor2d(sampleData.map(d => [d.isValid]));
        
        await this.model.fit(xs, ys, {
            epochs: 50,
            batchSize: 8,
            validationSplit: 0.2,
            callbacks: {
                onEpochEnd: (epoch, logs) => {
                    console.log(`Epoch ${epoch}: loss = ${logs.loss.toFixed(4)}`);
                }
            }
        });
    }

    generateSampleData(count) {
        const data = [];
        const cookingVerbs = ['mix', 'stir', 'bake', 'fry', 'boil', 'grill', 'chop'];
        const measurements = ['cup', 'tbsp', 'tsp', 'gram', 'kg', 'lb'];
        
        // Generate valid recipes
        for (let i = 0; i < count/2; i++) {
            const ingredientCount = Math.floor(Math.random() * 15) + 5;
            const instructionCount = Math.floor(Math.random() * 10) + 3;
            
            data.push({
                features: [
                    ingredientCount / 20,
                    instructionCount / 15,
                    (Math.random() * 5) + 3, // avg ingredient length
                    (Math.random() * 50) + 20, // avg instruction length
                    1, // has verbs
                    1, // has measurements
                    Math.random() > 0.3 ? 1 : 0, // has temp
                    Math.random() > 0.3 ? 1 : 0, // has time
                    (ingredientCount / instructionCount) / 5,
                    0.8 + Math.random() * 0.2 // name presence
                ],
                isValid: 1
            });
        }
        
        // Generate invalid recipes
        for (let i = 0; i < count/2; i++) {
            const ingredientCount = Math.floor(Math.random() * 3) + 1;
            const instructionCount = Math.floor(Math.random() * 2) + 1;
            
            data.push({
                features: [
                    ingredientCount / 20,
                    instructionCount / 15,
                    (Math.random() * 3) + 1,
                    (Math.random() * 10) + 5,
                    Math.random() > 0.7 ? 1 : 0,
                    Math.random() > 0.7 ? 1 : 0,
                    0,
                    0,
                    (ingredientCount / instructionCount) / 5,
                    Math.random() * 0.3
                ],
                isValid: 0
            });
        }
        
        return data;
    }

    async validateRecipe(recipeId) {
        console.log(">>> validateRecipe called for ID:", recipeId);
        try {
            // 1. Initialize if needed
            if (!this.initialized) {
                const success = await this.init();
                if (!success) throw new Error("Model initialization failed");
            }
            
            // 2. Fetch recipe data
            const response = await fetch(`validate_recipe_ml.php?id=${recipeId}`);
            const data = await response.json();
            if (!data.success) throw new Error(data.message);
            
            // 3. Extract features
            const features = this.extractFeatures(data.recipe);
            const inputTensor = tf.tensor2d([features]);
            
            // 4. Make prediction
            const prediction = await this.model.predict(inputTensor).data();
            const score = Math.round(prediction[0] * 100);
            
            // 5. Generate recommendation
            const recommendation = this.generateRecommendation(score, features);
            
            return {
                success: true,
                score: score,
                recommendation: recommendation,
                features: this.formatFeatures(features)
            };
            console.log(">>> Returning from validateRecipe:", { success: true, score: score, recommendation: recommendation, features: this.formatFeatures(features) }); // NEW LINE  
        } catch (error) {
            console.error("Validation error:", error);
            return {
                success: false,
                message: error.message
            };
            console.log(">>> Error returning from validateRecipe:", { success: false, message: error.message });
        }
    }

    extractFeatures(recipe) {
        const ingredients = recipe.ingredients.split(',').map(i => i.trim()).filter(i => i);
        const instructions = recipe.instructions.split('\n').map(i => i.trim()).filter(i => i);
        
        // Feature calculations
        const ingredientCount = Math.min(ingredients.length, 20);
        const instructionCount = Math.min(instructions.length, 15);
        const avgIngredientLength = ingredients.reduce((sum, ing) => sum + ing.length, 0) / ingredientCount;
        const avgInstructionLength = instructions.reduce((sum, inst) => sum + inst.length, 0) / instructionCount;
        
        // Check for important elements
        const cookingVerbs = ['mix', 'stir', 'bake', 'fry', 'boil', 'grill', 'chop'];
        const hasVerbs = cookingVerbs.some(verb => 
            recipe.instructions.toLowerCase().includes(verb)) ? 1 : 0;
        
        const measurements = ['cup', 'tbsp', 'tsp', 'gram', 'kg', 'lb', 'ounce'];
        const hasMeasurements = measurements.some(measure => 
            recipe.ingredients.toLowerCase().includes(measure)) ? 1 : 0;
        
        const hasTemperature = /(\d+\s*°[CF]|degrees|fahrenheit|celsius)/i.test(recipe.instructions) ? 1 : 0;
        const hasTime = /\d+\s*(min|minute|hour|sec)/i.test(recipe.instructions) ? 1 : 0;
        
        // Calculate ratios and presence
        const ingInstructRatio = ingredientCount / Math.max(1, instructionCount);
        const namePresence = recipe.name && (
            recipe.ingredients.toLowerCase().includes(recipe.name.toLowerCase()) || 
            recipe.instructions.toLowerCase().includes(recipe.name.toLowerCase())
        ) ? 1 : 0.5;
        
        // Return normalized features
        return [
            ingredientCount / 20,
            instructionCount / 15,
            Math.min(avgIngredientLength, 50) / 50,
            Math.min(avgInstructionLength, 200) / 200,
            hasVerbs,
            hasMeasurements,
            hasTemperature,
            hasTime,
            Math.min(ingInstructRatio, 5) / 5,
            namePresence
        ];
    }

    generateRecommendation(score, features) {
        if (score > 85) return "Excellent recipe structure";
        if (score > 70) return "Good recipe, could use minor improvements";
        if (score > 50) return "Needs work - check instructions and measurements";
        
        // Specific feedback based on weak features
        const weakPoints = [];
        if (features[4] < 0.5) weakPoints.push("add more cooking verbs");
        if (features[5] < 0.5) weakPoints.push("include measurements");
        if (features[1] < 0.3) weakPoints.push("add more instructions");
        if (features[0] < 0.3) weakPoints.push("include more ingredients");
        
        return weakPoints.length > 0 
            ? `Needs significant work: ${weakPoints.join(', ')}`
            : "Doesn't appear to be a valid recipe";
    }

    formatFeatures(features) {
        return this.featureNames.reduce((obj, name, i) => {
            obj[name] = features[i];
            return obj;
        }, {});
    }
}

// Initialize singleton validator
const recipeValidator = new RecipeValidator();

// Admin page integration
async function validateRecipeML(id) {
    const resultSpan = document.getElementById(`ml-result-${id}`);
    resultSpan.textContent = 'Analyzing...';
    
    try {
        await tf.ready();
        const result = await recipeValidator.validateRecipe(id);
        
        if (result.success) {
            resultSpan.innerHTML = `
                <strong>${result.score}%</strong> - ${result.recommendation}
                <div class="feature-details" style="font-size:0.8em;color:#666;margin-top:5px">
                    Features: ${JSON.stringify(result.features)}
                </div>
            `;
            resultSpan.style.color = result.score > 70 ? 'green' : result.score > 40 ? 'orange' : 'red';
        } else {
            resultSpan.textContent = `Error: ${result.message}`;
            resultSpan.style.color = 'red';
        }
    } catch (error) {
        resultSpan.textContent = 'Validation error';
        resultSpan.style.color = 'red';
        console.error("Validation failed:", error);
    }
}