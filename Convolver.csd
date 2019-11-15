<Cabbage>
form caption("Untitled") size(400, 300), colour(58, 110, 182), pluginid("def1")
rslider bounds(296, 162, 100, 100), channel("gain"), range(0, 1, 0, 1, .01), text("Gain"), trackercolour("lime"), outlinecolour(0, 0, 0, 50), textcolour("black")
rslider bounds(10, 162, 100, 100), channel("gain"), range(0, 1, 0, 1, .01), text("Skip"), trackercolour("lime"), outlinecolour(0, 0, 0, 50), textcolour("black"), channel("skipsamples"), range(0, 1.00, 0)




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


instr 1

kskipsamples	chnget	"skipsamples"
kGain chnget "gain"


; ***************INPUT SECTION***********************************************	
;a1 inch 1
;a2 inch 2
	a1, a2 diskin2	"stereoBass.wav",1,0,1	;USE A LOOPED STEREO SOUND FILE FOR TESTING
	ainMix	sum	a1,a2
;***************************************************************************

gSfilepath = "miraj_trim.wav"

	giImpulse	ftgen	1,0,0,1,gSfilepath,0,0,0	; load stereo file

iplen = 1024				;BUFFER LENGTH (INCREASE IF EXPERIENCING PERFORMANCE PROBLEMS, REDUCE IN ORDER TO REDUCE LATENCY)
itab = giImpulse			;DERIVE FUNCTION TABLE NUMBER OF CHOSEN TABLE FOR IMPULSE FILE
iirlen	= nsamp(itab)*0.5			;DERIVE THE LENGTH OF THE IMPULSE RESPONSE IN SAMPLES. DIVIDE BY 2 AS TABLE IS STEREO.
iskipsamples = nsamp(itab)*0.5*i(kskipsamples)	;DERIVE INSKIP INTO IMPULSE FILE. DIVIDE BY 2 (MULTIPLY BY 0.5) AS ALL IMPULSE FILES ARE STEREO
	
a1,a2	ftconv	ainMix, itab, iplen,iskipsamples, iirlen		;CONVOLUTE INPUT SOUND
	 ;adelL	delay	a1, abs((iplen/sr)+i(kDelayOS)) 	;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE
	 ;adelR	delay	a2, abs((iplen/sr)+i(kDelayOS)) 	;DELAY THE INPUT SOUND ACCORDING TO THE BUFFER SIZE

outs a1*kGain, a2*kGain

endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 [60*60*24*7] 
</CsScore>
</CsoundSynthesizer>
