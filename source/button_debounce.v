`timescale 1ns / 1ps

module button_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    reg [7:0] q_reg, q_next;  // q_reg:이동전, q_next:이동후
    reg edge_reg;  // Q5
    wire debounce;

    // 100M -> 1M
    reg [$clog2(100)-1:0] counter_reg;
    reg clk_reg;

    // clock divider
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 4'b0;
            clk_reg     <= 1'b0;
        end else begin
            if (counter_reg == 99) begin
                counter_reg <= 0;
                clk_reg     <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1;
                clk_reg     <= 1'b0;
            end
        end
    end


    // debounce shift register
    always @(posedge clk_reg, posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end


    // Serial input, Parallel output shift register
    always @(*) begin
        q_next = {i_btn, q_reg[7:1]};
    end


    // 4 input AND
    assign debounce = &q_reg;


    // Q5 output
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 1'b0;
        end else begin
            edge_reg <= debounce;
        end
    end


    // edge output
    assign o_btn = ~edge_reg & debounce;  // p1

endmodule
