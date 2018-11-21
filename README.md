# Pachatary iOS App
This repo contains the iOS application
code for Pachatary project.
This simple app aims to be a reference
to discover interesting places
and also to record our past experiences,
sharing content with other people.

Application domain is composed by `scenes`,
which are defined as something that happened
or can be done/seen in a located place.
A group of `scenes` are defined as an `experience`.

There are also `profiles`,
which are the representation of a person inside the app.

## App screens

Here is a quick documentation about the screens that compose the app:

#### WelcomeViewController

![WelcomeViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/welcome-ios-screenshot.png)

This is the first view that appears to a person that is not authenticated.
By clicking start new adventure, anonymous person is registered and guided to MainTabViewController.
I have an account button leads the person to LoginViewController.


#### LoginViewController

![LoginViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/login-ios-screenshot.png)

Form to get an email with a login link.


#### MainTabViewController

This is the screen that appears when you open the app.
There are three section tabs: mine, explore and saved.

##### ExploreExperiencesTab

![ExploreExperienceViewController1](https://s3-eu-west-1.amazonaws.com/pachatary/static/explore-1-ios-screenshot.png)

This is the main tab.
By default, it asks location permissions
and shows a search without word, just by proximity and popularity.
User can scroll viewing a summary of each experience.
Clicking over an experience navigates to experience detail.
Clicking over a profile picture or username navigates to profile.
Search can be customized with text filling the top search bar.
Location is also editable clicking map icon and selecting a location.

##### SavedExperiencesTab

![SavedExperienceViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/saved-ios-screenshot.png)

This screen shows saved experiences.
Clicking an experience navigates to experience detail.

##### MyExperiencesTab

![MyExperiencesViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/myexperiences-ios-screenshot.png)

This is the self profile view.
Here user can view and edit her profile.
A click on profile picture allows to change it.
Tapping the bio edit text allows to edit it.
Share icon show a dialog to share self profile url.
Settings icon navigates to settings.
On the bottom of the screen, self experiences appear on a scroll.
Finally, green + button navigates to create a new experience.

When person is not completely registered,
this screen redirects to register.


#### RegisterViewController

![RegisterViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/register-ios-screenshot.png)

An anonymous will be able to post content after register and email confirmation.
In this form the user inputs her email and username
to register and receive that confirmation email.


#### ProfileViewController

![ProfileViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/profile-ios-screenshot.png)

User navigates to this screen clicking on a profile picture or username.
Same screen as MyExperiences but just showing person's profile.
Block button allows a person to stop seeing others content.


#### ExperienceScenesViewController

![ExperienceScenesViewController1](https://s3-eu-west-1.amazonaws.com/pachatary/static/experience-detail-1-ios-screenshot.png)
![ExperienceScenesViewController2](https://s3-eu-west-1.amazonaws.com/pachatary/static/experience-detail-2-ios-screenshot.png)
![ExperienceScenesViewController3](https://s3-eu-west-1.amazonaws.com/pachatary/static/experience-detail-3-ios-screenshot.png)

This is the detail of an experience.
Here appear the experience and its scenes information.
Experience can be shared or saved with the top buttons.
Clicking profile picture or username navigates to profile screen.
Clicking on the map, it shows the scenes located over a map.
Clicking scene navigation button also navigates to the map, but locating the selected scene.
Descriptions are trunkated and can be expanded clicking the show more text.
Flag button allows to report abusive content.

If the experience is mine, save button is changed by edit experience and add scene buttons.
Also, if the user can edit the experience,
an edit button appears on the top right corner of each scene.


#### ExperiencesMapViewController

![ExperiencesMapViewController1](https://s3-eu-west-1.amazonaws.com/pachatary/static/experience-map-ios-screenshot.png)

This screen shows the scenes from the selected experience
(navigation toolbar shows its title)
over a visual map, provided by [Mapbox](https://www.mapbox.com/).
It places a marker over the exact position of each scene
and when it is clicked shows a bubble with the scene title.
When a bubble is tapped, app navigates to show its scene detail.


#### CreateExperienceViewController & EditExperienceViewController

![CreateExperienceViewController1](https://s3-eu-west-1.amazonaws.com/pachatary/static/create-experience-ios-screenshot.png)
![EditExperienceViewController2](https://s3-eu-west-1.amazonaws.com/pachatary/static/edit-experience-ios-screenshot.png)

This screens allows you to both create a new or edit old experience.
Add image icon navigates to pick and crop image.

#### CreateSceneViewController & EditSceneViewController

![CreateSceneViewController1](https://s3-eu-west-1.amazonaws.com/pachatary/static/create-scene-ios-screenshot.png)
![EditSceneViewController2](https://s3-eu-west-1.amazonaws.com/pachatary/static/edit-scene-ios-screenshot.png)

This screens allows you to both create a new or edit old scene.
Same as experience's ones but with location selection.


#### SelectLocationViewController

![SelectLocationViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/select-location-ios-screenshot.png)

This screen appear when you edit scene location,
but also when you choose search location on explore screen.
It allows the user to move the map to point an specific location.
The search bar is used to search an specific address, city or country.
Locate icon centers the map on the current user location.


#### PickAndCropImageViewController

For the image selection uses native UIImagePickerController.
It uses [CropViewController](https://github.com/TimOliver/TOCropViewController) library to let
user crop the image to make it square.
After that, it is resized to avoid bigger than 1600px images.


#### SettingsViewController

![SettingsViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/settings-ios-screenshot.png)

Settings screen, to navigate to terms and conditions or privacy policy.


#### TermsAndCondictionsViewController

![TermsAndConditionsViewController](https://s3-eu-west-1.amazonaws.com/pachatary/static/terms-ios-screenshot.png)

Screen that shows terms and conditions.
Privacy policy screen is the same as this.


## Documentation

The architecture of this app has 2 main characteristics:

* Code structure follows the **Clean Architecture** approach
with a little modification:
Use cases are not implemented unless required.
Correct responsibility assignment and deep unit testing are main goals.
Views are totally passive
and there are no visual tests yet.

* The app is totally **Reactive**, and repos cache most of the information that fetch from server.
RxSwift plays a very important role on the system.
A normal view only has to subscribe what it needs and react to events received.
Repositories are split in frontal and api.
The second one manages the moya requests,
and the first one handles caching,
both made reactively to reach the subscribed presenters.

Frontal repository uses an special pattern that consists on
merging the different source of item modification flowables
and making them emit functions instead of objects.
That allows streams to modify the state of the cached
elements using `scan` RxSwift operator.

Paginated caches are wrapped by a requester,
that handles every request from the view with the internal cache explained above.

All classes follow dependency injection pattern.

100% Swift!

### Authentication

When the app starts, checks if the user has credentials stored locally.
If not, it calls the api to create a guest person instance and get credentials.
To create content, person needs to be also registered and confirm the email.
There is a RegisterViewController and ConfirmEmailViewController that does that and
saves person info locally.

Login is the other way that a person can use to authenticate herself.

All api calls are authenticated using `AuthHeaderPlugin`.

## Setup

Follow these instructions to start working locally on the project:

First of all, you must run api server locally.
Code and setup instructions can be found in this other repo:
[pachatary-api](https://github.com/jordifierro/pachatary-api).
You also have to register at [Mapbox](https://www.mapbox.com/)
to get a token to use their api.
Finally, create a project at [Firebase](https://firebase.google.com/)
and create both debug and relase projects and get their `GoogleService-Info.plist`.

Once server is working, we must:

* Download code cloning this repo:
```bash
git clone https://github.com/jordifierro/pachatary-ios.git
```
* Copy `ApiKeys.plist.sample` file to `ApiKeys.plist`
and fill the fields following the hint instructions:
```bash
cp Pachatary/ApiKeys.plist.sample Pachatary/ApiKeys.plist
```
* Move `GoogleService-Info.plist` files to `/Pachatary`:
```bash
mv GoogleService-Info.plist Pachatary/
```
* Install pods:
```bash
pod install
```

* You are ready to run the application on your device!
