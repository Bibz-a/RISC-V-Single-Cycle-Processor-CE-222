

`timescale 1ns / 1ps

module stimulus;

    reg clk;
    reg reset;

    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, stimulus);
        $monitor("time=%0t PC=%d", $time, uut.pc1.pc_out);
        clk   = 0;
        reset = 1; //pc = 0

        #20 reset = 0; 

        // One cycle per instruction

        #10; // addi x16 = 10
        #10; // addi x17 = 5
        #10; // addi x18 = 20
        #10; // addi x19 = 3
        #10; // add  x5  = 15
        #10; // sub  x6  = 5
        #10; // and  x7  = 0
        #10; // or   x28 = 15
        #10; // add  x29 = 23
        #10; // sub  x30 = 17
        #10; // sw   dmem[0] = 15
        #10; // lw   x31 = 15
        #50; // beq test (branch not taken, then taken in loop)



        //After running inst, register, dmem, pc states:

        $display("           REGISTER FILE RESULTS              ");
        $display("----------------------------------------------");

        $display("x16 = %2d | expected = 10", uut.reg_file.regfile[16]); // addi x16 = 10
        $display("x17 = %2d | expected =  5", uut.reg_file.regfile[17]); // addi x17 = 5
        $display("x18 = %2d | expected = 20", uut.reg_file.regfile[18]); // addi x18 = 20
        $display("x19 = %2d | expected =  3", uut.reg_file.regfile[19]); // addi x19 = 3

        $display("x5  = %2d | expected = 15", uut.reg_file.regfile[5]);  // add x5  = 15
        $display("x6  = %2d | expected =  5", uut.reg_file.regfile[6]);  // sub x6  = 5
        $display("x7  = %2d | expected =  0", uut.reg_file.regfile[7]);  // and x7  = 0
        $display("x28 = %2d | expected = 15", uut.reg_file.regfile[28]); // or  x28 = 15
        $display("x29 = %2d | expected = 23", uut.reg_file.regfile[29]); // add x29 = 23
        $display("x30 = %2d | expected = 17", uut.reg_file.regfile[30]); // sub x30 = 17
        $display("x31 = %2d | expected = 15", uut.reg_file.regfile[31]); // lw  x31 = 15

        $display("----------------------------------------------");
        $display("             DATA MEMORY RESULTS              ");
        $display("----------------------------------------------");

        $display("dmem[0]  = %2d | expected = 15", uut.dmem.Memory[0]);

        $display("----------------------------------------------");
        $display("                 PC RESULT                    ");
        $display("----------------------------------------------");
        
        $display("PC       = %2d | expected = 52  when exiting", uut.pc1.pc_out);

        #100 $finish;
    end

endmodule

