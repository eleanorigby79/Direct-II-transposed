% funkcija za ogranicavanje dinamike na +/-1
%     br - broj koji se limitira
%     brbit - broj bita kojim se raspolaze
%     val - vrijednost koja se vraca u glavni program
%
function [ val ]=limit( br , brbit);
     base=2^(brbit-1);
     max=(2^(brbit-1)-1)/base;
     min=-(2^(brbit-1))/base;
     val=br;
     if(br>max),
       val=max;
     end;
     if(br<min),
       val=min;
     end;
end;
