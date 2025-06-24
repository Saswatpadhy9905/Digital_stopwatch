`timescale 1ns/1ps

module clk_divider(
    input clk,
    input reset,
    output reg clk_1hz,
    output reg clk_khz
);
    reg [26:0] count_hz = 0;
    reg [16:0] count_khz = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_hz <= 0;
            clk_1hz <= 0;
        end else begin
            count_hz <= count_hz + 1;
            if (count_hz == 5) begin
                clk_1hz <= ~clk_1hz;
                count_hz <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_khz <= 0;
            clk_khz <= 0;
        end else begin
            count_khz <= count_khz + 1;
            if (count_khz == 2) begin
                clk_khz <= ~clk_khz;
                count_khz <= 0;
            end
        end
    end
endmodule

module seven_segment_decoder(
    input [3:0] digit,
    output reg [6:0] seg
);
    always @(*) begin
        case (digit)
            4'd0: seg = 7'b0000001;  // a–f on, g off
            4'd1: seg = 7'b1001111;  // b, c on
            4'd2: seg = 7'b0010010;
            4'd3: seg = 7'b0000110;
            4'd4: seg = 7'b1001100;
            4'd5: seg = 7'b0100100;
            4'd6: seg = 7'b0100000;
            4'd7: seg = 7'b0001111;
            4'd8: seg = 7'b0000000;  // all on
            4'd9: seg = 7'b0000100;
            default: seg = 7'b1111111;  // all off
        endcase
    end
endmodule

module stopwatch_counter(
    input clk, start, stop, reset,
    output reg [3:0] sec_ones, sec_tens, min_ones, min_tens
);
    reg running = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sec_ones <= 0; sec_tens <= 0;
            min_ones <= 0; min_tens <= 0;
            running <= 0;
        end else begin
            if (start) running <= 1;
            if (stop) running <= 0;

            if (running) begin
                sec_ones <= sec_ones + 1;
                if (sec_ones == 9) begin
                    sec_ones <= 0;
                    sec_tens <= sec_tens + 1;
                end
                if (sec_tens == 5 && sec_ones == 9) begin
                    sec_tens <= 0;
                    min_ones <= min_ones + 1;
                end
                if (min_ones == 9 && sec_tens == 5 && sec_ones == 9) begin
                    min_ones <= 0;
                    min_tens <= min_tens + 1;
                end
            end
        end
    end
endmodule


module display_mux(
    input clk,  
    input [3:0] d0, d1, d2, d3,
    output reg [3:0] an, //active low enable
    output reg [3:0] digit
);
    reg [1:0] sel = 0;

    always @(posedge clk) begin
        sel <= sel + 1;
        case (sel)
            2'b00: begin an = 4'b1110; digit = d0; end
            2'b01: begin an = 4'b1101; digit = d1; end
            2'b10: begin an = 4'b1011; digit = d2; end
            2'b11: begin an = 4'b0111; digit = d3; end
        endcase
    end
endmodule

module top(
    input clk,
    input btn_start, btn_stop, btn_reset,
    output [6:0] seg,
    output [3:0] an
);
    wire clk_1hz, clk_khz;
    wire [3:0] s1, s2, m1, m2;
    wire [3:0] digit;

    clk_divider clkdiv(clk, btn_reset, clk_1hz, clk_khz);
    stopwatch_counter sw(clk_1hz, btn_start, btn_stop, btn_reset, s1, s2, m1, m2);
    display_mux disp(clk_khz, s1, s2, m1, m2, an, digit);
    seven_segment_decoder dec(digit, seg);
endmodule

module stopwatch_tb;
  reg clk = 0;
  reg reset = 1;
  reg start = 0;
  reg stop = 0;
  wire [6:0] seg;
  wire [3:0] an;

  // Instantiate the design
  top uut (
    .clk(clk),
    .btn_reset(reset),
    .btn_start(start),
    .btn_stop(stop),
    .seg(seg),
    .an(an)
  );

  // Clock generation
  always #5 clk = ~clk; 

  initial begin
    
    $dumpfile("waveform.vcd");
    $dumpvars(0, stopwatch_tb);

    #10 reset = 0;   // Release reset
    #20 start = 1;   // Start stopwatch
    #500 start = 0;  
    #1000 stop = 1;
    #100 stop = 0;

    #500 $finish;
  end
endmodule

