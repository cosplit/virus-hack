function [] = plotit(name_label)
%PLOTIT Summary of this function goes here
%   Detailed explanation goes here
holdflag = 1;
persistent label_list
persistent fig
if isempty(fig)
    fig = figure;
end
if isempty(label_list) || ~exist("name_label")
    holdflag = 0;
    label_list = ["optimal";"individual test"];
end

plotnew_flag = 0;
if exist("name_label")
    label_list = [label_list;name_label];
    plotnew_flag = 1;
end

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
if plotnew_flag
    loglog(p_inf_sw,efficiency_strategy);
end
legend(label_list,'Location','southeast');
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
if plotnew_flag
    loglog(p_inf_sw,num_tests_per_patient_mean);
end
legend(label_list);
title("Average number of tests per tested person");
xlabel("prevalence");
ylabel("Average number of tests per tested person");


subplot(2,3,2);
if(holdflag == 0)
    hold off;
    semilogx(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    semilogx(p_inf_sw,pcr_sensitivity*ones(size(p_inf_sw)));
else
    hold on
end
if plotnew_flag
    semilogx(p_inf_sw,sensitivity);
end
legend(label_list);
title("Sensitivity TP/(TP+FN)");
xlabel("prevalence");
ylabel("Sensitivity");

subplot(2,3,5);
if(holdflag == 0)
    hold off;
    semilogx(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    semilogx(p_inf_sw,pcr_specificity*ones(size(p_inf_sw)));
else
    hold on
end
if plotnew_flag
    semilogx(p_inf_sw,specificity);
end
legend(label_list);
title("Specificity TN/(TN+FP)");
xlabel("prevalence");
ylabel("Specificity");


subplot(2,3,3);
if(holdflag == 0)
    hold off;
    semilogx(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    semilogx(p_inf_sw,pcr_ppv);
else
    hold on
end
if plotnew_flag
    semilogx(p_inf_sw,ppv);
end
legend(label_list);
title("Positive predictive value TP/(TP+FP)");
xlabel("prevalence");
ylabel("PPV");

subplot(2,3,6);
if(holdflag == 0)
    hold off;
    semilogx(p_inf_sw,ones(size(p_inf_sw)));
    hold on;
    semilogx(p_inf_sw,pcr_npv);
else
    hold on
end
if plotnew_flag
    semilogx(p_inf_sw,npv);
end
legend(label_list);
title("Negative predictive value TN/(TN+FN)");
xlabel("prevalence");
ylabel("NPV");

end

