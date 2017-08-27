<a href="https://postgresql.org"><img src="https://img.shields.io/badge/Powered%20by-PostgreSQL-blue.svg"/></a>
<a href="https://nodejs.org"><img src="https://img.shields.io/badge/Served%20by-Node.js-brightgreen.svg"/></a>
<a href="https://github.com"><img src="https://img.shields.io/badge/Hosted%20on-GitHub-blue.svg"/></a>
<a href="https://zenhub.com"><img src="https://raw.githubusercontent.com/ZenHubIO/support/master/zenhub-badge.png"/></a>
<a href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img src="https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg"/></a>

# Gradebook

Gradebook is a free and open-source (FOSS) product for instructors to record
student assessment and attendance. It is developed at the Data Science & Systems Lab ([DASSL](https://dassl.github.io), read _dazzle_) at the Western Connecticut
State University ([WCSU](http://wcsu.edu/)).

## Goals
Gradebook is developed with the following goals:
1. Provide instructors a free, open, and modern tool to record student
assessment and attendance
2. Provide instructors a framework to surface, analyze, and visualize patterns
in student performance
3. Use (and demonstrate the use of) modern tools and processes in software and
data engineering
4. Provide Computer Science students a real-life application to develop and
maintain as both curricular and co-curricular activity
5. Provide Computer Science students a framework to experience first-hand topics
such as: database, web, and mobile application development; micro services and
RESTful APIs; multi-tenancy; scalability; and cloud-based services.

## Status

Gradebook is still in early stages of development ("alpha stage"). Much of its
external documentation is in the form of README files contained in various
directories within the product repository. The source code is commented
reasonably well.

__Caution:__ Because the product is still in very early stages of development,
it should not be used as a production system in its current state. There are no
guarantees that future development releases will provide any kind of backward
compatibility or portability.

## Requirements

Gradebook is a 3-tier web and database application requiring the following
runtime components:
- Database server: PostgreSQL version [9.6.3](https://www.postgresql.org/docs/9.6/static/index.html)
running as a "fully owned" instance
- Web server: Node.js version [6.11](https://nodejs.org/dist/latest-v6.x/docs/api/).
Additional Node.js modules are required as described in the README in the
directory `/src/webapp`.
- Web client: The web site uses the JavaScript libraries and CSS stylesheets
listed in the README in the directory `/src/webapp`. The site has been tested
with Chrome, Firefox, Edge, and Internet Explorer, and is expected to run in
Safari and Opera as well. (See the [full list of browsers](https://github.com/Dogfalo/materialize#supported-browsers) with which
the site is expected to be compatible.)

Overall, the application has been tested on Windows 10 and Ubuntu Server 16.04,
but it should run in any operating environment where the aforementioned
components can run. It is possible to mix and match running environments. For
example, it should be possible to run the database server on Ubuntu, the web
server on Windows, and the web client on macOS.

Developing and testing the application requires only a text editor along with
the tools that are typically bundled with the runtime components.

## Installation

To install Gradebook, follow the instructions in the README files in the
following directories: `/src/db` and `/src/webapp`.

To populate the Gradebook database with sample data, consult the README file in
the directory `/tests/data`.

## Contributors

Gradebook was conceived by and is designed by [Sean Murthy](http://sites.wcsu.edu/murthys/),
a member of the Computer Science faculty at WCSU.

The following undergraduate Computer Science students at WCSU contribute(d) to
the development of Gradebook:
- [Kyle Bella](https://github.com/bella004)
- [Zaid Bhujwala](https://github.com/zbhujwala)
- [Zach Boylan](https://github.com/ZBoylan)
- [Andrew Figueroa](https://github.com/afig)
- [Elly Griffin](https://github.com/griffine)
- [Steven Rollo](https://github.com/srrollo)
- [Hunter Schloss](https://github.com/hunterSchloss)

## Contributing

Contributions and ideas are welcome. Mail a summary of your thoughts to
`murthys at wcsu dot edu`. Please mention "Gradebook" in the subject line.

## Legal Stuff

(C) 2017- DASSL. ALL RIGHTS RESERVED.

Gradebook is distributed under [Creative Commons License BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

PROVIDED AS IS. NO WARRANTIES EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.
