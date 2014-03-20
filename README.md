poise-appenv
=============

[![Build Status](https://travis-ci.org/coderanger/poise-appenv.png?branch=master)](https://travis-ci.org/coderanger/poise-appenv)

Set up
------

Configure `node['poise-appenv']['cookbook']` with the name of the cookbook which
selects your application environment.

poise-appenv adds two methods to node. `node.app_environment` returns the name
of the current application environment. `node.app_envionrment?('name')` checks
if the application environment is `'name'`.

Example
-------

The included (test cookbook)[tests/cookbooks/poise-appenv_test] is an example
of full usage. In its [default attributes file](test/cookbooks/poise-appenv_test/attributes/default.rb#L19)
we configure the cookbook name to use, and then define shared attributes or defaults
to apply to all application environments.

In the attributes file for each environment (ex. [prod.rb](test/cookbooks/poise-appenv_test/attributes/prod.rb))
we include the default file to ensure it is run first, and then only process the
rest of the file if the environment is the one the file should apply to. After
that we have attributes that will be applied to the requested environment.

In the [recipes](test/cookbooks/poise-appenv_test/recipes) we have a default
recipe which does the logic for the application (generally just `include_recipe`
on other recipes). We also have stub recipes for each application environment
which just include the default.

Why?
----

Why not just use Chef environments? Sometimes you want to deploy slightly
different applications in the same Chef environment. An example would be
launching a new branch of your code in the test environment. You could copy the
Chef environment and tweak the settings you want, but this results in a lot of
duplicated configuration which is error prone and difficult to update.
Additionally, even though it is slightly different, this hypothetical new
application cluster is still semantically in the "test" environment, and
currently Chef environments don't have any kind of heirarchical relationship.
