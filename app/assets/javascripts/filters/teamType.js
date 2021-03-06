'use strict';

angular.module('QuepidApp')
  .filter('teamType', [
    function () {
      return function (items, test) {
        if ( test === 'owned' ) {
          return items.filter(function(item) { return item.owned; });
        } else if ( test === 'member' ) {
          return items.filter(function(item) { return !item.owned; });
        } else {
          return items;
        }
      };
    }
  ]);
