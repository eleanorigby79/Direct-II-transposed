% funkcija za realizaciju IIR filtra biqadratnim sekcijama na AD2115
% koja generira datoteke koeficijenata za vec prethodno napisani program
%
%       biquad16 [br,naz,in_scale]=(p,z,amp_tot,brbit,flip,whi,wlo,prip,apr)
%       p       - matrica polova
%       z       - matrica nula
%       amp_tot - totalno pojacanje filtra
%       brbit   - broj bit-a za realizaciju
%       flip    - redoslijed kaskada ... nije bitan jer se ovdje prepisuje
%       f_sample   - frekvencija sempliranja u KHz
%       cfs2_0_csl - bitovi data formay registra kodeka koji odreduju f_sample
%       whi,wlo,prip,apr - pomocne za prikaz pass banda
%
%       br      - koeficijenti brojnika kao Fixed point
%       naz     - koeficijenti nazivnika kao Fixed point
%       in_scale - faktori skaliranja biquad sekcija - atenuatori na ulazu u biquad

function [magr,phaser,br,naz,in_scale,amp_tot,ss]=biqudsp(p,z,amp_tot,brbit,f_sample,cfs2_0_csl,xxx,hhh,flip);
clc;
if xxx==1,
   sl1=figure;
   set(sl1, 'Visible', 'off');
end;
brtoc=512;        % BROJ TOCAKA U KOJIMA SE RACUNA FREQ KARAKTERISTIKA
base=2^(brbit-1);   % baza pretvorbe kod zaokruzivanja
famp=1;             % pojacanje filtra potrebno za daljnja proracunavamja
amp_org=amp_tot;
[H,wo]=freqz(amp_tot*poly(z),poly(p),brtoc); % IZRACUNAJ PRIJENOSNU FUNKCIJU
zr=z(imag(z)==0);
zc=z(imag(z)~=0);
pr=p(imag(p)==0);
pc=p(imag(p)~=0);
pc=dsort(pc);              % Sortiraj kompleksne
pr=dsort(pr);              % Sortiraj realne

if (flip==2),     % ako se zeli poredak od least Q do highest Q
   pc=flipud(pc); % okreni stupac s kompleksnim polovima naglavacke
end;

z2=[zc;zr];                % sortirani vektor nula
p2=[pc;pr];                % sortirani vektor polova

tt=size(p2);
if (rem(tt(1),2)==1), % ako je neparni broj polova dodaj jos jedan
   p2=[p2;0];
end;

tt=size(p2);
tz=size(z2);
if((tt(1)-tz(1))~=0),      % ako broj polova nije jednak broju nula dodaj potrebne nule
   z2=[z2;0*ones(tt(1)-tz(1),1)];
end;
brcas=tt(1)/2;
for i=1:2:2*brcas,
   br((i+1)/2,:)=poly(z2(i:(i+1)));
end;
for i=1:2:2*brcas,
   naz((i+1)/2,:)=poly(p2(i:(i+1)));
end;

for cas=1:brcas,             % inicijalno skaliranje koeficijenata na +/- 1
   m=max(abs(br(cas,:)));
   br(cas,:)=br(cas,:)/m;
   amp_tot=amp_tot*m;
   m=max(abs(naz(cas,:)));
   if (m>1),
      naz(cas,:)=naz(cas,:)/2;
      amp_tot=amp_tot/2;
   end;
end;

ramp_tot=amp_tot;            % rest of amplify
if xxx==1,
   fprintf('\nKoeficijenti polinoma nazivnika i brojnika nakon skaliranja na +/-1 : ');
   fprintf('\n     a0        a1        a2   ');
   fprintf('\n -----------------------------\n');
   disp(naz);
   fprintf('\n     b0        b1        b2   ');
   fprintf('\n -----------------------------\n');
   disp(br);
   fprintf('Faktor pojacanja %3.4f\n',amp_tot);
   fprintf('\n  .... <SPACE> za nastavak\n');
   pause;
end;
hout=ones(brtoc,1);                 % Inicijalizacija ulazne funkcije
reorder=[1:brcas];
oldreo=reorder;
naz=real(naz);                      % korekcija nazivnika i brojnika radi ispisa -> 
br=real(br);                        % ->funkcija poly vraca kompleksne brojeve sa jako malim kompleksnim dijelom

for cas=1:brcas,                    % Za sve kaskade :
   if xxx==1,
      fprintf('\n*******************************************************************\n');
      fprintf('*                         kaskada :  %.0f                                *\n',cas);
      fprintf('***********************************************************************\n');
      fprintf('\n                  -1      -2');
      fprintf('\n      b(0) + b(1)z  +b(2)z  ');
      fprintf('\nH(z)= ----------------------');
      fprintf('\n                  -1      -2');
      fprintf('\n      a(0) + a(1)z  +a(2)z  ');
      fprintf('\n S koeficijentima nazivnika : ');
      fprintf('\n      a(0) = %3.4f',naz(cas,1));
      fprintf('\n      a(1) = %3.4f',naz(cas,2));
      fprintf('\n      a(2) = %3.4f',naz(cas,3));
   end;
   % testiranje dinamike po cvorovima
   % za nazivnik
   % odziv cvora A (cvor stanja) trenutne sekcije prema ulazu u filter
   
   naz(cas,:)=round(naz(cas,:)*base)/base;    % odmah zaokruzi koeficijente jer se oni i tako ne diraju
   [h,wo]=freqz(1,naz(cas,:),brtoc);          % izracunaj h(z) za takve koeficijente
   
   % apsolutne vrijednosti od H(exp(j*om))
   mag=abs(h.*hout);
   
   if xxx==1,                                % nacrtaj freq karakteristiku
      plot(wo/(2*pi)*f_sample,([20*log10(mag) 20*log10(abs(hout))]));
      set(sl1, 'Visible', 'on');
      xlabel('Frekvencija (KHz)');
      ylabel('Pojacanje ');
      title('Pojacanja u cvoru nazivnika A i E prije atenuacije');
      grid;
      pause;
      set(sl1, 'Visible', 'off');
   end;
   
   mmag=max(mag);                                 % najvece pojacanje za cvor A
   
   % dozvoljeni faktor skale na ulazu u sekciju da najveci od A bude 1
   scalnaz=min([1/max(mmag) 2]);                  % dinamika u 1/ao bez atenuatora , hout dinamika dosadasnjeg niza sekcija
   % u ovom slucaju se ne dopusta pojacanje vece od 1
   % ako se umjesto 1 metne 2 dopusta pojacanje na ulazu
   
   scalnaz=floor(scalnaz*base)/base;
   if xxx==1
      fprintf('\nMaximalna dinamika u cvoru stanja nazivnika za sinusnu pobudu :\n');
      fprintf('Cvor A   : %3.4f\n',mmag);
      fprintf('Faktor skale kod kojega nema overload-a niti u jednom\n');
      fprintf('cvoru nazivnika   .... = %3.4f\n',scalnaz);
   end; 
   if (scalnaz==0),
      kmenu('Zadano je premalo bita za realizaciju zeljene funkcije. Filter je neostvariv!!!','OK');
      ss=0;
      delete(sl1);
      figure(hhh);
      set(hhh,'visible','on');
      break;
   end;
   in_scale(cas)=scalnaz;                          % spremi zaokruzeni faktor skale u polje
   dinc(cas)=max(hout);                            % dinamika u cvoru C
   hout=hout*scalnaz;                              % dinamika na izlazu iz ulaznog pojacala
   dine(cas)=max(hout);                            % dinamika u cvoru E
   dina(cas)=max(h.*hout);                         % dinamika u cvoru A
   clear najmag;                                   % obrisi top listu                                                           %
   
   if (cas~=brcas),                                % ako nije zadnji prolaz, imamo sto birati      
      for k=cas:brcas,                              % pretrazi sve preostale brojnike                
         [h,wo]=freqz(br(k,:),naz(cas,:),brtoc);     % odziv cvora C prema ulazu                                
         maxc=max(abs(h.*hout));
         najmag(k-cas+1)=abs(log10(maxc));           % ubaci u top listu odstupanje od 0dB (+ ili -, to je svejedno)                                 
      end;
      [dummy k]=min(najmag);                        % potrazi onog koji najmanje odstupa                                                   
      k=k+cas-1;
   else,                                           % ako nemas sto birati, uzmi sto imas                       
      k=brcas;
   end;
   
   tt=br(cas,:);                                   % upari pravi polinom u brojniku i nazivniku
   br(cas,:)=br(k,:);
   br(k,:)=tt;
   if xxx==1,
      fprintf('\n Koeficijenti brojnika kaskade %.0f',cas);
      fprintf('\n nakon odabira najpovoljnijeg para nula :\n');
      fprintf('\n      b(0) = %3.4f',br(cas,1));
      fprintf('\n      b(1) = %3.4f',br(cas,2));
      fprintf('\n      b(2) = %3.4f\n',br(cas,3));
   end;
   [h,wo]=freqz(br(cas,:),naz(cas,:),brtoc); % odziv cvora C prema ulazu
   
   mag=abs(h.*hout);
   
   mmag=max(mag);                            % nadji maksimum odziva za cvor C
   
   scalbr=min([1/max(mmag) 1]);
   scalbr=floor(scalbr*base)/base;
   
   scalafter=(1/scalnaz);
   amp_tot=amp_tot/scalnaz;
   
   br(cas,:)=br(cas,:)*scalbr;
   br(cas,:)=round(br(cas,:)*base)/base;
   
   scalafter=scalafter/scalbr;
   amp_tot=amp_tot/scalbr;
   ramp_tot=ramp_tot/scalbr;
   
   [h,wo]=freqz(br(cas,:),naz(cas,:),brtoc); % izracunaj odziv cvora C s tako skaliranim koeficijentima
   
   hout=h.*hout;                             % novi izlaz
   
   if xxx==1,
      plot(wo/(2*pi)*f_sample,20*log10([mag abs(hout)]));
      set(sl1, 'Visible', 'on');
      xlabel('Frekvencija (KHz)');
      ylabel('Pojacanje');
      title('++Pojacanja u cvoru  C /zuto prije skaliranja brojnika /ljub poslije++');
      grid;
      pause;
      set(sl1, 'Visible', 'off');
      fprintf('\nMaximalno pojacanje u izlaznom cvorovu brojnika za sinusnu pobudu :\n\n');
      fprintf('Cvor Cout : %3.4f\n',mmag);
      fprintf('\nFaktor skaliranja koeficijenata brojnika : %3.4f\n',scalbr);
      fprintf('\n  .... <SPACE> za nastavak\n');
      pause;
   end;
end;    % kraj petlje za sve kaskade

if (ss==0), break;end;    % potrebno radi kaskada

% PRILAGODJAVANJE KOEFICIJENATA KONKRETNOJ REALIZACIJI FILTRA

for i=1:brcas,
   for j=1:3,
      fbr(i,j)=limit(br(i,j),brbit);
   end;
   fnaz(i,1)=limit(1-1/naz(i,1),16);
   for j=2:3,
      fnaz(i,j)=limit(naz(i,j),brbit);
   end;
   fin_scale(i)=limit(1-in_scale(i),brbit);
end;
if brbit==16,
   famp_tot=limit(1-amp_tot,brbit);
elseif brbit==32,
   famp_tot=limit(floor((1-amp_tot)*base)/base,brbit);
end;
% KRAJ PRILAGODBE

hout=hout*amp_tot;
if xxx==1,
   fprintf('\nKoeficijenti realiziranih biquad sekcija :\n');
   fprintf('\n    inamp       a0        a1        a2        b0        b1        b2');
   fprintf('\n ---------------------------------------------------------------------\n');
   disp([in_scale'*base naz*base br*base])
   fprintf('\nKonacno pojacanje na samom izlazu %3.4f',amp_tot);
   fprintf('\n                                  -------');
   fprintf('\n  .... <SPACE> za nastavak\n');
   pause;
   
   fprintf('\nDinamika sinusnog signala po cvorovima (A,C i E):\n');
   fprintf('\n      E         A         C');
   fprintf('\n --------------------------------------------------\n');
   disp([abs(dine') abs(dina') abs(dinc') ])
   fprintf('  .... <SPACE> za nastavak\n');
   pause;
end;

[H,wo]=freqz(amp_org*poly(z),poly(p),brtoc); % IZRACUNAJ PRIJENOSNU FUNKCIJU
mag=abs(H);
phase=angle(H)/pi*180;

magr=abs(hout);
phaser=angle(hout)/pi*180;

if xxx==1,
   set(sl1, 'Visible', 'on');
   axis([0 f_sample/2 -80 20]);
   plot(wo/(2*pi)*f_sample,20*log10([mag magr]));
   xlabel('Frekvencija (KHz)');
   ylabel('Pojacanje (dB)');
   title('Magnituda filtra prije zaokruzenja/zuto i poslije/ljub');
   grid;
   axis;
   pause;
   plot(wo/(2*pi)*f_sample,[phase phaser]);
   axis([0 f_sample/2 -180 180]);
   xlabel('Frekvencija (KHz)');
   ylabel('Faza u stupnjevima');
   title('Faza prije zaokruzenja/zuto i poslije/ljub');
   grid;
   axis;
   pause;
end;

odziv=100;
x=[1 0*ones(1,odziv-1)];
time=[1:odziv];
if brbit==16,
   bbit=1;
elseif brbit==32,
   bbit=2;
end;
% ISPIS ULAZNOG TEST VEKTORA
delete pobuda.sym
file='pobuda.sym';
for i=1:odziv,
   line=([ hexa(limit(x(i),16)*2^15,1) sprintf('      ; x[%.0f]=%5.6f\n',i,x(i)) ]);
   fprintf(file,line);
end;

for i=1:brcas,
   x=filter(amp_tot*br(i,:)*in_scale(i),naz(i,:),x);
end;
if xxx==1,
   fprintf('\nkonacno izlazno pojacanje %5.4f ',amp_tot);
   fprintf('\nRedosljed kojim su uzimani nazivnici');
   fprintf('\nPocetno stanje : ');
   disp(oldreo);
   fprintf('\nKonacno stanje : ');
   disp(reorder);
   pause;
end;

fprintf('Printing to file ...\n');
if brbit==16,
   delete siir.cfs
   file='siir.cfs';
   line=sprintf('{ Koeficijenti za 16 bitnu realizaciju IIR filtra %.0f reda biquad sekcijama }\n',brcas*2);   
elseif brbit==32,
   delete diir.cfs
   file='diir.cfs';
   line=sprintf('{ Koeficijenti za 32 bitnu realizaciju IIR filtra %.0f reda biquad sekcijama }\n',brcas*2);
end;
filenam=([ file ]);
fprintf(filenam,line);
if brbit==16,
   for i=1:brcas,
      line=sprintf('\n{  %.0f. biquad sekcija}\n\n',i);
      fprintf(filenam,line);
      line=([ hexa(fin_scale(i)*base,bbit) sprintf('           { p(%.0f)= %5.6f}\n',i,in_scale(i)) ] );
      fprintf(filenam,line);
      for k=2:-1:1,
         line=([ hexa(fnaz(i,k+1)*base,1) sprintf('           { a(%.0f)= %5.6f}\n',k,naz(i,k+1)) ] );
         fprintf(filenam,line);
      end;
      line=([ hexa(fnaz(i,1)*base,1) sprintf('           { 1/ao= %5.6f}\n',1/naz(i,1)) ] );
      fprintf(filenam,line);
      k=0;
      line=( [ hexa(fbr(i,k+1)*base,1) sprintf('           { b(%.0f)= %5.6f}\n',k,br(i,k+1)) ] );
      fprintf(filenam,line);
      k=1;
      line=( [ hexa(fbr(i,k+1)*base,1) sprintf('           { b(%.0f)= %5.6f}\n',k,br(i,k+1)) ] );
      fprintf(filenam,line);
      k=2;
      line=( [ hexa(fbr(i,k+1)*base,1) sprintf('           { b(%.0f)= %5.6f}\n',k,br(i,k+1)) ] );
      fprintf(filenam,line);
      
   end;
   line=sprintf('\n');
   fprintf(filenam,line);
   [mant,expo]=expon(amp_tot);
   hex=hexa(limit(mant,16)*32768,1);
   line=([ hex sprintf('           { Aizl= %5.6f=%5.6f*2^%.0f }\n',amp_tot,mant,expo) ] );
   fprintf(filenam,line);
   hex=hexa(expo,1);
   line=([ hex sprintf('\n')]);
   fprintf(filenam,line);

   delete siirhead.h
   file='siirhead.h';
   line=sprintf('.MODULE/RAM             IIRFILT;\n');
   fprintf(file,line);
   line=sprintf('.CONST                   N=%.0f;\n',brcas);
   fprintf(file,line);
   line=sprintf('.CONST              FS_CFS=%.0f;\n',cfs2_0_csl);
   fprintf(file,line);

% Novi kod za XP sa BAT file-om
      load '..\postavi'				% pozovi filu koja postavlja put i port

      delete bat_file.bat      
      bat_name='bat_file.bat';
      fp=fopen(bat_name,'wt');

      % Remove previous compilation output
      fprintf(fp,'\ndel siir.dsp');
      fprintf(fp,'\ndel siir.sym');
      fprintf(fp,'\ndel siir.int');
      fprintf(fp,'\ndel siir.cde');
      fprintf(fp,'\ndel siir.obj');

      % Remove previous compilation output
      fprintf(fp,'\ndel ..\\ezkit16.int');
      fprintf(fp,'\ndel ..\\ezkit16.cde');
      fprintf(fp,'\ndel ..\\ezkit16.obj');

      fprintf(fp,'\ncopy siirhead.h + siir.bdy siir.dsp');
      fprintf(fp,'\ndel siirhead.h');

      fprintf(fp,'\n%s\\asm21 ..\\ezkit16',put);
      fprintf(fp,'\n%s\\asm21 siir',put);
      fprintf(fp,'\n%s\\ld21 ..\\ezkit16 siir -a ..\\ezkit_lt -g -e siir',put);
      fprintf(fp,'\n..\\ezexp %s siir.exe g',port);
      fclose(fp);

      str=sprintf('!%s',bat_name);
      eval(str)

elseif brbit==32,
   for i=1:brcas,
   line=sprintf('\n{  %.0f. biquad sekcija}\n\n',i);
   fprintf(filenam,line);
   hex=hexa(fin_scale(i)*base,2);
   line=([ hex(1:4)  sprintf('           { p(%.0f)= %13.10f}\n',i,in_scale(i)) ] );
   fprintf(filenam,line);
   line=([ hex(5:8) sprintf('\n') ]);
   fprintf(filenam,line);
   for k=2:-1:1,
      hex=hexa(fnaz(i,k+1)*base,2);
      line=([ hex(1:4)  sprintf('           { a(%.0f)= %13.10f}\n',k,naz(i,k+1)) ] );
      fprintf(filenam,line);
      line=([ hex(5:8)  sprintf('\n') ] );
      fprintf(filenam,line);
   end;
   hex=hexa(fnaz(i,1)*32768,1);
   line=([ hex(1:4) sprintf('           { 1/ao= %.0f }\n',1/naz(i,1)) ] );
   fprintf(filenam,line);
   for k=0:2,
      hex=hexa(fbr(i,k+1)*base,2);
      line=([ hex(1:4)  sprintf('           { b(%.0f)= %13.10f}\n',k,br(i,k+1)) ] );
      fprintf(filenam,line);
      line=([ hex(5:8) sprintf('\n') ] );
      fprintf(filenam,line);
   end;
   end;
   line=sprintf('\n');
   fprintf(filenam,line);
   [mant,expo]=expon(amp_tot);
   hex=hexa(limit(mant,32)*2^31,2);
   line=([ hex(1:4) sprintf('           { Aizl= %13.10f = %13.10f*2^%.0f }\n',amp_tot,mant,expo) ] );
   fprintf(filenam,line);
   line=([ hex(5:8) sprintf('\n') ] );
   fprintf(filenam,line);
   hex=hexa(expo,1);
   line=([hex(1:4) sprintf('\n')]);
   fprintf(filenam,line);
   delete diir.h
   file='diir.h';
   line=sprintf('.MODULE/RAM        DIIR;\n');
   fprintf(file,line);
   line=sprintf('.CONST                   N=%.0f;\n',brcas);
   fprintf(file,line);
   line=sprintf('.CONST              FS_CFS=%.0f;\n',cfs2_0_csl);
   fprintf(file,line);

% Novi kod za XP sa BAT file-om
      load '..\postavi'				% pozovi filu koja postavlja put i port

      delete bat_file.bat      
      bat_name='bat_file.bat';
      fp=fopen(bat_name,'wt');

      % Remove previous compilation output
      fprintf(fp,'\ndel diir.dsp');
      fprintf(fp,'\ndel diir.sym');
      fprintf(fp,'\ndel diir.int');
      fprintf(fp,'\ndel diir.cde');
      fprintf(fp,'\ndel diir.obj');

      % Remove previous compilation output
      fprintf(fp,'\ndel ..\\ezkit32a.int');
      fprintf(fp,'\ndel ..\\ezkit32a.cde');
      fprintf(fp,'\ndel ..\\ezkit32a.obj');

      fprintf(fp,'\ncopy diir.h + diir.bdy diir.dsp');
      fprintf(fp,'\ndel diir.h');

      fprintf(fp,'\n%s\\asm21 ..\\ezkit32a',put);
      fprintf(fp,'\n%s\\asm21 diir',put);
      fprintf(fp,'\n%s\\ld21 ..\\ezkit32a diir -a ..\\ezkit_lt -g -e diir',put);
      fprintf(fp,'\n..\\ezexp %s diir.exe g',port);
      fclose(fp);

      str=sprintf('!%s',bat_name);
      eval(str)

end;
ss=1;