function f=fos(N,fs)
deltaf=fs/N;
if mod(N,2)==0 % N je paran
 f=linspace(-fs/2,fs/2-deltaf,N);
else % N je neparan
 f=linspace(-(fs-deltaf)/2,(fs-deltaf)/2,N);
end 