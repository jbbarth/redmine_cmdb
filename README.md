Redmine CMDB plugin
===================

This plugin helps you connect your CMDB to Redmine, so that you can link tickets with your CI. It works by keeping a mirror table of your assets in Redmine's database, so that it's CMDB-agnostic, but you'll have to do a (tiny) script to keep everything in sync.


Install
-------

This plugin is compatible with Redmine 2.0.0+.

You can first take a look at general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

Then :
* install the redmine_base_deface plugin (see [here](https://github.com/jbbarth/redmine_base_deface))
* clone this repository in your "plugins/" directory ; if you have a doubt you put it at the good level, you can check you have a plugins/redmine_cmdb/init.rb file
* install dependencies (gems) by running `bundle install` from the root of your redmine instance
* restart your Redmine instance (depends on how you host it)


Principles
---------

Configuration items are stored in Redmine database with the following attributes:
* **name** (required) : the name of the CI
* **url** (required) : the url where the CI informations can be seen ; usually a link to the CI page in your CMDB
* **description** : an optional description
* **item_type** : an optional item type if you have multiple types (for instance "Application" and "Server")
* **cmdb_identifier** : a *unique* identifier that will guarantee the integrity of your redmine table with your CMDB
* **status** : an integer to store the status of the CI ; currently can be 'active' (1) or 'archived' (9), results in active=true/false in API results

It's highly recommended to provide a **cmdb_identifier** when creating a CI in the CMDB. If you don't, the plugin will try to build one from the item_type and name fields, but it has drawbacks (for instance renaming a CI won't will be a hard story in your synchronization script).  The **cmdb_identifier** field can be used as a pivot for most synchronization actions in the plugin. It's unique, so it let's you rename CIs, update or delete them without worrying about dirty things in your scripts. I personnally tend to use either a komposite key if my CMDB source is a relational database, or directly the identifier of the record if it's a document-oriented DB with unique identifiers (which is the case in my current DB Cartoque).

Configuration Items API
-----------------------

The plugin adds a REST API for retrieving and managing configuration items. There's no create, update or destroy action available through the web interface since everything has to be kept in sync with your CMDB (that's the whole point of the plugin), hence it should be automated.

These API endpoints work like any Redmine API endpoint, so you have to authenticate as usual (see Redmine documentation), you'll get the same HTTP status code as in Redmine, and you can use it with XML or JSON formats, though I'm only using JSON format personnally. You can replace JSON with XML in the following examples.

**NOTE**: all these actions should be perormed with Redmine administrator credentials.

### GET /configuration_items.json

Lists all configuration items. Expected response:
```
{"configuration_items":[{"id":"123","name":"Main Webapp","type":"Application","description":"A shiny application description.",
                         "url":"http://my.cmdb.host/345", "cmdb_identifier":"application::main-webapp", "active":"true"}]}
```

Parameters:
* **limit=<N>** : limit number of results to N.
* **search=<term>** : search for "term" in CI name.
* **not=<id1,id2,...>** : excludes specified ids from the results (mostly useful for internal use).
* **status=<active|archived|all>** : specify the status of searched items. Defaults to "active".

### GET /configuration_items/:id.json

Shows a specific configuration item. Expected response:
```
{"configuration_item":{"id":"123","name":"Main Webapp","type":"Application","description":"A shiny application description.",
                         "url":"http://my.cmdb.host/345", "cmdb_identifier":"application::main-webapp", "active":"true"}}
```
Parameters: none.

### POST /configuration_items.json

Creates a new configuration item.

### PUT /configuration_items/:id.json

Updates an existing configuration item.

### DELETE /configuration_items/:id.json

Deletes a configuration item.

Parameters:
* **strategy** : can be 'soft' (default) or 'hard'. 'soft' softly deletes items, meaning they will stay in the database but be tagged with a status of archived item. 'hard' really deletes the item.


Contribute
----------

If you like this plugin, it's a good idea to contribute :
* by giving feed back on what is cool, what should be improved
* by reporting bugs : you can open issues directly on github
* by forking it and sending pull request if you have a patch or a feature you want to implement

