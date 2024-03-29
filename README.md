# Junior-Design-2324: REHAPP

REHAPP is a rehabilitation app for stroke survivors. This app allows therapists to assign home exercise programs to their patients and view their progress. The patients can then see their assigned exercises and log their progress in the app. 

## Installing

### Prerequisites
1. Git (https://git-scm.com/downloads) 
2. We recommend installing Android Studio (https://developer.android.com/studio/install). If you are on MacOS, you can also install Xcode.
3. Project Installation: Install this REHAPP repository on your local machine.
4. Flutter Installation: Install Flutter on your local machine. 
5. If you are using Android Studio, you will need to install the Flutter Plug In and Dart Plug In via Android Studio. 

### Detailed Android Studio Installation and Set Up for Windows PC Users: 
The link below contains screenshots and thorough instructions for Flutter and Project Installation via Android Studio for Windows PC Users.
https://docs.google.com/document/d/1IuZj2MNcUqtaxMEQYJi0_f6q8ARFV24et6CWh60VYWM/edit?usp=sharing
This guide is helpful for troubleshooting and includes common errors that can arise when installing Rehapp. We highly recommend reviewing this guide before proceeding.

### Project Installation
1. Clone this project and name it accordingly: ``git clone https://github.com/yoshikikakehi/REHAPP.git``. If you are new to git, it isn't 100% necessary to install git in order to utilize the project. Simply download the project and unzip it wherever you want on your computer. ![image](https://user-images.githubusercontent.com/29733080/165175625-ae7ab14d-02c4-4aca-ab1f-e2a7b0a09933.png)

### Flutter Installation
For general Flutter installation instructions, head on over to Flutter's official website (https://docs.flutter.dev/get-started/install) and follow the instructions based on your operating system. Below are the set of Flutter installation instructions that our team used.
1. Clone the flutter repository using git clone https://github.com/flutter/flutter.git -b stable  
2. Add the Path to the Flutter repository to the environment variables
3. Run the command flutter doctor . This command will let you know if you are missing any requirements to run flutter and provide you the corresponding installation
links as needed. If you are missing any of the requirements, please follow the given instructions. For assistance on resolving this issues, we recommend visiting pages 13-20 of the "Detailed Android Studio Installation and Set Up for Windows PC Users" above.
   3a. Order to resolve the issues:
                X Visual Studio 
                X  Intellij Idea Community Version, Download Intellij Idea Community Version with the link provided
                X VS Code, Download Intellij Idea VS Code with the link provided
                X cmdline-tools component is missing - follow Resolve x Android SDK is missing command line tools below
                X run flutter doctor -- android-license - follow Resolve Android License missing - Flutter Doctor

### Android Studio Users: Flutter & Dart Plug In Installation
1. Open Android Studio. 
2. Click File -> Settings
3. Click Plugins. 
4. Type Flutter in the search bar. Select Install Flutter.
5. Type Dart in the search bar. Select Install Dart.

### Run Instructions for Android Studio
1. Follow pages 23-25 of "Detailed Android Studio Installation and Set Up for Windows PC Users"  above.

### Building the Application for Mobile

>For Android applications, follow [this guide](https://docs.flutter.dev/deployment/android).  
>For iOS applications, follow [this guide](https://docs.flutter.dev/deployment/ios).

# Getting Started for Developers

This section is targeted towards developers. The project structure will be broken down, and we will go over the general architecture of the application.

## Project Architecture

The folder `rehapp` features the important frontend pieces of the app. Here the folders and their explanations will be given.

#### ``android and ios``

These folders contain platform specific details. Team 2324 did not greatly alter these folders, so they should generally be the same as when you create a new Flutter template project.

#### ``fonts``

This folder contains the font we chose for Rehapp: Atkinson Hyperlegible. This font was released by the Braille Institute in an effort to increase legibility and readability among low vision readers. Read more about it [here](https://brailleinstitute.org/freefont).

#### ``test and web``

These folders are generally unused by Team 2324.

#### ``lib``

This folder is the most important, containing all the frontend code for the application. Let's break this down further in the next section.

## Frontend Code Explanation from previous year's team

Inside lib are several folders that all contain the vast majority of frontend code for the project. The folders are ``api``, ``assets``, ``model``, and ``pages``. There are also two additional files: ``ProgressHUD.dart`` and ``main.dart`` that do not exist within any folders. Here is an idea of how the application runs in the first place:

1. Once you have run the Flutter application, the first function that ever runs is the ``Future<void> main() async`` function within ``main.dart``. It handles checking whether the user is still logged in based on locally stored data before the line ``runApp(Phoenix(child: const MyApp()));`` begins the application through ``MyApp()``. 
2. The first page you will see is ``/pages/login.dart``. The ``/pages`` folder contains all the pages or screens visible through the app. 
3. Inside ``/pages/login.dart`` is a good initial view on how pages work. At the top is ``class LoginPage extends StatefulWidget`` which is the page that is being run, extending the ``StatefulWidget`` class. Flutter's general structure is that it consists of widgets nested within widgets. Widgets can be anything from buttons on your screen, to text, and to the entire scaffold of the screen. The ``LoginPage`` class uses ``createState()`` to create the state of the widget via ``class _LoginPageState extends State<LoginPage>``. The flow of functions being called is: ``createState()`` -> ``initState()`` -> ``build(BuildContext context)``. 
4. Inside ``initState()``, we see the line ``requestModel = LoginRequestModel();``. This is the first interaction with the ``/model`` folder. Opening this folder, you will see quite a few models. These models contain all the necessary formats for both sending and receiving HTTP requests. In this case, take a look at the structure of the ``LoginPage()``. You will see several ``TextFormField`` widgets that store data within the ``requestModel``.
5. Around line 187 is our first interaction with the ``/api`` folder. The line ``APIService apiService = APIService();`` calls the file ``/api/api_service.dart``. This file is the way in which Rehapp contacts its backend with HTTP requests. 
6. Once the user is logged in and authenticated, the user's information is stored with the global variable ``/api/user.dart``, ``/api/token.dart``, and also local storage via the ``shared_preferences`` dependency.
7. Some strings within the application are held within ``/assets/constants.dart``. There are also default pictures within ``/assets/images``, which are used for the default images for exercises.
8. The ``ProgressHUD.dart`` file is run in pages where the initialization of data requires an API call, so a loading icon is first displayed over the entire page preventing user input until everything has been loaded in. 
9. The ``api/chosen_exercise_bank.dart`` file is used when the therapist wants to use an exercise bank exercise from ``pages/exercise_bank_detail.dart``, two pages need to be popped off the Navigator stack, so the ``chosenExercise`` serves as a global variable to remember the details of the exercise for use later. Flutter uses a Navigator to travel between pages, keeping track of which pages are currently on the stack. You push onto the stack when you want to navigate to another page, and you pop when you want to return. In #1 of these details, we mentioned ``runApp(Phoenix(child: const MyApp()));``. The ``Phoenix`` that wraps around ``MyApp()`` is not standard: that is an outside dependency named ``flutter_phoenix`` which restarts the app, wiping clean all data and stacks. This is done on Logout.
10. Lastly, dependencies can be viewed within ``rehapp/pubspec.yaml``.

### Tips and Tricks from previous year's team

1. Whenever you install a new dependency by altering the ``rehapp/pubspec.yaml``, make sure to restart the app if it is running. If that does not work, running ``flutter clean`` and ``flutter run`` in that order should fix any issues.
2. If you use Visual Studio Code, you can right-click on any widget within the build() function, and select refactor. This will show a list of options where you can wrap a widget in a parent or swap it for something else.
3. Sometimes, bugs like data not propagating correctly can be solved by turning the function into an **async** one and **await**'ing HTTP requests or other function calls.

## Useful Resources :thumbsup:

> `Flutter` References

* [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
* [Flutter Youtube Channel](https://www.youtube.com/c/flutterdev)

# Release Notes

## New software features (Version 0.4.0)

### General Features
* Return to login page using a back button
* Upload a profile picture on the account page
* Upload personal information (email, number, role, etc.) and display it on account page

### Known Issues
* We are currently facing an error when trying to load the exercise page for either the therapist or the patient user. This issue should be resolved by Sprint 5.

## New software features (Version 0.3.0)

### General Features
* As a patient/therapist, I want to receive a confirmation email after account creation.
* As a patient/therapist, I want to be able to reset my password.
* As a therapist, I want a safety box to appear on the patient’s end that confirms that the patient is not at any safety risk and has the appropriate supervision required to complete the exercises.
* As a therapist, I want my patient to be able to rate the completed exercise with a point system, so it is easier for me to review.

### Bug Fixes
* Migration from Azure to Firebase has been successfully completed. Exercises can be assigned as a therapist to a patient. All of this is done using Firebase. 

### Known Issues
* Main branch has errors rendering the login page that need to be resolved.
* Issues with accessing fields such as images of exercises that no longer exist.

## New software features (Version 0.2.0)

Note: The implementation of new features are repeated in the v0.1.0 release notes, as we are in the process of migrating from Azure to Firebase.

### General Features
* Create an account as either a therapist or patient
* Log in with created credentials

### Therapist Features
* Add a patient via email
* View list of patients
* Delete a patient
* Assign an exercise to a patient (details shown in v0.1.0 release notes)

### Bug Fixes
* Migration from Azure to Firebase has successfully began. We will continue to re-implement current features in Sprint 3.

### Known Issues
* When a therapist attempts to add a patient that does not exist, the error message that displays is unclear. 

## New software features (Version 0.1.1)

### General Features
* Click a "Remember Me" checkbox during login
    
### Known Issues
* Currently, the previous Azure database service is expired. By Sprint 2, a new database should be configured.
    
## New software features (Version 0.1.0)

### Patient Features
* View incomplete assigned exercises
  - Includes name, description, expected time to complete, optional photo, and optional video
  - Submit feedback to therapist including: minutes spent on exercise, difficulty level (ie: easy, moderate, hard), and optional comments
  - Voice dictation to leave optional comments instead of typing with keyboard
* View completed assigned exercises
  - View old response to the exercises
  - Submit new response to therapist on already completed exercises

### Therapist Features
* Add a patients to roster 
* Remove a patient from roster
* Search for a patient by name
* View specific patient’s incomplete assigned exercises
* View specific patient’s complete assigned exercises
  - Shows patient's feedback
* Search for a patient’s assigned exercise by name
* Remove a patient’s assigned exercise
* Assign patient a new exercise
  - Custom exercise
      + Enter name, description, expected time to complete, days assigned to complete (ie: mondays and wednesdays), optional image, and optional video      demonstration
  - Exercise bank
      + Select from a list of common exercises
      + Name, description, expected time, image and video are autofilled
      + Enter days assigned to complete (ie: tuesdays and thursdays)
      + Optionally edit the autofilled information to better fit the patient’s needs

### Bug fixes (Version 0.1.0)
**Fixed Bugs**
- Null Video Link in the getPatientAssignments and getAssignedExercises APIs
- Broken Picture Link in the database

### Known bugs and defects (Version 0.1.0)
**Known Bugs**
- The status bar changes to white and stays white after the assign exercise page, making it difficult to read on other pages (it may change back)

**Missing Features (Incompleted Stretch Goals)**
- Calendar tab feature
- Push notifications
- Two factor authentication
- Login via 3rd party (ie: facebook, gmail, etc)
- Forgot your password feature
- Account tab feature (currently the account tab leads to logout)
- Embedded video player 

# `Team Toast (2324)` Members

| Name       | Role          
| ------------- |:-------------:
| Minhat Mustafa | Backend, Manager     |
| Kiran Nazarali | Backend              | 
| Nabeeha Nuba | Frontend, Communicator |
| Hira Shahzad | Backend                |
| Yoshiki Kakehi | Frontend, Backend    |
