# Requirement 1: Use a reliable Flutter image with Dart 3.x
FROM instrumentisto/flutter:latest

USER root
WORKDIR /app

# Ensure we can run as root safely
RUN git config --global --add safe.directory /sdks/flutter

# Requirement 1: Install dependencies
COPY . .
RUN flutter pub get

# Requirement 3: Prepare Android licenses for the APK build
RUN yes | sdkmanager --licenses

# Requirement 3: Build the release APK
CMD ["flutter", "build", "apk", "--release"]