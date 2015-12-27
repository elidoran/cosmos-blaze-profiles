# Cosmos Blaze Profiles

Reusable Blaze Templates via function profiles.

Function types:

1. helpers
2. event handlers
3. onCreated
4. onRendered
5. onDestroyed
6. functions - functions added to template instances

It's a tiny library, less than 100 lines of code.

## Install

```
meteor add cosmos:blaze-profiles
```

## Examples

See some [examples](http://github.com/elidoran/cosmos-blaze-profiles-examples).

The first one I created is straight from mitar's peerlibrary:blaze-components example: *ExtremeInputComponent*.

## API

### Template.profiles(object)

Add profiles for use by any templates. These may include all the function types listed above. They do not require an associated template.

The first level of keys in the specified object are profile names.
The second level of keys are the type, or category, of the functions beneath it (such as helpers).
The third level of keys are the names of the items of that type, such as the name of a helper.
The values for the third level's keys are the functions.

For example:

```coffeescript
Template.profiles
  someProfile:
    helpers:
      value: -> this.$myFunction 'return some value'
    events:
      'keypress input': (event, template) -> # do something...
    onCreated:
      initVar: -> # create something and assign it on template instance
    onRendered:
      alterView: -> # do something with rendered view
    onDestroyed:
      clearVar: -> # remove/reset something from the onCreated function above
    functions:
      $myFunction: -> # a function which is added to the template instance
```

It is possible to reference something in another profile. Specify the profile name in the third level key and the name of the function in that profile as the value for that key.

This allows building a new profile which uses things from one or more existing profiles.

For example:

```coffeescript
Template.profiles
  someProfile:
    helpers:
      value: -> # some value helper
    functions:
      $doWork: -> # some helpful function

  anotherProfile:
    helpers:
      # name of profile : name of helper in profile
      someProfile: 'value'
    functions:
      # name of profile : name of function in profile
      someProfile: '$doWork'
```

### Template.someTemplateName.profiles(array)

Add profiles to a Template by specifying an array of the names of the profiles to add.

All of the specified functions for each profile name in the array will be added.

Note:

1. helpers will override previous helpers when they have the same name. This can be helpful sometimes, and, can be awkward, others.
2. events accumulate so profiles with the same event will both be included.
3. lifecycle event listeners will also accumulate, as in #2
4. functions will override previous ones with the same name, as in helpers in #1.

So, either pay attention to the order profiles are added to templates, or, make a new profile specifying exactly the ones wanted.

For example:

```coffeescript
Template.SomeTemplate.profiles [ 'profileName', 'anotherProfile' ]

# custom profile to be selective
Template.profiles
  customProfile:
    helpers:
      profileName: 'someHelper'
    events:
      anotherProfile: 'some event'

Template.SomeTemplate.profiles [ 'customProfile' ]
```

## References allowed in standard API functions

Use references, as shown in Template.profiles(), to add things from profiles.

Allowed in:

1. Template.helpers()
2. Template.events()
3. Template.onCreated()
4. Template.onRendered()
5. Template.onDestroyed()
6. Template.functions() - this is a non-standard function, but, it's available

For example, to reference a helper in another profile:

```coffeescript
Template.myTemplate.helpers
  value: -> 'some normal helper'
  profile1: 'label' # helper 'label' in profile 'profile1'
```


## MIT License
