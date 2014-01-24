var reports = angular.module('openproject.reports', ['ngResource']);

reports.controller('op-report-type-controller', function($scope) {
  $scope.radius = 30;
});

reports.directive('opPunch', function() {
  return {
    scope: {
      value: '@',
      caption: '@',
      href: '@'
    },
    restrict: 'E',
    link : function($scope, $elem, $attr) {
      $scope.Math = Math;
    },
    template: '<svg height="50" width="50"><a xlink:href="{{ href }}"><circle cx="25" cy="25" r="{{ 23 * Math.sqrt(value) }}" stroke="#00658f" stroke-width="2" fill="#2480a5" /><text font-size="10" text-anchor="middle" x="25" y="29" fill="#ffffff">{{ caption }}</text></a></svg>'
  };
});
