function [result] = pcr_simple(samples,pcr_param)
%A very simple model of a PCR, where all samples are grouped columnwise. If
%any element within a group is logical true, the group is considered
%positive. The confusion of the results can be specified with the
%sensitivity and specificity of the pcr in pcr_param
%   The result will give a row vector with the result for each group with
%   the given confusion.

%Check groups for positive entries
state = any(samples,1);
%Init outputs
result = false(size(state));

%Generate Output with confusion
    %in the case of a positive group
result(state == 1) = rand(sum(state==1),1)<pcr_param.sensitivity;
    %in the case of a negative group
result(state == 0) = rand(sum(state==0),1)>pcr_param.specificity;
end

