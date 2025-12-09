`timescale 1ns / 1ps

module watch_dp (
    input        clk,
    input        rst,
    input        Btn_L,
    input        Btn_R,
    input        Btn_U,
    output [6:0] msec,
    output [5:0] sec,
    output [5:0] min,
    output [4:0] hour
);

    wire w_tick_100hz, w_sec_tick, w_min_tick, w_hour_tick;

    time_counter_w #(
        .BIT_WIDTH (7),
        .TIME_COUNT(100)
    ) U_MSEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_tick_100hz),
        .o_time(msec),
        .o_tick(w_sec_tick)
    );

    time_counter_w #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_SEC_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_sec_tick | Btn_U),
        .o_time(sec),
        .o_tick(w_min_tick)
    );

    time_counter_w #(
        .BIT_WIDTH (6),
        .TIME_COUNT(60)
    ) U_MIN_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_min_tick | Btn_R),
        .o_time(min),
        .o_tick(w_hour_tick)
    );

    time_counter_w #(
        .BIT_WIDTH (5),
        .TIME_COUNT(24)
    ) U_HOUR_COUNTER (
        .clk(clk),
        .rst(rst),
        .i_tick(w_hour_tick | Btn_L),
        .o_time(hour),
        .o_tick()
    );


    tick_gen_100hz_w U_TICK_GEN_100HZ (
        .clk         (clk),
        .rst         (rst),
        .o_tick_100hz(w_tick_100hz)
    );
endmodule


module time_counter_w #(
    parameter BIT_WIDTH = 7,
    TIME_COUNT = 100
) (
    input clk,
    input rst,
    input i_tick,
    output [(BIT_WIDTH-1):0] o_time,
    output o_tick
);

    reg [$clog2(TIME_COUNT)-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign o_time = count_reg;
    assign o_tick = tick_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 1'b0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end


    always @(*) begin
        count_next = count_reg;
        tick_next  = tick_reg;  // 1'b0;
        if (i_tick) begin
            if (count_reg == TIME_COUNT - 1) begin
                count_next = 0;
                tick_next  = 1'b1;
            end else begin
                count_next = count_reg + 1;
                tick_next  = 1'b0;  // 상위 단위 증가 신호 발생
            end
        end else begin
            tick_next = 1'b0;
        end
    end
endmodule


module tick_gen_100hz_w (
    input  clk,
    input  rst,
    output o_tick_100hz
);

    parameter F_COUNT = 100_000_000 / 100;
    reg [$clog2(F_COUNT-1):0] r_counter;
    reg r_tick;

    assign o_tick_100hz = r_tick;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <= 0;
            r_tick    <= 1'b0;
        end else begin
            // run
            if (r_counter == F_COUNT - 1) begin
                r_counter <= 0;
                r_tick    <= 1'b1;
            end else begin
                r_counter <= r_counter + 1;
                r_tick    <= 1'b0;
            end
        end
    end
endmodule
