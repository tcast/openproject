angular.module('openproject.models')

.factory('Query', ['Filter', function(Filter) {

  Query = function (data, options) {
    angular.extend(this, data);
    angular.extend(this, options);

    if (this.filters === undefined) this.filters = [];
  };

  Query.prototype = {
    toParams: function() {
      return angular.extend.apply(this, [
        {
          'f[]': this.getFilterNames(this.getActiveConfiguredFilters()),
          'c[]': this.selectedColumns.map(function(column) {
            return column.name;
           }),
          'group_by': this.group_by,
          'page': this.page, // These aren't on the query, hmm
          'per_page': this.per_page // These aren't on the query, hmm
        }].concat(this.getActiveConfiguredFilters().map(function(filter) {
          return filter.toParams();
        }))
      );
    },

    getFilterNames: function(filters) {
      return (filters || this.filters).map(function(filter){
        return filter.name;
      });
    },

    getFilterByName: function(filterName) {
      return this.filters.filter(function(filter){
        return filter.name === filterName;
      }).first();
    },

    addFilter: function(filterName, options) {
      var filter = this.getFilterByName(filterName);

      if (filter) {
        filter.deactivated = false;
      } else {
        this.filters.push(new Filter(angular.extend({name: filterName}, options)));
      }
    },

    removeFilter: function(filterName) {
      this.filters.splice(this.getFilterNames().indexOf(filterName), 1);
    },

    deactivateFilter: function(filter) {
      filter.deactivated = true;
    },

    getAvailableFilterValues: function(filterName) {
      return this.available_work_package_filters[filterName].values;
    },

    getFilterType: function(filterName) {
      return this.available_work_package_filters[filterName].type;
    },

    getActiveFilters: function() {
      return this.filters.filter(function(filter){
        return !filter.deactivated;
      });
    },

    getActiveConfiguredFilters: function() {
      return this.getActiveFilters().filter(function(filter){
        return filter.isConfigured();
      });
    }
  };

  return Query;
}]);
