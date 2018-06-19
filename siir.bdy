.VAR/PM/RAM/CIRC         COEFS[7*N+2];   { N*(PN A2 A1 A0 B0 B1 B2) + Aizl }
.VAR/DM/RAM/CIRC         DELAY[2*N];

.var/dm/ram              sampl_rate;
.global                  sampl_rate;

.entry ZAGLAVLJE;
.entry OBRADA;

.INIT                    COEFS : <SIIR.CFS>;
.init                    sampl_rate : FS_CFS;

ZAGLAVLJE:   
         I4=^COEFS;
         I3=^DELAY;

         L4=%COEFS;
         L3=%DELAY;

         M0=0;
         M1=1;           { mora biti 1 }
         M2=-1;
         M3=2;
         M4=1;

         CNTR=2*N;

         DO CLRBUF UNTIL CE;
CLRBUF:  DM(I3,M1)=0;
         RTS;

OBRADA:  CNTR=N;

         MR=0;            { ulaz je mx1 registar }
         MR1=MX1; 
         MY0=PM(I4,M4);                                        { PN      }
         DO BIQUAD UNTIL CE;
         MR=MR-MR1*MY0(SS),MY1=PM(I4,M4),MX1=DM(I3,M1);        { A2 , Z2 }
         MR=MR-MX1*MY1(SS),MY0=PM(I4,M4),MX0=DM(I3,M0);        { A1 , Z1 }
         MR=MR-MX0*MY0(SS),MY1=PM(I4,M4);                      { A0 ,    }
         MR=MR-MR1*MY1(SS),MY0=PM(I4,M4);                      { B0 ,    }
         MR=MR(RND)       ,MY1=PM(I4,M4);                      { B1 ,    }
         IF MV SAT MR;
         DM(I3,M2)=MR1,MR=MR1*MY0(SS);                         { MR -> Z1 }
         MR=MR+MX0*MY1(SS),MY1=PM(I4,M4);                      { B2       }
         MR=MR+MX1*MY1(RND),DM(I3,M3)=MX0;                     { Z1 -> Z2 }
         MY0=PM(I4,M4);                                        { PN + 1   }
BIQUAD:  IF MV SAT MR;

         MR=MR1*MY0(RND),AY0=PM(I4,M4);                         { IZLAZNO POJACALO }
         SE=EXP MR1(HI);
         AX0=SE;
         AR=AX0+AY0;
         IF GT JUMP OVERFLOW;
         SE=AY0;
         SR=ASHIFT MR1 (HI);
         MR1=SR1;
         MR=MR(RND);
         JUMP OUT_PORT;

OVERFLOW:AR=PASS MR1;
         IF LT JUMP NEGATIV;
         MR1=0X7FFF;
         JUMP OUT_PORT;
NEGATIV: MR1=0X8000;

OUT_PORT: RTS;     { izlaz je mr(1) registar}

.ENDMOD;
