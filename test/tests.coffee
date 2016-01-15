
makeTestProfiles = ->

  profile1:
    helpers:
      helper1: ->
    events:
      'some event1': ->
    onCreated:
      created1: ->
    onRendered:
      rendered1: ->
    onDestroyed:
      destroyed1: ->
    functions:
      $fn1: ->

  profile2:
    helpers:
      helper2: ->
    events:
      'some event2': ->
    onCreated:
      created2: ->
    onRendered:
      rendered2: ->
    onDestroyed:
      destroyed2: ->
    functions:
      $fn2: ->

  profile3:
    helpers:
      helper1: 'profile1'
      helperTwo: 'helper2@profile2'
    events:
      'some event1': 'profile1'
      'some eventTwo': 'some event2@profile2'
    onCreated:
      created1: 'profile1'
      createdTwo: 'created2@profile2'
    onRendered:
      rendered1: 'profile1'
      renderedTwo: 'rendered2@profile2'
    onDestroyed:
      destroyed1: 'profile1'
      destroyedTwo: 'destroyed2@profile2'
    functions:
      $fn1: 'profile1'
      $fnTwo: '$fn2@profile2'

testProfiles = makeTestProfiles()

Tinytest.add 'profiles stored on Template', (test) ->

  test.isNotUndefined Template._profiles


Tinytest.add 'Template.profiles()', (test) ->

  Template.profiles testProfiles

  # these should be the same because they are the same object...
  test.isTrue deepEqual(Template._profiles.profile1, testProfiles.profile1)
  test.isTrue deepEqual(Template._profiles.profile2, testProfiles.profile2)

  # let's test profile3 to ensure its ref's were replaced
  profile = Template._profiles.profile3
  test.isNotUndefined profile

  # make another version of the test profiles where profile3 is ref's
  testProfiles2 = makeTestProfiles()

  # ensure the stored profile3 is *not* like that, it should be functions now
  test.isFalse deepEqual(profile, testProfiles2.profile3)

  # ensure ref's were replaced with functions
  test.isUndefined profile.helpers.profile1
  test.equal typeof(profile.helpers.helper1), 'function', 'should replace helper1'
  test.isUndefined profile.helpers.profile2
  test.equal typeof(profile.helpers.helperTwo), 'function', 'should replace helperTwo'

  # ensure ref's were replaced with functions
  test.isUndefined profile.events.profile1
  test.equal typeof(profile.events['some event1']), 'function', 'should replace \'some event1\''
  test.isUndefined profile.events.profile2
  test.equal typeof(profile.events['some eventTwo']), 'function', 'should replace \'some eventTwo\''

  # ensure ref's were replaced with functions
  test.isUndefined profile.onCreated.profile1
  test.equal typeof(profile.onCreated.created1), 'function', 'should replace created1'
  test.isUndefined profile.onCreated.profile2
  test.equal typeof(profile.onCreated.createdTwo), 'function', 'should replace createdTwo'

  # ensure ref's were replaced with functions
  test.isUndefined profile.onRendered.profile1
  test.equal typeof(profile.onRendered.rendered1), 'function', 'should replace rendered1'
  test.isUndefined profile.onRendered.profile2
  test.equal typeof(profile.onRendered.renderedTwo), 'function', 'should replace rendered1'

  # ensure ref's were replaced with functions
  test.isUndefined profile.onDestroyed.profile1
  test.equal typeof(profile.onDestroyed.destroyed1), 'function', 'should replace destroyed1'
  test.isUndefined profile.onDestroyed.profile2
  test.equal typeof(profile.onDestroyed.destroyedTwo), 'function', 'should replace destroyedTwo'

  # ensure ref's were replaced with functions
  test.isUndefined profile.functions.profile1
  test.equal typeof(profile.functions.$fn1), 'function', 'should replace $fn1'
  test.isUndefined profile.functions.profile2
  test.equal typeof(profile.functions.$fnTwo), 'function', 'should replace $fnTwo'


Tinytest.add 'Template::profiles()', (test) ->

  template = Template.TestTemplate1

  eventMapSize = template.__eventMaps.length

  # add the profiles to the test template
  template.profiles [ 'profile1', 'profile2' ]

  testHasProfilesOneAndTwo test, template

  test.equal template.__eventMaps.length, 2, 'should add an event map per profile'
  test.isNotUndefined template.__eventMaps[0]['some event1']
  test.isNotUndefined template.__eventMaps[1]['some event2']

Tinytest.add 'Template::profiles() by refs', (test) ->

  template = Template.TestTemplate2

  # add the profiles to the test template
  template.profiles [ 'profile3' ]

  testHasProfilesOneAndTwo test, template

  test.isTrue template.__helpers.has 'helper1'
  # renamed via profile3 from profile2
  test.isTrue template.__helpers.has 'helperTwo'

  test.equal template.__eventMaps.length, 1, 'should add both into a single event map'
  test.isNotUndefined template.__eventMaps[0]['some event1']
  # renamed via profile3 from profile2
  test.isNotUndefined template.__eventMaps[0]['some eventTwo']

testHasProfilesOneAndTwo = (test, template) ->

  # now make sure the template has them

  test.include template._callbacks.created, testProfiles.profile1.onCreated.created1
  test.include template._callbacks.created, testProfiles.profile2.onCreated.created2

  test.include template._callbacks.rendered, testProfiles.profile1.onRendered.rendered1
  test.include template._callbacks.rendered, testProfiles.profile2.onRendered.rendered2

  test.include template._callbacks.destroyed, testProfiles.profile1.onDestroyed.destroyed1
  test.include template._callbacks.destroyed, testProfiles.profile2.onDestroyed.destroyed2

  test.equal template._callbacks.created.length, 3, 'should have the two added and one for the functions assignment'
