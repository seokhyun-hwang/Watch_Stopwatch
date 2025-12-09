`timescale 1ns / 1ps

module stopwatch (
    input        clk,
    input        rst,
    input        Btn_L,
    input        Btn_R,
    input        Btn_U,
    input        sw0,
    input        sw1,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);

    wire [6:0] w_msec;
    wire [5:0] w_sec;
    wire [5:0] w_min;
    wire [4:0] w_hour;
    wire w_runstop, w_clear;

    wire w_btn_l, w_btn_r;
    wire w_watch_l, w_watch_r, w_watch_u;

    wire [6:0] w_wa_msec;
    wire [5:0] w_wa_sec;
    wire [5:0] w_wa_min;
    wire [4:0] w_wa_hour;
    wire [23:0] w_time_io;

    // stopwatch button debounce
    button_debounce U_BD_RUNSTOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_R),
        .o_btn(w_btn_r)
    );

    button_debounce U_BD_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_L),
        .o_btn(w_btn_l)
    );

    // watch button debounce
    button_debounce U_BD_R (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_R),
        .o_btn(w_watch_r)
    );

    button_debounce U_BD_L (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_L),
        .o_btn(w_watch_l)
    );

    button_debounce U_BD_U (
        .clk  (clk),
        .rst  (rst),
        .i_btn(Btn_U),
        .o_btn(w_watch_u)
    );

    stopwatch_dp U_SW_DP (
        .clk      (clk),
        .rst      (rst),
        .i_runstop(w_runstop),
        .i_clear  (w_clear),
        .msec     (w_msec),
        .sec      (w_sec),
        .min      (w_min),
        .hour     (w_hour)
    );

    stopwatch_cu U_SW_CU (
        .clk      (clk),
        .rst      (rst),
        .i_runstop(w_btn_r),
        .i_clear  (w_btn_l),
        .o_runstop(w_runstop),
        .o_clear  (w_clear)
    );


    watch_dp U_WATCH (
        .clk  (clk),
        .rst  (rst),
        .Btn_L(w_watch_l),
        .Btn_R(w_watch_r),
        .Btn_U(w_watch_u),
        .msec (w_wa_msec),
        .sec  (w_wa_sec),
        .min  (w_wa_min),
        .hour (w_wa_hour)
    );

    combiner u_COMBINER (
        .sel  (sw1),
        .i_w  ({w_hour, w_min, w_sec, w_msec}),
        .i_sw ({w_wa_hour, w_wa_min, w_wa_sec, w_wa_msec}),
        .o_tot(w_time_io)
    );


    fnd_controller U_FND_CNTL (
        .clk     (clk),
        .reset   (rst),
        .i_time  (w_time_io),
        .sw0     (sw0),
        .fnd_com (fnd_com),
        .fnd_data(fnd_data)
    );

endmodule
