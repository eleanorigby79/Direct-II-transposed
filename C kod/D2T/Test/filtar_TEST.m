close all;
n = (0 : 10000);
Fs = 8000;

y = round (rand (1, 10000)  * 2^15); %Gaussov signal
t = (0:length(y)-1)/Fs;

ULAZ = dec2hex(typecast(int16(y), 'uint16'));

fileID = fopen('ULAZ_data.txt', 'w');
fclose(fileID);
dlmwrite('ULAZ_data.txt',ULAZ,'delimiter','%c%c%c%c');
edit ULAZ_data.txt;

[b,a] = butter(4,0.2,'high'); %Koeficijetni LP filtra Fg=0.2 s pravokutnim prozorom
freqz(b,1) %Bode plot projektiranog filtra

IZLAZ = filter(b,a,y);

%Crtanje karakteristike porjektirane u MATLABu
subplot(2,1,1);
plot(t,abs(fftshift(fft(y))));
title('Original Signal');
axis([0 1 -50 2*10^6]);

subplot(2,1,2);
plot(t,abs(fftshift(fft(IZLAZ))));
title('IZLAZ Signal');
axis([0 1 -50 2*10^6]);

%Crtanje karakteristiek dobivene u C-u
figure;

fileID = fopen('IZLAZ_data7.txt','r');  %Dohvat podataka iz file (koji je iz Ca)
formatSpec = '%hX';
A = dec2hex((fscanf(fileID, formatSpec)));
B = typecast(uint16(base2dec(A, 16)), 'int16');
IZLAZ_C = B;
IZLAZ_C = IZLAZ_C'; 
fclose(fileID);
clear A;
clear B;

%Prikaz rezultata dobivenih u C-u
subplot(2,1,1);
plot(t,abs(fftshift(fft(y))));
title('Original Signal');
axis([0 1 -50 2*10^6]);

subplot(2,1,2);
plot(t,abs(fftshift(fft(IZLAZ_C))));
title('IZLAZ Signal');
axis([0 1 -50 2*10^6]);
