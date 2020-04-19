%Parameters to test (vector or scalar)
p_inf_sw = linspace(1e-4,2e-1,1000);
pcr_sensitivity = 0.99;
pcr_specificity = 0.9;

%Number of groups for Monte Carlo testing
iterations = 1e4;

%Calculating the testefficiency of individual testing as a baseline
eff_of_single_test = efficiency_of_a_single_test(p_inf_sw);

%calculate the size of the output (depending on the number of parameters used)
sz_out = [length(p_inf_sw),length(pcr_sensitivity),length(pcr_specificity)];

%Initializing all output arrays
sensitivity = zeros(sz_out);    %Sensitivity of overall testing
specificity = zeros(sz_out);    %Specificity of overall testing
ppv = zeros(sz_out);            %Positive predictive value of overall testing
npv = zeros(sz_out);            %Negative predictive value of overall testing
num_tests_per_patient_mean = zeros(sz_out); %Number of tests required per patient on average
efficiency_strategy = zeros(sz_out);    %Efficiency of the strategy
num_splits_mean = zeros(sz_out);    %Mean of splits a sample has to undergo
num_splits_std= zeros(sz_out);  %Std of splits a sample has to undergo
num_splits_max = zeros(sz_out); %Max of splits a sample has to undergo
cnt = 0;
num_sim = prod(sz_out); %number of parameter combinations

strat_list = {@strategy_CoSplit,@strategy_CoSplit};


cur_strategy = strat_list{1}();
%cur_strategy.max_pool_size = inf;
cur_strategy.split_factor = 1e6;
%cur_strategy.min_pool_size_for_retesting = 2;

wb = waitbar(0);

for p_inf_idx = 1:length(p_inf_sw)
    for pcr_sens_idx = 1:length(pcr_sensitivity)
        for pcr_spec_idx = 1:length(pcr_specificity)   
            %Read parameters from array
            p_inf = p_inf_sw(p_inf_idx);
            pcr_par.sensitivity = pcr_sensitivity(pcr_sens_idx);
            pcr_par.specificity = pcr_specificity(pcr_spec_idx);
            
            %Calculate the optimum number of people within a group when 
            %assuming a perfect PCR.
            n = cur_strategy.getGroupSZ(p_inf);
            
            %Randomly generate patients infectedness
            pat_state = rand(n, iterations)<p_inf;
            
            %Run the strategy
            [results, num_splits, num_tests] = cur_strategy.test(pat_state, @pcr_simple, pcr_par);
            %Calculate the average number of test per patient
            test_per_pat = num_tests/numel(pat_state);
            num_tests_per_patient_mean(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = test_per_pat;
            %Save the baseline for individual testing
            efficiency_strategy(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = eff_of_single_test(p_inf_idx) /test_per_pat;
            %Calculate statistics on the number of splits
            num_splits_mean(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = mean(num_splits(:));
            num_splits_std(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = std(num_splits(:),0);
            num_splits_max(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = max(num_splits(:));
            
            %calculate the statistics on the overall PCR
            tp = mean(pat_state(:) == 1 & results(:) == 1);
            tn = mean(pat_state(:) == 0 & results(:) == 0);
            fp = mean(pat_state(:) == 0 & results(:) == 1);
            fn = mean(pat_state(:) == 1 & results(:) == 0);
            sensitivity(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = tp/(tp+fn);
            specificity(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = tn/(tn+fp);
            
            ppv(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = tp/(tp+fp);
            npv(p_inf_idx,pcr_sens_idx,pcr_spec_idx) = tn/(tn+fn);
            
            %Outpunt the progress in the command prompt
            cnt = cnt + 1;
            waitbar(cnt/num_sim,wb,sprintf("Progress:%3d%%.\n",uint8(cnt/num_sim*100)));
            %fprintf("Progress:%3d%%.\n",uint8(cnt/num_sim*100))
        end
    end
end
close(wb);

