classdef strategy_CoSplit
	properties
        max_pool_size (1,1) {mustBeInteger,mustBePositive} = 100
        split_factor (1,1) {mustBeGreaterThanOrEqual(split_factor,2)} = 2
        min_pool_size_for_retesting (1,1) {mustBeInteger,mustBePositive} = 1e8
    end
	methods
        function [vars] = getParams(obj)
            vars{1}.name = 'max_pool_size';
            vars{1}.lebel = 'Maximum Pool Size';
            vars{1}.type = 'integer';
            vars{1}.input_type = 'textBox';
            vars{1}.min = 1;
            vars{1}.max = inf;
            vars{1}.log_scale = 'false';
            
            vars{2}.name = 'split_factor';
            vars{2}.lebel = 'Split Factor';
            vars{2}.type = 'numeric';
            vars{2}.input_type = 'textBox';
            vars{2}.min = 2;
            vars{2}.max = inf;
            vars{2}.log_scale = 'false';
        end
        
        function [sz] = getGroupSZ(obj,p_inf)
            sz = min(round(-1/log2(1-p_inf)),obj.max_pool_size);
            if(sz <= obj.split_factor)
                n = 1:min(1e3,obj.max_pool_size);
                num_t = 1./n + 1-(1-p_inf).^n;
                sz = n(num_t == min(num_t));
            end
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
        
        %if retesting is enabled
        if(obj.min_pool_size_for_retesting <= sz1)
            sel = ~results_temp;
            results_temp(sel) = tester(samples(:,sel),test_param);
            num_tests = num_tests + sum(sel);
            num_split(:,sel) = 2;
        end
        
        
        
        %If each group consists of one person only, return
        if sz1 == 1
            results = results_temp;
            return
        end
        %Otherwise perform split
        %find size of first split
        num_smpl = ceil(size(samples,1)/obj.split_factor);
        
        %Initialize an array for all samples (even if tested negative during this
        %recursive call
        results = false(size(samples));
        
        %Recursive call of first and second half. Only for those groups, that
        %resulted in a positive test
        for i=1:obj.split_factor
            sel = (1:num_smpl)+((i-1)*num_smpl);
            sel(sel>sz1) =[];
            [res_temp, num_split_temp, num_tests_temp] = obj.test(samples(sel,results_temp),tester,test_param);
            %Aggregate results by filling the results of those samples, that were split
            %with the information from the recursive calls.
            results(sel,results_temp) = res_temp;
            %Aggregate number of splits.
            num_split(sel,results_temp) = num_split(sel,results_temp) + num_split_temp;
            %Aggregate number of tests.
            num_tests = num_tests + num_tests_temp;
            if i*num_smpl >= sz1
                break
            end
        end

        end
   end
end

