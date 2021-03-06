;; -*- mode: asm -*-
;;
;; This file is part of a Supersingular Isogeny Key Encapsulation (SIKE) over P434 for Commodore 64.
;; Copyright (c) 2020 isis lovecruft
;; See LICENSE for licensing information.
;;
;; Authors:
;; - isis agora lovecruft <isis@patternsinthevoid.net>

;; Constants and pseudo registers.
;;
;; We shove all the scratch space at the top of the userspace at $c000-$cfff.

!cpu 6510                       ; For 6502/6510 with undocumented opcodes
!zone constants                 ; Namespacing

;; Number of words in a field element.
;;
;; 434 bits divided by 8 is 54.25, but we round up to 56 to get a 448-bit
;; element to match existing implementations for 32-bit and 64-bit
;; architectures.  We wouldn't want Commodore 64s to be unable to talk to
;; "modern" CPUs.
FE_WORDS = 56

;; Various cryptographic masks for constant-time operations.
!addr MASK = $cfff
!addr MASK_HIGH = $cffe
!addr MASK_LOW = $cffd

!addr ADDER_REAL = $cffc
!addr ADDER_FAKE = $cfeb

;; Pseudo registers for storing intermediate values during field element subtraction and addition.
!addr FE_SUB_BORROW = $cffa
!addr FE_ADD_CARRY = $cff9
!addr FE_ADD_TMP2 = $cff8
!addr FE_ADD_TMP1 = $cff7

;; Pseudo registers for storing intermediate values during field element multiplication.
!addr FE_MUL_RESULT = $cff0     ; 2 words
!addr FE_MUL_CARRY = $cfee
!addr FE_MUL_T = $cfed
!addr FE_MUL_U = $cfec
!addr FE_MUL_V = $cfeb
!addr FE_MUL_TMP = $cfea

;; Pseudo registers for field element reduction.
!addr FE_RDC_RESULT =  $cfe9    ; 2 words
!addr FE_RDC_CARRY = $cfe7
!addr FE_RDC_T = $cfe6
!addr FE_RDC_U = $cfe5
!addr FE_RDC_V = $cfe4
!addr FE_RDC_TMP = $cfe3
!addr FE_RDC_SKIP = $cfe2

;; Pseudo registers for field element negation.
!addr FE_NEG_TMP = $cfe1

;; Pseudo registers for field element squaring.
!addr FE_SQR_TMP = FE_NEG_TMP - (1 * FE_WORDS) ; Fuckin' fancy assembler parser passing.

;; Pseudo registers for GF(p^2) squaring.
!addr FE2_SQR_TMP1 = FE_NEG_TMP - (2 * FE_WORDS)
!addr FE2_SQR_TMP2 = FE_NEG_TMP - (3 * FE_WORDS)
!addr FE2_SQR_TMP3 = FE_NEG_TMP - (4 * FE_WORDS)

;; Pseudo registers for GF(p^2) multiplication.
!addr FE2_MUL_TMP1 = FE_NEG_TMP - (5 * FE_WORDS)
!addr FE2_MUL_TMP2 = FE_NEG_TMP - (6 * FE_WORDS)
!addr FE2_MUL_TMP3 = FE_NEG_TMP - (7 * FE_WORDS)
!addr FE2_MUL_TMP4 = FE_NEG_TMP - (8 * FE_WORDS)
!addr FE2_MUL_TMP5 = FE_NEG_TMP - (9 * FE_WORDS)

;; Pseudo registers for GF(p^2) element inversion.
!addr FE2_INV_TMP1 = FE_NEG_TMP - (10 * FE_WORDS)
!addr FE2_INV_TMP2 = FE_NEG_TMP - (11 * FE_WORDS)
!addr FE2_INV_TMP3 = FE_NEG_TMP - (12 * FE_WORDS)

;; XXX should maybe double check these addresses to make sure we're not
;;     crossing page boundaries
!addr FE_ADD_A = FE_NEG_TMP - (13 * FE_WORDS)
!addr FE_ADD_B = FE_NEG_TMP - (14 * FE_WORDS)
!addr FE_ADD_C = FE_NEG_TMP - (15 * FE_WORDS)

;; For some reason for the following with the ACME Crossass assembler
;; in order to store for example $ABCDEF01 at a given location in the
;; binary we need to do:
;;
;; !le32 $EF01ABCD
;;
;; and swap each set of two words.  I do not know why this is, and
;; frankly I do not care to find out.

;; P434_PRIME = 24439423661345221551909145011457493619085780243761596511325807336205221239331976725970216671828618445898719026692884939342314733567
!addr P434_PRIME = FE_NEG_TMP - (16 * FE_WORDS)

    LDA *                       ; Save program counter
    PHA                         ; Push it to the global stack
    * = P434_PRIME              ; Change program couter to location of P434_PRIME

    ;; Write raw bytes to this offset in the program
!le32 $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $767AFDC1, $FFFFE2FF, $5C787BC6, $AEA33158, $5FD66CFC, $205681C5, $341F0002, $73442717

    PLA                         ; Pull the old program counter back out
    STA MASK                    ; Store it in a junk spot for now
    * = MASK                    ; Restore it

;; 2 * P434_PRIME
!addr P434_PRIME_2 = FE_NEG_TMP - (17 * FE_WORDS)

    LDA *                       ; Save program counter
    PHA                         ; Push it to the global stack
    * = P434_PRIME_2            ; Change program couter to location of P434_PRIME_2

    ;; Write raw bytes to this offset in the program
!le32 $FFFFFFFF, $FFFFFFFE, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $FFFFFFFF, $ECF5FB82, $FFFFC5FF, $B8F0F78C, $5D4762B1, $BFADD9F8, $40AC038A, $683E0004, $E6884E2E

    PLA                         ; Pull the old program counter back out
    STA MASK                    ; Store it in a junk spot for now
    * = MASK                    ; Restore it

;; P434_PRIME + 1
!addr P434_PRIME_PLUS_1 = FE_NEG_TMP - (18 * FE_WORDS)

    LDA *                       ; Save program counter
    PHA                         ; Push it to the global stack
    * = P434_PRIME_PLUS_1       ; Change program couter to location of P434_PRIME_PLUS_1

    ;; Write raw bytes to this offset in the program
!le32 $00000000, $00000000, $00000000, $00000000, $00000000, $00000000, $767AFDC1, $0000E300, $5C787BC6, $AEA33158, $5FD66CFC, $205681C5, $341F0002, $73442717

    PLA                         ; Pull the old program counter back out
    STA MASK                    ; Store it in a junk spot for now
    * = MASK                    ; Restore it

;; Scratch space for chained inversion field element squarings.
!addr FE_INV_TMP1 = FE_NEG_TMP - (19 * FE_WORDS)
!addr FE_INV_TMP2 = FE_NEG_TMP - (20 * FE_WORDS)
!addr FE_INV_TMP3 = FE_NEG_TMP - (21 * FE_WORDS)
!addr FE_INV_TMP4 = FE_NEG_TMP - (22 * FE_WORDS)

;; Precomputed tables for field element inversions.
!addr FE_INV_TABLE0  = FE_NEG_TMP - (23 * FE_WORDS)
!addr FE_INV_TABLE1  = FE_NEG_TMP - (24 * FE_WORDS)
!addr FE_INV_TABLE2  = FE_NEG_TMP - (25 * FE_WORDS)
!addr FE_INV_TABLE3  = FE_NEG_TMP - (26 * FE_WORDS)
!addr FE_INV_TABLE5  = FE_NEG_TMP - (27 * FE_WORDS)
!addr FE_INV_TABLE6  = FE_NEG_TMP - (28 * FE_WORDS)
!addr FE_INV_TABLE7  = FE_NEG_TMP - (29 * FE_WORDS)
!addr FE_INV_TABLE9  = FE_NEG_TMP - (30 * FE_WORDS)
!addr FE_INV_TABLE10 = FE_NEG_TMP - (31 * FE_WORDS)
!addr FE_INV_TABLE12 = FE_NEG_TMP - (32 * FE_WORDS)
!addr FE_INV_TABLE13 = FE_NEG_TMP - (33 * FE_WORDS)
!addr FE_INV_TABLE14 = FE_NEG_TMP - (34 * FE_WORDS)
!addr FE_INV_TABLE16 = FE_NEG_TMP - (35 * FE_WORDS)
!addr FE_INV_TABLE19 = FE_NEG_TMP - (36 * FE_WORDS)
!addr FE_INV_TABLE20 = FE_NEG_TMP - (37 * FE_WORDS)
!addr FE_INV_TABLE21 = FE_NEG_TMP - (38 * FE_WORDS)
!addr FE_INV_TABLE22 = FE_NEG_TMP - (39 * FE_WORDS)
!addr FE_INV_TABLE23 = FE_NEG_TMP - (40 * FE_WORDS)
!addr FE_INV_TABLE24 = FE_NEG_TMP - (41 * FE_WORDS)
!addr FE_INV_TABLE25 = FE_NEG_TMP - (42 * FE_WORDS)
!addr FE_INV_TABLE26 = FE_NEG_TMP - (43 * FE_WORDS)
!addr FE_INV_TABLE28 = FE_NEG_TMP - (44 * FE_WORDS)
!addr FE_INV_TABLE30 = FE_NEG_TMP - (45 * FE_WORDS)
	
;; Number of field elements for Alice's 2-isogenisation strategy.
ALICE_ELEMENTS = 108
;; Number of field elements for Bob's 3-isogenisation strategy
BOB_ELEMENTS = 137

;; Number of zero words in the P434 prime + 1.  We exploit this structure for field element reduction.
ZERO_WORDS = 24
