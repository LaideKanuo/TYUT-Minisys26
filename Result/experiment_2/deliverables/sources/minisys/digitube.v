`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module digitube (
    input               clk,            // system clock (23MHz)
    input               rst,            // reset, active high
    input               digitube_cs,    // chip select from memorio
    input               digitube_write, // write enable from controlIO32
    input       [1:0]   digitube_addr,  // address low bits from alu_result[3:2]
    input       [15:0]  write_data,     // data to display
    output      [15:0]  digitube_rdata, // readback data for ioread
    output reg  [7:0]   seg,            // segment select (a,b,c,d,e,f,g,dp)
    output reg  [3:0]   an              // digit select (active low for common anode)
);

    // Display registers: two 4-bit digit values
    reg [3:0] digit0;   // low byte  → right digit
    reg [3:0] digit1;   // high byte → left digit

    // Write digit values on IO write
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            digit0 <= 4'h0;
            digit1 <= 4'h0;
        end else if (digitube_cs && digitube_write) begin
            case (digitube_addr[1:0])
                2'b00: begin
                    digit0 <= write_data[3:0];
                    digit1 <= write_data[7:4];
                end
                // 2'b01 and above: reserved for future expansion
                default: ;
            endcase
        end
    end

    // Dynamic scan counter: divide 23MHz by 2^13 ≈ 2.8kHz scan rate
    reg [12:0] scan_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst)
            scan_cnt <= 13'd0;
        else
            scan_cnt <= scan_cnt + 1'b1;
    end

    wire scan_sel;
    assign scan_sel = scan_cnt[12];  // MSB toggles at ~2.8kHz

    // 4-bit value to 7-segment decoder (common anode: 0 = segment ON)
    // seg bits: {dp, g, f, e, d, c, b, a}
    function [7:0] bcd_to_seg;
        input [3:0] val;
        begin
            case (val)
                4'h0:    bcd_to_seg = 8'b11000000;  // 0
                4'h1:    bcd_to_seg = 8'b11111001;  // 1
                4'h2:    bcd_to_seg = 8'b10100100;  // 2
                4'h3:    bcd_to_seg = 8'b10110000;  // 3
                4'h4:    bcd_to_seg = 8'b10011001;  // 4
                4'h5:    bcd_to_seg = 8'b10010010;  // 5
                4'h6:    bcd_to_seg = 8'b10000010;  // 6
                4'h7:    bcd_to_seg = 8'b11111000;  // 7
                4'h8:    bcd_to_seg = 8'b10000000;  // 8
                4'h9:    bcd_to_seg = 8'b10010000;  // 9
                4'ha:    bcd_to_seg = 8'b10001000;  // A
                4'hb:    bcd_to_seg = 8'b10000011;  // b
                4'hc:    bcd_to_seg = 8'b11000110;  // C
                4'hd:    bcd_to_seg = 8'b10100001;  // d
                4'he:    bcd_to_seg = 8'b10000110;  // E
                4'hf:    bcd_to_seg = 8'b10001110;  // F
                default: bcd_to_seg = 8'b11111111;  // blank
            endcase
        end
    endfunction

    // Readback data for ioread module
    assign digitube_rdata = {8'b0, digit1, digit0};

    // Segment output (common anode: 0 = ON)
    always @* begin
        if (scan_sel == 1'b0) begin
            seg = bcd_to_seg(digit0);
            an  = 4'b1110;   // digit0 (right) ON, active low
        end else begin
            seg = bcd_to_seg(digit1);
            an  = 4'b1101;   // digit1 (left) ON, active low
        end
    end

endmodule
