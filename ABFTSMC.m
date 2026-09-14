%clear all;clc;
% Example: Read an Excel file
filename = 'data.xlsx';
data = xlsread(filename);  % Returns numeric data from the Excel file
plot(2014:2021,data)
title('Pertumbuhan Ekonomi Kabupaten Halmahera Tengah')
xlabel('Tahun')
ylabel('Pendapatan Asli Daerah')

% Membentuk Data Train dan Test
Ptrain = input('Presentase data train = ');
Ptest = input('Presentase data tes = ');
J = size(data,1);
Jtrain = Ptrain*J/100;
Jtest  = Ptest*J/100;
Dtrain = data(1:Jtrain,1);
Dtes = data(Jtrain+1:J,1);

% Menentukan interval dengan average-base
J = size(Dtrain,1);
dif(1,1) = Dtrain(1,1);
for n = 2:J
    dif(n,1) = Dtrain(n,1);
    dif(n,2) = Dtrain(n,1)-Dtrain(n-1,1);
end;
Adif = abs(dif)
disp('Rata-rata selisih dari data: ');
disp(Adif);
ratadif= mean(Adif(:,2));
Sratadif=ratadif/2;
% csvwrite('Rata-rata selisih dari data 90 10.csv',Adif)

% menentukan panjang interval sesuai basis interval
if Sratadif > 100
    interval = roundn(Sratadif,2);
elseif Sratadif > 10
    interval = roundn(Sratadif,1);
elseif Sratadif > 1
    interval = roundn(Sratadif,0);
else Sratadif > 0.1;
    interval = roundn(Sratadif,-1);
end;

% Step 1 definisi universe of discourse
bottom=min(data)
% csvwrite('Bottom 90 10.csv',bottom)
top=max(data)
% csvwrite('Top 90 10.csv',top)
 
Dmin=bottom(1,1)
Dmax=top(1,1)
disp('Data terkecil :')
disp(Dmin)
% csvwrite('Data terkecil 90 10.csv',Dmin)
disp('Data terbesar :')
disp(Dmax)
% csvwrite('Data terbesar 90 10.csv',Dmax)
 
D1=input('D1 = ');
D2=input('D2 = ');

Ubottom = Dmin-D1;
Utop=Dmax+D2;
disp('Universe of discourse = ');
disp(Ubottom);
% csvwrite('Ubottom 90 10.csv',Ubottom)
disp(Utop);
% csvwrite('Utop 90 10.csv',Utop)

countU=roundn((Utop-Ubottom)/interval,0);

U(1,1)= Ubottom;
for n=1:countU-1
    U(n,2)=U(n,1)+interval;
    U(n+1,1)=U(n,2);
    U(n,3)=n;
    U(n,4)=(U(n,1)+U(n,2))/2;
end;

U(countU,1)=Utop-interval;
U(countU,2)=Utop;
U(countU,3)=countU;
U(countU,4)=(U(countU,1)+U(countU,2))/2;

bb=1:countU;
fuzdata=Dtrain(:,1);
J=Jtrain;
for n=1:J
    for bb=1:countU
        if (Dtrain(n,1)>=U(bb,1))&&(Dtrain(n,1)<U(bb,2))
            fuzdata(n,2)=U(bb,3);
        end;
    end;
end;

fuzdata(1,3)=0;
fuzdata(1,4)=fuzdata(1,2)
for n=2:J
    fuzdata(n,3)=fuzdata(n-1,2);
    fuzdata(n,4)=fuzdata(n,2);
end;

temp = zeros(countU,countU);
for n=2:J
    temp(fuzdata(n,3),fuzdata(n,4)) = temp(fuzdata(n,3),fuzdata(n,4))+1;
end;
disp(temp)
% csvwrite('Fuzzy data 90 10.csv',fuzdata)
% csvwrite('Temp 90 10.csv',temp)

forecast_table(:,1)=U(:,3);
for n=1:countU
    if sum(temp(n,:))<1
        y = forecast_table(n,1);
        forecast_table(n,2) = U(y,4);
    elseif sum(temp(n,:)) >= 1
        x = temp(n,:);
        z = U(:,4);
        forecast_table(n,2)=((x(1:countU)*z)/sum(temp(n,:)));
    end;
end;

%Hasil Forecast
forecast(:,1) = fuzdata(:,2);
forecast(1,2) = data(1,1);
for m=2:size(forecast(:,1))
    for n=1:size(forecast_table)
        if (forecast_table(n,1) == forecast(m-1,1))
            forecast(m,2) = round(forecast_table(n,2));
        end
    end
end;

% Menghitung dt1 untuk melihat hubungan dengan state itu sendiri
for n=1:J
    for m=1:countU
        if fuzdata(n,2) == forecast_table(m,1)
            if temp(forecast_table(m,1),forecast_table(m,1)) >= 1
                Dt1(n,1) = interval/2;
            elseif temp(forecast_table(m,1),forecast_table(m,1)) == 0
                Dt1(n,1)= 0 ;
            end;
        end;
    end;
end;

%Adjustment value
for n=2:J
    perpindahan_state(n,1)=0;
    perpindahan_state(n,1)=fuzdata(n,2)-fuzdata(n-1,2);
end;

% menghitung Dt2
for n=1:J
    if perpindahan_state(n,1)==0
        Dt1(n,2)=Dt1(n,1);
        Dt2(n,1)=0;
    elseif perpindahan_state(n,1)<= -1
        Dt1(n,2) = Dt1(n,1)*(-1);
        y=perpindahan_state(n,1)
        tidak perlu dikali -1/2 karena perpindahannya sudah minus
        Dt2(n,1)=1/2*interval*y;
    else perpindahan_state(n,1) >= 1
        Dt1(n,2)=Dt1(n,1);
        y=perpindahan_state(n,1)
        Dt2(n,1) = 1/2*interval*y;
    end;
end;

% Adjustment forecasting
for n=1:J
    adjustment_forecasting(n,1) = forecast(n,2)+Dt2(n,1)+Dt1(n,2)
end;
% csvwrite('Adjustment Forecasting 90 10.csv',adjustment_forecasting)

% Membentuk Data Train dan Test
Data_asli_60 = csvread('Data asli 60.csv');
Data_asli_70 = csvread('Data asli 70.csv');
Data_asli_80 = csvread('Data asli 80.csv');
Data_asli_90 = csvread('Data asli 90.csv');

% Membaca file hasil adjustment forecasting
adjustment_forecasting_90_10 = csvread('Adjustment Forecasting 90 10.csv');
adjustment_forecasting_80_20 = csvread('Adjustment Forecasting 80 20.csv');
adjustment_forecasting_70_30 = csvread('Adjustment Forecasting 70 30.csv');
adjustment_forecasting_60_40 = csvread('Adjustment Forecasting 60 40.csv');

% MAPE
MAPE_60 = mean(abs((Data_asli_60-adjustment_forecasting_60_40)./Data_asli_60))*100;
MAPE_70 = mean(abs((Data_asli_70-adjustment_forecasting_70_30)./Data_asli_70))*100;
MAPE_80 = mean(abs((Data_asli_80-adjustment_forecasting_80_20)./Data_asli_80))*100;
MAPE_90 = mean(abs((Data_asli_90-adjustment_forecasting_90_10)./Data_asli_90))*100;
MAPE = [MAPE_60 MAPE_70 MAPE_80 MAPE_90];
plot(60:10:90,MAPE)
title('MAPE Average Based Fuzzy Time Series Markov Chain')
xlabel('Persentase Data Training (%)')
ylabel('MAPE (%)')

figure

MSE_60 = mean((Data_asli_60-adjustment_forecasting_60_40).^2);
MSE_70 = mean((Data_asli_70-adjustment_forecasting_70_30).^2);
MSE_80 = mean((Data_asli_80-adjustment_forecasting_80_20).^2);
MSE_90 = mean((Data_asli_90-adjustment_forecasting_90_10).^2);
MSE = [MSE_60 MSE_70 MSE_80 MSE_90];
plot(60:10:90,MSE)
title('MSE Average Based Fuzzy Time Series Markov Chain')
xlabel('Persentase Data Training (%)')
ylabel('MSE')
figure

% MAD
MAD_60 = mean(abs(Data_asli_60-adjustment_forecasting_60_40));
MAD_70 = mean(abs(Data_asli_70-adjustment_forecasting_70_30));
MAD_80 = mean(abs(Data_asli_80-adjustment_forecasting_80_20));
MAD_90 = mean(abs(Data_asli_90-adjustment_forecasting_90_10));
MAD = [MAD_60 MAD_70 MAD_80 MAD_90];
plot(60:10:90,MAD)
title('MAD Average Based Fuzzy Time Series Markov Chain')
xlabel('Persentase Data Training (%)')
ylabel('MAD')
figure

plot(2014:2021,data,'k')
hold on
plot(2014:(2014+(length(adjustment_forecasting_60_40)-1)),adjustment_forecasting_60_40,'r')
hold on
plot(2014:(2014+(length(adjustment_forecasting_70_30)-1)),adjustment_forecasting_70_30,'y')
hold on
plot(2014:(2014+(length(adjustment_forecasting_80_20)-1)),adjustment_forecasting_80_20,'g')
hold on
plot(2014:(2014+(length(adjustment_forecasting_90_10)-1)),adjustment_forecasting_90_10,'b')
title('Perbandingan Hasil Peramalan')
title('Pertumbuhan Ekonomi Kabupaten Halmahera Tengah')
xlabel('Tahun')
ylabel('Pendapatan Asli Daerah')
legend('Data','Forecasting 60:40','Forecasting 70:30','Forecasting 80:20','Firecasting 90:10')