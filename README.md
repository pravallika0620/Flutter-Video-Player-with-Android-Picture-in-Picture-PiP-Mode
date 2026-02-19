# PiP Video Player - Flutter Mandatory Task

A sophisticated Flutter video player application featuring Picture-in-Picture (PiP) mode, automated metadata persistence, and playback resume functionality. This project demonstrates Flutter-to-Native communication using MethodChannels and containerized build environments.

## Features

- Picture-in-Picture (PiP): Manual toggle and automatic entry on app minimize.
- Metadata Persistence: Fetches video data from a REST API and stores it locally in app_data/video_metadata.json.
- Playback Resume: Saves and restores the last video position using SharedPreferences.
- Error Handling: Robust UI with retry logic for network and server-side failures.
- Dockerized Build: Ready for automated CI/CD environments.

## Project Structure

- lib/main.dart: Core Flutter application logic.
- android/: Native Kotlin implementation for Picture-in-Picture mode.
- app_data/: Directory for persistent JSON metadata.
- Dockerfile & docker-compose.yml: Environment configuration for Difficulty 3 requirements.

## Prerequisites

- Flutter SDK: ^3.0.0
- Android Studio / VS Code
- Android NDK: 27.0.12077973
- Docker (for containerized builds)

## Setup and Installation

1. Clone the repository:
   git clone <https://github.com/pravallika0620/Flutter-Video-Player-with-Android-Picture-in-Picture-PiP-Mode>
   cd pip_video_player

2. Install Dependencies:
   flutter pub get

3. Configure Environment:
   Copy the example environment file:
   cp .env.example .env

4. Prepare Metadata Directory:
   Ensure the app_data folder exists in the root:
   mkdir app_data

## Running the Application

### Running on Physical Device/Emulator
flutter run

### Running Tests
To verify core functionality and UI keys:
flutter test

## Docker Build Instructions

To generate the release APK using the Docker environment (as per Difficulty 3 requirements):

1. Build the image and generate APK:
   docker-compose up --build

2. The final APK will be mirrored to:
   build/app/outputs/flutter-apk/app-release.apk

## Environment Variables

Documented in .env.example:
- API_URL: The endpoint for fetching video metadata.
- VIDEO_URL: The direct link to the video source.

## Evaluation Notes

- MethodChannel: Uses com.fluttercast.pip/controller to communicate with Android's PictureInPictureParams.
- Persistence: Implements path_provider for file-based JSON storage and shared_preferences for playback state.
- UI: Designed with Material 3 and responsive layouts to prevent overflows in PiP mode.