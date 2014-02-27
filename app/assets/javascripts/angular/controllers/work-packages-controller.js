angular.module('openproject.workPackages.controllers')

.controller('WorkPackagesController', ['$scope', 'WorkPackagesTableHelper', 'Query', 'Sortation', function($scope, WorkPackagesTableHelper, Query, Sortation) {

  $scope.$watch('groupBy', function() {
    var groupByColumnIndex = $scope.columns.map(function(column){
      return column.name;
    }).indexOf($scope.groupBy);

    $scope.groupByColumn = $scope.columns[groupByColumnIndex];
    $scope.query.group_by = $scope.groupBy; // keep the query in sync
  });

  function initialSetup() {
    $scope.projectIdentifier = gon.project_identifier;
    $scope.operatorsAndLabelsByFilterType = gon.operators_and_labels_by_filter_type;
  }

  function setupQuery() {
    sortation = new Sortation(gon.sort_criteria);
    query = new Query(gon.query);
    query.setSortation(sortation);
    $scope.query = query;

    // Columns
    $scope.columns = gon.columns;
    $scope.availableColumns = WorkPackagesTableHelper.getColumnDifference(gon.available_columns, $scope.columns);

    $scope.groupBy = $scope.query.group_by;

    angular.extend($scope.query, {
      selectedColumns: $scope.columns
    });
  };

  $scope.withLoading = function(callback, params){
    startedLoading();
    return callback.apply(this, params).then(function(data){
      finishedLoading();
      return data;
    });
  };

  function startedLoading() {
    // TODO: We could also disable/enable everything to prevent multiple updates (Or maybe we want this anyway?)
    $scope.loading++;
  };

  function finishedLoading() {
    $scope.loading--;
  };

  $scope.setupWorkPackagesTable = function(json) {
    $scope.workPackageCountByGroup = json.work_package_count_by_group;
    $scope.rows = WorkPackagesTableHelper.getRows(json.work_packages, $scope.groupBy);
    $scope.totalSums = json.sums;
    $scope.groupSums = json.group_sums;
  };

  // Initially setup scope via gon
  initialSetup();
  setupQuery(gon);

  $scope.setupWorkPackagesTable(gon);
  $scope.loading = 0;
}]);
