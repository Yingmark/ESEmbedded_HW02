.syntax unified

.word 0x20000100
.word _start

.global _start
.type _start, %function
_start:
	movs r0, #100
	movs r1, #50
	mov  r2, #102

	push {r0, r1, r2}

	//pop {r3, r4, r5}

	pop {r3}
	pop {r4}
	pop {r5}

	b	label01

label01:
	nop
	bl	sleep

sleep:
	nop
	b	.
