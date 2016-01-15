Package.describe({
  name: 'cosmos:blaze-profiles',
  version: '0.2.0',
  summary: 'Reusable Blaze Templates via function profiles',
  git: 'https://github.com/elidoran/cosmos-blaze-profiles',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.2');

  uses(api);

});

Package.onTest(function(api) {

  uses(api);

  api.use(['tinytest'], 'client');

  api.addFiles([
    , 'test/tests.coffee'             // the tests
    , 'test/package.browserified.js'  // deep-equal from npm via bonce
    , 'test/templates.html'           // templates to target with profiles
  ], 'client');

});

function uses(api) {
  api.use(['coffeescript', 'templating'], 'client')

  api.addFiles('client/blaze.coffee', 'client');

}
