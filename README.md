# Junior-Design-2324: REHAPP

REHAPP is a rehabilitation app for stroke survivors. This app allows therapists to assign home exercise programs to their patients and view their progress. The patients can then see their assigned exercises and log their progress in the app. 

## Installing

### Prerequisites

1. The first step is to install Flutter on your local machine. Head on over to [Flutter's official website](https://docs.flutter.dev/get-started/install) and follow the instructions based on your operating system.
2. If you are on a Windows PC, install Android Studio as instructed in the link above. If you are on MacOS, please install Xcode as instructed.
3. The link above will also have instructions on how to set up the emulator. Please folow them. The emulator will simulate the mobile device in order to run the application.

### Project Installation

1. Clone this project and name it accordingly: ``git clone https://github.com/yoshikikakehi/REHAPP.git``. If you are new to git, it isn't 100% necessary to install git in order to utilize the project. Simply download the project and unzip it wherever you want on your computer. ![image](https://user-images.githubusercontent.com/29733080/165175625-ae7ab14d-02c4-4aca-ab1f-e2a7b0a09933.png)
2. Open the project with either Android Studio or Xcode, depending on which operating system you have. Windows users likely will open the project with Android Studio, and MacOS users will likely use Xcode.
3. For Android Studio users, open the project. At the top there will be a bar. In the **target selector**, select an Android device for running the app. If none are listed as available, select Tools > AVD Manager and create one there. For details, see [Managing AVDs](https://developer.android.com/studio/run/managing-avds).
Click the run icon in the toolbar, or invoke the menu item Run > Run. ![image](https://user-images.githubusercontent.com/29733080/165176384-eab8552c-4231-4486-ac08-1266469b6b0b.png) 
4. For Xcode users, on your Mac, find the Simulator via Spotlight. You can also open "Terminal", a command line program, and enter this command: ``open -a Simulator``. With Terminal still open, you must navigate to the location of the project folder on your Mac. If you are unfamiliar with Terminal commands, see this [guide](https://computers.tutsplus.com/tutorials/navigating-the-terminal-a-gentle-introduction--mac-3855). The general gist is that entering the command ``ls`` shows you the current folders. ``cd <folder-name>`` allows you to enter a folder. ``cd ..`` allows you exit the folder you are currently in. You should aim to enter the folder "REHAPP" and again to enter the folder "rehapp". Make sure the Simulator is running, and enter ``flutter run`` in Terminal.
5. Congratulations! The project should be running and you will be able to interact with the application.

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

## Frontend Code

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

### Tips and Tricks

1. Whenever you install a new dependency by altering the ``rehapp/pubspec.yaml``, make sure to restart the app if it is running. If that does not work, running ``flutter clean`` and ``flutter run`` in that order should fix any issues.
2. If you use Visual Studio Code, you can right-click on any widget within the build() function, and select refactor. This will show a list of options where you can wrap a widget in a parent or swap it for something else.
3. Sometimes, bugs like data not propagating correctly can be solved by turning the function into an **async** one and **await**'ing HTTP requests or other function calls.

## Useful Resources :thumbsup:

> `Flutter` References

* [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
* [Flutter Youtube Channel](https://www.youtube.com/c/flutterdev)

# Release Notes
## New software features (Version 0.1.1)

### General Features
* Click a "Remember Me" checkbox during login
    
### Known Issues
* Currently, the previous Azure database service is expired. By Sprint 2, a new database should be configured.
    
## New software features (Version 0.1.0)

### General Features
* Create an account as either a therapist or patient
* Login with created credentials
* Log out

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
