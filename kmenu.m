function k=kmenu(s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,...
                 s18,s19,s20,s21,s22,s23,s24,s25);

 


              kids=get(0,'children');
              if ~isempty(kids),
                 otherfigure=gcf;
              end;
              
brizb=nargin-1;
visina=0.1;
duljina=0.2;
visinaslike=0.05*(2+brizb)+0.02+0.01*brizb;
duljinaslike=0.4;
meni=figure('name','UPOZORENJE',...
            'NumberTitle','off',...
            'Units','normal',...
            'menubar','none',...
            'color','r',...
            'Position',[0.5 0.5 duljinaslike visinaslike]);
visinabuttna=1/(brizb+2);
tekst=s0;         
naslov=uicontrol('style','text',...
                 'string',tekst,...
                 'units','normal',...
                 'position',[0.05 (visinabuttna*brizb+0.02) 0.9 (1.7*visinabuttna-0.02)],...
                 'backgroundcolor','r');

              p=1;
global k;

k=1;
              
for n=brizb:-1:1,
%   bn=['b' int2str(n)];
   bn(n)=uicontrol('style','push',...
                'string',eval(['s' int2str(n)]),...
                'units','normal',...      
                'position',[0.05 (0.01+(n-1)*visinabuttna) 0.9 (visinabuttna-0.01)]);
             
%             set(bn,'call',['global k, k=',int2str(p),';']);
            
             
   p=p+1;
end;


waitforbuttonpress;

delete(meni);
if ~isempty(kids),
   set(0,'currentfigure',otherfigure);
end;
end;


          