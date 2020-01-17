'use strict';

angular.module('QuepidApp')
  .filter('scoreDisplay', [
    '$filter',
    function($filter) {
      return function(score, decimalPlaces) {
        if (score === '?') {
          return '?';
        } else if ( angular.isNumber(score) ) {
          console.log("decimals:" + decimalPlaces);
          return $filter('number')(score, decimalPlaces);
        } else {
          return score;
        }
      };
    }
  ]);
