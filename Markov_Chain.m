%Constructing data-driven Markov Chains with Matlab
%Example 1.
%(JESSE DORRESTIJN, 7 June 2016)
% A Finite State Markov chain has a finite number of states and it switches
% between these states with certain probabilities. These probabilities can
% be put into a matrix P. If the Markov chain has 2 states, this transition
% probability matrix is of size 2 x 2. On the diagonal are the
% probabilities that the state does not change in one time-step from t to
% t+1. The other probabilities are off the diagonal. For example, the
% probability that it switches from state 1 to state 2 is at place (1,2) in
% the matrix. Together with an initial value, the Markov chain can produce
% sequences.
%
% A Markov chain can be used to mimic a certain process. If a process has
% for example only two states, and a long sequence is available, transition
% probabilities of the Markov chain can be estimated from this sequence.
%
% In the following example, we first construct a sequence with only two
% states. This sequence, which we call the observations y_obs, will be used
% to estimate transition probabilities of a Markov chain and put into a
% matrix P_MC.
%
% Finally, we will use the Markov chain to construct a sequence y_MC which is
% similar to the original y_obs sequence. We will plot the two sequences.
%
% The length of the original sequence L can be adjusted. Then, the
% probability matrix P_MC can be compared to P_obs.
%
% Also the transition probabilities can be adjusted.
%

clear all
clc
close all

%YOUR INPUT:
p11 = 0.9;            %Transition 0<prob<1 to switch from state 1 to state 1.
p22 = 0.9;             %Transition 0<prob<1 to switch from state 2 to state 2.
% T = 500;               %Plot the first T states of the sequence. T should be smaller than L.

%First we produce a sequence that we later use as observational data
%for the construction of the Markov chain.
filename = 'data.xlsx';
y_obs = xlsread(filename);         %y_obs will be the input or OBServational sequence.
L = length(y_obs);            %length of observational sequence.
P = [p11,1-p11;1-p22,p22];    %transition matrix used to construct input sequence.
P_cum = [P(:,1),[1;1]];     %cumulative version of P.
% y_obs(1) = 1;               %sequence starts with a 1;

% for t=1:L-1                 %construct entire sequence
%     r = rand;
%     y_obs(t+1) = sum(r>P_cum(y_obs(t),:))+1;
% end

%Plot the sequence:

figure(1)
subplot(2,1,1)
plot(y_obs(1:(80*size(y_obs)/100),1))          %plot the first T states of the sequence
set(gca,'YTick',[1 2])
xlabel('observations')
ylabel('state')

%%
%Estimation of transition probability matrix.

P_MC = zeros(2,2);
for t=1:(length(y_obs)-1)
    P_MC(y_obs(t),y_obs(t+1))= P_MC(y_obs(t),y_obs(t+1))+1;
end

P_MC(1,:) = P_MC(1,:)/sum(P_MC(1,:));
P_MC(2,:) = P_MC(2,:)/sum(P_MC(2,:));

%Compare estimated matrix P_MC with initial matrix P.

P
P_MC

%%
%Produce sequence with the Markov chain.

y_MC = zeros(L,1);                %y_obs will be the input or OBServational sequence.
P_MC_cum = [P_MC(:,1),[1;1]];     %cumulative version of P_MC.
y_MC(1) = 1;                      %sequence starts with a 1;

for t=1:L-1                       %construct entire sequence
    r = rand;
    y_MC(t+1) = sum(r>P_MC_cum(y_MC(t),:))+1;
end

%Plot sequence:

figure(1)
subplot(2,1,2)
plot(y_MC(1:(80*size(y_obs)/100),1))          %plot the first T states of the sequence (T defined above).
set(gca,'YTick',[1 2])
xlabel('Markov Chain')
ylabel('state')



