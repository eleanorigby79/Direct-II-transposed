% funkcija za realizaciju IIR filtra biqadratnim sekcijama
function [magr,phaser,ibr,inaz,iin_scale,ss]=biquad(p,z,amp_tot,brbit,xxx,hhh,flip);


ss=1;
brtoc=512;
[H,wo]=freqz(amp_tot*poly(z),poly(p),brtoc);

zr=z(imag(z)==0);
zc=z(imag(z)~=0);
pr=p(imag(p)==0);
pc=p(imag(p)~=0);

pc=dsort(pc);
pr=dsort(pr);
if (flip==2),     % ako se zeli poredak od least Q do highest Q
   pc=flipud(pc); % okreni stupac s kompleksnim polovima naglavacke
end;
z2=[zc;zr];
p2=[pc;pr];

tt=size(p2);
if (rem(tt(1),2)==1),
   p2=[p2;0];
end;
tt=size(p2);
tz=size(z2);
if((tt(1)-tz(1))~=0),
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

ramp_tot=amp_tot;

if xxx==1,
   set(hhh,'visible','off');
   sl1=figure;
   set(sl1, 'Visible', 'off');
   fprintf('\nKoeficijenti polinoma nazivnika i brojnika: \n');
   fprintf('\n     a0        a1        a2   ');
   fprintf('\n -----------------------------\n');
   disp(naz);
   fprintf('\n     b0        b1        b2   ');
   fprintf('\n -----------------------------\n');
   disp(br);
   fprintf('Faktor pojacanja %3.4f\n',amp_tot);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;

hout=ones(brtoc,1);

reorder=[1:brcas];
oldreo=reorder;

% korekcija nazivnika i brojnika radi ispisa -> 
% ->funkcija poly vraca kompleksne brojeve sa jako malim kompleksnim dijelom
naz=real(naz);
br=real(br);

for cas=1:brcas,     % Za sve kaskade :
   
   if xxx==1,
      fprintf('\nPrenosna funkcija H(z) kaskade %.0f:\n',cas);
      fprintf('\n                  -1      -2');
      fprintf('\n      b(0) + b(1)z  +b(2)z  ');
      fprintf('\nH(z)= ----------------------');
      fprintf('\n                  -1      -2');
      fprintf('\n      a(0) + a(1)z  +a(2)z  ');
      fprintf('\n\n S koeficijentima nazivnika : \n');
      fprintf('\n      a(0) = %3.4f',naz(cas,1));
      fprintf('\n      a(1) = %3.4f',naz(cas,2));
      fprintf('\n      a(2) = %3.4f\n',naz(cas,3));
      fprintf('\n  .... <ENTER> za nastavak\n');
      pause;
   end;
   
   % testiranje dinamike po cvorovima
   
   % za nazivnik
   naz(cas,:)=round(naz(cas,:)*2^(brbit-1))/2^(brbit-1);    % odmah zaokruzi koeficijente jer se oni i tako ne diraju
   % odziv cvora A trenutne sekcije prema ulazu u filter
   [h,wo]=freqz(1,naz(cas,:),brtoc);
   
   % odziv cvora B trenutne sekcije prema ulazu u filter
   [h1,wo]=freqz([0 naz(cas,[2:3])],naz(cas,:),brtoc);
   
   % apsolutne vrijednosti od H(exp(j*om))
   mag=abs(h.*hout);
   mag1=abs(h1.*hout);
   maxul=1;               % maksimalna dinamika na ulazu je za prvu kaskadu 1
   if (cas>1),            % za ostale kaskade ... zavisi o dinamici izlaza
      % prethodne kaskade = dinc
      maxul=dinc(cas-1);
   end;
   
   if xxx==1,
      sl1;
      set(sl1, 'Visible', 'on');
      plot(wo/(2*pi),20*log10([mag mag1]));
      xlabel('Frekvencija (1=frekv. otipkavanja)');
      ylabel('Pojacanje (dB)');
      title('Pojacanja po cvorovima nazivnika A/zuto B/ljub');
      grid;
      pause;
      set(sl1, 'Visible', 'off');
   end;
   % najvece pojacanje za cvorove A i B
   mmag=max(mag);
   mmag1=max(mag1);
   if xxx==1,
      fprintf('\nMaximalna dinamika po cvorovima nazivnika za sinusnu pobudu :\n\n');
      fprintf('Cvor A   : %3.4f\n',mmag);
      fprintf('Cvor B   : %3.4f\n',mmag1);
      fprintf('Cvor Cin : %3.4f\n',maxul);
   end;
   % dozvoljeni faktor skale na ulazu u sekciju da najveci od A, B i E bude 1
   scalnaz=1/max([mmag mmag1 maxul]);
   
   % spremi faktor skale u polje
   in_scale(cas)=scalnaz;
   
   % dinamika na izlazu iz ulaznog pojacala
   dine(cas)=maxul*scalnaz;
   
   % dinamika u cvoru A
   dina(cas)=mmag*scalnaz;
   
   % dinamika u cvoru B
   dinb(cas)=mmag1*scalnaz;
   
   if xxx==1,
      fprintf('\nFaktor skale kod kojega nema overload-a niti u jednom\n');
      fprintf('cvoru nazivnika   .... = %3.4f\n',scalnaz);
      fprintf('\n  .... <ENTER> za nastavak\n');
      pause;
   end;
   
   % za nazivnik, trazi brojnik cija je dinamika u cvorovima C i D
   % sto bliza jedan (0 dB).
   
   % obrisi top listu
   clear najmag;
   
   if (cas~=brcas),          % ako nije zadnji prolaz, imamo sto birati
      for k=cas:brcas,       % pretrazi sve preostale brojnike
         
         % odziv cvora C prema ulazu
         [h,wo]=freqz(br(k,:),naz(cas,:),brtoc);
         
         % odziv cvora D prema ulazu
         [h1,wo]=freqz([0 br(k,[2:3])],naz(cas,:),brtoc);
         
         maxc=max(abs(h.*hout)*scalnaz);
         maxd=max(abs(h1.*hout)*scalnaz);
         maxcd=max([maxc maxd]);
         
         % ubaci u top listu odstupanje od 0dB (+ ili -, to je svejedno)
         najmag(k-cas+1)=abs(log10(maxcd));
      end;
      
      % potrazi onog koji najmanje odstupa
      [dummy k]=min(najmag);
      k=k+cas-1;
   else,          % ako nemas sto birati, uzmi sto imas
      k=brcas;
   end;
   
   tt=br(cas,:);        % upari pravi polinom u brojniku i nazivniku
   br(cas,:)=br(k,:);
   br(k,:)=tt;
   
   if xxx==1,
      fprintf('\n Koeficijenti brojnika kaskade %.0f',cas);
      fprintf('\n nakon odabira najpovoljnijeg para nula :\n');
      fprintf('\n      b(0) = %3.4f',br(cas,1));
      fprintf('\n      b(1) = %3.4f',br(cas,2));
      fprintf('\n      b(2) = %3.4f\n',br(cas,3));
      fprintf('\n  .... <ENTER> za nastavak\n');
      pause;
   end;

   % odziv cvora C prema ulazu
   [h,wo]=freqz(br(cas,:),naz(cas,:),brtoc);
   
   % odziv cvora D prema ulazu
   [h1,wo]=freqz([0 br(cas,[2:3])],naz(cas,:),brtoc);
   
   mag=abs(h.*hout)*scalnaz;
   mag1=abs(h1.*hout)*scalnaz;
   
   if xxx==1,
      sl1;
      plot(wo/(2*pi),20*log10([mag mag1]));
      set(sl1, 'Visible', 'on');
      xlabel('Frekvencija (1=frekv. otipkavanja)');
      ylabel('Pojacanje (dB)');
      title('Pojacanja po cvorovima C/zuto D/ljub');
      grid;
      pause;
      set(sl1, 'Visible', 'off');
   end;
   
   % nadji maksimume odziva za cvorove C i D
   mmag=max(mag);
   mmag1=max(mag1);
   
   if xxx==1,
      fprintf('\nMaximalna pojacanja po cvorovima brojnika za sinusnu pobudu :\n\n');
      fprintf('Cvor Cout : %3.4f\n',mmag);
      fprintf('Cvor D    : %3.4f\n',mmag1);
   end;
   
   scalbr=1/max([mmag mmag1]);
   
   if (scalbr>=1),
      scalafter=(1/scalnaz);
      amp_tot=amp_tot*scalafter;
      
      if xxx==1,
         fprintf('\nNema overload-a u brojniku, izlaz je ispod 1');
         fprintf('\nFaktor pojacanja ubacen u totalni faktor %3.4f',scalafter);
         fprintf('\nTrenutni totalni faktor %3.4f\n',amp_tot);
      end;
      
   else,
      br(cas,:)=br(cas,:)*scalbr;
      scalafter=(1/scalnaz)*(1/scalbr);
      amp_tot=amp_tot*scalafter;
      ramp_tot=ramp_tot/scalbr;
      
      if xxx==1,
         fprintf('\nPotrebni faktor atenuacije da ne dodje do overload-a niti\n');
         fprintf('u jednom cvoru brojnika   .... = %3.4f\n',scalbr);
         fprintf('\nSkalirani koeficijenti brojnika :\n');
         fprintf('\n      b(0) = %3.4f',br(cas,1));
         fprintf('\n      b(1) = %3.4f',br(cas,2));
         fprintf('\n      b(2) = %3.4f\n',br(cas,3));
         fprintf('\nFaktor pojacanja ubacen u totalni faktor %3.4f',scalafter);
         fprintf('\nTrenutni totalni faktor %3.4f\n',amp_tot);
         fprintf('\n  .... <ENTER> za nastavak\n');
         pause;
      end;
      
   end;
   
   
   % izracunaj odziv cvora C i D s tako skaliranim koeficijentima
   [h,wo]=freqz(br(cas,:),naz(cas,:),brtoc);
   [h1,wo]=freqz([0 br(cas,[2:3])],naz(cas,:),brtoc);
   
   % dinamika u cvoru D
   dind(cas)=max(abs(h1.*hout)*scalnaz);
   
   % novi izlaz
   hout=(h.*hout)*scalnaz;
   
   % dinamika na izlazu (cvor C)
   dinc(cas)=max(abs(hout));
   
end;    % kraj petlje za sve kaskade

hout=hout*amp_tot;

if xxx==1,
   fprintf('\nKoeficijenti realiziranih biquad sekcija :\n');
   fprintf('\n    inamp       a0        a1        a2        b0        b1        b2');
   fprintf('\n ---------------------------------------------------------------------\n');
   disp([in_scale' naz br])
   fprintf('Konacno pojacanje na samom izlazu %3.4f\n',amp_tot);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
   fprintf('\nDinamika sinusnog signala po cvorovima (A,B,C,D i E):\n');
   fprintf('\n      E         A         B         C         D');
   fprintf('\n --------------------------------------------------\n');
   disp([dine' dina' dinb' dinc' dind'])
   fprintf('  .... <ENTER> za nastavak\n');
   pause;
end;

ibr=round(br*(2^(brbit-1)));
inaz=round(naz*(2^(brbit-1)));

rbr=ibr/(2^(brbit-1));
rnaz=inaz/(2^(brbit-1));

if xxx==1,
   fprintf('\nKoeficijenti nakon zaokruzenja : \n');
   fprintf('\n     a0        a1        a2        b0        b1        b2');
   fprintf('\n -----------------------------------------------------------\n');
   disp([rnaz rbr])
   fprintf('  .... <ENTER> za nastavak\n');
   pause;
end;

% testiranje dinamike po cvorovima nakon zaokruzenja

hout=ones(brtoc,1);
for cas=1:brcas,     % Za sve kaskade :
   
   if xxx==1,
      fprintf('\nProvjera dinamike za kaskadu %.0f:\n',cas);
   end;
   % za nazivnik
   
   % odziv cvora A trenutne sekcije prema ulazu u filter
   [h,wo]=freqz(1,rnaz(cas,:),brtoc);
   
   % odziv cvora B trenutne sekcije prema ulazu u filter
   [h1,wo]=freqz([0 rnaz(cas,[2:3])],rnaz(cas,:),brtoc);
   
   % apsolutne vrijednosti od H(exp(j*om))
   mag=abs(h.*hout);
   mag1=abs(h1.*hout);
   
   maxul=1;               % maksimalna dinamika na ulazu je za prvu kaskadu 1
   if (cas>1),            % za ostale kaskade ... zavisi o dinamici izlaza
      % prethodne kaskade = dinc
      maxul=dinc(cas-1);
   end;
   
   % najvece pojacanje za cvorove A i B
   mmag=max(mag);
   mmag1=max(mag1);
   
   if xxx==1,
      fprintf('Maximalna dinamika po cvorovima nazivnika nakon zaokruzenja :\n\n');
      fprintf('Cvor A   : %3.4f\n',mmag);
      fprintf('Cvor B   : %3.4f\n',mmag1);
      fprintf('Cvor Cin : %3.4f\n',maxul);
   end;
   
   % potrebni faktor skale na ulazu u sekciju da veci od A,B i E bude 1
   newscalnaz=1/max([mmag mmag1 maxul]);
   
   % dinamika na izlazu iz ulaznog pojacala
   rdine(cas)=maxul;
   
   % dinamika u cvoru A
   rdina(cas)=mmag;
   
   % dinamika u cvoru B
   rdinb(cas)=mmag1;
   
   if xxx==1,
      fprintf('\nFaktor skale da nema overload-a niti u jednom\n');
      fprintf('cvoru nazivnika   .... = %3.4f\n',newscalnaz);
      fprintf('\n  .... <ENTER> za nastavak\n');
      pause;
   end;
   
   % za brojnik
   
   % odziv cvora C prema ulazu
   [h,wo]=freqz(rbr(cas,:),rnaz(cas,:),brtoc);
   
   % odziv cvora D prema ulazu
   [h1,wo]=freqz([0 rbr(cas,[2:3])],rnaz(cas,:),brtoc);
   
   mag=abs(h.*hout);
   mag1=abs(h1.*hout);
   
   % nadji maksimume odziva za cvorove C i D
   mmag=max(mag);
   mmag1=max(mag1);
   scalbr2=1/max([mmag mmag1]);
   worst_scalnaz=min(scalbr2,newscalnaz);
   if xxx==1,
      fprintf('\nMaximalna dinamika po cvorovima brojnika nakon zaokruzenja :\n\n');
      fprintf('Cvor Cout : %3.4f\n',mmag);
      fprintf('Cvor D    : %3.4f\n',mmag1);
      fprintf('\nUlazni faktor skaliranja da nema overload-a u brojniku = %3.8f\n'...
         ,scalbr2);
      fprintf('Manji od dva faktora (brojnika i nazivnika) = %3.8f\n',worst_scalnaz);
   end;
   
   iscalnaz=floor(worst_scalnaz*(2^(brbit-1)));
   rscalnaz=iscalnaz/(2^(brbit-1));
   
   if (rscalnaz==0),
      kmenu('Zadano je premalo bita za realizaciju zeljene funkcije. Filter je neostvariv!!!','OK');
      ss=0;
      delete(sl1);
      figure(hhh);
      set(hhh,'visible','on');
      break;
   end;
   
   if xxx==1,
      fprintf('Nakon odsijecanja na broj bita ... faktor = %3.8f\n',rscalnaz);
      fprintf('\n  .... <ENTER> za nastavak\n');
      pause;
   end;
   % spremi faktor skale u polje
   iin_scale(cas)=iscalnaz;
   rin_scale(cas)=rscalnaz;
   
   rdine(cas)=rdine(cas)*rscalnaz;
   rdina(cas)=rdina(cas)*rscalnaz;
   rdinb(cas)=rdinb(cas)*rscalnaz;
   
   ramp_tot=ramp_tot/rscalnaz;
   
   
   % dinamika u cvoru D
   rdind(cas)=max(abs(h1.*hout)*rscalnaz);
   
   % novi izlaz
   hout=(h.*hout)*rscalnaz;
   
   % dinamika na izlazu (cvor C)
   rdinc(cas)=max(abs(hout));
   
end;    % kraj petlje za sve kaskade

if (ss == 0),         % treba radi petlje po kaskadama
   break;
end;

iout_amp=floor((1/rdinc(brcas))*(2^(brbit-1)));
rout_amp=iout_amp/(2^(brbit-1));

if xxx==1,
   fprintf('\nPreostalo potrebno pojacanje da izlaz bude 0dB: %3.8f\n',...
      1/rdinc(brcas));
   fprintf('Nakon zaokruzenja na broj bit-a : %3.8f\n',rout_amp);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
end;

mag=abs(H);
magr=abs(hout)*rout_amp;
phase=angle(H)/pi*180;
phaser=angle(hout)/pi*180;

if xxx==1,
   sl1;
   plot(wo/(2*pi),20*log10([mag magr]));
   axis([0 0.5 -80 20]);
   set(sl1, 'Visible', 'on');
   xlabel('Frekvencija (1=frekv. otipkavanja)');
   ylabel('Pojacanje (dB)');
   title('Magnituda filtra prije zaokruzenja/zuto i poslije/ljub');
   grid;
   pause;
   axis;
   plot(wo/(2*pi),[phase phaser]);
   axis([0 0.5 -180 180]);
   xlabel('Frekvencija (1=frekv. otipkavanja)');
   ylabel('Faza u stupnjevima');
   title('Faza prije zaokruzenja/zuto i poslije/ljub');
   grid;
   pause;
   axis;
   delete(sl1);
   fprintf('\n Cijeli Koeficijenti realiziranih biquad sekcija :\n');
   fprintf('\n inamp    a0    a1    a2    b0    b1    b2');
   fprintf('\n -------------------------------------------\n');
   disp([iin_scale' inaz ibr])
   fprintf('Konacno pojacanje na samom izlazu = %.0f\n',iout_amp);
   fprintf('\n  .... <ENTER> za nastavak\n');
   pause;
   fprintf('\nDinamika sinusnog signala po cvorovima (A,B,C,D i E):\n');
   fprintf('\n      E         A         B         C         D');
   fprintf('\n --------------------------------------------------\n');
   disp([rdine' rdina' rdinb' rdinc' rdind'])
   fprintf('  .... <ENTER> za nastavak\n');
   pause;
   figure(hhh);
   set(hhh,'visible','on');
   
end;
% ss=1;
iin_scale=[iin_scale iout_amp];
