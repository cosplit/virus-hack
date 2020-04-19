classdef pcr_advanced
	properties
        min_concentration = 4
        max_concentration = 10
        sensitivity_above_max = 0.995
        prob_primer_cluster = 0.01;
        conc_distr
        prob_inside_sample = 1/200;
        sensitivity
        specificity
    end
	methods
        function obj = pcr_advanced()
            load('viral_load.mat');
            obj.conc_distr = concentration_dist;
        end
        function specificity = get.specificity(obj)
            specificity = 1- obj.prob_primer_cluster;
        end
        
        function sensitivity = get.sensitivity(obj)
            obj.conc_distr;
            sel_ful = obj.conc_distr(:,1)*obj.prob_inside_sample>= obj.max_concentration;
            sel_half = obj.conc_distr(:,1)*obj.prob_inside_sample< obj.max_concentration & obj.conc_distr(:,1)*obj.prob_inside_sample>= obj.min_concentration;
            sensitivity = sum(obj.conc_distr(sel_ful,2))+ sum(obj.conc_distr(sel_half,2))/2;
        end
        
        function [patient] = generatePatients(obj,groupsize,iterations,p_inf)
            patient.state = rand(groupsize, iterations) < p_inf;
            patient.data = zeros(size(patient.state));
            num_pos = sum(patient.state(:));
            
            CDF = [0;cumsum(obj.conc_distr(:,2))];
            rand_vals = rand(num_pos,1);
            out_val = interp1(CDF,0:1/(length(CDF)-1):1,rand_vals); %spans zero to one
            ind = ceil(out_val*length(obj.conc_distr(:,1)));
            patient.data(patient.state) = obj.conc_distr(ind,1);
        end
        
        
        function [result] = test(obj,samples)
        %A very simple model of a PCR, where all samples are grouped columnwise. If
        %any element within a group is logical true, the group is considered
        %positive. The confusion of the results can be specified with the
        %sensitivity and specificity of the pcr in pcr_param
        %   The result will give a row vector with the result for each group with
        %   the given confusion.

        conc = round(mean(samples,1));
        
        
        %Init outputs
        result = false(size(conc));
        
        %Check groups for concentration
        %num_virus_part = binornd(conc,obj.prob_inside_sample);
        num_virus_part = poissrnd(conc*obj.prob_inside_sample);
        %Check for concentration for robust detection.
        sel = num_virus_part>=obj.max_concentration;
        result(sel) = rand(sum(sel),1) < obj.sensitivity_above_max;
        
        %Check for available concentration below robust detection.
        sel = num_virus_part<obj.max_concentration | num_virus_part >= obj.min_concentration;
        virt_sel = num_virus_part(sel);
        diff_conc = obj.max_concentration-obj.min_concentration;
        result(sel) = rand(sum(sel),1)' < (virt_sel-obj.min_concentration)/diff_conc * obj.sensitivity_above_max;

        %Check for primer clustering
        result(rand(size(result))<obj.prob_primer_cluster) = true;
        end
    end
end



