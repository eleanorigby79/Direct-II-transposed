function [ mant, ex ]=expon( x );
     xa=abs(x);
     ex=ceil(log(xa)/log(2));
     mant=x/2^ex;
end;
