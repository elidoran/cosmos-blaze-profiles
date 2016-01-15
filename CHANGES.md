0.3.0 - Released 2015/01/15

1. avoid assigning functions to the template instance which overwrite core functions


0.2.0 - Released 2015/01/15

1. changed ref's from `profileName: 'thingName'` to `thingName: 'profileName'` or `localThingName: 'thingName@profileName'`


0.1.1 - Released 2015/12/29

1. provided internal `replaceReferences` functions via `Template.profiles.$replaceReferences`
2. tweaked the onCreated listener assigning functions to check for `this.template` to help *cosmos:blaze-this*


0.1.0 - Released 2015/12/27

1. initial working version with tests and a test app
