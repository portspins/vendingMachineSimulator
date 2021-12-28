# vendingMachineSimulator
ARM program to simulate the operation of a soda vending machine.

Use these command to assemble, link, run and debug this program:
    as -o vendingMachine.o vendingMachine.s
    gcc -o vendingMachine vendingMachine.o
    ./vendingMachine ;echo $?
    gdb --args ./vendingMachine
