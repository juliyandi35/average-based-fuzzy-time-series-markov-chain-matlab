%Constructing data-driven Markov Chains with Matlab
%Example 2.
%(JESSE DORRESTIJN, 7 June 2016)
% Let us do almost the same as in Example 1. However, now we will consider Markov
% chains with more than 2 states. Now, let N>2 be the number of states.
%

clear
clc
close all

%YOUR INPUT:
N = 5;                 %Number of states of the Markov Chain.
L = 100000;            %length of observational sequence.
T = 500;               %Plot the first T states of the sequence. T should be smaller than L.

%First we produce a sequence that we later use as observational data
%for the construction of the Markov chain.

y_obs = zeros(L,1);         %y_obs will be the input or OBServational sequence.
P = rand(N);                %randomly chosen transition probability matrix used to construct input sequence.
P_cum = P;
for j=2:N
    P_cum(:,j) = P_cum(:,j-1) + P(:,j);     %cumulative version of P.
end
for j=1:N
    P(:,j) = P(:,j)./P_cum(:,N);                 %Normalize transition matrix
end
P_cum = P;
for j=2:N
    P_cum(:,j) = P_cum(:,j-1) + P(:,j);     %normalized cumulative version of P.
end

y_obs(1) = 1;               %sequence starts with a 1;

for t=1:L-1                 %construct entire sequence
    r = rand;
    y_obs(t+1) = sum(r>P_cum(y_obs(t),:))+1;
end

%Plot the sequence:

figure(1)
subplot(2,1,1)
plot(y_obs(1:T))          %plot the first T states of the sequence
xlim([-10 T+10])
ylim([0.5 N+0.5])
set(gca,'YTick',1:N)
xlabel('observations')
ylabel('state')

%%
%Estimation of transition probability matrix.

P_MC = zeros(N,N);
for t=1:L-1
    P_MC(y_obs(t),y_obs(t+1))= P_MC(y_obs(t),y_obs(t+1))+1;
end
P_MC_cum = P_MC;
for j=2:N
    P_MC_cum(:,j) = P_MC_cum(:,j-1) + P_MC(:,j);     %cumulative version of P.
end
for j=1:N
    P_MC(:,j) = P_MC(:,j)./P_MC_cum(:,N);                 %Normalize transition matrix
end
P_MC_cum = P_MC;
for j=2:N
    P_MC_cum(:,j) = P_MC_cum(:,j-1) + P_MC(:,j);     %normalized cumulative version of P.
end

%Compare estimated matrix P_MC with initial matrix P.

P
P_MC

%%
%Produce sequence with the Markov chain.

y_MC = zeros(L,1);                %y_obs will be the input or OBServational sequence.
y_MC(1) = 1;                      %sequence starts with a 1;

for t=1:L-1                       %construct entire sequence
    r = rand;
    y_MC(t+1) = sum(r>P_MC_cum(y_MC(t),:))+1;
end

%Plot sequence:

figure(1)
subplot(2,1,2)
plot(y_MC(1:T))          %plot the first T states of the sequence (T defined above).
xlim([-10 T+10])
ylim([0.5 N+0.5])
set(gca,'YTick',1:N)
xlabel('Markov Chain')
ylabel('state')



