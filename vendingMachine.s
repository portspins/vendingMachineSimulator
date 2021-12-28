@ Author: Matthew Hise
@ Email: mrh0036@uah.edu
@ Section: CS413-01 Spring 2021
@ Date: 03/20/2021
@ Assignment: Lab 4
@ Purpose: Simulate the operation of a soda vending machine.
@
@ Use these command to assemble, link, run and debug this program:
@    as -o vendingMachine.o vendingMachine.s
@    gcc -o vendingMachine vendingMachine.o
@    ./vendingMachine ;echo $?
@    gdb --args ./vendingMachine

.global main

READERROR = 0
PRICE = 55  @ Price of soda

@**********************
main:
@**********************

@ Display welcome message and instructions

	ldr r0, =welcomeMsg		@ Load the welcome message address
	bl printf				@ Make the printf call
	ldr r0, =priceMsg		@ Load the prices message address
	bl printf				@ Make the printf call
	

@**********************
selectDenom:
@**********************

@ Ask the user to enter a coin or dollar bill to the machine

	ldr r0, =acceptMoneyMsg @ Load the money request message address
	bl printf				@ Make the printf call
	ldr r0, =inputCharPattern @ Load the character input pattern address
	ldr r1, =denomSelected	  @ Load the denomination selected address
	bl scanf				  @ Make the scanf call
	cmp r1, #READERROR		  @ Check if there was a read error
	bleq readerror			  @ If so, go handle it
	
@**********************
checkDenom:
@**********************

@ Check which denomination of money was entered

	ldr r0, =denomSelected @ Load the selected denomination address
	ldrb r0, [r0]		   @ Load the denomination character
	
	cmp r0, #'N'			@ Check if a nickel was entered
	@@@@cmpne r0, #'n'			@ Check for lowercase n (Removed to comply with rubric)
	moveq r0, #5			@ Load r0 with 5 cents if nickel was selected
	beq applyMoney			@ Then go add the money
	
	cmp r0, #'D'			@ Check if a dime was entered
	@@@@cmpne r0, #'d'			@ Check for lowercase d (Removed to comply with rubric)
	moveq r0, #10			@ Load r0 with 10 cents if dime was selected
	beq applyMoney			@ Then go add the money
	
	cmp r0, #'Q'			@ Check if a quarter was entered
	@@@@cmpne r0, #'q'			@ Check for lowercase q (Removed to comply with rubric)
	moveq r0, #25			@ Load r0 with 25 cents if quarter was selected
	beq applyMoney			@ Then go add the money
	
	cmp r0, #'B'			@ Check if a one-dollar bill was entered
	@@@@cmpne r0, #'b'			@ Check for lowercase b (Removed to comply with rubric)
	moveq r0, #100			@ Load r0 with 100 cents if one-dollar bill was selected
	beq applyMoney			@ Then go add the money
	
	cmp r0, #'!'			@ Check if special inventory code was entered
	bleq printInventory		@ If so, go print inventory
	beq selectDenom			@ Then go prompt for another input
	
	ldr r0, =invalidDenomMsg @ If here, the denomination selected was invalid
	bl printf				 @ Print the invalid denomination message
	b selectDenom			 @ Then go prompt for a valid input
	
@**********************
applyMoney:
@**********************

@ Apply the money input to the current balance
@ Parameters - r0 should contain the amount of money to apply

	ldr r1, =moneyCollected		@ Load the money collected address
	ldr r2, [r1]				@ Load the money collected value
	add r2, r2, r0				@ Apply the newly-input money to balance
	str r2, [r1]				@ Update the money collected variable
	ldr r0, =moneyCollectedMsg  @ Load the money collected message address
	mov r1, r2					@ Load the money collected value into r1
	PUSH { r2 }					@ Save the money collected value onto stack
	bl printf					@ Output the current total
	POP { r2 }					@ Restore the money collected value
	cmp r2, #PRICE				@ Check if price of soda reached
	blt selectDenom				@ If not, go get more money
	
@**********************
selectDrink:
@**********************

@ Request a drink selection from the user

	ldr r0, =drinkSelectMsg		@ Load the drink select message
	bl printf					@ Make the printf call
	ldr r0, =inputCharPattern	@ Load the character input pattern address
	ldr r1, =drinkSelected		@ Load the drink selected address
	bl scanf					@ Make the scanf call
	cmp r1, #READERROR			@ Check if there was a read error
	bleq readerror				@ If there was, go handle it
	
@**********************
checkDrink:
@**********************

@ Check which drink was selected

	ldr r0, =drinkSelected		@ Load the drink selected address
	ldrb r0, [r0]				@ Load the drink selected value
	
	cmp r0, #'C'				@ Check if Coke was selected
	@@@@cmpne r0, #'c'				@ Check for lowercase c (Removed to comply with rubric)
	beq coke					@ If so, go to Coke
	
	cmp r0, #'S'				@ Check if Sprite was selected
	@@@@cmpne r0, #'s'				@ Check for lowercase s (Removed to comply with rubric)
	beq sprite					@ If so, go to Sprite
	
	cmp r0, #'P'				@ Check if Dr. Pepper was selected
	@@@@cmpne r0, #'p'				@ Check for lowercase p (Removed to comply with rubric)
	beq drPepper				@ If so, go to Dr. Pepper
	
	cmp r0, #'Z'				@ Check if Coke Zero was selected
	@@@@cmpne r0, #'z'				@ Check for lowercase z (Removed to comply with rubric)
	beq cokeZero				@ If so, go to Coke Zero
	
	cmp r0, #'X'				@ Check if user wants to cancel the transaction
	@@@@cmpne r0, #'x'				@ Check for lowercase x (Removed to comply with rubric)
	bne invalidDrink			@ If not, go handle the invalid drink selection
	ldr r0, =drinkNameMsg		@ Load the address of the drink selected message
	ldr r1, =cancelSelectedStr  @ Load the address of the cancel selected string
	bl printf					@ Make the printf call
	bl verifyDrink				@ Verify that the user wants to cancel
	b cancelTransaction			@ If user wants to cancel, go return money and cancel
	
@**********************
invalidDrink:
@**********************

	ldr r0, =invalidDrinkMsg	@ If here, the drink selected was invalid
	bl printf					@ Print the invalid drink message
	b selectDrink			 	@ Then go prompt for a valid input

@**********************
coke:
@**********************

@ Coke was selected

	mov r0, #0				@ Load array offset for Coke
	bl printDrinkSelected	@ Then go print the drink name message
	mov r0, #0				@ Load inventory array offset for Coke
	bl verifyDrinkInv		@ Go check Coke inventory
	cmp r1, #0				@ See if drink was out of stock
	beq outOfStock			@ If it was, go handle that
	bl verifyDrink			@ If inventory is fine, verify the user wants that drink
	mov r0, #0				@ Reload r0 with offset
	mov r1, #0				@ Load array offset for Coke
	b dispenseDrink			@ Go dispense the drink		

@**********************
sprite:
@**********************

@ Sprite was selected

	mov r0, #5				@ Load array offset for Sprite
	bl printDrinkSelected	@ Then go print the drink name message
	mov r0, #1				@ Load inventory array offset for Sprite
	bl verifyDrinkInv		@ Go check Sprite inventory
	cmp r1, #0				@ See if drink was out of stock
	beq outOfStock			@ If it was, go handle that
	bl verifyDrink			@ If inventory is fine, verify the user wants that drink
	mov r0, #1				@ Reload r0 with offset
	mov r1, #5				@ Load array offset for Sprite
	b dispenseDrink			@ Go dispense the drink		

@**********************
drPepper:
@**********************

@ Dr. Pepper was selected
	
	mov r0, #12				@ Load array offset for Dr. Pepper
	bl printDrinkSelected	@ Then go print the drink name message
	mov r0, #2				@ Load inventory array offset for Dr. Pepper
	bl verifyDrinkInv		@ Go check Dr. Pepper inventory
	cmp r1, #0				@ See if drink was out of stock
	beq outOfStock			@ If it was, go handle that
	bl verifyDrink			@ If inventory is fine, verify the user wants that drink
	mov r0, #2				@ Reload r0 with offset
	mov r1, #12				@ Load array offset for Dr. Pepper
	b dispenseDrink			@ Go dispense the drink

@**********************
cokeZero:
@**********************

@ Coke Zero was selected

	mov r0, #23				@ Load array offset for Coke Zero
	bl printDrinkSelected	@ Then go print the drink name message
	mov r0, #3				@ Load inventory array offset for Coke Zero
	bl verifyDrinkInv		@ Go check Coke Zero inventory
	cmp r1, #0				@ See if drink was out of stock
	beq outOfStock			@ If it was, go handle that
	bl verifyDrink			@ If inventory is fine, verify the user wants that drink
	mov r0, #3				@ Reload r0 with offset
	mov r1, #23				@ Load array offset for Coke Zero
	b dispenseDrink			@ Go dispense the drink		
	
@**********************
verifyDrinkInv:
@**********************

@ Verify there is enough inventory to dispense desired drink
@ Parameters - r0 should contain the index of the drink selected
@ Return - r1 will contain 1 if the selected drink has remaining stock, 0 otherwise

	ldr r1, =drinkInv			@ Load r1 with starting address of drink inventory array
	ldr r1, [r1, r0, LSL #2]	@ Get the drink inventory value
	
	cmp r1, #0					@ Compare inventory with zero
	moveq r1, #0				@ If drink is out of stock, return 0
	movne r1, #1				@ Otherwise return 1
	mov pc, lr					@ Otherwise return
	
@**********************
outOfStock:
@**********************
	
@ Drink selected was out of stock

	ldr r0, =drinkOutOfStockMsg	@ Load the out of stock message
	bl printf					@ Make the printf call
	b selectDrink				@ Go get another drink selection
	
@**********************
printDrinkSelected:
@**********************

@ Print the drink selected message
@ Parameters - r0 should contain the offset for the drink selected

	ldr r1, =drinkNames			@ Load r1 with starting address of drink names array
	add r1, r1, r0				@ Add the offset to r1
	ldr r0, =drinkNameMsg		@ Load the drink name message
	PUSH { lr }					@ Save link register
	bl printf					@ Print the drink name message
	POP { lr }					@ Restore the link register
	mov pc, lr					@ Return
	

@**********************
verifyDrink:
@**********************

@ Verify the drink selection

	PUSH { lr }					@ Save link register
	ldr r0, =drinkVerifyMsg		@ Load the drink verify message
	bl printf					@ Print the confirmation message
	ldr r0, =inputCharPattern	@ Load the character input pattern address
	ldr r1, =confirmVal			@ Load the confirmation variable address
	bl scanf					@ Get the confirmation from the user
	cmp r1, #READERROR			@ Check if there was a read error
	bleq readerror				@ If there was, go handle it
	POP { lr }					@ Restore link register
	
	ldr r0, =confirmVal			@ Load the confirm character address
	ldrb r0, [r0]				@ Load the confirmation character
	
	cmp r0, #'Y'				@ If user confirms their selection
	cmpne r0, #'y'				@ with Y or y
	moveq pc, lr				@ Then return to the selected drink
	
	cmp r0, #'N'				@ If user wants to change their selection
	cmpne r0, #'n'				@ with N or n
	beq selectDrink				@ Then go get another drink selection
	
	ldr r0, =invalidConfirmMsg	@ If here, the confirmation character was invalid
	bl printf					@ Print the invalid confirmation character message
	b selectDrink			 	@ Then go prompt for another drink selection
	
@**********************
dispenseDrink:
@**********************

@ Dispense the selected drink
@ Parameters - r0 should contain the inventory array offset
@ 			   r1 should contain the drink names offset

	mov r2, r0				@ Move the first argument to r2
	mov r3, r1				@ Move the second argument to r3
	ldr r0, =drinkInv		@ User confirmed selection and inventory is fine, so dispense drink
	ldr r1, [r0, r2, LSL #2]! @ Get the value of inventory
	sub r1, #1				@ Decrement it
	str r1, [r0]			@ Store updated value
	ldr r0, =moneyCollected @ Load money collected address
	ldr r1, [r0]			@ Load money collected value
	sub r2, r1, #PRICE		@ Calculate change to dispense
	mov r4, #0				@ Load r4 with zero
	str r4, [r0]			@ Reset money collected variable
	ldr r0, =dispensedMsg	@ Load r0 with the dispensed message
	ldr r1, =drinkNames		@ Load r1 with starting address of drink names array
	add r1, r1, r3			@ Load r1 with the drink name address
	bl printf				@ Make the printf call
	
	mov r0, #0				@ Initialize counter for loop
	
@**********************
postDispenseLoop:
@**********************	

@ Check inventory of all drinks, shut down if all out of stock
	
	cmp r0, #4				@ Check if inventory was all gone
	ldreq r0, =shutdownMsg	@ If it was, load shutdown message address
	bleq printf				@ and print shutdown message
	beq exit				@ then exit the program
	bl verifyDrinkInv		@ Otherwise, check inventory of drink
	cmp r1, #1				@ Check if the drink had inventory
	beq selectDenom			@ If so, reset for next purchase
	add r0, #1				@ Increment counter
	b postDispenseLoop		@ Restart loop
	
@**********************
printInventory:
@**********************

@ Print the inventory of all drinks

	PUSH { lr }			@ Save the link register
	ldr r0, =invStr 	@ Load the inventory string
	ldr r1, =drinkNames @ Load the starting address of names array
	ldr r2, =drinkInv	@ Load the starting address of inventory array
	ldr r2, [r2]		@ Load inventory value
	bl printf			@ Make the printf call
	ldr r0, =invStr 	@ Load the inventory string
	ldr r1, =drinkNames @ Load the starting address of names array
	add r1, #5			@ Move to next name
	ldr r2, =drinkInv	@ Load the starting address of inventory array
	ldr r2, [r2, #4]	@ Move to the next index of array and load value
	bl printf			@ Make the printf call
	ldr r0, =invStr 	@ Load the inventory string
	ldr r1, =drinkNames @ Load the starting address of names array
	add r1, #12			@ Move to next name
	ldr r2, =drinkInv	@ Load the starting address of inventory array
	ldr r2, [r2, #8]	@ Move to the next index of array and load value
	bl printf			@ Make the printf call
	ldr r0, =invStr 	@ Load the inventory string
	ldr r1, =drinkNames @ Load the starting address of names array
	add r1, #23			@ Move to next name
	ldr r2, =drinkInv	@ Load the starting address of inventory array
	ldr r2, [r2, #12]	@ Move to the next index of array and load value
	bl printf			@ Make the printf call
	POP { lr }			@ Restore the link register
	mov pc, lr			@ Return
	



@**********************
cancelTransaction:
@**********************

@ Return all money and cancel transaction

	ldr r0, =moneyCollected		@ Load the money collected address
	ldr r1, [r0]				@ Load the value of money to return
	mov r2, #0					@ Prepare to reset money collected
	str r2, [r0]				@ Overwrite money collected with zero
	ldr r0, =cancelledMsg		@ Load the cancellation message
	bl printf					@ Make the printf call
	b main						@ Transaction cancelled, restart program
	
@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer and ask
@ for the user to enter a value. 
@ An invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

	push { lr }
	ldr r0, =strInputPattern
	ldr r1, =strInputError   @ Put address into r1 for read.
	bl scanf                 @ scan the keyboard.
	pop { lr }
	bx lr
	
@**********************
exit:
@**********************

@ Exit the program and return control to the OS

	mov r7, #0x01	@ SVC call to exit
	svc 0		 	@ Make the system call


.data

.balign 4
welcomeMsg: .asciz "Welcome to Cold Hard Cache soft drink vending machine!\n"
@ Welcome message for program startup

.balign 4
priceMsg: .asciz "The cost of Coke, Sprite, Dr. Pepper, and Coke Zero is 55 cents.\n(Enter ! instead of money to display inventory)\n\n"
@ Message stating the price of the drinks

.balign 4
acceptMoneyMsg: .asciz "Enter money nickel (N), dime (D), quarter (Q), or one-dollar bill (B):\n"
@ Message to request money input

.balign 4
drinkSelectMsg: .asciz "\nMake selection:\nCoke (C), Sprite (S), Dr. Pepper (P), or Coke Zero (Z)\n[(X) to cancel transaction and return all money.]\n"
@ Message to request drink selection

.balign 4
drinkNameMsg: .asciz "\nYou selected %s. \n"
@ Message to state the drink the user selected

.balign 4
drinkOutOfStockMsg: .asciz "Unfortunately, that drink is out of stock. Please select another drink.\n"
@ Message to alert user that the drink they selected is out of stock

.balign 4
drinkVerifyMsg: .asciz "Is this OK? (Y or N)\n"
@ Message to verify drink selection

.balign 4
moneyCollectedMsg: .asciz "Total money collected: %d cents\n"
@ Message to display current total money collected so far

.balign 4
dispensedMsg: .asciz "A %s has been dispensed with %d cents change.\n"
@ Message to dispense drink and change

.balign 4
invStr: .asciz " %s - %d\n"
@ Format string for inventory printing

.balign 4
drinkNames: .asciz "Coke", "Sprite", "Dr. Pepper", "Coke Zero"
@ Strings containing the drink names

.balign 4
cancelSelectedStr: .asciz "to cancel the transaction"
@ String for when user wants to cancel transaction

.balign 4
invalidDenomMsg: .asciz "\nThe denomination of money you entered was invalid.\n"
@ Message for an invalid money input

.balign 4
invalidConfirmMsg: .asciz "\nThe confirmation character you entered was invalid.\n"
@ Message for an invalid confirmation character input

.balign 4
invalidDrinkMsg: .asciz "\nYour drink selection was invalid.\n"
@ Message for an invalid drink input

.balign 4
cancelledMsg: .asciz "\nTransaction cancelled. Money returned: %d cents\n\n"
@ Message for a cancelled transaction

.balign 4
shutdownMsg: .asciz "\nAll drinks are out of stock. Cold Hard Cache is closed for now!\n"
@ Message for when inventory is depleted and the vending machine shuts down

.balign 4
moneyCollected: .word 0
@ Stores the money collected

.balign 4
drinkInv: .word 2, 2, 2, 2
@ Stores the inventory of Coke, Sprite, Dr. Pepper, and Coke Zero in that order

.balign 4
inputCharPattern: .asciz "%s"
@ Input pattern for string, from which a character will be read

.balign 4
denomSelected: .byte ' '
@ Stores the money denomination selected

.balign 4
drinkSelected: .byte ' '
@ Stores the drink selected

.balign 4
confirmVal: .byte ' '
@ Stores the drink confirmation character

.balign 4
strInputPattern: .asciz "%[^\n]"
@ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4
@ For the read error handling to read in the input

.global printf

.global scanf
