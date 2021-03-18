! inicijalizacija simulacije
dc x.1, x.9996
dc x.0, x.9998
onkp false, x.1, x.1
onkp false, x.1, x.1
onkp true, x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
ondma x.1, x.1
kpreg 1.1, r0, x.1
kpreg 1.1, r1, x.2
kpreg 1.1, r2, x.3
kpreg 1.1, r3, x.4
kpreg 1.1, r4, x.5
kpreg 1.1, r5, x.6
kpreg 1.1, r6, x.7
kpreg 1.1, r7, x.8
kpreg 2.1, r0, x.9
kpreg 2.1, r1, x.a
kpreg 2.1, r2, x.b
kpreg 2.1, r3, x.c
kpreg 2.1, r4, x.d
kpreg 2.1, r5, x.e
kpreg 2.1, r6, x.f
kpreg 2.1, r7, x.10
reg pc, x.4000
reg ivtp, x.4000
reg sp, x.9000
! kraj inicijalizacije

! Glavni program--------------------------------------
org x.4000
intd

ldimm x.300, r1
mvrir r1, ivtp	! INICIJALIZACIJA IVTP

ldimm x.2000, r1
stmem x.300, r1	! IVTP[0]


ldimm x.1500, r1
stmem x.301, r1	! IVTP[1]


ldimm x.2500, r1
stmem x.302, r1	! IVTP[2]


ldimm x.500, r1
stmem x.303, r1	! IVTP[3]


ldimm x.1000, r1
stmem x.304, r1	! IVTP[4]


ldimm x.3000, r1
stmem x.305, r1	! IVTP[5]

inte

! Prejebi stek
push r1
push r2
push r3
push r4
push ra
push r5
push r6
push r7
push r8
push rb


! Pokretanje KP1.1-------
ldimm x.3, r1
stmem x.f102, r1
ldimm x.5000, r2	! lokacija elementa niza A
ldimm x.9, r3	! broj elemenata niza + 1 za ucitavanje
ldimm x.f, r4	! vrednost za startovanje KP1.1
clr ra		! semafor za KP1.1
stmem x.f100, r4


! Pokretanje KP2.1-------
ldimm x.1, r5
stmem x.f202, r5
ldimm x.6000, r6	! lokacija elementa niza B
ldimm x.9, r7	! broj elemenata niza + 1 za ucitavanje
ldimm x.f, r8	! vrednost za startovanje KP2.1
clr rb		! semafor za KP2.1
stmem x.f200, r8


! Sacekaj da se KP-ovi zavrse
ldimm x.1, rf
wait1:
	and ra, ra, rf
	beql wait1
wait2:
	and rb, rb, rf
	beql wait2
pop rb
pop r8
pop r7
pop r6
pop r5
pop ra
pop r4
pop r3
pop r2
pop r1

ldimm x.9, r1	! counter
ldimm x.4fff, ra	! pokazivac na niz A
ldimm x.5fff, rb	! pokazivac na niz B

iterator:
	ldimm x.1, r2
	inc ra
	inc rb
	dec r1
	beql finish
	ldrid [rb]x.0, rc
	and r0, r2, rc
	bneq iterator
	push ra
	jsr complement
	pop ra
	jmp iterator	
	

finish:
ldimm x.5000, r1
ldrid [r1]x.0, r2
stmem x.9999, r2
	
! Pokretanje DMA kontrolera
ldimm x.5, r0
stmem x.f0c2, r0	! Mozda ne

ldimm x.8, r2
stmem x.f0c4, r2
ldimm x.5000, r3
stmem x.f0c5, r3
ldimm x.5100, r4
stmem x.f0c6, r4


clr ra	! Semafor za DMA 1.4

ldimm x.b6, r1
stmem x.f0c0, r1

ldimm x.f, r5
wait3:
	and ra, ra, r5
	bneq wait3



! Pokretanje KP1.2-------
ldimm x.4, r1
stmem x.f142, r1
ldimm x.5000, r2	! lokacija elementa niza A
ldimm x.9, r3	! broj elemenata niza + 1 za ucitavanje
ldimm x.e, r4	! vrednost za startovanje KP1.2
clr ra		! semafor za KP1.2
stmem x.f140, r4

ldimm x.1, rf
wait4:
	and ra, ra, rf
	beql wait4

! Pokretanje DMA1.2------
ldimm x.2, r0
stmem x.f042, r0	! Mozda ne

ldimm x.1, r2
stmem x.f044, r2
ldimm x.9999, r3
stmem x.f045, r3

clr ra	! Semafor za DMA 1.2

ldimm x.86, r1
stmem x.f040, r1

ldimm x.f, r5
wait5:
	and ra, ra, r5
	bneq wait5




halt
! Kraj programa---------------------------------------


! Komplementiranje potprogram---------

complement:
	pop r4	! PC
	pop r5
	ldrid [r5]x.0, r7
	ldimm x.f, r6
	xor r7, r7, r6
	stri [r5], r7
	push r5
	push r4
rts

! Prekidna rutina KP1.2
org x.1000
dec r3
bneq prenos3
clr r4
stmem x.f140, r4
ldimm x.1, ra
jmp back3

prenos3:
	ldrid [r2]x.0, re
	stmem x.f143, re
	inc r2
back3:
	rti
! Kraj za KP1.2

! Prekidna rutina za KP1.1-------
org x.500
dec r3
bneq prenos1
clr r4
stmem x.f100, r4
ldimm x.1, ra
jmp back1


prenos1:
	ldmem x.f103, rc
	stri [r2], rc
	inc r2
back1:
	rti
! Kraj za KP1.1

! Prekidna rutina za KP2.1-------
org x.1500
dec r7
bneq prenos2
clr r8
stmem x.f200, r8
ldimm x.1, rb
jmp back2


prenos2:
	ldmem x.f203, re
	stri [r6], re
	inc r6
back2:
	rti
! Kraj za KP2.1

! Prekidna rutina za DMA 1.4--------------
org x.3000
push r0
ldimm x.1, ra
clr r0
stmem x.f0c0, r0
pop r0
rti

! Prekidna rutina za DMA 1.2--------------
org x.2500
push r0
ldimm x.1, ra
clr r0
stmem x.f040, r0
pop r0
rti



