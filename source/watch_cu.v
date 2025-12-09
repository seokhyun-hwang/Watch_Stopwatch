`timescale 1ns / 1ps

module watch_cu (
    input      clk,
    input      rst,
    input      i_hour,  // Btn_L
    input      i_min,   // Btn_U
    input      i_sec,   // Btn_R
    output reg o_hour,
    output reg o_min,
    output reg o_sec
);

    // 버튼 엣지 검출 (간단히 Rising Edge만 처리)
    reg btn_hour_d, btn_min_d, btn_sec_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_hour_d <= 0;
            btn_min_d  <= 0;
            btn_sec_d  <= 0;
            o_hour   <= 0;
            o_min    <= 0;
            o_sec    <= 0;
        end else begin
            btn_hour_d <= i_hour;
            btn_min_d <= i_min;
            btn_sec_d <= i_sec;

            // 버튼이 0→1로 변할 때 1클럭 펄스
            o_hour <= i_hour & ~btn_hour_d;
            o_min <= i_min & ~btn_min_d;
            o_sec <= i_sec & ~btn_sec_d;
        end
    end

endmodule
