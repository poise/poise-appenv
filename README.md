poise-appenv
=============

[![Build Status](https://travis-ci.org/coderanger/poise-appenv.png?branch=master)](https://travis-ci.org/coderanger/poise-appenv)

Quick Start
-----------

### Attributes

In your [default attributes file](test/cookbooks/poise-appenv_test/attributes/default.rb#L19)
configure the name of the cookbook that determines your application environment:

```ruby
default['poise-appenv']['cookbook'] = 'role-myapp'
```

Then create one attribute file for each [app_environment](test/cookbooks/poise-appenv_test/attributes/prod.rb#L19-L20)
with a header like:

```ruby
include_attribute 'role-myapp'
return unless node.app_environment?('prod')
```

This header will prevent executing the file unless the app_environment
matches the given name(s). Put any shared attributes on the `default.rb` file
and per-app_environment attribute in the relevant file.

### Recipes

The cookbook specified in `node['poise-appenv']['cookbook']` is used to determine
which app_environment we are in. Each recipe within the cookbook maps to an
app_environment of that name, so adding `role-myapp::prod` to the run list
will mark the node as being in the `prod` app_environment. If you add plain
`role-myapp` to the run list, it will use the name of the chef_environment.

To accomplish this you need to create stub recipes like [recipes/prod.rb](test/cookbooks/poise-appenv_test/recipes/prod.rb)
which just include the default recipe:

```ruby
include_recipe 'role-myapp'
```

The default recipe should contain the normal code for installing your application,
generally this will be one more `include_recipe` to other cookbooks.

Application Environments
------------------------

Application environments offer a way to have different node attributes applied
via a cookbook. Combined with [role or environment cookbooks](http://vialstudios.logdown.com/posts/166848-the-environment-cookbook-pattern)
this lets you separate the varying configuration of an application in different
deployment scenarios from the code to install the application.

As a concrete example, imagine you have two Chef environments; prod and test.
You run a cluster of servers in each environment with your application installed.
Now you want to launch a new cluster in your test environment running an
experimental build and divert some portion of traffic to it. You could create
a new Chef environment by copying the existing test one, but almost all the
settings will be the same, only the version to deploy and similar attributes
need to be overridden for the new servers. Application environments give you
a way to apply those customizations.

Reference
---------

### node.app_environment

`node.app_environment` returns the name of the detected application environment
based on the configured cookbook. Note that this is a method, not a node attribute.

### node.app_environment?(*names)

`node.app_environment?` returns true if the current application environment
is any of the given names.

### node['poise-appenv']['cookbook']

`node['poise-appenv']['cookbook']` is a node attribute used to configure which
cookbook is searched for to determine the current application environment.

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
