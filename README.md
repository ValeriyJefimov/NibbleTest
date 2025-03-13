# 📌 Technologies Used in the SwiftUI Project

## 1. **OpenAI API** 🧠
   - **Purpose**: Used for **text summarization**.
   - **How it’s used**: Takes a book title as input and returns a structured JSON with chapter summaries.
   - **Tech Stack**: Uses `GPT-4` via `https://api.openai.com/v1/chat/completions`.

## 2. **Google Text-to-Speech (TTS) API** 🗣️
   - **Purpose**: Converts **text summaries into speech**.
   - **How it’s used**: Takes the chapter summaries and generates an audio file (MP3) for playback.
   - **Tech Stack**: Uses `Google Cloud TTS API`.

## 3. **AVPlayer** 🎵
   - **Purpose**: Handles **audio playback** of the TTS-generated voice.
   - **How it’s used**: Loads the generated MP3 file and allows play, pause, and seek controls.
   - **Tech Stack**: Uses `AVPlayer` from **AVFoundation**.

## 4. **The Composable Architecture (TCA)** ⚙️
   - **Purpose**: Provides a **structured state management system**.
   - **How it’s used**: Manages UI state, API requests, and audio playback logic in a predictable way.
   - **Tech Stack**: Uses `swift-composable-architecture` package.

## 5. **SwiftUI** 🎨
   - **Purpose**: **UI framework** for building the app.
   - **How it’s used**: Creates a modern, declarative interface with animations, custom buttons, and interactive elements.
   - **Tech Stack**: Uses **SwiftUI** for views and UI interactions.
