var system = require('system'),
    env = system.env,
    page = require('webpage').create();

var RESULTS_SEPARATOR = '_______RESULTS_______';

page.open(env.JASMINE_RUNNER_URL, function (status) {
    var results = page.evaluate(function () {
      return jasmine.getJSReportAsString();
    });
    console.log('Spec results are:');
    console.log(RESULTS_SEPARATOR);
    console.log(results);
    console.log(RESULTS_SEPARATOR);
    phantom.exit();
});