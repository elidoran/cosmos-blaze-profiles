# store all the profiles here
Template._profiles = profiles = {}

# make Template store profiles of functions
Template.profiles = (newProfiles) ->
  for own profileName,profile of newProfiles
    for type in [ 'helpers', 'events', 'onCreated', 'onRendered', 'onDestroyed', 'functions' ]
      if profile[type]? then replaceReferences type, profile[type]

    if profiles[profileName]?
      # copy new stuff into there
      existingProfile = profiles[profileName]
      existingProfile[key] = value for key,value of profile
    else
      # store the new profile into profiles
      profiles[profileName] = profile

# gets ref'd function or writes an error
replaceReference = (profile, type, name) ->
  referencedFunction = profiles?[profile]?[type]?[name]
  unless referencedFunction?
    console.log "Error, no function named \"#{name}\" found for type \"#{type}\" in profile \"#{profile}\""
  return referencedFunction

# replace all references in the object with their referenced functions
Template._replaceReferences = replaceReferences = (type, object) ->
  # in case the stuff is stored within a property matching `type`
  if object?[type]? then object = object[type]

  for own name,value of object
    if 'string' is typeof value
      # posibilities:
      #  1. may be a string value, nothing for us to do
      #  2. may be a profile name to retrieve the thing from, like: 'profileName'
      #  3. may be both a profile name and the thing's name there, like: 'name@profileName'
      if profiles[value]? then profileName = value
      else # check for format name@profile
        parts = value.split '@'
        if profiles?[parts?[1]]?
          profileName = parts[1]
          otherName = parts[0]   # name of thing in the other profile
      if profileName?
        delete object[name]
        object[name] = replaceReference profileName, type, (otherName ? name)

  return object

appendReference = (callbackArray, type, fn) ->
  # check if the function is actually a string referencing a profile
  if 'string' is typeof fn
    [profile, name] = fn.split ':'
    fn = replaceReference profile, type, name

  # add function to internal callbacks array
  callbackArray.push fn

# add our enhanced versions which allow referencing things in other profiles
Template::helpers = (object) ->
  # replace refs in object and then put them into the helpers object
  object = replaceReferences 'helpers', object
  @__helpers.set name, fn for own name,fn of object

Template::onCreated = (fn) ->
  appendReference this._callbacks.created, 'onCreated', fn

Template::onRendered = (fn) ->
  appendReference this._callbacks.rendered, 'onRendered', fn

Template::onDestroyed = (fn) ->
  appendReference this._callbacks.destroyed, 'onDestroyed', fn

originalEventsFn = Template::events
Template::events = (object) ->
  originalEventsFn.call this, replaceReferences 'events', object

Template::functions = (object) ->

  object = replaceReferences 'functions', object

  # first, have we added an onCreated listener to assign our functions?
  # if not, then assign it now.
  unless @_instanceFunctions?
    @_instanceFunctions = instanceFunctions = {}
    @onCreated ->
      # small tweak to help cosmos:blaze-this which alters the `this`
      template = this?.template ? this
      for own name,fn of instanceFunctions
        template[name] = fn

  # now we add the specified functions to the stored ones
  @_instanceFunctions[name] = fn for own name,fn of object

# add Template.<name>.profile(string+) which accepts profile names
# it adds all the stuff from the named profiles into this template
Template::profiles = (profileNames) ->
  # loop over each profile name specified
  for profileName in profileNames
    # get profile from storage
    profile = profiles[profileName]
    # if the profile exists, then, for each type of thing in that profile,
    # call the corresponding function with its values (adding them all)
    if profile?
      @helpers profile.helpers if profile?.helpers?
      @events profile.events if profile?.events?

      for type in [ 'onCreated', 'onRendered', 'onDestroyed' ]
        if profile?[type]?
          @[type] fn for own name,fn of profile[type]

      @functions profile.functions if profile.functions?

    else
      console.log 'Error, no profile named:',profileName

Template::renderAs = (name) ->
  Template[name] = new Template("Template.#{name}", this.renderFunction);
