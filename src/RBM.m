% һ����˵�����ӽڵ����ĿҪ�������ؽڵ�
% ����㷨������һ���MC������ԭ����ʹ�����˻��˼�룬���ֱ�ӹ���PA��PB��������
% ���ܴ󣬵����������һ��ƽ�ȵ����оͿ���ʹ��PA��PBʮ�ֽӽ���
% ���������Ǵ�һ��������״̬��ʼ���ϵ��˻���������Ҫ�Ľ��

% ��Gibbs������MCMC��һ��������������Ĺ̶�ĳһά��xi��Ȼ��ͨ������ά��x��i��ֵ��������ά�ȵ�ֵ
% ע�⣬gibbs����ֻ��z�Ǹ�ά��2ά���ϣ������Ч��

% logZZ_est                  -- estimate of Z
% parameter_W            -- a matrix of RBM weights [numvis, numhid]
% parameter_a              -- a row vector of hidden  biases [1 numhid]
% parameter_b              -- a row vector of visible biases [1 numvis]
% numruns                   -- number of AIS runs
% beta                          -- a row vector containing beta's, (the inverse temperature��
% testbatchdata            -- the data that is divided into batches (numcases numdims numbatches)  

close all; clc; clear all; home;
load('h20.mat');
load('test.mat');
numruns = 10;

% in different stage, we can have different step
beta = 0 : 0.00001 : 1;

% Base model
[numVisible, numHidden] = size(parameter_W); 
visibleBiases_A = 0*parameter_b;

% copy the three paramters to run repeatly
visibleBias_A = repmat(visibleBiases_A, numruns, 1); % biases of base model.  
hiddenBias_B = repmat(parameter_a, numruns, 1); 
visibleBias_B = repmat(parameter_b, numruns, 1);  

% Sample from the base model
logw_AIS = zeros(numruns, 1);
visible_B = repmat(1./(1+exp(-visibleBiases_A)), numruns, 1);  
visible_B = visible_B > rand(numruns, numVisible);
logw_AIS  =  logw_AIS - (visible_B*visibleBiases_A' + numHidden*log(2));

% update parameters
WightAndHidden = visible_B*parameter_W + hiddenBias_B; 
Bv_base = visible_B*visibleBiases_A';
Bv = visible_B*parameter_b';   
logZ_A = sum(log(1 + exp(visibleBiases_A))) + (numHidden)*log(2);  % the log-likehood of Z of PA

% the core process of  AIS, using a random sequence to transfer from PA to PB
temp = 1;
drawPlot = zeros(size(beta)-1);  % for drawing
for eachBeta = beta(2 : end-1)
    % iteration 1
    expWh = exp(eachBeta*WightAndHidden);
    logw_AIS  =  logw_AIS + (1 - eachBeta)*Bv_base + eachBeta*Bv + sum(log(1+expWh), 2);
    
    % gibbs sample the new v', using losgistic function
    hidden_B = expWh ./ (1 + expWh) > rand(numruns, numHidden); 
    visible_B = 1 ./ (1 + exp(-(1-eachBeta)*visibleBias_A - eachBeta*(hidden_B*parameter_W' + visibleBias_B))); 
    visible_B = visible_B > rand(numruns, numVisible); % random number between 0 and 1
    
    % update parameters
    WightAndHidden = visible_B*parameter_W + hiddenBias_B;
    Bv_base = visible_B*visibleBiases_A';
    Bv = visible_B*parameter_b';
    
    % draw current value
    if mod(temp, 500) == 0
        fprintf('In step %d. The variance of weight is : %f \n', temp/500, var(logw_AIS( : )));
    end
    drawPlot(temp) = var(logw_AIS( : ));
    
    % iteration 2
    expWh = exp(eachBeta*WightAndHidden);
    logw_AIS  =  logw_AIS - ((1-eachBeta)*Bv_base + eachBeta*Bv + sum(log(1+expWh), 2));
    
    temp = temp + 1;
end 

% draw the variance of logw_AIS
figure(1);
plot(drawPlot, 'b.');
grid on;
xlabel('the step of beta');
ylabel('the variance of logw_AIS');

%------------------------------------------------------------------------------------------------------------------------
logw_AIS  = logw_AIS + visible_B*parameter_b' + sum(log(1+expWh), 2);
% logAndSum returns the log of sum of logs, use w_AIS to get r_AIS (the ratio of two state)
% the function is log(sum(exp(x))) = alpha + log(sum(exp(x-alpha)));
xdims = size(logw_AIS);
dim = find(xdims > 1);
alpha = max(logw_AIS, [ ], dim) - log(realmax) / 2;
repdims = ones(size(xdims)); 
repdims(dim) = xdims(dim);
logsum = alpha + log(sum(exp(logw_AIS - repmat(alpha, repdims)), dim));
% get r_AIS
r_AIS = logsum - log(numruns);   
% exp(r_AIS) = PB/PA, so logZZ = log(exp(r_AIS)) + log_base 
logZ_B = r_AIS + logZ_A;  


%-------------------------------------------------------------------------------------------------------------------------
% Estimate Test Log-Probability
%--------------------------------------------------------------------------------------------------------------------------
[~, numVisible, numbatches] = size(testbatchdata);
data = [];
for ii = 1 : numbatches
    data = [data; testbatchdata(: , : , ii)];
end

% the count of the test set
[numruns, numdims]  = size(data);  
% sum(A, 2) means get sum of matrix A's every crow, the result is a column
pd = data * parameter_b' + sum(log(1 + exp(ones(numruns, 1) * parameter_a + data * parameter_W)), 2); % *
% log-likehood of P(v) 
logprob = sum(pd)/numruns - logZ_B; % *
% output the partition function and log_pro
fprintf(1, 'Estimated  log-partition function : %f \n', logZ_B);
fprintf(1, 'Average estimated log_prob on the test data : %f\n', logprob);



