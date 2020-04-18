classdef strategy_CoSplit
	properties
        max_pool_size (1,1) {mustBeInteger} = 100
    end
	methods
        function [vars] = getVars(obj)
            vars{1}.name = 'max_pool_size';
            vars{1}.lebel = 'Maximum Pool Size';
            vars{1}.type = 'integer';
            vars{1}.input_type = 'textBox';
            vars{1}.min = 1;
            vars{1}.max = inf;
            vars{1}.log_scale = 'false';
        end
        
        function [sz] = getOptGroupSZ(obj,p_inf)
            sz = min(round(-1/log2(1-p_inf)),obj.max_pool_size);
        end
        
        function [results, num_split, num_tests] = test(obj,samples,tester,test_param)
        %Runs the Cosplit strategy on the samples while using the tester which
        %represents the underlying biomedical modell of e.g. PCR testing
        %   CoSplit tests each group (each column in samples) as a whole in first
        %   place. The groups of which the result from the tester modell is
        %   positive are being split up and a recursive function call of this
        %   strategy is performed. If there is nothing to split anymore (only one
        %   person left), the result of this one person is being regarded as the
        %   state of the sample. 
        %The output is: 
        %results (same size as samples): the test results for each patient.
        %num_split (same size as samples): The number of tests conducted for each
        %patient (The sample therefore has to be split up in that many pieces).
        %num_tests (1x1): The total number of tests conducted 

        %Find the size of each group (all groups have similar size)
        sz1 = size(samples,1);

        %If the groupsize is zero return
        if sz1 == 0
            results = false(0);
            num_split = zeros(0);
            num_tests = 0;
            warning("nothing to test! #WasGuckstDu");
            return
        end

        %Perform the test on all groups
        results_temp = tester(samples,test_param);
        %The number of performed tests is the number of groups (one test per group)
        num_tests = size(samples,2);
        %One fraction of each sample was used during testing 
        num_split = ones(size(samples));
        %If each group consists of one person only, return
        if sz1 == 1
            results = results_temp;
            return
        end
        %Otherwise perform split
        %find center index
        mid_idx = ceil(size(samples,1)/2);
        %Recursive call of first and second half. Only for those groups, that
        %resulted in a positive test
        [res_a, num_split_a, num_tests_a] = obj.test(samples(1:mid_idx,results_temp),tester,test_param);
        [res_b, num_split_b, num_tests_b] = obj.test(samples(mid_idx+1:end,results_temp),tester,test_param);

        %Initialize an array for all samples (even if tested negative during this
        %recursive call
        results = false(size(samples));
        %Aggregate results by filling the results of those samples, that were split
        %with the information from the recursive calls.
        results(:,results_temp) = [res_a;res_b];
        %Aggregate number of splits.
        num_split(:,results_temp) = num_split(:,results_temp) + [num_split_a;num_split_b];
        %Aggregate number of tests.
        num_tests = num_tests + num_tests_a + num_tests_b;

        end
	function r = multiplyBy(obj,n)
        r = [obj.Value] * n;
	end
   end
end

