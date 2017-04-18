nSamples = 10000;  
   
mu = [0 0]; % TARGET MEANĿ���ֵ  
rho(1) = 0.8; % rho_21Ŀ�귽��  
rho(2) = 0.8; % rho_12Ŀ�귽��  
   
% INITIALIZE THE GIBBS SAMPLER    
minn = [-3 -3];  
maxx = [3 3];  
   
% INITIALIZE SAMPLES  
x = zeros(nSamples,2);  
x(1,1) = unifrnd(minn(1), maxx(1));%unifrnd�����������ȷֲ��������  
x(1,2) = unifrnd(minn(2), maxx(2));  
   
dims = 1:2; % INDEX INTO EACH DIMENSION  
   
% RUN GIBBS SAMPLER  
t = 1;  
while t < nSamples
    t = t + 1;  
    T = [t-1, t];  
    for iD = 1 : 2 % 2-dimension
        % ���²�����  
        nIx = dims ~= iD; % *NOT* THE CURRENT DIMENSION�ҵ�����һάnIx=[0 1]logical����  
        % CONDITIONAL MEAN  
        muCond = mu(iD) + rho(iD)*(x(T(iD),nIx)-mu(nIx));%�����ֵ = ���ʽ��(1)+��(1)*(x(n,2)-��(2)) ����x(n,2)����������n�����ݵĵڶ�ά  
        % CONDITIONAL VARIANCE  
        varCond = sqrt(1 - rho(iD)^2);  %���㷽��  
        % DRAW FROM CONDITIONAL  
        x(t, iD) = normrnd(muCond, varCond);%��̬�ֲ��������������õ���ǰ��t�����ݵĵ�1ά����value  
    end  
end  
   
% ��ͼ
figure;  
h1 = scatter(x(:,1),x(:,2),'r.');%scatter���ɢ��ͼ��xΪ�����꣬yΪ������  
   
% CONDITIONAL STEPS/SAMPLES  
hold on;   %����ǰ��ʮ��������  
for t = 1:50  
    plot([x(t,1),x(t+1,1)],[x(t,2),x(t,2)],'k-');  
    plot([x(t+1,1),x(t+1,1)],[x(t,2),x(t+1,2)],'k-');  
    h2 = plot(x(t+1,1),x(t+1,2),'ko');  
end  
   
h3 = scatter(x(1,1),x(1,2),'go','Linewidth',3);  
legend([h1,h2,h3],{'Samples','1st 50 Samples','x(t=0)'},'Location','Northwest')  
hold off;  
xlabel('x_1');  
ylabel('x_2');  
axis square  