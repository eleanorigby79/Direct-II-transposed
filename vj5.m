function vj5(action,brbit)
max_atten=120;
%===trazenje pravog prozora===
if (nargin < 1),%ako je funkcija pozvana bez ulaznih argumenata
   action = 'prikazi';
end;
a=get(0,'children');

nas_prozor = -1;

if (~isempty(a)),%ako u nultom hendlu veæ postoje neki prozori
   for i=1:max(size(a)),
      if strcmp(get(a(i),'Name'), 'PROJEKTIRANJE IIR FILTERA DIREKTNOM FORMOM II I KASKADNOM FORMOM'),%trazi naš prozor
         nas_prozor = a(i);
         break;
      end;
   end;
end;

if (nas_prozor == -1),%ako nije našao naš prozor
   action='init';%inicijalizira
   
else,%ako je našao naš prozor
   
   %===definiranje varijabli===
   list=get(nas_prozor,'Userdata');
   prozor=list(1);ax1=list(2);ax2=list(3);fleka=list(4);realizacija=list(5);
   txt1=list(6);redfilt=list(7);txt2=list(8);grfr1=list(9);;txt3=list(10);
   grfr2=list(11);txt4=list(12);granica1=list(13);txt16=list(14);granica2=list(15);
   txt15=list(16);granica3=list(17);txt5=list(18);granica4=list(19);txt6=list(20);
   val1=list(21);txt7=list(22);val2=list(23);txt8=list(24);okvir2=list(25);
   tipfilt=list(26);txt9=list(27);tipapr=list(28);txt10=list(29);fsample=list(30);
   txt11=list(31);brbitk=list(32);txt12=list(33);okvir3=list(34);obradi16=list(35);
   obradi32=list(36);make16=list(37);make32=list(38);okvir4=list(39);slike=list(40);
   txt14=list(41);okvir5=list(42);ax3=list(43);nacin=list(44);okvir4a=list(45);
   txt16a=list(46);txt32a=list(47);
   
   
end;

if strcmp(action,'prikazi'),
   figure(prozor);
   
   %===inicijalizacija===
elseif strcmp(action,'init'),
   %definiranje prozora
   
   prozor=figure('Name','PROJEKTIRANJE IIR FILTERA DIREKTNOM FORMOM II I KASKADNOM FORMOM' ,...
      'NumberTitle','off',...          
      'Units','normal',...
      'menubar','none',...
... %      'color',[0 0 0],...
      'Position',[0.05 0.05 0.9 0.9]);
   %gornji koordinatni sustav
   ax1=axes('box','on',...
      'units','normal',...
      'position',[0.095 0.57 0.65 0.38],...
      'fontsize',8);
   %donji koordinatni sustav
   ax2=axes('box','on',...
      'units','normal',...
      'position',[0.095 0.07 0.65 0.38],...
      'fontsize',8);
   %veliki koordinatni sustav
   ax3=axes('box','on',...
      'units','normal',...
      'position',[0.1 0.1 0.6 0.8],...
      'fontsize',8,...
      'visible','off');
   %realizacija filtra (direktna ili kaskadna)
   realizacija=uicontrol('string','DIREKTNA|KASKADNA, padajuci Q|KASKADNA, rastuci Q|DIREKTNA+KASKADNA(padajuciQ)|DIREKTNA+KASKADNA(rastuciQ)',...
      'style','pop',...
      'units','normal',...
      'position',[0.76 0.92 0.23 0.03],...
      'call','vj5(''prebaci'')',...
      'value',1);
   txt1=uicontrol('style','text',...
      'string','Odabir realizacije:',...
      'units','normal',...
      'backgroundcolor',[0 0 0],...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.95 0.2 0.03]);
   %nacin zadavanja filtra (preko reda ili preko valovitosti)
   nacin=uicontrol('style','push',...
      'units','normal',...
      'position',[0.76 0.64 0.23 0.04],...
      'string','Definicija filtra preko reda',...
      'userdata',[2],...
      'call','vj5(''blokiraj'')');
   %red filktra
   redfilt=uicontrol('style','edit',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.59 0.04 0.03],...
      'units','normal',...
      'string',4,...
      'userdata',[4],...
      'call','vj5(''racunaj1'')');
   txt2=uicontrol('style','text',...
      'string','Red filtra :',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.59 0.15 0.03]);
   %granicna frekvencija w1
   grfr1=uicontrol('style','edit',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.56 0.04 0.03],...
      'units','normal',...
      'string',0.2,...
      'userdata',[0.2],...
      'call','vj5(''racunaj1'')');
   txt3=uicontrol('style','text',...
      'string','Gornja gran.frekv. , (1=Fo):',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.56 0.185 0.03]);
   %granicna frekvencija w2
   grfr2=uicontrol('style','edit',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.53 0.04 0.03],...
      'units','normal',...
      'string',0.4,...
      'userdata',[0.4],...
      'call','vj5(''racunaj1'')');
   txt4=uicontrol('style','text',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.53 0.187 0.03]);
   %prva granica (kod zadavanja preko valovitosti)
   granica1=uicontrol('style','text',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.42 0.04 0.03],...
      'units','normal',...
      'string',0.2,...
      'userdata',[0.2],...
      'call','vj5(''racunaj2'')');
   txt16=uicontrol('style','text',...
      'string','Kraj Pass banda:',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.42 0.187 0.03]);         
   %druga granica (kod zadavanja preko valovitosti)
   granica2=uicontrol('style','text',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.39 0.04 0.03],...
      'units','normal',...
      'string',0.25,...
      'userdata',[0.25],...
      'call','vj5(''racunaj2'')');
   txt15=uicontrol('style','text',...
      'string','Pocetak Stop banda:',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.39 0.187 0.03]);
   %treca granica (kod zadavanja preko valovitosti)
   granica3=uicontrol('style','text',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.36 0.04 0.03],...
      'units','normal',...
      'string',0.35,...
      'userdata',[0.35],...
      'call','vj5(''racunaj2'')');
   txt5=uicontrol('style','text',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.36 0.187 0.03]);
   %cetvrta granica (kod zadavanja preko valovitosti)
   granica4=uicontrol('style','text',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.33 0.04 0.03],...
      'units','normal',...
      'string',0.4,...
      'userdata',[0.4],...
      'call','vj5(''racunaj2'')');
   txt6=uicontrol('style','text',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.33 0.187 0.03]);
   %valovitost prvog pojasa
   val1=uicontrol('style','edit',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.49 0.04 0.03],...
      'units','normal',...
      'string',0.1,...
      'userdata',[0.1],...
      'call','vj5(''racunaj1'')');
   txt7=uicontrol('style','text',...
      'string','Ripple u pass bandu: ',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.49 0.187 0.03]);
   %valovitost drugog pojasa (gusenje)
   val2=uicontrol('style','edit',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.46 0.04 0.03],...
      'units','normal',...
      'string',70,...
      'userdata',[70],...
      'call','vj5(''racunaj1'')');
   txt8=uicontrol('style','text',...
      'string','Gusenje u Stop  bandu:',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.46 0.187 0.03]);
   okvir2=uicontrol('style','frame',...
      'units','normal',...
      'position',[0.755 0.325 0.24 0.30],...
      'backgroundcolor','b');
   %tip filtra
   tipfilt=uicontrol('string','Niski propust|Visoki propust|Pojasni propust|Pojasna brana',...
      'style','pop',...
      'position',[0.76 0.76 0.23 0.03],...
      'units','normal',...
      'call','vj5(''sredi'')',...
      'value',1);
   txt9=uicontrol('style','text',...
      'string','Tip filtra:',...
      'units','normal',...
      'backgroundcolor',[0 0 0],...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.79 0.155 0.03]);
   %tip aproksimacije
   tipapr=uicontrol('string','Butterworth|Chebyshev tip I|Chebyshev tip II|Elipticki (Cauer)',...
      'style','pop',...
      'position',[0.76 0.69 0.23 0.03],...
      'units','normal',...
      'call','vj5(''sredi'')',...
      'value',1);
   txt10=uicontrol('style','text',...
      'string','Tip aproksimacije:',...
      'units','normal',...
      'backgroundcolor',[0 0 0],...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.72 0.16 0.03]);
   txt11=uicontrol('style','text',...
      'string','Odabir Fo (Frek. otipkavanja):',...
      'units','normal',...
      'backgroundcolor',[0 0 0],...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.23 0.23 0.03]);
   %frekvencija otipkavanja za DSP
   fsample=uicontrol('string','5.5125 kHz|6.615 kHz|8.0 kHz|9.6 kHz|11.025 kHz|16.0 kHz|18.9 kHz|22.05 kHz|27.42857 kHz|32.0 kHz|33.075 kHz|37.8 kHz|44.1 kHz|48.0 kHz',...
      'style','pop',...
      'position',[0.8 0.20 0.19 0.03],...
      'units','normal',...
      'value',1);
   txt12=uicontrol('style','text',...
      'string','Broj bita za kvantizaciju koeficijenata:',...
      'units','normal',...
      'backgroundcolor','b',...
      'foregroundcolor',[1 1 1],...
      'horizontalalignment','left',...
      'position',[0.76 0.27 0.18 0.04]);
   %broj bita za kvantizaciju koeficijenata
   brbitk=uicontrol('style','edit',...
      'backgroundcolor',[1 0.8 0.9],...
      'position',[0.945 0.27 0.04 0.03],...
      'units','normal',...
      'string',8,...
      'userdata',[8],...
      'call','vj5(''prebaci'')');
   okvir3=uicontrol('style','frame',...
      'units','normal',...
      'position',[0.755 0.265 0.24 0.05],...
      'backgroundcolor','b');
   
%DSP dio   
   obradi16=uicontrol('style','push',...
      'units','normal',...
      'position',[0.88 0.130 0.11 0.03],...
      'string','Obrada 16',...
      'call','vj5(''obrada16'',16)');
   obradi32=uicontrol('style','push',...
      'units','normal',...
      'position',[0.88 0.06 0.11 0.03],...
      'string','Obrada 32',...
      'call','vj5(''obrada16'',32)');
   make16=uicontrol('style','push',...
      'units','normal',...
      'position',[0.8 0.160 0.08 0.03],...
      'string','Start DSP',...
      'call','vj5(''napravi16'',16)');
   make32=uicontrol('style','push',...
      'units','normal',...
      'position',[0.8 0.09 0.08 0.03],...
      'string','Start DSP',...
      'call','vj5(''napravi16'',32)');
   
   okvir4=uicontrol('style','frame',...          % 16-bita
      'units','normal',...
      'position',[0.795 0.125 0.2 0.07],...
      'backgroundcolor',[.7 .8 .9]);
   okvir4a=uicontrol('style','frame',...         % 32-bita
      'units','normal',...
      'position',[0.795 0.055 0.2 0.07],...
      'backgroundcolor',[.9 .8 .7] );
   txt16a = uicontrol('style','text',...
      'string','16-bita',...
      'units','normal',...
      'backgroundcolor',[.7 .8 .9] ,...
      'foregroundcolor',[0 0 0],...
      'horizontalalignment','left',...
      'position',[0.820 0.130 0.05 0.03]);
   txt32a = uicontrol('style','text',...
      'string','32-bita',...
      'units','normal',...
      'backgroundcolor',[.9 .8 .7] ,...
      'foregroundcolor',[0 0 0],...
      'horizontalalignment','left',...
      'position',[0.820 0.06 0.05 0.03]);
% kraj DSP dijela
   
   %izbornik za odabir prikaza na koordinatnom sustavu (sto se zeli gledati?)
   slike=uicontrol('string','Raspored polova i nula|Amplitudna i fazna karakteristika|Odziv na impuls i na step|Amplitudna i fazna karak. nakon zaokr.|Impulsni odziv nakon zaokruzenja|Proracun dinamike',...
      'style','pop',...
      'position',[0.76 0.845 0.23 0.03],...
      'units','normal',...
      'call','vj5(''prebaci'')',...
      'value',1);
   txt14=uicontrol('style','text',...
      'string','Prikaz:',...
      'units','normal',...
      'backgroundcolor','y',...
      'foregroundcolor',[0 0 0],...
      'horizontalalignment','left',...
      'position',[0.76 0.875 0.23 0.03]);
   okvir5=uicontrol('style','frame',...
      'units','normal',...
      'position',[0.755 0.84 0.24 0.07],...
      'backgroundcolor','y');
   
   kraj=uicontrol('style','push',...
      'units','normal',...
      'position',[0.89 0.005 0.1 0.045],...
      'backgroundcolor',[0.5 1 0.83],...
      'string','KRAJ',...
      'call','close');
   fleka=uicontrol('style','text',...
      'visible','off',...
      'units','normal',...
      'string','fleka',...
      'position',[0.01 0.01 0.011 0.011]);
   list=[prozor; ax1; ax2; fleka; realizacija; txt1; redfilt; txt2; grfr1;...
         txt3; grfr2; txt4; granica1; txt16; granica2; txt15; granica3; txt5;...
         granica4; txt6; val1; txt7; val2; txt8; okvir2;...
         tipfilt; txt9; tipapr; txt10; fsample; txt11; brbitk; txt12; ...
         okvir3; obradi16; obradi32; make16; make32; okvir4; slike; txt14; okvir5;...
         ax3;nacin;okvir4a;txt16a;txt32a];
   set(prozor,'UserData',list);
   set([grfr2 txt4 granica3 txt6 granica4 txt5 val1 txt7 val2 txt8],'visible','off');
   vj5('racunaj1');
   
elseif strcmp(action,'prebaci'),
   
   %ovdje se dolazi ako se aktivira izbornik prikaza 
   m=get(realizacija,'value');
   sl=get(slike,'value');
   if (sl==1|sl==2|sl==3), %ako se odabere promatranje filtra prije kvantizacije
      s=sprintf('vj5(''crtaj%d'')',sl);
      eval(s);
   elseif (sl==4|sl==5|sl==6)& m==1, %ako se zeli promatrati ucinci kvantizacije, direktna realizacija
      coefbit=str2num(get(brbitk,'string'));%broj bita za kvantizaciju koeficijenata
      if isempty(coefbit),
         kmenu('Krivo ste unijeli podatak.Broj bita mora biti prirodan broj veci od 0.','OK');
         coefbit=get(brbitk,'userdata');
         set(brbitk,'string',coefbit);
      end;
      if (rem(coefbit,1)~=0|coefbit<=0),
         kmenu('Krivo ste unijeli podatak.Broj bita mora biti prirodan broj veci od 0.','OK');
         coefbit=get(brbitk,'userdata');
         set(brbitk,'string',coefbit);
      end;
      num=get(txt5,'userdata');%brojnik filtra (nekvantiziranog)
      den=get(txt6,'userdata');%nazivnik filtra (nekvantiziranog)
      if sl==4,x=0;elseif sl==5, x=0; elseif sl==6, x=1;end;%ako je x=0 ne ispisivati proracun dinamike, ako je x=1, ispisivati
      h=gcf;%handl od glavnog prozora tako, kad se udje u funkciju direct da se zna vratiti
      [magr,phaser,inum,iden,iin_scale,ss]=direct(num,den,coefbit,x,h); %pokretanje direktne realizacije
      %ako je ss=1, realizacija je izvrsena, ide se dalje, ako je ss=0, bilo je premalo bita za realizaciju,
      %izlazi se iz programa direct bez ikakvih slijedecih akcija
      if ss==1,
         set(txt7,'userdata',[magr,phaser]);%amplituda i faza
         set(txt8,'userdata',inum);%brojnik
         set(txt9,'userdata',iden);%nazivnik
         set(txt10,'userdata',iin_scale);%pojacala
         if (sl==4 | sl==6),
            vj5('crtaj4');
            set(slike,'value',4);
         elseif sl==5,
            vj5('crtaj5');  
         end;
      else, axes(ax2); cla; axes(ax1); cla; break;
      end;
   elseif (sl==4|sl==5|sl==6) & (m==2|m==3), %promatranje ucinaka kvantizacije, kaskadna realizacija
      coefbit=str2num(get(brbitk,'string'));%broj bita za kvantizaciju koeficijenata
      if isempty(coefbit),
         kmenu('Krivo ste unijeli podatak.Broj bita mora biti prirodan broj veci od 0.','OK');
         coefbit=get(brbitk,'userdata');
         set(brbitk,'string',coefbit);
      end;
      if (rem(coefbit,1)~=0|coefbit<=0),
         kmenu('Krivo ste unijeli podatak.Broj bita mora biti prirodan broj veci od 0.','OK');
         coefbit=get(brbitk,'userdata');
         set(brbitk,'string',coefbit);
      end;
      p=get(txt3,'userdata');%polovi
      z=get(txt1,'userdata');%nule
      k=get(txt11,'userdata');%pojacalo
      if sl==4,x=0;elseif sl==5, x=0; elseif sl==6, x=1;end;%x=1...ispisivanje dinamike; x=0...ne ispisivanje dinamike
      h=gcf;%handl glavnog prozora da se zna vratiti iz funkcije biquad
      if m==2,
         flip=1;%padajuci koeficijenti
      elseif m==3,
         flip=2;%rastuci koeficijenti
      end;
      [magr,phaser,ibr,inaz,iin_scale,ss]=biquad(p,z,k,coefbit,x,h,flip);%kaskadna realizacija
      %ss=1...realizirani filter;  ss=0...filter nije realiziran zbog premalo bita
      if ss==1,
         set(txt7,'userdata',[magr,phaser]);
         set(txt8,'userdata',ibr);
         set(txt9,'userdata',inaz);
         set(txt10,'userdata',iin_scale);
         if (sl==4 | sl==6),
            vj5('crtaj4');
            set(slike,'value',4);
         elseif sl==5,
            vj5('crtaj5');  
         end;
      else, axes(ax2); cla; axes(ax1); cla; break;
      end;
      
      
   elseif (sl==4|sl==5|sl==6) & (m==4|m==5),%usporedba ucinaka kvantizacije, kaskadne i direktne realizacije
      if sl==6,%ako je odabrano ispisivanje proracuna dinamike
         kmenu('Ne mozete imati opciju proracuna dinamike za obadva tipa realizacije. Odaberite jednu od realizacija!!!','OK');
         break;
      end;
      coefbit=str2num(get(brbitk,'string'));
      if isempty(coefbit),
         kmenu('Krivo ste unijeli podatak.Broj bita mora biti prirodan broj veci od 0.','OK');
         coefbit=get(brbitk,'userdata');
         set(brbitk,'string',coefbit);
      end;
      if (rem(coefbit,1)~=0|coefbit<=0),
         kmenu('Krivo ste unijeli podatak.Broj bita mora biti prirodan broj veci od 0.','OK');
         coefbit=get(brbitk,'userdata');
         set(brbitk,'string',coefbit);
      end;
      set(ax3,'visible','off');
      delete(get(ax3,'children'));
      set([ax1 ax2],'visible','on');
      a=get(txt2,'userdata');
      wo=a(:,1);mag=a(:,2);phase=a(:,3);%nekvantizirani filter
      if sl==4,%ako je odabrano iscrtavanje A/F i F/F karakteristike iscrtaj nekvantizirani filter,
               %a ako je odabrano iscrtavanje impulsnog odziva, ne iscrtavaj
         axes(ax1);
         plot(wo,20*log10([mag]));
         hold on;
         axes(ax2);
         plot(wo,[phase]);
         hold on;
      end;
      num=get(txt5,'userdata');%
      den=get(txt6,'userdata');%nekvantizirani filtar
      %kvantizacija koeficijenata, direktna realizacija
      h=gcf;
      [magr,phaser,inum,iden,iin_scale,ss]=direct(num,den,coefbit,0,h);
      if ss==1,
         if sl==4%A/F karakteristika
            axes(ax1);
            plot(wo,20*log10([magr]),'m');
            hold on;
            axes(ax2);
            plot(wo,[phaser],'m');
            hold on;
         elseif sl==5,%impulsni odziv
            set(ax2,'visible','off');delete(get(ax2,'children'));
            timepoints=64;
            set(ax3,'visible','off');
            delete(get(ax3,'children'));
            set([ax1],'visible','on');
            mxc=2^(coefbit-1);
            u=[1 0*ones(1,timepoints-1)];
            Y=filter(num,den,u);
            Yr=filter(inum/mxc,iden/mxc,u);
            Yr=Yr*prod(iin_scale/mxc);
            axes(ax1);
            plot([0:timepoints-1],[Y' Yr']);
            hold on;
         end;
      else, 
         axes(ax1);hold off;
         axes(ax2);hold off;
         axes(ax2); cla; axes(ax1); cla; break;
      end;
      %kaskadna realizacija
      p=get(txt3,'userdata');
      z=get(txt1,'userdata');
      k=get(txt11,'userdata');
      if m==4,
         flip=1;
      elseif m==5,
         flip=2;
      end;
      [magr,phaser,ibr,inaz,iin_scale,ss]=biquad(p,z,k,coefbit,0,h,flip);
      if ss==1,
         if sl==4 
            axes(ax1);
            axis([0 0.5 -max_atten 10]);
            plot(wo,20*log10([magr]),'g');
            axis([0 0.5 -max_atten 10]);
            hold off;
            set(ax1,'xlabel',text(0,0,'Frekvencija , 1=Fs'));
            set(ax1,'ylabel',text(0,0,'Pojacanje / dB'));
            set(ax1,'title',text(0,0,'Amplitudno-frekv. karakteristika filtra prije zaokruzenja/zuto, direktna/ljub kaskadna/zeleno'));
            grid on;
            axes(ax2);
            plot(wo,[phaser],'g');
            hold off;
            set(ax2,'xlabel',text(0,0,'Frekvencija, 1=Fs'));
            set(ax2,'ylabel',text(0,0,'Amplituda'));
            set(ax2,'title',text(0,0,'Fazno-frekv. karakteristika filtra prije zaokruzenja/zuto, direktna/ljub'));
            grid on;
         elseif sl==5,
            tt=size(ibr);
            brcas=tt(1);
            Yr=u;            
            for cas=1:brcas,
               Yr=filter(ibr(cas,:)/mxc,inaz(cas,:)/mxc,Yr);
            end;
            Yr=Yr*prod(iin_scale/mxc);
            axes(ax1);
            plot([0:timepoints-1],[Yr'],'g');
            hold off;
            set(ax1,'xlabel',text(0,0,'Vremenska os'));
            set(ax1,'ylabel',text(0,0,'Amplituda'));
            set(ax1,'title',text(0,0,'Impulsni odziv s realnim/zuto i cjelobrojnim (direkt/ljub i kask/zele) koeficijentima'));
            grid on;
            hold off;
         end;
      else,
         axes(ax1);hold off;
         axes(ax2);hold off;
         axes(ax2); cla; axes(ax1); cla; break;
      end;
   end;%kraj petlje koja provjerava sto odabrano za promatranje
   
elseif strcmp(action,'blokiraj'),
   
   %Brise i postavlja komande ovisno o tome koji je nacin zadavanja filtra odabran
   n=get(nacin,'userdata');

   if n==1,
      set(nacin,'string','Definicija filtra preko reda');
      set([granica1 granica2 granica3 granica4], 'style','text');
      set([redfilt grfr1 grfr2 val1 val2],'style','edit');
      set([val1 val2],'call','vj5(''racunaj11'')');
      set(nacin,'userdata',[2]);
   elseif n==2,
      set(nacin,'string','Definicija filtra preko valovitosti');
      set([granica1 granica2 granica3 granica4 val1 val2], 'style','edit');
      set([redfilt grfr1 grfr2],'style','text');
      set([val1 val2],'call','vj5(''racunaj2'')');
      set(nacin,'userdata',[1]);
   end;
   vj5('sredi');
   
elseif strcmp(action,'sredi'),
   
   %postavlja i brise komande ovisno o tome koji tip filtra i aproksimacije je odabrano
   tipf=get(tipfilt,'value');
   tipa=get(tipapr,'value');
   if tipf==1|tipf==2,
      set([grfr2 txt4 granica3 txt5 granica4 txt6],'visible','off');
      if tipf==1,
         set(txt3,'string','Gornja gran.frekv., (1=Fo):');
         set(txt16,'string','Kraj pass banda, (1=Fo):');
         set(txt15,'string','Pocetak stop banda, (1=Fo)');
      elseif tipf==2,
         set(txt3,'string','Donja gran. frekv., (1=Fo):');
         set(txt16,'string','Kraj stop banda, (1=Fo):');
         set(txt15,'string','Pocetak pass banda, (1=Fo):');
      end;
   end;
   if tipf==3|tipf==4,
      set([grfr2, txt4 granica3 txt5 granica4 txt6],'visible','on');
      set(txt3,'string','Donja gran.frekv., (1=Fo):');
      set(txt4,'string','Gornja gran.frekv., (1=Fo):');
      if tipf==3,
         set(txt16,'string','Kraj 1. stop banda, (1=Fo):');
         set(txt15,'string','Pocetak pass banda, (1=Fo):');
         set(txt5,'string','Kraj pass banda, (1=Fo):');
         set(txt6,'string','Pocetak 2. stop banda, (1=Fo):');
      elseif tipf==4,
         set(txt16,'string','Kraj 1. pass banda, (1=Fo):');
         set(txt15,'string','Pocetak stop banda, (1=Fo):');
         set(txt5,'string','Kraj stop banda, (1=Fo):');
         set(txt6,'string','Pocetak 2. pass banda, (1=Fo):');
      end; 
   end;
   n=get(nacin,'userdata');
   if tipa==1&n==2,
      set([val1 txt7 val2 txt8],'visible','off');
   elseif tipa==2&n==2,
      set([val1 txt7],'visible','on');
      set([val2 txt8],'visible','off');
      set(txt7,'string','Valovitost u pass bandu [dB] :');
   elseif tipa==3&n==2,
      set([val1 txt7],'visible','off');
      set([val2 txt8],'visible','on');
      set(txt8,'string','Gusenje u stop bandu [dB]');
   elseif tipa==4&n==2,
      set([val1 txt7 val2 txt8],'visible','on');
      set(txt7,'string','Valovitost u pass bandu [dB] :');
      set(txt8,'string','Gusenje u stop bandu [dB] :');
   end;
   if n==1,
      set([val1 txt7 val2 txt8],'visible','on');
      set(txt7,'string','Valovitost u pass bandu [dB] :');
      set(txt8,'string','Gusenje u stop bandu [dB] :');
      vj5('racunaj2');
   else
      vj5('racunaj1');
   end;
   
elseif strcmp(action,'racunaj1'),
   %racuna filtar
   brtoc=512;
   time_points=128;
   N=str2num(get(redfilt,'string'));
   if isempty(N),
      kmenu('red filtra mora biti prirodan broj veci od 1','OK');
      N=get(redfilt,'userdata');
      set(redfilt,'string',N);
   end;
   if N<1|rem(N,1)~=0,
      kmenu('Red filtra mora biti prirodan broj veci od 1','OK');
      N=get('redfilt','userdata');
      set(redfilt,'string',N);
   end;
   Tip=get(tipfilt,'value');
   apr=get(tipapr,'value');
   w1=str2num(get(grfr1,'string'));
   w2=str2num(get(grfr2,'string'));
   if any([isempty(w1) isempty(w2)]),
      kmenu('Upisali ste krive podatke.Granicne frekvencije moraju biti realni brojevi 0<fg<0.5','OK');
      w1=get(grfr1,'userdata')/2;
      set(grfr1,'string',w1);
      w2=get(grfr2,'userdata')/2;
      set(grfr2,'string',w2);
   end;
   if (w1<=0|w1>=0.5|w2<=0|w2>=0.5)|((Tip==3|Tip==4)&w2<=w1),
      kmenu('Krivo ste unijeli podatke.Granicne frekvencije moraju biti realni brojevi 0<fg<0.5.','OK');
      w1=get(grfr1,'userdata')/2;
      set(grfr1,'string',w1);
      w2=get(grfr2,'userdata')/2;
      set(grfr2,'string',w2);
   end;
   prip=str2num(get(val1,'string'));
   srip=str2num(get(val2,'string'));
   if any([isempty(prip) isempty(srip)]),
      kmenu('Upisali ste krive podatke. Valovitosti moraju biti realni brojevi.','OK');
      prip=get(val1,'userdata');
      set(val1,'string',prip);
      srip=get(val2,'userdata');
      set(val2,'string',srip);
   end;
   w1=2*w1;
   w2=2*w2;
   if (apr==1),
      if (Tip==1),
         [num,den]=butter(N,w1);
      elseif (Tip==2),
         [num,den]=butter(N,w1,'high');
      elseif (Tip==3),
         [num,den]=butter(N,[w1 w2]);
      elseif (Tip==4),
         [num,den]=butter(N,[w1 w2],'stop');
      end;
   end;
   
   if (apr==2),
      if (Tip==1),
         [num,den]=cheby1(N,prip,w1);
      elseif (Tip==2),
         [num,den]=cheby1(N,prip,w1,'high');
      elseif (Tip==3),
         [num,den]=cheby1(N,prip,[w1 w2]);
      elseif (Tip==4),
         [num,den]=cheby1(N,prip,[w1 w2],'stop');
      end;
   end;
   
   if (apr==3),
      if (Tip==1),
         [num,den]=cheby2(N,srip,w1);
      elseif (Tip==2),
         [num,den]=cheby2(N,srip,w1,'high');
      elseif (Tip==3),
         [num,den]=cheby2(N,srip,[w1 w2]);
      elseif (Tip==4),
         [num,den]=cheby2(N,srip,[w1 w2],'stop');
      end;
   end;
   
   if (apr==4),
      if (Tip==1),
         [num,den]=ellip(N,prip,srip,w1);
      elseif (Tip==2),
         [num,den]=ellip(N,prip,srip,w1,'high');
      elseif (Tip==3),
         [num,den]=ellip(N,prip,srip,[w1 w2]);
      elseif (Tip==4),
         [num,den]=ellip(N,prip,srip,[w1 w2],'stop');
      end;
   end;
   [z,p,k]=tf2zp(num,den);
   [h,wo]=freqz(num,den,brtoc);
   wo=wo/(2*pi);
   mag=abs(h);
   phase=angle(h)/pi*180;
   x=[1 0*ones(1,time_points-1)];
   y=filter(num,den,x);
   x1=ones(1,time_points);
   y1=filter(num,den,x1);
   set(redfilt,'userdata',N);    %da se zapamti sadasnji parametar u slucaju pogresnog unosa
   set(grfr1,'userdata',w1);     %-----------II--------------II-------------II--------------
   set(grfr2,'userdata',w2);     %-----------II--------------II-------------II--------------
   set(val1,'userdata',prip);    %-----------II--------------II-------------II--------------
   set(val2,'userdata',srip);    %-----------II--------------II-------------II--------------
   set(txt5,'userdata',[num]);%brojnik filtra
   set(txt6,'userdata',[den]);%nazivnik filtra
   set(txt4,'userdata',[y1' y']);%odziv na step i na impuls
   set(txt1,'userdata',[z]);%nule filtra
   set(txt3,'userdata',[p]);%polovi filtra
   set(txt11,'userdata',[k]);%pojacanje
   set(txt2,'userdata',[wo,mag,phase]);%frekvencijsaka os, magnituda i faza filtra
   sl=get(slike,'value');
   if (sl==4|sl==5|sl==6),
      set(slike,'value',2);
      sl=2;
   end;
   s=sprintf('vj5(''crtaj%d'')',sl);
   eval(s);
   
elseif strcmp(action,'racunaj2'),
   
   %racuna filtar pomocu valovitosti
   Tip=get(tipfilt,'value');
   w1=str2num(get(granica1,'string'));
   w2=str2num(get(granica2,'string'));
   w3=str2num(get(granica3,'string'));
   w4=str2num(get(granica4,'string'));
   if any([isempty(w1) isempty(w2) isempty(w3) isempty(w4)]),
      kmenu('Upisali ste krive podatke. Granicne frekvencije moraju biti realni brojevi!!!','OK');
      w1=get(granica1,'userdata');
      w2=get(granica2,'userdata');
      w3=get(granica3,'userdata');
      w4=get(granica4,'userdata');   
   end;
   if (w1<=0|w1>=0.5|w2<=0|w2>=0.5|w3<=0|w3>=0.5|w4<=0|w4>=0.5),
      kmenu('Upisali ste krive podatke. Granicne frekvencije moraju biti realni brojevi, koji zadovoljavaju uvjet 0<fg<0.5 !!!','OK');
      w1=get(granica1,'userdata');
      w2=get(granica2,'userdata');
      w3=get(granica3,'userdata');
      w4=get(granica4,'userdata');
   end;
   if (Tip==1|Tip==2),
      if w1>=w2,
         kmenu('Krivo ste unijeli podatke. Niz frekvencija mora biti strogo rastuci!!!','OK');
         w1=get(granica1,'userdata');
         w2=get(granica2,'userdata');
      end;
   elseif (Tip==3|Tip==4),
      if (w1>=w2|w2>=w3|w3>=w4),
         kmenu('Krivo ste unijeli podatke. Niz frekvencija mora biti strogo rastuci!!!','OK');
         w1=get(granica1,'userdata');
         w2=get(granica2,'userdata');
         w3=get(granica3,'userdata');
         w4=get(granica4,'userdata');
      end;
   end;
   set(granica1,'string',w1);
   set(granica2,'string',w2);
   set(granica3,'string',w3);
   set(granica4,'string',w4);
   
   prip=str2num(get(val1,'string'));
   srip=str2num(get(val2,'string'));
   if any([isempty(prip) isempty(srip)]),
      kmenu('Upisali ste krive podatke. Valovitosti moraju biti realni brojevi.','OK');
      prip=get(val1,'userdata');
      set(val1,'string',prip);
      srip=get(val2,'userdata');
      set(val2,'string',srip);
   end;
   
   apr=get(tipapr,'value');
   
   if ((Tip==1)|(Tip==2)),
      w1=w1*2;
      w2=w2*2;
      if (apr==1),
         [N,w]=buttord(w1,w2,prip,srip);
      elseif (apr==2),
         [N,w]=cheb1ord(w1,w2,prip,srip);
      elseif (apr==3),
         [N,w]=cheb2ord(w1,w2,prip,srip);
      else, 
         [N,w]=ellipord(w1,w2,prip,srip);
      end;
      if (Tip==2),
         w=w2-(w-w1);
      end;
      set(redfilt,'string',N);
      set(grfr1,'string',sprintf('%1.3f',w/2));
   end;
   
   if ((Tip==3)|(Tip==4)),
      w1=w1*2;
      w2=w2*2;
      w3=w3*2;
      w4=w4*2;
      if (apr==1),
         [Na,w11]=buttord(w1,w2,prip,srip);
         [Nb,w22]=buttord(w3,w4,prip,srip);
      elseif (apr==2),
         [Na,w11]=cheb1ord(w1,w2,prip,srip);
         [Nb,w22]=cheb1ord(w3,w4,prip,srip);
      elseif (apr==3),
         [Na,w11]=cheb2ord(w1,w2,prip,srip);
         [Nb,w22]=cheb2ord(w3,w4,prip,srip);
      elseif (apr==4), 
         [Na,w11]=ellipord(w1,w2,prip,srip);
         [Nb,w22]=ellipord(w3,w4,prip,srip);
      end;
      N=max(Na,Nb); 
      if (Tip==3),
         w1=w2-(w11-w1);
         w2=w22;
      else, 
         w1=w11;
         w2=w4-(w22-w3);
      end;
      set(redfilt,'string',N);
      set(grfr1,'string',sprintf('%1.3f',w1/2));
      set(grfr2,'string',sprintf('%1.3f',w2/2));
   end;
   vj5('racunaj1');%kad je proracunao red i granicne frekvencije, vrati se na 'racunaj1' da se izracunaju koeficijenti
   
elseif strcmp(action,'crtaj1'),
   
   set(ax1,'buttondownfcn','vj5('''')');
   set([ax1 ax2],'visible','off');
   delete([get(ax1,'children') get(ax2,'children')]);
   set(ax3,'visible','on');
   axes(ax3);
   z=get(txt1,'userdata');
   p=get(txt3,'userdata');
%   pzmap(p,z);
   
   fi_kru=[0:256]/256*2*pi;
   plot(cos(fi_kru),sin(fi_kru),'--',real(p),imag(p),'x',real(z), imag(z),'o');
   grid;
   title('Raspored polova i nula filtra');
   xlabel('Realna os');
   ylabel('Imaginarna os');
   
elseif strcmp(action,'crtaj2'),
   
   set([ax1 ax2],'visible','on');
   set(ax3,'visible','off');delete(get(ax3,'children'));
   a=get(txt2,'userdata');
   wo=a(:,1);mag=a(:,2);phase=a(:,3);
   axes(ax1);
   axis([0 0.5 -max_atten 10]);
   plot(wo,20*log10(mag));
   axis([0 0.5 -max_atten 10]);
   set(ax1,'xlabel',text(0,0,'Frekvencija (1=frekv. otipkavanja)'));
   set(ax1,'ylabel',text(0,0,'Atenuacija (dB)'));
   set(ax1,'title',text(0,0,'Amplitudno - frekvencijska karakteristika filtra'));
   set(ax1,'buttondownfcn','vj5(''crtaj22'')');
   grid on;
   axes(ax2);
   axis([0 0.5 -180 180]);
   plot(wo,phase);
   set(ax2,'xlabel',text(0,0,'Frekvencija (1=frekv. otipkavanja)'));
   set(ax2,'ylabel',text(0,0,'Faza (dB)'));
   set(ax2,'title',text(0,0,'Fazno - frekvencijska karakteristika filtra'));
   grid on;
   
elseif strcmp(action,'crtaj22'),
   
   a=get(txt2,'userdata');
   wo=a(:,1);mag=a(:,2);phase=a(:,3);
   w1=str2num(get(grfr1,'string'));
   p1=min(find(wo>w1));
   w2=str2num(get(grfr2,'string'));
   p2=min(find(wo>w2));
   if isempty(p2), p2=max(size(wo)); end;
   if isempty(p1),p1=1;end;
   tipf=get(tipfilt,'value');
   poz=get(ax1,'currentpoint');poz=poz(1,1);
   if (tipf==1|tipf==2),
      if poz<w1, w=wo(1:p1);mag=mag(1:p1);ph=phase(1:p1);
      elseif poz>w1, w=wo(p1:max(size(wo)));mag=mag(p1:max(size(mag)));ph=phase(p1:max(size(phase)));
      end;
   elseif (tipf==3|tipf==4),
      if poz<w1, w=wo(1:p1);mag=mag(1:p1);ph=phase(1:p1);
      elseif (poz>w1&poz<w2), w=wo(p1:p2);mag=mag(p1:p2);ph=phase(p1:p2);
      elseif poz>w2, w=wo(p2:max(size(wo)));mag=mag(p2:max(size(mag)));ph=phase(p2:max(size(phase)));              
      end;           
   end;
   axes(ax1);
   axis([0 0.5 -max_atten 10]);
   plot(w,20*log10(mag));
   axis([0 0.5 -max_atten 10]);
   set(ax1,'xlabel',text(0,0,'Frekvencija (1=frekv. otipkavanja)'));
   set(ax1,'ylabel',text(0,0,'Atenuacija (dB)'));
   set(ax1,'title',text(0,0,'Amplitudno - frekvencijska karakteristika filtra'));
   grid on;
   axes(ax2);
   plot(w,ph);
   set(ax2,'xlabel',text(0,0,'Frekvencija (1=frekv. otipkavanja)'));
   set(ax2,'ylabel',text(0,0,'Faza (dB)'));
   set(ax2,'title',text(0,0,'Fazno - frekvencijska karakteristika filtra'));
   grid on;
   set(ax1,'buttondownfcn','vj5(''crtaj2'')');
   
elseif strcmp(action,'crtaj3'),
   
   set([ax1 ax2],'visible','on');
   set(ax3,'visible','off');delete(get(ax3,'children'));
   set(ax1,'buttondownfcn','vj5('''')');
   a=get(txt4,'userdata');
   y1=a(:,1);y=a(:,2);
   axes(ax1);
   plot(y);
   set(ax1,'xlabel',text(0,0,'Vremenska os'));
   set(ax1,'ylabel',text(0,0,'Amplituda'));
   set(ax1,'title',text(0,0,'Uzorci impulsnog odziva filtra'));
   grid on;
   axes(ax2);
   plot(y1);
   set(ax2,'xlabel',text(0,0,'Vremenska os'));
   set(ax2,'ylabel',text(0,0,'Amplituda'));
   set(ax2,'title',text(0,0,'Uzorci odziva filtra na step' ));
   grid on;
   
elseif strcmp(action,'crtaj4'),
   
   set(ax3,'visible','off');
   delete(get(ax3,'children'));
   set([ax1 ax2],'visible','on');
   a=get(txt7,'userdata');
   magr=a(:,1);phaser=a(:,2);
   a=get(txt2,'userdata');
   wo=a(:,1);mag=a(:,2);phase=a(:,3);
   m=get(realizacija,'value');
   axes(ax1);
   axis([0 0.5 -max_atten 10]);
   plot(wo,20*log10([mag magr]));
   axis([0 0.5 -max_atten 10]);
   set(ax1,'xlabel',text(0,0,'Frekvencija , 1=Fs'));
   set(ax1,'ylabel',text(0,0,'Pojacanje / dB'));
   set(ax1,'title',text(0,0,'Amplitudno-frekv. karakteristika filtra prije zaokruzenja/zuto i poslije/ljub'));
   grid on;
   axes(ax2);
   plot(wo,[phase phaser]);
   set(ax2,'xlabel',text(0,0,'Frekvencija, 1=Fs'));
   set(ax2,'ylabel',text(0,0,'Amplituda'));
   set(ax2,'title',text(0,0,'Fazno-frekv. karakteristika filtra prije zaokruzenja/zuto i poslije/ljub'));
   grid on;
   set(ax1,'buttondownfcn','vj5(''crtaj44'')');
   
elseif strcmp(action,'crtaj44'),
   
   a=get(txt2,'userdata');
   wo=a(:,1);mag=a(:,2);phase=a(:,3);
   a=get(txt7,'userdata');
   magr=a(:,1);phaser=a(:,2);
   w1=str2num(get(grfr1,'string'));
   p1=min(find(wo>w1));
   w2=str2num(get(grfr2,'string'));
   p2=min(find(wo>w2));
   if isempty(p2), p2=max(size(wo)); end;
   if isempty(p1),p1=1;end;
   tipf=get(tipfilt,'value');
   poz=get(ax1,'currentpoint');poz=poz(1,1);
   if (tipf==1|tipf==2),
      if poz<w1,
         w=wo(1:p1);
         mag=mag(1:p1);ph=phase(1:p1);magr=magr(1:p1);phaser=phaser(1:p1);
      elseif poz>w1, 
         w=wo(p1:max(size(wo)));
         mag=mag(p1:max(size(mag)));ph=phase(p1:max(size(phase)));
         magr=magr(p1:max(size(magr)));phaser=phaser(p1:max(size(phaser)));
      end;
   elseif (tipf==3|tipf==4),
      if poz<w1, 
         w=wo(1:p1);
         mag=mag(1:p1);ph=phase(1:p1);magr=magr(1:p1);phaser=phaser(1:p1);
      elseif (poz>w1&poz<w2), 
         w=wo(p1:p2);
         mag=mag(p1:p2);ph=phase(p1:p2);magr=magr(p1:p2);phaser=phaser(p1:p2);
      elseif poz>w2,
         w=wo(p2:max(size(wo)));
         mag=mag(p2:max(size(mag)));ph=phase(p2:max(size(phase)));
         magr=magr(p2:max(size(magr)));phaser=phaser(p2:max(size(phaser)));              
      end;           
   end;
   axes(ax1);
   axis([0 0.5 -max_atten 10]);
   plot(w,20*log10([mag magr]));
   axis([0 0.5 -max_atten 10]);
   set(ax1,'xlabel',text(0,0,'Frekvencija (1=frekv. otipkavanja)'));
   set(ax1,'ylabel',text(0,0,'Atenuacija (dB)'));
   set(ax1,'title',text(0,0,'Amplitudno - frekvencijska karakteristika filtra'));
   grid on;
   axes(ax2);
   plot(w,[ph phaser]);
   set(ax2,'xlabel',text(0,0,'Frekvencija (1=frekv. otipkavanja)'));
   set(ax2,'ylabel',text(0,0,'Faza (dB)'));
   set(ax2,'title',text(0,0,'Fazno - frekvencijska karakteristika filtra'));
   grid on;
   set(ax1,'buttondownfcn','vj5(''crtaj4'')');

elseif strcmp(action,'crtaj5'),
   
   set(ax1,'buttondownfcn','vj5('''')');
   timepoints=64;
   set(ax3,'visible','off');
   delete(get(ax3,'children'));
   set([ax1 ax2],'visible','on');
   a=get(txt2,'userdata');
   num=get(txt5,'userdata');
   den=get(txt6,'userdata');
   coefbit=str2num(get(brbitk,'string'));
   mxc=2^(coefbit-1);
   inum=get(txt8,'userdata');
   iden=get(txt9,'userdata');
   iscale=get(txt10,'userdata');
   u=[1 0*ones(1,timepoints-1)];
   m=get(realizacija,'value');
   Y=filter(num,den,u);
   if m==1,
      Yr=filter(inum/mxc,iden/mxc,u);
      Yr=Yr*prod(iscale/mxc);
   elseif (m==2|m==3),
      tt=size(inum);
      brcas=tt(1);
      Yr=u;
      for cas=1:brcas,
         Yr=filter(inum(cas,:)/mxc,iden(cas,:)/mxc,Yr);
      end;
      Yr=Yr*prod(iscale/mxc);
   end;
   axes(ax1);
   plot([0:timepoints-1],[Y' Yr']);
   set(ax1,'xlabel',text(0,0,'Vremenska os'));
   set(ax1,'ylabel',text(0,0,'Amplituda'));
   set(ax1,'title',text(0,0,'Impulsni odziv s realnim/zuto i cjelobrojnim/ljub koeficijentima'));
   grid on;
   set(ax2,'visible','off');delete(get(ax2,'children'));
   
elseif strcmp(action,'napravi16'),
   
   m=get(realizacija,'value');
   sl=get(slike,'value');
   if m>3,
      kmenu('Morate odabrati nacin realizacije, ne moze biti opcija DIREKTNA + KASKADNA!!!','OK');
      break;
   end;
   set(brbitk,'string',brbit);
   num=get(txt5,'userdata');
   den=get(txt6,'userdata');
   tt=get(fsample,'value');
   ff=[  1   5.5125
      15   6.615
      0   8.0
      14   9.6
      3  11.025
      2  16.0
      5  18.9
      7  22.05
      4  27.42857
      6  32.0
      13  33.075
      9  37.8
      11  44.1
      12  48.0  ];
   
   f_sample=ff(tt,2);                   % Frekvencija sempliranja u kilohercima
   cfs2_0_csl=ff(tt,1);                 % Iznos tri kontrolna bita kodeka kojim
   % se odredjuje frekvencija sempliranja i
   % cetvrtog koji odredjuje kristal
   % Ovo vrijedi za kristale 24.576 MHz i
   % 16.9344 MHz
   
   if sl==4,x=0;elseif sl==5, x=0; elseif sl==6, x=1;end;
   h=gcf;
   if m==1,
      [magr,phaser,inum,iden,iin_scale,ss]=diredsp(num,den,brbit,f_sample,cfs2_0_csl,x);
      if ss==1,
         set(txt7,'userdata',[magr,phaser]);
         set(txt8,'userdata',inum);
         set(txt9,'userdata',iden);
         set(txt10,'userdata',iin_scale);
         if (sl==4 | sl==6),
            vj5('crtaj4');
            set(slike,'value',4);
         elseif sl==5,
            vj5('crtaj5');  
         end;

      else, axes(ax2); cla; axes(ax1); cla; break; end;
   elseif m==2|m==3, 
      if sl==4,x=0;elseif sl==5, x=0; elseif sl==6, x=1;end;
      h=gcf;
      if m==2,
         flip=1;
      elseif m==3,
         flip==2;
      end;
      p=get(txt3,'userdata');
      z=get(txt1,'userdata');
      k=get(txt11,'userdata');
      [magr,phaser,br,naz,in_scale,amp_tot,ss]=biqudsp(p,z,k,brbit,f_sample,cfs2_0_csl,x,h,flip);
      if ss==1,
         ibr=round(br*(2^(brbit-1)));
         inaz=round(naz*(2^(brbit-1)));
         set(txt7,'userdata',[magr,phaser]);
         set(txt8,'userdata',ibr);
         set(txt9,'userdata',inaz);
         set(txt10,'userdata',in_scale);
         if (sl==4 | sl==6),
            vj5('crtaj4');
            set(slike,'value',4);
         elseif sl==5,
            vj5('crtaj5');
         end;
         set(txt12,'userdata',br);
         set(txt16,'userdata',naz);
         set(txt14,'userdata',in_scale);
         set(txt15,'userdata',amp_tot);
      else, axes(ax2); cla; axes(ax1); cla;  break; end;
   end;
   
elseif strcmp(action,'obrada16'),
   
   m=get(realizacija,'value');
   if (m>3),
      kmenu('Morate odabrati nacin realizacije, odabrana opcija ne smije biti DIREKTNA + KASKADNA!!!','OK');
      break;
   end;
   tt=get(fsample,'value');
   ff=[  1   5.5125
      15   6.615
      0   8.0
      14   9.6
      3  11.025
      2  16.0
      5  18.9
      7  22.05
      4  27.42857
      6  32.0
      13  33.075
      9  37.8
      11  44.1
      12  48.0  ];
   
   f_sample=ff(tt,2); 
   if m==1,
      iin_scale=get(txt10,'userdata');
      iscalnaz=iin_scale(1,:);
      iout_amp=iin_scale(2,:);
      rout_amp=iout_amp/(2^(brbit-1));
      rscalnaz=iscalnaz/(2^(brbit-1));
      inum=get(txt8,'userdata');
      rnum=inum/(2^(brbit-1));
      iden=get(txt9,'userdata');
      rden=iden/(2^(brbit-1));

      % Novi kod za XP sa BAT file-om
      load '..\postavi'				% pozovi filu koja postavlja put i port

      delete bat_file.bat 
% Remove previous data input/output
      delete ul.mat
      delete iz.mat
      bat_name='bat_file.bat';
      fp=fopen(bat_name,'wt');

      fprintf(fp,'\ndel prvi.mat');
      fprintf(fp,'\ndel drugi.mat');

      fprintf(fp,'\n..\\ezimp %s prvi.mat D 1000 1FFF',port);
      fprintf(fp,'\nren prvi.mat ul.mat');

      fprintf(fp,'\n..\\ezimp %s drugi.mat P 1000 1FFF',port);
      fprintf(fp,'\nren drugi.mat iz.mat');
      fclose(fp);

      str=sprintf('!%s',bat_name);
      eval(str)

      fp=fopen('ul.mat','r');
      while ( fp==-1 ),		% cekaj da nastane fila
         fp=fopen('ul.mat','r');
      end
      fclose(fp);

      fp=fopen('iz.mat','r');
      while ( fp==-1 ),		% cekaj da nastane fila
         fp=fopen('iz.mat','r');
      end
      fclose(fp);

      if brbit==32,
         load iz
         save temp dat  % ????
         d1 = dat(1:2:4096);     % gornja rijec
         d2 = dat(2:2:4096);     % donja rijec
         d2(find(d2<0)) = d2(find(d2<0)) + 2;      % komplement
         dat = d1 + d2*(2^(-16));
         save iz dat
         clear dat;
      end;
      load ul;
      if brbit==16,ulaz=dat';elseif brbit==32,ulaz=dat(1:2:4095)';
      end;
      load iz
      izlaz=dat';
      clear dat;
      y=filter(rnum,rden,ulaz*rscalnaz*rout_amp);
      y=round(y*2^(brbit-1))*(2^(-(brbit-1)));
   else,
      br=get(txt12,'userdata');
      naz=get(txt16,'userdata');
      in_scale=get(txt14,'userdata');
      amp_tot=get(txt15,'userdata');

      % Novi kod za XP sa BAT file-om
      load '..\postavi'				% pozovi filu koja postavlja put i port

      delete bat_file.bat 
% Remove previous data input/output
      delete ul.mat
      delete iz.mat
      bat_name='bat_file.bat';
      fp=fopen(bat_name,'wt');

      fprintf(fp,'\ndel prvi.mat');
      fprintf(fp,'\ndel drugi.mat');

      fprintf(fp,'\n..\\ezimp %s prvi.mat D 1000 1FFF',port);
      fprintf(fp,'\nren prvi.mat ul.mat');

      fprintf(fp,'\n..\\ezimp %s drugi.mat P 1000 1FFF',port);
      fprintf(fp,'\nren drugi.mat iz.mat');
      fclose(fp);

      str=sprintf('!%s',bat_name);
      eval(str)

      fp=fopen('ul.mat','r');
      while ( fp==-1 ),		% cekaj da nastane fila
         fp=fopen('ul.mat','r');
      end
      fclose(fp);

      fp=fopen('iz.mat','r');
      while ( fp==-1 ),		% cekaj da nastane fila
         fp=fopen('iz.mat','r');
      end
      fclose(fp);

      if brbit==32,

         load iz
         save temp dat  % ????
         d1 = dat(1:2:4096);     % gornja rijec
         d2 = dat(2:2:4096);     % donja rijec
         d2(find(d2<0)) = d2(find(d2<0)) + 2;      % komplement
         dat = d1 + d2*(2^(-16));
         save iz dat
         clear dat;
      end;
      
      load ul
      if brbit==16,ulaz=dat';elseif brbit==32,ulaz=dat(1:2:max(size(dat)))';
      end;
      load iz
      izlaz=dat';
      clear dat;
      [m,n]=size(br);         % m ... broj kaskada
      y=ulaz;
      for i=1:m,                      % filtriranje po kaskadama
          x=y*in_scale(i);
          y=filter(br(i,:),naz(i,:),x);
      end;
      y=y*amp_tot;
      y=round(y*2^(brbit-1))*(2^(-(brbit-1)))';
   end;
   
   set([ax1 ax2],'visible','on');
   set(ax3,'visible','off');delete(get(ax3,'children'));
   axes(ax1);
   plot([ulaz izlaz y]);
   set(ax1,'title',text(0,0,'zuto=ULAZ, ljub=DSP, modro=MATLAB'));
   set(ax1,'xlabel',text(0,0,'Vrijeme (s)'));
   set(ax1,'ylabel',text(0,0,'Napon (V)'));
   grid on;
   axes(ax2);
   greska=(izlaz-y)*(2^(brbit-1));
   plot(greska);
   set(ax2,'title',text(0,0,sprintf('Greska kvantizacija stanja DSP-MATLAB (%2.0d  bita)',brbit)));
   set(ax2,'xlabel',text(0,0,'Uzorci'));
   set(ax2,'ylabel',text(0,0,'Greska (LSB)'));
   grid on;

end;
set(fleka,'visible','on');%
set(fleka,'visible','off');%fleka
