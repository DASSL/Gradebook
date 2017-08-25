README.md - Gradebook Web Server

Steven Rollo   
Data Science & Systems Lab (DASSL), Western Connecticut State University (WCSU)

(C) 2017- DASSL. ALL RIGHTS RESERVED.   
Licensed to others under CC 4.0 BY-SA-NC:   
https://creativecommons.org/licenses/by-nc-sa/4.0/

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.


## Overview
This document outlines how to setup the Gradebook web server. The web server is an
intermediate layer between the DBMS and client. It serves the static client web page
to clients, and implements a REST API that the client web page uses to request Data
from the DBMS. The gradebook web server is written in javascript using [node.js](https://nodejs.org/en/).
The current version of the web server has been tested with node.js 6.11.2 on Ubuntu 16.04.

## Setup
In order for the web server to function, you must first install node.js and some
additional modules the Gradebook web server uses.
1) Install node.js. The [node.js web page](https://nodejs.org/en/) details the installation
procedure for many different platforms. We recommend using a 6.x version of node.js.
Also, ensure that npm, node.js's module package manager is installed, as some installation
packages do not install it by default.
2) Install the required node.js modules. The Gradebook web server uses three node.js modules:
[Express](https://expressjs.com/), [node-postgres](https://github.com/brianc/node-postgres), and
[The Stanford Javascript Crypto Library](http://bitwiseshiftleft.github.io/sjcl/). All three can be installed automatically using npm.
   * Open a command prompt or terminal window and navigate to the `Gradebook/src/webapp`
   folder (the same folder this README is in).
   * Execute the command `npm install`.This will automatically install all needed
   dependencies using the `package.json` file.

## Running the server
To run the server, simply open a command prompt or terminal and navigate to the
`Gradebook/src/webapp` folder, and execute the command `npm start`. This will
start the Gradebook server. Note that this command may need to be executed with
elevated privileges, since the server listens on port 80 by default. Navigating to 127.0.0.1
should display the Gradebook login page.
