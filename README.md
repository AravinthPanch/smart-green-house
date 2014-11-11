#Networked Embedded System : Smart Green House
##Description
Smart Green House is a scalable plant monitoring system that helps us to monitor our plants and water them automatically. This system is built using WaspMote and XBee Modules. It includes sensor node, actuator node, control center and Frontend application to visualize the whole monitoring process. Additionally, water reservoir must be established for this system to work. Information about each plant is transmitted wirelessly using IEEE 802.15.4 protocols using XBee modules as underlying hardware.

This project work is done to demonstrate the advantages of wireless mesh networks WSN using WaspMotes. This has created a basic plant monitoring system and hope to be improved in future using cheaper hardware.

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