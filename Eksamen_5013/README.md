
Xcode: Version 11.2.1 (11B500)
Deployment Target: 13.0

PG5600



#  Reflection and assumptions

The application has all the functionalities from assigment 1 through 6.  If there is one thing i have to question, it would be about the reordering and deletion, i assume that when you reorder tracks in favorites, this would then persist with coreData so when you open the app next time the order would stay as after the edit, but this was not mentioned. I still made deletion work with coreData for "extra" functionality if it counts.

Furthermore i made design for fun, and made the app run with constraints on all the different iphone sizes, even looks ok with the Ipad pro 12.9 inch. There's also some differences from the simulator and running on device that i have taken in mind, such as when writing in the searchBar through SearchViewController, the standard keyboard pops up for users on device, which then blocks the tabbar making the only possible way out of this view is to click on a search result, but i made it so when pressing the cancel button on the tabbar it then ends editing, making the keyboard disapear.

the code structure could be better, should perhaps made a folder where i do the different requests to the apis for readability, also the different fetch methods from CoreData should have been made into their own functions for readability.

I am confident that with the functionality and effort ive made, this makes atleast a B, having in mind that the structure of the code could have been better, but then again its not bad.

sources:

https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-remote-image-url-into-uiimageview
