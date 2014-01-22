var reports = angular.module('openproject.reports', ['ngResource']);

reports.controller('op-report-type-controller', function($scope) {
  $scope.radius = 30;
});

reports.directive('opReportCircle', function() {
  return {
    scope: {
      radius: '@',
      caption: '@',
      href: '@'
    },
    restrict: 'E',
    template: '<svg height="{{ 2*radius || 50 }}" width="{{ 2*radius || 50 }}"><a xlink:href="{{ href }}"><circle cx="{{ radius || 25 }}" cy="{{ radius || 25 }}" r="{{ radius-2 || 23 }}" stroke="#00658f" stroke-width="2" fill="#2480a5" /></a></svg>'
  };
});
