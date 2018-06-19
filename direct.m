% funkcija za direktnu realizaciju IIR filtra
function [magr,phaser,inum,iden,iin_scale,ss]=direct(num,den,brbit,xxx,hhh);
% num=koeficijenti brojnika
% den=koeficijenti nazivnika
% brbit= broj bitova
% xxx=da li pokazati medjurezultate(xxx=1) ili ne(xxx=0)
% hhh=hendl od glavnog figur-ea
if xxx==1,
   set(hhh,'visible','off');
   sl1=figure;
   gcf=sl1;
   set(sl1, 'Visible', 'off');
end;
brtoc=512;                      % broj tocaka u kojima se racuna H(exp(j*om))

k=max(abs(num));                % magnituda najveceg elementa brojnika
num=num/k;                      % skaliraj brojnik
k2=max(abs(den));               % magnituda najveceg elementa nazivnika
if (k2>1),                      % ako je veca od 1
   k2=ceil(log10(k2)/log10(2));  % prva veca potencija broja 2 > od k2
   k2=2^k2;                      % k2 faktor kojim treba dijeliti naz da
   den=den/k2;                   % bi se 1/a0 mogao realizirati kao shifter
   k=k/k2;                       % rezultirajuci k faktor
end;
tt=size(den);
N=max(tt)-1;                    % red sistema
tt=size(num);
rb=max(tt);                     % red brojnika
if (N>rb),                      % ako je red brojnika manji nego red sistema
   num=[num 0*ones(1,N-rb)];     % dodaj mu nule na kraj
end;

if xxx==1,
   fprintf('\nPrenosna funkcija H(z) u obliku:\n');
   fprintf('\n                      -1                   -%.0f',N);
   fprintf('\n          b(0) + b(1)z  +   ....    + b(%.0f)z  ',N);
   fprintf('\nH(z)= k * -----------------------------------');
   fprintf('\n                      -1                   -%.0f',N);
   fprintf('\n          a(0) + a(1)z  +   ....    + a(%.0f)z  ',N);
   fprintf('\n\n S koeficijentima : \n');
   for i=1:N+1,
      fprintf('\n      b(%.0f) = %3.4f',i-1,num(i));
      fprintf('     a(%.0f) = %3.4f',i-1,den(i));
   end;
   fprintf('\n\n i faktorom pojacanja k = %f\n',k);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;
% testiranje dinamike po cvorovima

% za nazivnik

mag=ones(brtoc,N);          % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(1,den,brtoc);  % nadji odziv cijelog nazivnika (cvor iza 1/a0)
mag(:,1)=abs(h);            % apsolutnu vrijednost ubaci u matricu

for i=1:N-1,
   [h,wo]=freqz([0*ones(1,N-i) den([N-i+1:N+1])],den,brtoc);
   mag(:,i+1)=abs(h);
end;

if xxx==1,
   sl1;
   set(sl1, 'Visible', 'on');
   plot(wo/(2*pi),20*log10(mag));
   xlabel('Frekvencija (1=frekv. otipkavanja)');
   ylabel('Pojacanje (dB)');
   title('Dinamika cvora 1/a0 (zuto), dinamika sumatora nazivnika (ostali)');
   grid;
   pause;
   set(sl1, 'Visible', 'off');
end;

mmag=max(mag);   % nadji maksimume za pojedine cvorove

if xxx==1,
   fprintf('\nMaximalna dinamika po cvorovima nazivnika za sinusnu pobudu :\n\n');
   fprintf('Cvor stanja (1/a0) : %3.4f\n',mmag(1));
   for i=2:N,
      fprintf('Sumator %.0f : %3.4f\n',N-i+2,mmag(i));
   end;
   fprintf('Sumator 1 : %3.4f\n',mmag(1)*den(1));
end;

scalnaz=1/max(mmag);
if scalnaz>1,
   scalnaz=1;
else,
   k=k/scalnaz;
end;
if xxx==1,
   if (scalnaz>1),
      fprintf('\nDinamika u svim cvorovima je manja od 1 i nema overload-a\n');
   else,
      fprintf('\nPotrebni faktor skale da ne dodje do overload-a niti u jednom\n');
      fprintf('cvoru nazivnika   .... = %3.4f\n',scalnaz);
      fprintf('Trenutni totalni faktor = %f\n',k);
   end;
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;

% za brojnik

mag=ones(brtoc,N);            % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(num,den,brtoc);  % nadji odziv cijelog filtra
mag(:,1)=abs(h)*scalnaz;      % apsolutnu vrijednost ubaci u matricu

for i=1:N-1,
   [h,wo]=freqz([0*ones(1,N-i) num([N-i+1:N+1])],den,brtoc);
   mag(:,i+1)=abs(h)*scalnaz;
end;

if xxx==1,
   sl1;
   plot(wo/(2*pi),20*log10(mag));
   set(sl1, 'Visible', 'on');
   xlabel('Frekvencija (1=frekv. otipkavanja)');
   ylabel('Pojacanje (dB)');
   title('Dinamika izlaza filtra (zuto), dinamika sumatora brojnika (ostali)');
   grid;
   pause;
   set(sl1, 'Visible', 'off');
end;

mmag=max(mag);   % nadji maksimume za pojedine cvorove

if xxx==1,
   fprintf('\nMaximalna dinamika po cvorovima brojnika za sinusnu pobudu :\n\n');
   for i=2:N,
      fprintf('Sumator %.0f : %3.4f\n',N-i+2,mmag(i));
   end;
   fprintf('Sumator 1 : %3.4f\n',mmag(1));
   fprintf('Izlaz filtra : %3.4f\n',mmag(1)*k);
end;

scalbr=1/max([mmag mmag(1)*k]);

if scalbr<1,
   num=num*scalbr;
   k=k/scalbr;
else,
   scalbr=1;
end;

if xxx==1,
   if (scalbr<1),
      fprintf('\nPotrebni faktor skale da ne dodje do overload-a niti u jednom\n');
      fprintf('cvoru brojnika   .... = %3.4f\n',scalbr);
      fprintf('\nSkalirani koeficijenti brojnika :\n');
      for i=1:N+1,
         fprintf('\n      b(%.0f) = %f',i-1,num(i));
      end;
   else,
      fprintf('\nDinamika u svim cvorovima je manja od 1 i nema overload-a');
   end;
   fprintf('\n\nSkaliranje nakon filtracije %f\n',k);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;


inum=round(num*(2^(brbit-1)));
iden=round(den*(2^(brbit-1)));
   
rnum=inum/(2^(brbit-1));
rden=iden/(2^(brbit-1));

if xxx==1,
   fprintf('\nPromjena koeficijenata prije i poslije zaokruzenja : ');
   for i=1:N+1,
      fprintf('\n      a(%.0f) = %3.8f  --->',i-1,den(i));
      fprintf('  %3.8f',rden(i));
   end;
   fprintf('\n');
   for i=1:N+1,
      fprintf('\n      b(%.0f) = %3.8f  --->',i-1,num(i));
      fprintf('  %3.8f',rnum(i));
   end;
   fprintf('\n\n  .... <ENTER> za nastavak\n');
   pause;
end;

% testiranje dinamike po cvorovima nakon zaokruzenja

% za nazivnik

mag=ones(brtoc,N);          % inicijaliziraj matricu s magnitudama cvorova

%%%%%%%%%%
[h,wo]=freqz(1,rden,brtoc); % nadji odziv cijelog nazivnika (cvor iza 1/a0)
%%%%%%%%%%TU SAD FREQZ IZRACUNA h-OVE KOJI SU NaN

mag(:,1)=abs(h);            % apsolutnu vrijednost ubaci u matricu

for i=1:N-1,
   [h,wo]=freqz([0*ones(1,N-i) rden([N-i+1:N+1])],rden,brtoc);
   mag(:,i+1)=abs(h);
end;

mmag=max(mag);   % nadji maksimume za pojedine cvorove
newscalnaz=1/max(mmag);

if xxx==1,
   fprintf('\nMaximalna dinamika nazivnika nakon zaokruzenja :\n\n');
   fprintf('Cvor stanja (1/a0) : %3.4f\n',mmag(1));
   for i=2:N,
      fprintf('Sumator %.0f : %3.4f\n',N-i+2,mmag(i));
   end;
   fprintf('Sumator 1 : %3.4f\n',mmag(1)*rden(1));
   
   fprintf('\nPotrebni faktor skale na ulazu da ne dodje do overload-a niti\n');
   fprintf('u jednom cvoru nazivnika nakon zaokruzenja  .... = %3.8f\n',...
      newscalnaz);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;

% provjera za brojnik nakon zaokruzenja

mag=ones(brtoc,N);              % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(rnum,rden,brtoc);  % nadji odziv cijelog filtra
mag(:,1)=abs(h);                % apsolutnu vrijednost ubaci u matricu

for i=1:N-1,
   [h,wo]=freqz([0*ones(1,N-i) rnum([N-i+1:N+1])],rden,brtoc);
   mag(:,i+1)=abs(h);
end;

mmag=max(mag);
scalbr2=1/max(mmag);
worst_scalnaz=min([scalbr2 newscalnaz 1]);
iscalnaz=floor(worst_scalnaz*(2^(brbit-1)));
rscalnaz=iscalnaz/(2^(brbit-1));


if xxx==1,
   fprintf('\nMaximalna dinamika brojnika nakon zaokruzenja :\n\n');
   for i=2:N,
      fprintf('Sumator %.0f : %3.4f\n',N-i+2,mmag(i));
   end;
   fprintf('Sumator 1 : %3.4f\n',mmag(1));
   fprintf('\nUlazni faktor skaliranja da nema overload-a u brojniku = %3.8f\n'...
      ,scalbr2);
   fprintf('Manji od dva faktora (brojnika i nazivnika) = %3.8f\n',worst_scalnaz);
   fprintf('Nakon odsijecanja na broj bita ... skala = %3.8f\n',rscalnaz);
end;

if iscalnaz==0,
   kmenu('Zadano je premalo bita za realizaciju zeljene funkcije. Filter je neostvariv!!!','OK');
   ss=0;
   delete(sl1);
   figure(hhh);
   set(hhh,'visible','on');
   break;
end;


out_amp=1/(mmag(1)*rscalnaz);
iout_amp=floor((out_amp)*(2^(brbit-1)));
rout_amp=iout_amp/(2^(brbit-1));

if xxx==1,
   fprintf('\nPreostalo potrebno pojacanje : %3.8f\n',out_amp);
   fprintf('Nakon zaokruzenja na broj bit-a : %3.8f\n',rout_amp);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
   fprintf('\nKoeficijenti filtra za fractional aritmetiku : \n');
   fprintf('\nUlazno pojacalo : %.0f\n',iscalnaz);
   for i=1:N+1,
      fprintf('\n   a(%.0f) = %.0f',i-1,iden(i));
      fprintf('     b(%.0f) = %.0f',i-1,inum(i));
   end;
   fprintf('\n\nIzlazno pojacalo : %.0f\n\n',iout_amp);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
   fprintf('\n                                     --> racunam ! \n');
end;

iin_scale=[iscalnaz; iout_amp];

[h,wo]=freqz(num,den,brtoc);
mag=abs(h)*scalnaz*k;
[hr,wo]=freqz(rnum,rden,brtoc);
magr=abs(hr)*rscalnaz*rout_amp;

if xxx==1,
   sl1;
   plot(wo/(2*pi),20*log10([mag magr]));
   set(sl1, 'Visible', 'on');
   xlabel('Frekvencija , 1=Fs ');
   ylabel('Pojacanje (dB)');
   title('Magnituda filtra prije zaokruzenja/zuto i poslije/ljub');
   grid;
   pause;
   set(sl1, 'Visible', 'off');
   axis;
end;

phase=angle(h)/pi*180;
phaser=angle(hr)/pi*180;
if xxx==1,
   sl1;
   axis([0 0.5 -180 180]);
   plot(wo/(2*pi),[phase phaser]);
   set(sl1,'visible','on');
   xlabel('Frekvencija (1=frekv. otipkavanja)');
   ylabel('Faza u stupnjevima');
   title('Faza prije zaokruzenja (zuto) i poslije (ljub)');
   grid;
   pause;
   axis;
   delete(sl1);
   figure(hhh);
   set(hhh,'visible','on');
end;
ss=1;
