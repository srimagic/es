function search($scope, $http) {

	$scope.query = function() {
		var request = $http({method:'get',                                                                                                        
                    url:'/search',                                                                                                               
                    params: {
                    	'dow': $scope.dow,
                    	'tod': $scope.tod,
                    	'itemtype': $scope.itemtype,
                    	'placetype': $scope.placetype
                    }                                                                                                              
        });                                                                                                                                
                                                                                                                                                       
	    request.success(function(result){                                                                                                        
	    	$scope.result = result;                                              
	    });                                                                                                                                       
	                                                                                                                                             
	    request.error(function(err){  
	    	$scope.result = err;                                         
	    });
	};

	$scope.clear = function() {
		init();
		$scope.query();
	};

	var init = function() {
		var d = new Date();
		$scope.dow = d.getDay();
		$scope.tod = d.getHours();
		$scope.itemtype = "appetizers";
		$scope.placetype = "bars";
	}

	$scope.$watch('dow + tod + itemtype + placetype', $scope.query, true);

	init();
}