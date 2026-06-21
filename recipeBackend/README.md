# RecipeHub Backend 🚀

**Quick deployment guide for the RecipeHub AI model backend on Google Colab**

## 📋 Quick Setup

### 1. Upload Files to Colab
- Upload the notebook to Google Colab
- Create a `data/` folder in your Colab environment
- Upload your `.pkl` vocabulary files to the `data/` folder

### 2. File Structure
```

├── data/
│   ├── ingredient_vocab.pkl
│   ├── instruction_vocab.pkl
│   └── model_weights.pkl
└── rest of the files
```

### 3. Run the Notebook
1. Execute all cells in the notebook
2. The Flask server will start automatically
3. Note the Cloudflare tunnel URL from the output

## 🔧 Required Files

Make sure you have these `.pkl` files in your `data/` folder:
- **Ingredient vocabulary**: Maps ingredient IDs to names
- **Instruction vocabulary**: Maps instruction tokens to text

## 🌐 API Endpoints

Once running, your backend will expose:
- `POST /predict` - Image to recipe generation
- `GET /health` - Health check

## ⚡ Features
- **GPU Acceleration**: Automatic GPU detection in Colab
- **Secure Hosting**: HTTPS endpoints via Cloudflare tunneling
- **Real-time Processing**: Fast inference with optimized model loading

## 🚨 Important Notes
- Keep your Colab session active to maintain the API
- The tunnel URL changes each time you restart
- Free Colab has usage limits - consider Colab Pro for production use

## 🔗 Usage
Copy the generated tunnel URL and use it as your backend endpoint in the frontend application.

---
**Ready to serve recipes in minutes! 🍳**