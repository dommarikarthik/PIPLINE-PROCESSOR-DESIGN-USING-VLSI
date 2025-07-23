module PipelineProcessor (
    input clk,
    input reset,
    output reg [31:0] PC,
    output reg [31:0] instruction
);

    reg [31:0] instruction_memory [0:255]; // Instruction Memory

    initial begin
        instruction_memory[0] = 32'hA00000AA;
        instruction_memory[1] = 32'hB00000BB;
        instruction_memory[2] = 32'hC00000CC;
        instruction_memory[3] = 32'hD00000DD;
    end

    always @(posedge clk) begin
        if (reset) begin
            PC <= 0;
            instruction <= 0;
        end else begin
            instruction <= instruction_memory[PC[9:2]];
            PC <= PC + 4;
        end
    end
endmodule

Testbnench code :-

`timescale 1ns / 1ps

module PipelineProcessor_tb;

    reg clk;
    reg reset;
    wire [31:0] PC;
    wire [31:0] instruction;

    PipelineProcessor uut (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("pipeline.vcd");     // VCD output file
        $dumpvars(0, PipelineProcessor_tb); // Dump all signals

        clk = 0;
        reset = 1;
        #10 reset = 0;

        #100 $finish; // Simulation duration
    end

    always #5 clk = ~clk;

endmodule
