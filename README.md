# dbobjects
Lists changed obejcts in D?L files. Adding the object type (where possible) for Oracle DB.

The story was that for Production Instruction desribinh the software installation, customer required to have listed all new or modified DB objects.
Not to do that manually, I created the script which lists the objects and checks in DB the type of the object if necesarry.

One needs to have environment variable defined: ORACLE_UID to get to the DB.
Some actions may be environment specific like last line of the script (where I delete the prefix of "PPB."). Feel free to remove it or adapt it.
