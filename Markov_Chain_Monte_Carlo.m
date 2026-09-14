clear all;clc
%% read in CSV data
filename = 'data.xlsx';
data = xlsread(filename);  % Returns numeric data from the Excel file
year = [2014:2021];
newdata=horzcat(year',data);
plot(newdata(:,1),newdata(:,2))
title('Pertumbuhan Ekonomi Kabupaten Halmahera Tengah')
xlabel('Tahun')
ylabel('Pendapatan Asli Daerah')

%% MCMC
% first guess for params
params0 = [1;8];

% first loglikelihood
ll_init = ll_function(newdata, params0);

% keeping track of params and LLs
paraset = [];
paraset = [paraset params0];

loglikelihoodset = [];
loglikelihoodset = [loglikelihoodset ll_init];

all_guesses = [];
all_guesses = [all_guesses params0];

run_num = 10000;

for i = 2:run_num
    % keep track of progress
    if rem(i,100)==0
        i/run_num
    end

    paramtest = [random('Uniform',0,2); random('Uniform', 0,10000)];
    ll_test = ll_function(newdata, paramtest);

    % Metropolis - Hastings
    if ll_test >= loglikelihoodset(end) + log(random('Uniform',0,1))
        loglikelihoodset = [loglikelihoodset ll_test];
        paraset = [paraset paramtest];
        all_guesses = [all_guesses paramtest];
    else
        loglikelihoodset = [loglikelihoodset loglikelihoodset(end)];
        paraset = [paraset paraset(:,end)];
        all_guesses = [all_guesses paramtest];        
    end
end
%% plots
figure
subplot(2,1,1);
histogram(all_guesses(1,:));
title('r Prior Distribution');

subplot(2,1,2);
histogram(paraset(1,:));
title('r Posterior Distribution');
xlabel('Parameter Value') ;
ylabel('Occurences'); 

figure
subplot(2,1,1);
histogram(all_guesses(2,:));
title('K Prior Distribution');

subplot(2,1,2);
histogram(paraset(2,:));
title('K Posterior Distribution');
xlabel('Parameter Value') ;
ylabel('Occurences'); 

%% Take the random sampel from posterior distribution
sampleIndex = randi(run_num);
sampleParams = paraset(:,sampleIndex);

%% Create the prediction data based on the sample parameter-model
predictionData = datagen(newdata(:,1),sampleParams);

%% Visualize the result
disp('Data observasi:')
disp(newdata)
disp('Data Prediksi:')
disp(predictionData)

figure
subplot(2,1,1);
plot(newdata(:,1),newdata(:,2),'b-','LineWidth',2);
title('Data Aktual')
xlabel('Tahun')
ylabel('Pendapatan Asli Daerah')

subplot(2,1,2);
plot(newdata(:,1),predictionData(:,2),'r-','LineWidth',2);
title('Hasil Prediksi Markov Chain Monte Carlo')
xlabel('Tahun')
ylabel('Pendapatan Asli Daerah')

%% Accuracy check
mse = calculateMSE(newdata(:,2),predictionData(:,2));
rmse = sqrt(mse)
disp(['Mean Squared Error (MSE):',num2str(mse)])
disp(['Root Mean Squared Error (RMSE):',num2str(rmse)])

%% functions to use
function [dxdt] = sim(t,x,theta)
% variable for cell counts
X = x(1);
r = theta(1); 
K = theta(2); 

dXdt = r*X * (1 - X/K);
dxdt = [dXdt];
end

function [out] = datagen(timepoints,theta)
[t,y] = ode23s(@sim, timepoints, [1],[],theta);
out = [t,sum(y,2)];
end

function [loglikelihood] = ll_function(data,theta)
[testdata] = datagen(data(:,1),theta);
loglikelihood = sum(log(pdf('Normal', data(:,2), testdata(:,2), 1000)));
end

function mse = calculateMSE(data,predictions)
mse = mean((data-predictions).^2);
end