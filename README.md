#Networked Embedded System : Smart Green House
##Description
Imagine you are a university student and you live far away from your family. You live in an unknown town and no one cares about you. You have to wash the dishes yourself and you have to take care about your clothes. In addition your mother gave you same very beautiful plants. Now you want to go to your holidays and travel around Europe for some weeks and you have no idea how to pour your very beautiful plants during this time. Your neighbor is not very friendly and your mother lives in another town.... :-(
Than you need the Smart Green Home for students!
With the Smart Green Home for Students you can leave your plants alone for several weeks. The Smart Green Home for Students controls the pouring of every plant in your flat perfectly. The pouring works complete automatically and of course wireless.

##Collaborators
* Alexander Platz
* Aravinth, S. Panchadcharam
* Florian David Roubal
* Martin Kessel
* Sven Erik Jeroschewski


##Software Tools Used
* Git Versioning - [Source Tree Gui](https://www.atlassian.com/software/sourcetree) (Windows, Mac)
* XBee Module Firmware Configuration - [XCTU](http://www.digi.com/support/productdetail?pid=3352&osvid=57&type=utilities) (Windows, Mac, Linux)
* Arduino IDE 1.0.5
* WaspMote IDE

##User Interface
It enables the user to control, configure and monitor the status of the Smart Green House. This program is implemented to run platform independently.

##Minimum Requirement to run UI
* Operating System with Web browser that can support Web Sockets (Chrome, Firefox, Safari, IE)
* [Node.JS](http://nodejs.org/download)
* Administrator access rights to open Serial Port

##Tools Used to build UI
* Node.Js
* Require.JS
* Jquery
* Semantic UI
* Moment.JS
* HTML/CSS

##How to start UI
* Install Node.JS (To check if it is already install, type 'npm -version' on the terminal)
* Change directory ./Source/UI
* Enter 'sudo npm install' on the terminal (It takes a while to install all dependencies)
* Enter 'node server.js' (No need to 'sudo npm install' to start it next time)
* Open the Web browser and open 'http://localhost:3000'