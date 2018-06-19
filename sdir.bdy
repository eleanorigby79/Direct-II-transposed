.VAR/PM/RAM/CIRC         COEFS[1+2*(N+1)+2];
.VAR/DM/RAM/CIRC         DELAY[N];

.VAR/DM/RAM             sampl_rate;
.GLOBAL                 sampl_rate;

.ENTRY ZAGLAVLJE;
.ENTRY OBRADA;

.INIT                    COEFS : <SDIR.CFS>;
.INIT               sampl_rate : FS_CFS;

ZAGLAVLJE:   
         I2=^DELAY;
         I4=^COEFS;

         L2=%DELAY;
         L4=%COEFS;

         M2=1;
         M3=0;

         M4=1;

         MX0=0;
         CNTR=%DELAY;
         DO CLRBUF UNTIL CE;
CLRBUF:  DM(I2,M2)=MX0;

         RTS;

OBRADA:  
         MX0 = MX1;
         MY0=PM(I4,M4);
         MR=MX0*MY0(SS),MX0=DM(I2,M2),MY0=PM(I4,M4);

         CNTR=N-1;
         DO NA_LOOP UNTIL CE;
NA_LOOP: MR=MR-MX0*MY0(SS),MX0=DM(I2,M2),MY0=PM(I4,M4);

         MR=MR-MX0*MY0(SS),AX0=PM(I4,M4);
         IF MV JUMP NA_SAT;

         SE=EXP MR1(HI),MX0=DM(I2,M3);
         AY0=SE;
         AR=AX0+AY0    ,MY0=PM(I4,M4);
         IF LE JUMP NA_NORM;
         AR=PASS MR1;
         IF GE JUMP NA_POZ;
         MR1=0X8000;
         JUMP BROJNIK;

NA_POZ:  MR1=0X7FFF;
         JUMP BROJNIK;

NA_SAT:  MX0=DM(I2,M3),MY0=PM(I4,M4);
         IF MV SAT MR;
         JUMP BROJNIK;

NA_NORM: SE=AX0;
         SR=ASHIFT MR1(HI);
         SR=SR OR LSHIFT MR0(LO);
         MR0=SR0;
         MR1=SR1;
         MR=MR(RND);

BROJNIK: DM(I2,M2)=MR1,MR=MR1*MY0(SS);
         MY0=PM(I4,M4);

         CNTR=N;
         DO BR_LOOP UNTIL CE;
BR_LOOP: MR=MR+MX0*MY0(SS),MX0=DM(I2,M2),MY0=PM(I4,M4);

         IF MV JUMP BR_SAT;

         MX0=MR0;
         MX1=MR1,MR=MX0*MY0(US);

         MR0=MR1;
         MR1=MR2;

         MR=MR+MX1*MY0(SS),AX0=PM(I4,M4);

         SE=EXP MR1(HI);
         AY0=SE;
         AR=AX0+AY0;       
         IF LE JUMP BR_NORM;
         AR=PASS MR1;
         IF GE JUMP BR_POZ;
         MR1=0X8000;
         JUMP IZLAZ;

BR_POZ:  MR1=0X7FFF;
         JUMP IZLAZ;

BR_SAT:  AX0=PM(I4,M4);
         IF MV SAT MR;
         JUMP IZLAZ;

BR_NORM: SE=AX0;           
         SR=ASHIFT MR1(HI);
         SR=SR OR LSHIFT MR0(LO);
         MR0=SR0;
         MR1=SR1;
         MR=MR(RND);

IZLAZ:   MX1=MR1;
         RTS;

.ENDMOD;
