% funkcija za pretvaranje decimalnih u hexa brojeve
% function [hex]=hexa( p ,l )
%
%     p - broj koji se pretvara
%     l - duzina hexa broja ( 1 - 16 bit )
%                           ( 2-  32 bit )
%
function [ st ]=hexa( p,l );
      st='';
      s(1)='0';
      s(2)='1';
      s(3)='2';
      s(4)='3';
      s(5)='4';
      s(6)='5';
      s(7)='6';
      s(8)='7';
      s(9)='8';
      s(10)='9';
      s(11)='A';
      s(12)='B';
      s(13)='C';
      s(14)='D';
      s(15)='E';
      s(16)='F';

      p=round(p);

      if (p>=0),
        for i=0:(4*l-1),
          st=[s(rem(p,16)+1) st];
          p=floor(p/16);
        end;
      else
        for i=0:(4*l-1),
          p=p/16;
          ost=16*(p-floor(p));

          if (p~=0),
            if (ost<0),
              st=[ s((ost+15)+1) st ];
            else
              st=[ s(ost+1) st ];
            end;
          else
            st=[ s(15+1) st ];
          end;
          p=floor(p);
        end;
      end;
end;
