USEGRAPHIC 9
USECLASS CKNJ16
USEVAR MAXH,MAXW,CHRH,CHRW,CODE,CSR_X,CSR_Y,KU,AREAH,SEL_X,KANA
MAXW=SYSTEM(22)
MAXH=SYSTEM(23)
CHRW=16
CHRH=16
KU=$A4
CODE=(KU<<8)+$A1
AREAH=($FE-$A1+1)/(MAXW/CHRW-2)+1
X=0
Y=MAXH-1-CHRH*AREAH
SEL_X=0
CSR_X=0
CSR_Y=SYSTEM(21)-AREAH*2+1 
DIM KANA((($5A-$30+1)+($BF-$BA+1)+2+1)+1)

RESTORE KANA_T
FOR I=0 TO (($5A-$30+1)+($BF-$BA)+1)+2+1-1
  KANA(I)=READ()
NEXT

K=NEW(CKNJ16,"EUC-JP")

GOSUB PRTCHR,KU

COLOR 2
CURSOR CSR_X,CSR_Y
PRINT CHR$($82)+CHR$($82)
WHILE 1
  S=READKEY()
  IF S THEN
    A=(S >> 8) AND $FF
    CURSOR CSR_X,CSR_Y
    PRINT "  "

    IF (S AND $040000) != 0 THEN
      A=(S >> 8) AND $FF
      IF ((A >= $30) AND (A <= $5A)) THEN
        CODE=KANA(A-$30) 
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
        CSR_X=(((CODE AND $FF)-$A1) % (MAXW/CHRW-1))*2 
        CSR_Y=(((CODE AND $FF)-$A1) / (MAXW/CHRW-1))*2+SYSTEM(21)-AREAH*2+1
      ELSEIF ((A >= $BA) AND (A <= $BF)) THEN
        CODE=KANA(A-$BA+($5A-$30+1)) 
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
        CSR_X=(((CODE AND $FF)-$A1) % (MAXW/CHRW-1))*2 
        CSR_Y=(((CODE AND $FF)-$A1) / (MAXW/CHRW-1))*2+SYSTEM(21)-AREAH*2+1
      ELSEIF ((A >= $DD) AND (A <= $DE)) THEN
        CODE=KANA(A-$DD+($5A-$30+1)+($BF-$BA+1)) 
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
        CSR_X=(((CODE AND $FF)-$A1) % (MAXW/CHRW-1))*2 
        CSR_Y=(((CODE AND $FF)-$A1) / (MAXW/CHRW-1))*2+SYSTEM(21)-AREAH*2+1
      ELSEIF A = $E2 THEN
        CODE=KANA(($5A-$30+1)+($BF-$BA+1)+2) 
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
        CSR_X=(((CODE AND $FF)-$A1) % (MAXW/CHRW-1))*2 
        CSR_Y=(((CODE AND $FF)-$A1) / (MAXW/CHRW-1))*2+SYSTEM(21)-AREAH*2+1
      ENDIF
    ELSE
      IF ((A>=$70) AND (A<=$77)) THEN
        CODE=$A1A1+(A-$70)*$100
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
      ELSEIF A=$78 THEN
        CODE=$B0A1
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
      ELSEIF A=$79 THEN
        CODE=$D0A1
        KU=(CODE >> 8) AND $FF
        GOSUB PRTCHR,KU
      ELSEIF A=$26 THEN
        CSR_Y=CSR_Y-2
      ELSEIF A=$28 THEN
        CSR_Y=CSR_Y+2
      ELSEIF A=$25 THEN
        CSR_X=CSR_X-2
      ELSEIF A=$27 THEN
        CSR_X=CSR_X+2
      ELSEIF A=$08 THEN
        SEL_X=SEL_X-CHRW
        IF SEL_X < 0 THEN SEL_X=0
        BOXFILL SEL_X,0,SEL_X+CHRW-1,CHRH-1,0
      ELSEIF A=$0D THEN
        POINT SEL_X,0
        C$=CHR$(KU)+CHR$($A1+((MAXW/CHRW)-1)*(CSR_Y-(SYSTEM(21)-AREAH*2)-1)/2+CSR_X/2)+CHR$($00)
        K.GPRT(C$,7,0)
        SEL_X=SEL_X+CHRW
      ENDIF
    ENDIF

    IF CSR_X < 0 THEN
      CSR_X=SYSTEM(20)-4
    ELSEIF CSR_X >= SYSTEM(20)-2 THEN
      CSR_X=0
    ELSEIF CSR_Y < SYSTEM(21)-AREAH*2+1 THEN
      CODE=CODE-$100
      KU=(CODE >> 8) AND $FF
      IF CODE < $A1A1 THEN
        CODE=$A1A1
        KU=(CODE >> 8) AND $FF
        CSR_Y=SYSTEM(21)-AREAH*2+1
      ELSE
        IF CODE < $A9A1 THEN
        ELSEIF CODE < $B0A1 THEN
          CODE=$A8A1
          KU=(CODE >> 8) AND $FF
        ELSEIF CODE < $F5A1 THEN
        ELSEIF CODE < $F9A1 THEN
          CODE=$A4A1
          KU=(CODE >> 8) AND $FF
        ELSE
        ENDIF
        GOSUB PRTCHR,KU
        CSR_Y=SYSTEM(21)-1
      ENDIF
    ELSEIF CSR_Y > SYSTEM(21)-1 THEN
      CODE=CODE+$100
      KU=(CODE >> 8) AND $FF
      IF CODE > $FEA1 THEN
        CODE=$FEA1
        KU=(CODE >> 8) AND $FF
        CSR_Y=SYSTEM(21)-1
      ELSE
        IF CODE < $A9A1 THEN
        ELSEIF CODE < $B0A1 THEN
          CODE=$B0A1
          KU=(CODE >> 8) AND $FF
        ELSEIF CODE < $F5A1 THEN
        ELSEIF CODE < $F9A1 THEN
          CODE=$F9A1
          KU=(CODE >> 8) AND $FF
        ELSE
        ENDIF
        GOSUB PRTCHR,KU
         CSR_Y=SYSTEM(21)-AREAH*2+1
      ENDIF
    ENDIF

    COLOR 2
    CURSOR CSR_X,CSR_Y
    PRINT CHR$($82)+CHR$($82)
  ENDIF
WEND

LABEL PRTCHR
VAR A,S
S=ARGS(1)
BOXFILL 0,MAXH-1-CHRH*AREAH,MAXW-1,MAXH-1,0
X=0
REM Y=MAXH-1-CHRH*(($FE-$A1+1)/(MAXW/CHRW-2))
Y=MAXH-1-CHRH*AREAH
A=$A1
DO WHILE A < $FE
  FOR I=0 TO MAXW/CHRW-2
    POINT X+CHRW*I,Y
    C$=CHR$(S)+CHR$(A)+CHR$($00)
    K.GPRT(C$,7,0)
    A=A+1
  NEXT
  X=0
  Y=Y+CHRH 
LOOP
WHILE READKEY()!=0:WEND
RETURN

LABEL KANA_T
DATA $CFC1,$C7AD,$CAA1,$B0A1,$B1A6,$B1C1,$B2A1,$CDA1,$CDA1,$CDBD,
     $A1A1,$A1A1,$A1A1,$A1A1,$A1A1,$A1A1,$A1A1,
     $C4A1,$B8C3,$C0A4,$BCC5,$B1A1,$C7C5,$B5A1,
     $B7A1,$C7A1,$CCA1,$C7B5,$CEA1,$CDA1,$CCA3,
     $CEA1,$C0A4,$C2BE,$C0A3,$C5A1,$B2BC,$C7A1,
     $C9A1,$C5A1,$BAB3,$D0A1,$C4C5,
     $B7B5,$CFA1,$C7AD,$CBA1,$CFA1,$CCBD,
     $CCB5,$CABA,
     $CFA4

