.VAR/PM/RAM/CIRC         COEFS[2+2*N+1+2*(N+1)+3];
.VAR/DM/RAM/CIRC         DELAY[2*(N+1)];

.entry  ZAGLAVLJE;
.entry  OBRADA;

.var/dm/ram sampl_rate;
.global     sampl_rate;

.INIT                    COEFS : <DDIR.CFS>;
.init               sampl_rate : FS_CFS ;

ZAGLAVLJE:
         I3=^DELAY;
         I4=^COEFS;

         L3=%DELAY;
         L4=%COEFS;

         M3=1;
         M0=0;  
         M2=2;
         
         M4=2;
         M5=-(2*N-1);
         M6=-(2*N+1);
         M7=1;

         CNTR=%DELAY;
         MX0=0;
         DO CLRDEL UNTIL CE;
CLRDEL:  DM(I3,M3)=MX0;

         RTS;

OBRADA:  
         DM(I3,M3)=MX1;
         MX0=0;
         DM(I3,M0)=MX0;  { !!! }

         MR=0,MX0=DM(I3,M2),MY0=PM(I4,M4);
         MR=MR+MX0*MY0(US),MX0=DM(I3,M2),MY0=PM(I4,M4);

         CNTR=N-2;
         DO NA_LOHI UNTIL CE;
NA_LOHI: MR=MR-MX0*MY0(US),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR-MX0*MY0(US),MX0=DM(I3,M3),MY0=PM(I4,M5);

         MR=MR-MX0*MY0(US),MX0=DM(I3,M2),MY0=PM(I4,M4);

         { POCETAK DRUGOG KRUGA  PUL*XUL }

         MR=MR+MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M4);

         CNTR=N-2;
         DO NA_HILO UNTIL CE;
NA_HILO: MR=MR-MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR-MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M6);

         MR=MR-MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR(RND);
         MR0=MR1;
         MR1=MR2;

         {POCETAK TRECEG KRUGA}

         MR=MR+MX0*MY0(SS),MX0=DM(I3,M2),MY0=PM(I4,M4);

         CNTR=N-1;
         DO NA_HIHI UNTIL CE;
NA_HIHI: MR=MR-MX0*MY0(SS),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR-MX0*MY0(SS),AX0=PM(I4,M7); {PROCITA A0 I POZICIONIRA SE NA B0HI}

         IF MV JUMP NA_OVER;

         SE=EXP MR1(HI);
         AY0=SE;
         AR=AX0+AY0;
         IF LE JUMP NA_NORM;
         AR=PASS MR1;
         IF GE JUMP NA_POZ;
         MR0=0X0000;
         MR1=0X8000;
         JUMP BROJNIK;

NA_POZ:  MR0=0XFFFF;
         MR1=0X7FFF;
         JUMP BROJNIK;

NA_OVER: IF MV SAT MR;
         JUMP BROJNIK;

NA_NORM: SE=AX0;
         SR=ASHIFT MR1(HI);
         SR=SR OR LSHIFT MR0(LO);
         MR0=SR0;
         MR1=SR1;

BROJNIK: DM(I3,M3)=MR1;
         DM(I3,M0)=MR0;

         MR=0,MX0=DM(I3,M2),MY0=PM(I4,M4);
         MR=MR+MX0*MY0(US),MX0=DM(I3,M2),MY0=PM(I4,M4);

         CNTR=N-2;
         DO BR_LOHI UNTIL CE;
BR_LOHI: MR=MR+MX0*MY0(US),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR+MX0*MY0(US),MX0=DM(I3,M3),MY0=PM(I4,M5);

         MR=MR+MX0*MY0(US),MX0=DM(I3,M2),MY0=PM(I4,M4);

         { POCETAK DRUGOG KRUGA  B0*1/A0 }

         MR=MR+MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M4);

         CNTR=N-2;
         DO BR_HILO UNTIL CE;
BR_HILO: MR=MR+MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR+MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M6);

         MR=MR+MX0*MY0(SU),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR(RND);
         MR0=MR1;
         MR1=MR2;

         {POCETAK TRECEG KRUGA}

         MR=MR+MX0*MY0(SS),MX0=DM(I3,M2),MY0=PM(I4,M4);

         CNTR=N-1;
         DO BR_HIHI UNTIL CE;
BR_HIHI: MR=MR+MX0*MY0(SS),MX0=DM(I3,M2),MY0=PM(I4,M4);

         MR=MR+MX0*MY0(SS),MY1=PM(I4,M7);
                           MY0=PM(I4,M7);
                           AX0=PM(I4,M7);

         IF MV JUMP BR_OVER;

         SR0=MR0;
         SR1=MR1;

         MR=SR1*MY0(SU);
         MR=MR+SR0*MY1(US);
         MR0=MR1;
         MR1=MR2;
         MR=MR+SR1*MY1(SS);

         SE=EXP MR1(HI);
         AY0=SE;
         AR=AX0+AY0;
         IF LE JUMP BR_NORM;
         AR=PASS MR1;
         IF GE JUMP BR_POZ;
         MR0=0X0000;
         MR1=0X8000;
         JUMP IZLAZ;

BR_POZ:  MR0=0XFFFF;
         MR1=0X7FFF;
         JUMP IZLAZ;

BR_OVER: IF MV SAT MR;
         JUMP IZLAZ;

BR_NORM: SE=AX0;
         SR=ASHIFT MR1(HI);
         SR=SR OR LSHIFT MR0(LO);
         MR0=SR0;
         MR1=SR1;

IZLAZ:   MODIFY(I3,M2);
         RTS;
.ENDMOD;
