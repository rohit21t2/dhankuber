Dhankuber

India's trusted platform to compare, invest, manage, and track family's FD/RD investments.

Features





Real-time phone authentication with OTP



Bottom navigation bar with Home, Comparison, Portfolio, Payments, and Profile tabs



Loading animations using Lottie



Firebase integration for user data storage



GetX for state management and navigation

Setup





Install Flutter 3.x and Android Studio.



Clone the repo: git clone https://github.com/rohit21t2/dhankuber.git



Run flutter pub get to fetch dependencies.



Configure Firebase:





Add google-services.json to android/app/.



Ensure Firebase rules are set up (see below).



Run flutter run to launch the app.

Firebase Rules

rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
match /users/{userId} {
allow read, write: if request.auth != null && request.auth.uid == userId;
}
}
}

Folder Structure





lib/: Main Dart code





app/: Bindings, controllers, data, UI



ui/: Pages, widgets, components



utils/: Helper functions and constants



assets/: Images, icons, and Lottie animations

Tech Stack





Frontend: Flutter 3.x, GetX



Backend: Firebase Firestore, Firebase Auth



APIs: Fixerra (mock), Razorpay, OneSignal



Analytics: Firebase Analytics



Crash Reporting: Firebase Crashlytics

Contributing





Create a feature branch: git checkout -b feature/your-feature



Commit changes: git commit -m "Add your-feature"



Push to GitHub: git push origin feature/your-feature



Create a pull request to main.

Team Workflow





Use GitHub Issues for task tracking.



Daily stand-ups to discuss progress.



Weekly demo APKs via Firebase App Distribution.



Regular updates to the founder with changelogs.