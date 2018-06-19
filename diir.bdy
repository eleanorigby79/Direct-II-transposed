.VAR/PM/RAM/CIRC         COEFS[N*(2+4+1+6)+3]; { n*(pn a2 a1 a0 b0 b1 b2) Aizl }
.VAR/DM/RAM/CIRC         DELAY[4*N];

.var/dm/ram              sampl_rate;
.global                  sampl_rate;

.INIT                    COEFS : < DIIR.CFS >;
.init                    sampl_rate : FS_CFS;

.entry    ZAGLAVLJE;
.entry    OBRADA;

ZAGLAVLJE:
         I2=^DELAY;
         L2=%DELAY;
         M1=1;

         I4=^COEFS;
         L4=%COEFS;
         M4=1;

         M0=-1;
         M2=0;
         M3=4;

         MX0=0;
         CNTR=2*N;

         DO INITD UNTIL CE;
         DM(I2,M1)=MX0;
INITD:   DM(I2,M1)=MX0;
         rts;

OBRADA:  MR=0          ,MY1=PM(I4,M4);
         SR1=mx1;
         MF=MR(RND)    ,SR0=MR0;
         MY0=PM(I4,M4);
         AY0=0;
         AY1=SR1;
         AX0=0;
         
         CNTR=N;
         DO ENDBIQ UNTIL CE;

         MR=MR-SR0*MY1(US),MX1=DM(I2,M1);
         MR=MR-SR1*MY0(SU),MX0=DM(I2,M1);
         MR0=MR1;
         MR1=MR2;
         MR=MR-SR1*MY1(SS),MY1=PM(I4,M4);
         AR=MR0+AY0;
         AY0=AR           ,AR=MR1+AY1+C;
         AF=MR2+C         ,AY1=AR;
         AR=AX0+AF        ,MY0=PM(I4,M4);
         MR=0             ,AX0=AR;

A2Z2:    MR=MR-MX0*MY1(US);
         MR=MR-MX1*MY0(SU);
         MR0=MR1;
         MR1=MR2;
         MR=MR-MX1*MY1(SS),MY1=PM(I4,M4),MX1=DM(I2,M1);
         AR=MR0+AY0       ,MY0=PM(I4,M4),MX0=DM(I2,M2);
         AY0=AR           ,AR=MR1+AY1+C;
         AF=MR2+C         ,AY1=AR;
         AR=AX0+AF;
         MR=0             ,AX0=AR;

A1Z1:    MR=MR-MX0*MY1(US);
         MR=MR-MX1*MY0(SU);
         MR0=MR1;
         MR1=MR2;
         MR=MR-MX1*MY1(SS),MY1=PM(I4,M4);
         AR=MR0+AY0;
         AY0=AR           ,AR=MR1+AY1+C;
         AF=MR2+C         ,AY1=AR;
         AR=AX0+AF        ,SR0=AY0;
         MR=0             ,AX0=AR;

AO:      MR=MR-SR0*MY1(US),SR1=AY1;
         MR0=MR1;
         MR1=MR2;
         MR=MR-SR1*MY1(SS);
         AR=MR0+AY0       ,MY1=PM(I4,M4);
         MR0=AR           ,AR=MR1+AY1+C;
         AF=MR2+C         ,MR1=AR;
         AR=AX0+AF        ,MY0=PM(I4,M4);
         MR2=AR;
{         MR=MR+MX0*MF(SS);
         IF MV SAT MR;
}
         SR1=MR1;
         SR0=MR0;

BOS:     MR=SR0*MY1(US);
         MR=MR+SR1*MY0(SU);
         MR0=MR1;
         MR1=MR2;
         MR=MR+SR1*MY1(SS),MY1=PM(I4,M4);
         AY0=MR0;
         AY1=MR1;
         AX0=MR2;

B1Z1:    MR=MX0*MY1(US)   ,MY0=PM(I4,M4);
         MR=MR+MX1*MY0(SU),DM(I2,M0)=SR0;
         MR0=MR1;
         MR1=MR2;
         SR0=MX0;
         DM(I2,M0)=SR1;
         MR=MR+MX1*MY1(SS),MY1=PM(I4,M4);
         AR=MR0+AY0       ,MY0=PM(I4,M4);
         AY0=AR           ,AR=MR1+AY1+C;
         AY1=AR           ,AF=MR2+C;
         AR=AX0+AF        ,MX0=DM(I2,M2);
         AX0=AR;           
         SR1=MX1;
         DM(I2,M0)=SR0;

B2Z2:    MR=MX0*MY1(US)   ,MX1=DM(I2,M2);
         MR=MR+MX1*MY0(SU),DM(I2,M3)=SR1;
         MR0=MR1;
         MR1=MR2;
         MR=MR+MX1*MY1(SS),MY1=PM(I4,M4);
         AR=MR0+AY0       ,MY0=PM(I4,M4);
         MR0=AR           ,AR=MR1+AY1+C;
         AF=MR2+C         ,MR1=AR;
         AR=AX0+AF;
         MR2=AR;
 {        MR=MR+MX0*MF(SS);  SAMO DA SE POSTAVE ZASTAVICE MONZI SE S NULA }
{         IF MV SAT MR;
 }
         SR0=MR0;
         SR1=MR1;
         AY0=MR0;
         AY1=MR1;
         AX0=MR2;
ENDBIQ:  MR=0;

         MR=SR1*MY0(SU);
         MR=MR+SR0*MY1(US);
         MR0=MR1;
         MR1=MR2;
         MR=MR+SR1*MY1(SS);

         AX0=PM(I4,M4);
         SE=EXP MR1(HI);
         AY0=SE;
         AR=AX0+AY0;
         IF GT JUMP OVERFLOW;
         SE=AX0;
         SR=ASHIFT MR1(HI);
         SR=SR OR LSHIFT MR0(LO);
         MR0=SR0;
         MR1=SR1;
         MR=MR+MX0*MF(SS);
         JUMP OUT_PORT;

OVERFLOW:AR=PASS MR1;
         IF LT JUMP NEGATIV;
         MR1=0X7FFF;
         MR0=0XFFFF;
         JUMP OUT_PORT;

NEGATIV: MR1=0X8000;
         MR0=0X0000;

OUT_PORT:                             { MR se vraca }
          rts;
.ENDMOD;
