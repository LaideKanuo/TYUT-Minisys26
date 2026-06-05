`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module ioread (
    input           reset,                  // reset signal
    input           ior,                    // IO read strobe from control32
    input           switchctrl,             // switch chip select from memorio
    input           digitubectrl,           // digitube chip select from memorio
    input   [15:0]  ioread_data_switch,     // data from switchs module
    input   [15:0]  ioread_data_digitube,   // data from digitube module
    output  [15:0]  ioread_data             // data to memorio
);

    reg [15:0] ioread_data;

    always @* begin
        if (reset == 1)
            ioread_data = 16'b0;
        else if (ior == 1) begin
            if (switchctrl == 1)
                ioread_data = ioread_data_switch;
            else if (digitubectrl == 1)
                ioread_data = ioread_data_digitube;
            else
                ioread_data = 16'b0;       // fix latch: default to 0 instead of self-assign
        end else
            ioread_data = 16'b0;           // fix latch: default when ior=0
    end
endmodule
