# 🧠 CrackDSA – Your Local AI Copilot for Proctored DSA Rounds (For Fun 😉)

**ClearDSA** is a macOS-native desktop chat assistant built with Flutter. It connects to local Ollama LLMs like `llama3`, `mistral`, and `codellama` to provide discreet, offline-friendly help for Data Structures & Algorithms (DSA) challenges—even during proctored coding rounds (strictly for "educational purposes" of course).

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

- **Chrome Tab Or Window Overlay**  
  Open the chat assistant on top of any coding window without getting caught

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

## 💡 Ideal Use Case

* Running in split-screen beside your browser-based proctored coding test (😉)
* Typing quick DSA queries like:

  * “Write a recursive solution to generate all balanced parentheses”
  * “Optimize this O(n²) approach using a hashmap”
  * “What’s the difference between BFS and DFS?”

> ⚠️ This app does **not** bypass any monitoring or screen sharing tools. Use responsibly.

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

## ⭐️ Fun Disclaimer

This tool is **for educational and entertainment purposes only**.
Please respect exam integrity policies. But hey... what you do on localhost stays on localhost.

---
