An (attempt at) a universal review system, using
[DataSift](http://www.datasift.com)’s API.

Copyright (c) Catincan 2013, License AGPL

The code in this repository is placed under the terms of the
[GNU AGPL](http://www.gnu.org/licenses/agpl-3.0.html)

Cursory description of the code base
------------------------------------

Main parts of the code:
app/controllers for the controllers.
app/views for ... the views.
The code that would normally be in the models is in lib, as Rails
insists that models should be connected to a database by default, and we
don’t have any at this point.

The main interface with DataSift is thus in lib/resque_job.rb; it’s used
to queue Resque jobs (background tasks); these write their output to a
Redis database, that is polled by the front-end code.
