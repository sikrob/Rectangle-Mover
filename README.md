Rectangle-Mover
===============

Rectangle Mover allows the user to move a rectangle and see a stylized Hello World screen by tapping the rectangle.

## Correct Rectangle Movement and Rotation
The Tinder app is implemented with a view that moves around based on touch translation, with no regard to whether it keeps your finger in the view or not. This movement is characterized by finding an angle against the change in horizontal movement and sliding the image up and down the hypotenuse of that angle. The angle can always be calculated against the change in X and an anchor point either above or below the view, depending the desired direction of rotation.

This is not my preferred way to implement this sort of behavior; I prefer if your finger stays over the view that is being moved, which is more intuitive. However, there may be slight advantages to Tinder's way of doing things. For example, since the view can "crawl out" from under your finger, you might be able to see more of the image again. This may suit the usage patterns of the Tinder app if a user was impulsively swiping one way or the other, as seeing a glimpse of the image again may cause them to reconsider their choice.

Regardless, I also implemented this behavior in a manner where the view is always translated beneath the finger, which provides a more intuitive motion. You can see this version of the project in the goodAngles branch.

### Non-Affiliation Notice
Although this project is copying certain non-core functionality from the Tinder app and mentions it in several notes and places, this project is completely unaffiliated with Tinder.
