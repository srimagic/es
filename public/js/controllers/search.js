function search($scope, $http) {

	$scope.query = function() {
		var request = $http({method:'get',                                                                                                        
                    url:'/search',                                                                                                               
                    params: {
                    	'dow': $scope.dow,
                    	'tod': $scope.tod,
                    	'query_string': $scope.query_string
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
		$scope.query_string = "";
	}

	$scope.$watch('dow + tod', $scope.query, true);

	init();
}