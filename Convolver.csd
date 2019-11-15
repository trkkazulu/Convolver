; Convolver (working title)
; Written by Jair-Rohm Parker Wells 2019
; A convlution based effect

<Cabbage>
form caption("Convolver") size(400, 300), colour(58, 110, 182), pluginid("def1")
rslider bounds(296, 162, 100, 100), channel("gain"), range(0, 1, 0, 1, .01), text("Gain"), trackercolour("lime"), outlinecolour(0, 0, 0, 50), textcolour("black")
rslider bounds(10, 162, 100, 100), channel("skipsamples"), range(0, 1, 0, 1, .01), text("Skip"), trackercolour("lime"), outlinecolour(0, 0, 0, 50), textcolour("black"), range(0, 1.00, 0)
rslider bounds(150, 50, 100, 100), channel("mix"), range(0, 1, 0, 1, .01), text("Mix"), trackercolour("lime"), outlinecolour(0, 0, 0, 50), textcolour("black") range(0, 1.00, 0.25)




</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -d -+rtmidi=NULL -M0 -m0d 
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
ksmps = 32
nchnls = 2
0dbfs = 1

giImpulse	ftgen	1,0,2,-2,0

; compress function table UDO
opcode	tab_compress,i,iii
ifn,iCompRat,iCurve    xin
iTabLen         =               ftlen(ifn)
iTabLenComp     =               int(ftlen(ifn)*iCompRat)
iTableComp      ftgen           ifn+200,0,-iTabLenComp,-2, 0
iAmpScaleTab	ftgen		ifn+300,0,-iTabLenComp,-16, 1,iTabLenComp,iCurve,0
icount          =               0
loop:
ival            table           icount, ifn
iAmpScale   	table		icount, iAmpScaleTab
                tableiw         ival*iAmpScale,icount,iTableComp
                loop_lt         icount,1,iTabLenComp,loop
                xout   	        iTableComp
endop



instr 1

kskipsamples	chnget	"skipsamples"
kmix	chnget	"mix"
kGain chnget "gain"
	kCompRat       init	1 
	kCurve init 0

; ***************INPUT SECTION***********************************************	
ainL inch 1
ainR inch 2
;	ainL, ainR diskin2	"stereoBass.wav",1,0,1	;USE A LOOPED STEREO SOUND FILE FOR TESTING
	ainMix	sum	ainL,ainR
;***************************************************************************

gSfilepath = "miraj_trim.wav"

aasig,aasig2 diskin2 "miraj_trim.wav" , 1, 0, 1

aComp compress aasig, aasig2, -12, 48, 60, 4, 0.2, 0.3, .05

giImpulse	ftgen	1,0,0,1,gSfilepath,0,0,0	; load stereo file into fTable

iplen = 2048				;BUFFER LENGTH (INCREASE IF EXPERIENCING PERFORMANCE PROBLEMS, REDUCE IN ORDER TO REDUCE LATENCY)
itab = giImpulse			;DERIVE FUNCTION TABLE NUMBER OF CHOSEN TABLE FOR IMPULSE FILE
iirlen	= nsamp(itab)*0.5			;DERIVE THE LENGTH OF THE IMPULSE RESPONSE IN SAMPLES. DIVIDE BY 2 AS TABLE IS STEREO.
iskipsamples = nsamp(itab)*0.5*i(kskipsamples)	;DERIVE INSKIP INTO IMPULSE FILE. DIVIDE BY 2 (MULTIPLY BY 0.5) AS ALL IMPULSE FILES ARE STEREO


	;;CREATE COMPRESSED TABLES
			icomp	tab_compress	giImpulse,i(kCompRat),i(kCurve)
	
aL,aR	ftconv	ainMix, icomp, iplen,iskipsamples, iirlen		;CONVOLUTE INPUT SOUND
	 adelL	delay	ainL, 0.2 ;abs((iplen/sr)+i(kDelayOS)) 	;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
	 adelR	delay	ainR, 0.2 ;abs((iplen/sr)+i(kDelayOS)) 	;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
	
;	 CREATE A DRY/WET MIX
	aMixL	ntrpol	adelL,aL*0.1,kmix
	aMixR	ntrpol	adelR,aR*0.1,kmix

outs aMixL*kGain, aMixR*kGain

endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 [60*60*24*7] 
</CsScore>
</CsoundSynthesizer>
