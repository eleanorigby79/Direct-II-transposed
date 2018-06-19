% funkcija za direktnu realizaciju IIR filtra
function [magr,phaser,inum,iden,iin_scale,ss]=diredsp(num,den,brbit,f_sample,cfs2_0_csl,xxx);

if xxx==1,
   sl2=figure;
   figure(sl2);
   set(sl2, 'Visible', 'off');
end;

brtoc=512;                                       % broj tocaka u kojima se racuna H(exp(j*om))

k=max(abs(num));                                 % magnituda najveceg elementa brojnika
num=num/k;                                       % skaliraj brojnik
k2=max(abs(den));                                % magnituda najveceg elementa nazivnika
if (k2>1),                                       % ako je veca od 1
   k2=ceil(log10(k2)/log10(2));                  % prva veca potencija broja 2 > od k2
   k2=2^k2;                                      % k2 faktor kojim treba dijeliti naz da
   den=den/k2;                                   % bi se 1/a0 mogao realizirati kao shifter
   k=k/k2;                                       % rezultirajuci k faktor
end;
tt=size(den);
N=max(tt)-1;                                    % red sistema
tt=size(num);
rb=max(tt);                                     % red brojnika
if (N>rb),                                      % ako je red brojnika manji nego red sistema
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

mag=ones(brtoc,N);                      % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(1,den,brtoc);      % nadji odziv cijelog nazivnika (cvor iza 1/a0)
mag(:,1)=abs(h);                        % apsolutnu vrijednost ubaci u matricu

for i=1:N-1,
   [h,wo]=freqz([0*ones(1,N-i) den([N-i+1:N+1])],den,brtoc);
   mag(:,i+1)=abs(h);
end;

if xxx==1,
   plot(wo/(2*pi)*f_sample,20*log10(mag));
   set(sl2, 'Visible', 'on');
   xlabel('Frekvencija (KHz)');
   ylabel('Pojacanje (dB)');
   title('Dinamika cvora 1/a0 (zuto), dinamika sumatora nazivnika (ostali)');
   grid;
   pause;
   set(sl2, 'Visible', 'off');
end;

mmag=max(mag);   % nadji maksimume za pojedine cvorove
scalnaz=1/max(mmag(1));
if (scalnaz>1),
   scalnaz=1;
else,
   k=k/scalnaz;
end;

if xxx==1,
   fprintf('\nMaximalna dinamika po cvorovima nazivnika za sinusnu pobudu :\n\n');
   fprintf('Cvor stanja (1/a0) : %3.4f\n',mmag(1));
   for i=2:N,
      fprintf('Sumator %.0f : %3.4f\n',N-i+2,mmag(i));
   end;
   fprintf('Sumator 1 : %3.4f\n',mmag(1)*den(1));
   if (scalnaz>1),
      fprintf('\nDinamika u cvoru 1/ao je manja od 1 i nema overload-a\n');
   else,
      fprintf('\nPotrebni faktor skale da ne dodje do overload-a niti u cvoru\n');
      fprintf('nazivnika 1/ao .... = %3.4f\n',scalnaz);
      fprintf('Trenutni totalni faktor = %f\n',k);
   end;
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;

% za brojnik

mag=ones(brtoc,N);                        % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(num,den,brtoc);  % nadji odziv cijelog filtra
mag(:,1)=abs(h)*scalnaz;          % apsolutnu vrijednost ubaci u matricu

for i=1:N-1,
   [h,wo]=freqz([0*ones(1,N-i) num([N-i+1:N+1])],den,brtoc);
   mag(:,i+1)=abs(h)*scalnaz;
end;

if xxx==1,
   plot(wo/(2*pi)*f_sample,20*log10(mag)); 
   set(sl2, 'Visible', 'on');
   xlabel('Frekvencija (KHz)');
   ylabel('Pojacanje (dB)');
   title('Dinamika izlaza filtra (zuto), dinamika sumatora brojnika (ostali)');
   grid;
   pause;
   set(sl2, 'Visible', 'off');
end;

mmag=max(mag);   % nadji maksimume za pojedine cvorove
scalbr=1/max([mmag(1) mmag(1)*k]);

if xxx==1,
   fprintf('\nMaximalna dinamika po cvorovima brojnika za sinusnu pobudu :\n\n');
   for i=2:N,
      fprintf('Sumator %.0f : %3.4f\n',N-i+2,mmag(i));
   end;
   fprintf('Sumator 1 : %3.4f\n',mmag(1));
   fprintf('Izlaz filtra : %3.4f\n',mmag(1)*k);
end;
if (scalbr<1),
   num=num*scalbr;
   if xxx==1,
      fprintf('\nPotrebni faktor skale da ne dodje do overload-a niti u jednom\n');
      fprintf('cvoru brojnika   .... = %3.4f\n',scalbr);
      fprintf('\nSkalirani koeficijenti brojnika :\n');
      for i=1:N+1,
         fprintf('\n      b(%.0f) = %f',i-1,num(i));
      end;
   end;
   k=k/scalbr;
else,
   if xxx==1,
      fprintf('\nDinamika u svim cvorovima je manja od 1 i nema overload-a');
   end;
   scalbr=1;
end;
if xxx==1,
   fprintf('\n\nSkaliranje nakon filtracije %f\n',k);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;

for i=1:N+1,
   inum(i)=round(limit(num(i),brbit)*(2^(brbit-1)));
end;
for i=1:N+1,
   iden(i)=round(limit(den(i),brbit)*(2^(brbit-1)));
end;
rnum=inum/(2^(brbit-1));
rden=iden/(2^(brbit-1));
rden(1)=den(1);
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

mag=ones(brtoc,N);                      % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(1,rden,brtoc); % nadji odziv cijelog nazivnika (cvor iza 1/a0)
mag(:,1)=abs(h);                        % apsolutnu vrijednost ubaci u matricu

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

mag=ones(brtoc,N);                              % inicijaliziraj matricu s magnitudama cvorova
[h,wo]=freqz(rnum,rden,brtoc);  % nadji odziv cijelog filtra
mag(:,1)=abs(h);                                % apsolutnu vrijednost ubaci u matricu

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
   
   
   fprintf('\nUlazni faktor skaliranja da nema overload-a u brojniku = %3.8f\n',scalbr2);
   
   fprintf('Manji od dva faktora (brojnika i nazivnika) = %3.8f\n',worst_scalnaz);
   
   
   fprintf('Nakon odsijecanja na broj bita ... skala = %3.8f\n',rscalnaz);
   pause;
end;
if (iscalnaz==0),
   kmenu('Zadano je premalo bita za realizaciju zeljene funkcije. Filter je neostvariv!!!','OK');
   ss=0;
   delete(sl2);
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
end;
if xxx==1,
   fprintf('\nKoeficijenti filtra za fractional aritmetiku : \n');
   fprintf('\nUlazno pojacalo : %.0f\n',iscalnaz);
   for i=1:N+1,
      fprintf('\n   a(%.0f) = %.0f',i-1,iden(i));
      fprintf('     b(%.0f) = %.0f',i-1,inum(i));
   end;
   fprintf('\n\nIzlazno pojacalo : %.0f\n\n',iout_amp);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;
iin_scale=[iscalnaz; iout_amp];
[h,wo]=freqz(num,den,brtoc);
mag=abs(h)*scalnaz*k;
[hr,wo]=freqz(rnum,rden,brtoc);
magr=abs(hr)*rscalnaz*rout_amp;
if xxx==1,
   plot(wo/(2*pi)*f_sample,20*log10([mag magr]));
   set(sl2, 'Visible', 'on');
   xlabel('Oznaci kursorom prozor za povecanje !!! ');
   ylabel('Pojacanje (dB)');
   title('Magnituda filtra prije zaokruzenja/zuto i poslije/ljub');
   grid;
end;
phase=angle(h)/pi*180;
phaser=angle(hr)/pi*180;
if xxx==1,
   plot(wo/(2*pi)*f_sample,[phase phaser]);
   axis([0 f_sample/2 -180 180]);
   xlabel('Frekvencija (KHz)');
   ylabel('Faza u stupnjevima');
   title('Faza prije zaokruzenja/zuto i poslije/ljub');
   grid;
   axis;
   pause;
   delete(sl1);
   figure(hhh);
   set(hhh,'visible','on');
end;
tt=size(den);
N=max(tt)-1;
x=[1-1/32768 0*ones(1,99) ];
delete pobuda.sym 
file='pobuda.sym';
fle='';
if brbit==16,
   bbit=1;
elseif brbit==32,
   bbit=2;
end;
if brbit==16,
   for i=1:100,
    line=[ hexa(limit(x(i),brbit)*32768,1) sprintf('       {    x(%.0f)=%5.6f }\n',i-1,x(i) ) ] ;
    fle=[fle line];
   end;
   fprintf(file,fle);
   delete sdir.cfs
   file='sdir.cfs';
   line=sprintf('{ Koeficijenti za 16 bitnu direktnu realizaciju filtra %.0f reda }\n\n',N);
   fprintf(file,line);
   hex=hexa( limit( rscalnaz , brbit )*32768,1);
   line=[ hex sprintf('        { in_amp=%5.6f }\n\n', rscalnaz )];
   fprintf(file,line);					 
   for i=N+1:-1:2,
       hex=hexa( iden(i) ,1);
       line=[ hex sprintf('        { a(%.0f)=%5.6f }\n',i-1,rden(i))];
       fprintf(file,line);
   end;
   [ mant ex ]=expon( 1/rden(1) );
   hex=hexa(ex,1);
   line=[ hex sprintf('        { 1/a(0)=%.0f }\n\n',1/rden(1))];
   fprintf(file,line);
   hex=hexa( limit( rnum(1) , brbit )*2^(brbit-1),1);
   line=[ hex sprintf('        { b(0)=%5.6f }\n',rnum(1))];
   fprintf(file,line);
   for i=N+1:-1:2,
       hex=hexa( inum(i) ,1);
       line=[ hex sprintf('        { b(%.0f)=%5.6f }\n',i-1,rnum(i))];
       fprintf(file,line);
   end;
   [ mant ex ]=expon(rout_amp);
   hex=hexa( limit( mant , brbit )*32768,1);
   line=[ sprintf('\n') hex sprintf('        { out_amp=%5.6f }', rout_amp )];
   fprintf(file,line);
   hex=hexa(ex,1);
   line=[ sprintf('\n') hex sprintf('        { %5.6f*2^%.0f } \n',mant,ex)];
   fprintf(file,line);

   delete sdir.h 
   file='sdir.h';
   line=sprintf('.MODULE/RAM        SDIR;\n.CONST                   N=%.0f;\n',N);
   fprintf(file,line);
   line=sprintf('.CONST        FS_CFS=%.0f;\n',cfs2_0_csl);
   fprintf(file,line);

% Novi kod za XP sa BAT file-om
      load '..\postavi'				% pozovi filu koja postavlja put i port

      delete bat_file.bat      
      bat_name='bat_file.bat';
      fp=fopen(bat_name,'wt');

      % Remove previous compilation output
      fprintf(fp,'\ndel sdir.dsp');
      fprintf(fp,'\ndel sdir.sym');
      fprintf(fp,'\ndel sdir.int');
      fprintf(fp,'\ndel sdir.cde');
      fprintf(fp,'\ndel sdir.obj');

      % Remove previous compilation output
      fprintf(fp,'\ndel ..\\ezkit16.int');
      fprintf(fp,'\ndel ..\\ezkit16.cde');
      fprintf(fp,'\ndel ..\\ezkit16.obj');

      fprintf(fp,'\ncopy sdir.h + sdir.bdy sdir.dsp');
      fprintf(fp,'\ndel sdir.h');

      fprintf(fp,'\n%s\\asm21 ..\\ezkit16',put);
      fprintf(fp,'\n%s\\asm21 sdir',put);
      fprintf(fp,'\n%s\\ld21 ..\\ezkit16 sdir -a ..\\ezkit_lt -g -e sdir',put);
      fprintf(fp,'\n..\\ezexp %s sdir.exe g',port);
      fclose(fp);

      str=sprintf('!%s',bat_name);
      eval(str)

elseif brbit==32,
   for i=1:100,
       line=[ hexa(limit(x(i),brbit)*32768,1) sprintf('       {    x(%.0f)=%5.6f }\n',i-1,x(i) ) ] ;
       fle=[fle line];
   end;
   fprintf(file,fle);
   delete ddir.cfs
   file='ddir.cfs';
   line=sprintf('{ Koeficijenti za 32 bitnu direktnu realizaciju filtra %.0f reda }\n',N);
   fprintf(file,line);
   hex=hexa( limit( rscalnaz , brbit )*2^(brbit-1),2);
   line=[ hex(1:4) sprintf('        { in_amp=%13.10f }\n', rscalnaz )];
   fprintf(file,line);
   line=[ hex(5:8) sprintf('\n')];
   fprintf(file,line);
   for i=N+1:-1:2,
       hex=hexa( iden(i) ,2);
       line=[ hex(1:4) sprintf('        { a(%.0f)=%13.10f }\n',i-1,rden(i))];
       fprintf(file,line);
       line=[ hex(5:8) sprintf('\n')];
       fprintf(file,line);
   end;
   [ mant ex ]=expon( 1/rden(1) );
   hex=hexa(ex,1);
   line=[ hex sprintf('        { 1/a(0)=%.0f }\n',1/rden(1))];
   fprintf(file,line);
   hex=hexa( limit( rnum(1) , brbit )*2^(brbit-1),2);
   line=[ hex(1:4) sprintf('        { b(0)=%13.10f }\n',rnum(1))];
   fprintf(file,line);
   line=[ hex(5:8) sprintf('\n')];
   fprintf(file,line);
   for i=N+1:-1:2,
       hex=hexa( inum(i) ,2);
       line=[ hex(1:4) sprintf('        { b(%.0f)=%13.10f }\n',i-1,rnum(i))];
       fprintf(file,line);
       line=[ hex(5:8) sprintf('\n')];
       fprintf(file,line);
   end;
  [ mant ex ]=expon(rout_amp);
  hex=hexa( limit( mant , brbit )*2^(brbit-1),2);
  line=[ hex(1:4) sprintf('        { out_amp=%13.10f }', rout_amp )];
  fprintf(file,line);
  line=[ sprintf('\n') hex(5:8) sprintf('\n')];
  fprintf(file,line);
  hex=hexa(ex,1);
  line=[ hex sprintf('        { %13.10f*2^%.0f } \n',mant,ex)];
  fprintf(file,line);
  delete ddir.h
  file='ddir.h';
  line=sprintf('.MODULE/RAM        DDIR;\n.CONST                   N=%.0f;\n',N);
  fprintf(file,line);
  line=sprintf('.CONST             FS_CFS=%.0f;\n',cfs2_0_csl);
  fprintf(file,line);

% Novi kod za XP sa BAT file-om
      load '..\postavi'				% pozovi filu koja postavlja put i port

      delete bat_file.bat      
      bat_name='bat_file.bat';
      fp=fopen(bat_name,'wt');

      % Remove previous compilation output
      fprintf(fp,'\ndel ddir.dsp');
      fprintf(fp,'\ndel ddir.sym');
      fprintf(fp,'\ndel ddir.int');
      fprintf(fp,'\ndel ddir.cde');
      fprintf(fp,'\ndel ddir.obj');

      % Remove previous compilation output
      fprintf(fp,'\ndel ..\\ezkit32.int');
      fprintf(fp,'\ndel ..\\ezkit32.cde');
      fprintf(fp,'\ndel ..\\ezkit32.obj');

      fprintf(fp,'\ncopy ddir.h + ddir.bdy ddir.dsp');
      fprintf(fp,'\ndel ddir.h');

      fprintf(fp,'\n%s\\asm21 ..\\ezkit32',put);
      fprintf(fp,'\n%s\\asm21 ddir',put);
      fprintf(fp,'\n%s\\ld21 ..\\ezkit32 ddir -a ..\\ezkit_lt -g -e ddir',put);
      fprintf(fp,'\n..\\ezexp %s ddir.exe g',port);
      fclose(fp);

      str=sprintf('!%s',bat_name);
      eval(str)

end;
ss=1;
