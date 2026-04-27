%% This repository provides a lightweight workflow-level mock-up script for the proposed multi-step optimized Compare R method.
% The script is intended to demonstrate the main computational pipeline, 
% including initialization of the base data set, symmetric-stage selection, switching to the asymmetric candidate set, 
% orthogonality filtering, and output of the optimized array set.

%% The script does not contain the full production MATLAB/GPU implementation used in the manuscript. 
% The full implementation relies on large precomputed Jacobian matrices, two-electrode sensitivity data, and hardware-dependent GPU acceleration. 
% Therefore, the mock-up script is provided only to improve the transparency of the algorithmic workflow.

close all; clc; clear;

rng(1);
Ttotal = tic;

numele = 48;
data_point = 4092;
increase = 0.05;
threshold = 0.97;
switch_ratio = 0.75;

num_base = 300;
num_symme = 3000;
num_unsym = 6000;
num_model_cells = 500;

confi_base = (1:num_base)';
confi_symme = (num_base+1:num_base+num_symme)';
confi_unsym = (num_base+num_symme+1:num_base+num_symme+num_unsym)';

index_optim = confi_base;

num_index_optim = length(index_optim);
iter = ceil(log(data_point/num_index_optim)/log(1+increase));

temp = 1;
S = zeros(iter+5,1);
S(temp) = 0.35;

stage_record = strings(iter+5,1);
num_record = zeros(iter+5,1);

index_test = confi_symme;
current_stage = "symmetric";

while length(index_optim) < data_point

    if temp > ceil(iter*switch_ratio) && current_stage == "symmetric"
        index_test = confi_unsym;
        current_stage = "asymmetric";
    end

    temp_num = min(floor(increase*num_index_optim), data_point - length(index_optim));
    temp_num = max(temp_num,1);

    Fcr = mock_ranking_function(index_test,current_stage);

    [~,sorted_indices] = sort(Fcr,'descend');

    best_ones = mock_orthogonality_filter(sorted_indices,temp_num,threshold,num_model_cells);

    index_best = index_test(best_ones);

    index_optim = [index_optim; index_best];

    index_test(best_ones) = [];

    num_index_optim = length(index_optim);

    S(temp+1) = mock_resolution_update(S(temp),current_stage,temp_num);

    stage_record(temp) = current_stage;
    num_record(temp) = temp_num;

    temp = temp + 1;

    if isempty(index_test)
        break;
    end
end

confi_optim = index_optim;

Time_all = toc(Ttotal);

figure;
plot(S(1:temp),'-o');
xlabel('Iteration number');
ylabel('Mock average relative model resolution');
grid on;

workflow_summary = table((1:temp-1)',stage_record(1:temp-1),num_record(1:temp-1), ...
    'VariableNames',{'Iteration','Stage','Number_of_added_arrays'});

disp(workflow_summary);
disp(['Total selected arrays = ',num2str(length(confi_optim))]);
disp(['Total workflow time = ',num2str(Time_all),' s']);



function Fcr = mock_ranking_function(index_test,current_stage)

n = length(index_test);

if current_stage == "symmetric"
    Fcr = 0.6 + 0.4*rand(n,1);
else
    Fcr = 0.4 + 0.6*rand(n,1);
end

end

function best_ones = mock_orthogonality_filter(sorted_indices,temp_num,threshold,num_model_cells)

best_ones = zeros(temp_num,1);

selected_vectors = [];

j = 1;
i = 1;

while j <= temp_num && i <= length(sorted_indices)

    candidate_vector = randn(1,num_model_cells);
    candidate_vector = candidate_vector./norm(candidate_vector);

    if isempty(selected_vectors)
        best_ones(j) = sorted_indices(i);
        selected_vectors = candidate_vector;
        j = j + 1;
    else
        I = abs(selected_vectors*candidate_vector');
        if max(I) < threshold
            best_ones(j) = sorted_indices(i);
            selected_vectors = [selected_vectors; candidate_vector];
            j = j + 1;
        end
    end

    i = i + 1;
end

best_ones = best_ones(best_ones>0);

end

function S_new = mock_resolution_update(S_old,current_stage,temp_num)

if current_stage == "symmetric"
    gain = 0.004*log(1+temp_num);
else
    gain = 0.006*log(1+temp_num);
end

S_new = min(S_old + gain,0.95);

end