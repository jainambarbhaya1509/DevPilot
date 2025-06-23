# 🧠 DevPilot - Your Personal AI Coding Copilot (Offline & Discreet)

**DevPilot** is a macOS-native desktop assistant built with Flutter that acts as an offline AI companion, connecting to local Ollama models (like Llama3, Mistral, CodeLlama) to streamline my development workflow.

> 🤖 Because sometimes even geniuses need a quiet nudge.

---

## 🚀 Features

- **Private & Local**  
  Connects to `http://localhost:11434` — no internet, no data sharing, just pure local AI inference.

- **Minimal Chat Interface**  
  Clean, distraction-free UI tailored for high-pressure DSA environments.

- **Model Switching On The Fly**  
  Toggle between powerful LLMs (e.g., `llama3`, `codellama`, `mistral`) based on your coding context.

- **Instant Connection Status**  
  Know exactly when your local Ollama server is ready.

- **Formatted Code Output**  
  Beautified display of code blocks for quick copy-paste.

---

## ⚙️ Setup

### 1. Requirements

- macOS (tested on Ventura+)
- [Flutter](https://flutter.dev)
- [Ollama](https://ollama.com) (for local LLMs)

### 2. Install Ollama & Models

```bash
brew install ollama
ollama serve
ollama run llama3   # or mistral, codellama, etc.
````

### 3. Clone & Run

```bash
git clone https://github.com/your-username/ClearDSA
cd ClearDSA
flutter pub get
flutter run -d macos
```

---

## 🧠 Supported Models

* `llama3`
* `mistral`
* `codellama`
* `gemma`
* `llava` (vision + text)

> Add more via `ollama run <model-name>`

---

## 🛠️ File Structure

```bash
lib/
├── main.dart               # App entry point
├── ollama_chat.dart        # Chat UI + logic
├── model_selector.dart     # Dropdown to switch models
├── connection_status.dart  # Ollama status indicator
└── code_block_widget.dart  # Styled output for AI code responses
```

---

## 📸 Preview

> *Screenshot coming soon: clean chat UI, dark mode, real-time responses*

---

## 📜 License

MIT License — do whatever you want, but don't blame me if you get caught using it in a real interview 😄

---
