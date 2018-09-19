n = (0 : 10000);
Fs = 10000;

y = round (rand (1, 10000)  * 2^15); %Gaussov signal
t = (0:length(y)-1)/Fs;



FID = fopen('IZLAZ_data7.txt');
ulaz = textscan(FID, '%s');
fclose(FID);
sum = 0;
N = size(ulaz{1});
ul = zeros(10000, 1);
for i = 1 : N
    ul(i) = hex2dec(ulaz{1}{i});
    sum = sum + ul(i);
end
prosjek = sum / 10000
for i = 1 : N
    ul = ul - prosjek;
end

figure;
plot(t,fftshift(abs(fft(ul))));

