
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
      profile1: 'helper1'
      profile2: 'helper2'
    events:
      profile1: 'some event1'
      profile2: 'some event2'
    onCreated:
      profile1: 'created1'
      profile2: 'created2'
    onRendered:
      profile1: 'rendered1'
      profile2: 'rendered2'
    onDestroyed:
      profile1: 'destroyed1'
      profile2: 'destroyed2'
    functions:
      profile1: '$fn1'
      profile2: '$fn2'

testProfiles = makeTestProfiles()

Tinytest.add 'profiles stored on function as $', (test) ->

  test.isNotUndefined Template.profiles.$


Tinytest.add 'Template.profiles()', (test) ->

  Template.profiles testProfiles

  # these should be the same because they are the same object...
  test.isTrue deepEqual(Template.profiles.$.profile1, testProfiles.profile1)
  test.isTrue deepEqual(Template.profiles.$.profile2, testProfiles.profile2)

  # make another version of the test profiles where profile3 is ref's
  testProfiles2 = makeTestProfiles()
  # ensure the stored profile3 is *not* like that, it should be functions
  test.isFalse deepEqual(Template.profiles.$.profile3, testProfiles2.profile3)

  # let's test profile3 to ensure its ref's were replaced
  profile = Template.profiles.$.profile3

  test.isNotUndefined profile

  # ensure ref's were replaced with functions
  test.isUndefined profile.helpers.profile1
  test.equal typeof(profile.helpers.helper1), 'function'
  test.isUndefined profile.helpers.profile2
  test.equal typeof(profile.helpers.helper2), 'function'

  # ensure ref's were replaced with functions
  test.isUndefined profile.events.profile1
  test.equal typeof(profile.events['some event1']), 'function'
  test.isUndefined profile.events.profile2
  test.equal typeof(profile.events['some event2']), 'function'

  # ensure ref's were replaced with functions
  test.isUndefined profile.onCreated.profile1
  test.equal typeof(profile.onCreated.created1), 'function'
  test.isUndefined profile.onCreated.profile2
  test.equal typeof(profile.onCreated.created2), 'function'

  # ensure ref's were replaced with functions
  test.isUndefined profile.onRendered.profile1
  test.equal typeof(profile.onRendered.rendered1), 'function'
  test.isUndefined profile.onRendered.profile2
  test.equal typeof(profile.onRendered.rendered2), 'function'

  # ensure ref's were replaced with functions
  test.isUndefined profile.onDestroyed.profile1
  test.equal typeof(profile.onDestroyed.destroyed1), 'function'
  test.isUndefined profile.onDestroyed.profile2
  test.equal typeof(profile.onDestroyed.destroyed2), 'function'

  # ensure ref's were replaced with functions
  test.isUndefined profile.functions.profile1
  test.equal typeof(profile.functions.$fn1), 'function'
  test.isUndefined profile.functions.profile2
  test.equal typeof(profile.functions.$fn2), 'function'


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

  test.equal template.__eventMaps.length, 1, 'should add both into a single event map'
  test.isNotUndefined template.__eventMaps[0]['some event1']
  test.isNotUndefined template.__eventMaps[0]['some event2']

testHasProfilesOneAndTwo = (test, template) ->

  # now make sure the template has them
  test.isTrue template.__helpers.has 'helper1'
  test.isTrue template.__helpers.has 'helper2'

  test.include template._callbacks.created, testProfiles.profile1.onCreated.created1
  test.include template._callbacks.created, testProfiles.profile2.onCreated.created2

  test.include template._callbacks.rendered, testProfiles.profile1.onRendered.rendered1
  test.include template._callbacks.rendered, testProfiles.profile2.onRendered.rendered2

  test.include template._callbacks.destroyed, testProfiles.profile1.onDestroyed.destroyed1
  test.include template._callbacks.destroyed, testProfiles.profile2.onDestroyed.destroyed2

  test.equal template._callbacks.created.length, 3, 'should have the two added and one for the functions assignment'
