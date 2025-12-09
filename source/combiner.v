`timescale 1ns / 1ps

module combiner (
    input      [ 1:0] sel,
    input      [23:0] i_sw,
    input      [23:0] i_w,
    output reg [23:0] o_tot
);

    always @(*) begin
        if (sel == 1'b0) o_tot = i_sw;  // stopwatch 데이터 선택
        else o_tot = i_w;  // watch 데이터 선택
    end
endmodule
