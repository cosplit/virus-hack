function [label_list] = plotit(name_label,label_list)
%PLOTIT Summary of this function goes here
%   Detailed explanation goes here
holdflag = 1;
if ~exist("label_list")
    holdflag = 0;
    label_list = ["optimal";"individual test"];
end
label_list = [label_list;name_label];

p_inf_sw = evalin('base', 'p_inf_sw');
eff_of_single_test = evalin('base', 'eff_of_single_test');
efficiency_strategy = evalin('base', 'efficiency_strategy');
num_tests_per_patient_mean  = evalin('base', 'num_tests_per_patient_mean');
sensitivity = evalin('base', 'sensitivity');
specificity = evalin('base', 'specificity');
ppv = evalin('base', 'ppv');
npv = evalin('base', 'npv');

pcr_sensitivity = evalin('base', 'pcr_sensitivity');
pcr_specificity = evalin('base', 'pcr_specificity');

pcr_tp = pcr_sensitivity * p_inf_sw;
pcr_tn = pcr_specificity * (1-p_inf_sw);
pcr_fp = (1-pcr_specificity) * (1-p_inf_sw);
pcr_fn = (1-pcr_sensitivity) * p_inf_sw;

pcr_ppv = pcr_tp./(pcr_tp+pcr_fp);
pcr_npv = pcr_tn./(pcr_tn+pcr_fn);

subplot(2,3,1);
if(holdflag == 0)
    hold off;
    loglog(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    loglog(p_inf_sw,eff_of_single_test);
else
    hold on
end
loglog(p_inf_sw,efficiency_strategy);
legend(label_list);
title("Informational efficiency");
xlabel("prevalence");
ylabel("efficiency");


subplot(2,3,4);
if(holdflag == 0)
    hold off;
    loglog(p_inf_sw,eff_of_single_test);
    hold on;
    loglog(p_inf_sw,ones(size(p_inf_sw)));
else
    hold on
end
loglog(p_inf_sw,num_tests_per_patient_mean);
legend(label_list);
title("Average number of tests per tested person");
xlabel("prevalence");
ylabel("Average number of tests per tested person");


subplot(2,3,2);
if(holdflag == 0)
    hold off;
    plot(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    plot(p_inf_sw,pcr_sensitivity*ones(size(p_inf_sw)));
else
    hold on
end
plot(p_inf_sw,sensitivity);
legend(label_list);
title("Sensitivity TP/(TP+FN)");
xlabel("prevalence");
ylabel("Sensitivity");

subplot(2,3,5);
if(holdflag == 0)
    hold off;
    plot(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    plot(p_inf_sw,pcr_specificity*ones(size(p_inf_sw)));
else
    hold on
end
plot(p_inf_sw,specificity);
legend(label_list);
title("Specificity TN/(TN+FP)");
xlabel("prevalence");
ylabel("Specificity");


subplot(2,3,3);
if(holdflag == 0)
    hold off;
    plot(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    plot(p_inf_sw,pcr_ppv);
else
    hold on
end
plot(p_inf_sw,ppv);
legend(label_list);
title("Positive predictive value TP/(TP+FP)");
xlabel("prevalence");
ylabel("PPV");

subplot(2,3,6);
if(holdflag == 0)
    hold off;
    plot(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    plot(p_inf_sw,pcr_npv);
else
    hold on
end
plot(p_inf_sw,npv);
legend(label_list);
title("Negative predictive value TN/(TN+FN)");
xlabel("prevalence");
ylabel("NPV");

end

