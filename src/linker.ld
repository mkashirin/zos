/*
An LD file is a script written in the GNU "linker command language".
It contains one or more commands that are used to configure how input files
storing static object code are to be compiled into a single executable
program or library for the GNU operating system.
*/

/* Defining the first executable instruction in an output file. */
ENTRY(_start)

    /*
    Basically with SECTIONS you can do one of:
    * Define the entry point;
    * Assign a value to a symbol;
    * Describe the placement of a named output section, and which input
    sections go into it.

    Here we're doing the third thing.
    */
    SECTIONS {

        /*
        The special linker variable `.` always contains the current output
        location counter.
        */
        . = 1M;

        /* 
        Here we define sections with `.* : ALIGN(E)` syntax.
        `ALIGN(E)` returns the result of the current location counter (`.`)
        aligned to the next `E` boundary. (`E` stands for expression.)
        */
        .text : ALIGN(4K) {

            /*
            This marks a section that should NOT be eliminated.
            You can also name one or more sections from your input files, for
            insertion in the current output section with `*(E)` syntax.
            */
            KEEP(*(.multiboot))
            *(.text)
        }

        .rodata : ALIGN(4K) {
            *(.rodata)
        }

        .data : ALIGN(4K) {
            *(.data)
        }

        .bss : ALIGN(4K) {
            *(COMMON)
            *(.bss)
        }
}
