# KDVH Proxy code

These scripts set  up the foreign data wrapper around the KDVH Oracle
database.

The SQL scripts are intended to be used with the evolution script
included in the repository.

- SQL scripts are immutable; i.e., the existing SQL scripts may not be
modified in any way once they have been approved/pushed to the 
repository. Changes/corrections should be handled by creating a new
SQL script.

- The scripts are intended to be run in numerical order.

- Each script should run in a transaction. That way, if an update should
fail, the changes will be rolled back and prevent the database evolution
from landing in an inconsistent state.

- While it is not currently used; each SQL script should ideally be
idempotent, so that one can run them repeatedly without affecting the
database.

- The SQL scripts are intended to be read-only; once released into
production, you should never go back and edit a released SQL script.
Instead, create a new SQL script in the sequence, and if needed, undo
or alter the results of the previous scripts.

- Although not currently supported, downgrade scripts ought to be
written for each SQL script.
