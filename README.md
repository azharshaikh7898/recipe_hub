# RecipeHub 🍳📱

**An AI-powered culinary assistant that transforms food images into complete, human-readable recipes using deep learning and natural language generation.**

## 📱 App Demo Screenshots

<div style="display: flex; gap: 20px; flex-wrap: wrap;">
  <img src="https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=RecipeHub%20mobile%20app%20main%20screen%20showing%20Today%27s%20Menu%2C%20Breakfast%20Lunch%20Snack%20cards%2C%20Ingredients%20Stock%2C%20and%20bottom%20navigation%20with%20camera%20button&image_size=square_hd" alt="RecipeHub Home Screen" width="300">
  <img src="https://coresg-normal.trae.ai/api/ide/v1/text_to_image?prompt=RecipeHub%20mobile%20app%20recipe%20details%20screen%20showing%20Beef%20Bourguignon%20recipe%2C%20ingredients%20list%2C%20and%20instructions&image_size=square_hd" alt="Recipe Details Screen" width="300">
</div>

## Overview

RecipeHub is a full-stack application that leverages cutting-edge computer vision and natural language processing to extract ingredients and cooking instructions from food images. Built with a custom PyTorch model inspired by the Inverse Cooking architecture, it provides an intuitive way to discover recipes from visual content.

## ✨ Key Features

- **🖼️ Image-to-Recipe Generation**: Upload a food image and get complete recipes with ingredients and step-by-step instructions
- **📱 Multi-Input Support**: Camera capture or image upload functionality
- **🤖 AI Chatbot Assistant**: Integrated conversational AI powered by Gemini API for cooking questions and recipe suggestions
- **⚡ Real-time Processing**: GPU-accelerated inference for fast recipe generation
- **🔒 Secure Deployment**: HTTPS endpoints through Cloudflare tunneling

## 🏗️ Architecture

### Deep Learning Pipeline

The core model follows a sophisticated multi-component architecture:

#### 1. **CNN-based Image Encoder**
- Extracts rich visual features from food images
- Captures texture, color, and structural information

#### 2. **Multi-label Ingredient Predictor**
- Uses sigmoid-based attention mechanism over image features
- Identifies multiple ingredients simultaneously with confidence scores

#### 3. **Transformer-based Instruction Decoder**
- Generates step-by-step cooking instructions
- Trained with attention to both ingredient embeddings and image context
- Produces human-readable, coherent recipe steps

### Data Processing
- **Vocabulary Management**: Ingredient and instruction vocabularies serialized as `.pkl` files
- **Image Preprocessing**: Normalized and resized inputs to match model expectations
- **Structured Mapping**: Efficient inference through pre-built vocabulary mappings

## 🛠️ Tech Stack

### Backend
- **Framework**: Flask API
- **ML Framework**: PyTorch
- **Hosting**: Google Colab (GPU acceleration)
- **Networking**: Cloudflare Tunneling for secure HTTPS endpoints

### Frontend
- **Image Processing**: Camera integration and upload functionality
- **Real-time Rendering**: Dynamic recipe display
- **Conversational AI**: Gemini API integration

### AI/ML Components
- **Computer Vision**: Custom CNN architecture
- **NLP**: Transformer-based text generation
- **Attention Mechanisms**: Multi-head attention for ingredient-instruction alignment

## 🚀 Getting Started

### Prerequisites
- Python 3.8+
- PyTorch
- Flask
- Google Colab account (for GPU inference)
- Cloudflare account (for tunneling)
- Gemini API key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/recipehub.git
   cd recipehub
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Set up backend model hosting**
   ```bash
   # Place your trained model and vocabulary files
   # Host the file on colab or any hosting service
   # Add your .pkl vocabulary files and model weights
   # Deploy to get the model endpoint Link
   ```

4. **Configure Backend Endpoint**
   ```bash
   # Launch the Application.
   # Go to Settings and paste the endpoint URL.
   # After that you are good to go.
   ```

5. **Chatbot API Configuration(Optional)**
    ```bash
    # Go to lib/widget/Geminiapp and update with your API key
    static const String apiKey = 'add_your_api_key_here';
    ```




### Running the Application

#### Backend (Google Colab)
1. Upload the notebook to Google Colab
2. Install dependencies and load model files
3. Start the Flask server
4. Set up Cloudflare tunnel for public access

#### Frontend
1. Configure the backend endpoint URL
2. Run the frontend application
3. Start capturing and generating recipes!

## 📋 API Endpoints

### Recipe Generation
```http
POST /predict
Content-Type: multipart/form-data

Parameters:
- image: Food image file
```

### Chatbot
```http
POST /chat
Content-Type: application/json

{
  "message": "How can I make this dish vegetarian?",
  "context": "recipe_context"
}
```

## 🎯 Usage Examples

### Basic Recipe Generation
1. Open the app
2. Take a photo or upload an image of a dish
3. Wait for AI processing
4. View generated ingredients and instructions

### Interactive Assistance
- Ask: "What can I substitute for eggs in this recipe?"
- Ask: "Show me similar Asian recipes"
- Ask: "How can I make this healthier?"

## 🧠 Model Performance

The Inverse Cooking-inspired architecture provides:
- **High accuracy** in ingredient detection
- **Coherent instruction generation** with proper cooking sequence
- **Context-aware** recipe adaptation
- **Multi-cuisine support** through diverse training data

## 🤝 Contributing

We welcome contributions! 

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Inverse Cooking**: Inspiration for the core architecture
- **PyTorch Community**: Framework and model components
- **Google Colab**: GPU infrastructure for development
- **Cloudflare**: Secure tunneling solution
- **Gemini API**: Conversational AI capabilities

**Made with ❤️ and lots of ☕ by the RecipeHub team**