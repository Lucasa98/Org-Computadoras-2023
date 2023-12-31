module Receiver2
#(
    parameter   DBIT = 8,
                SB_TICK = 16
)
(
    input wire clk,
    input wire rx, s_tick,
    output reg rx_done_tick,
    output wire [7:0] dout
);

//estados
localparam [1:0]
    idle = 2'b00,
    start = 2'b01,
    data = 2'b10,
    stop = 2'b11;

//seniales internas
reg [1:0] state_reg, state_next;
reg [3:0] s_reg,s_next;
reg [2:0] n_reg, n_next;
reg [7:0] b_reg, b_next;

initial
begin
    state_reg <= idle;
    s_reg <=0;
    n_reg <=0;
    b_reg <= 0;
end

// body
always @ (posedge clk)
begin
    state_reg <= state_next;
    s_reg <= s_next;
    n_reg <= n_next;
    b_reg <= b_next;
end

always @(*)
begin
    state_next = state_reg;
    rx_done_tick = 1'b0;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;

    case (state_reg)
    idle:
    begin
        if(~rx)
        begin
            state_next = start;
            s_next = 0;
        end
    end
    start:
    begin
        if (s_tick)
        begin
            if(s_reg==7)
                begin
                    state_next = data;
                    s_next = 0;
                    n_next = 0;
                end
            else
                s_next = s_reg+1;
        end
    end
    data:
    begin
        if(s_tick)
        begin
            if(s_reg==15)
                begin
                    s_next = 0;
                    b_next = {rx,b_reg[7:1]};
                    if(n_reg == (DBIT-1))
                        state_next = stop;
                    else
                        n_next = n_reg + 1;
                end
            else
                s_next = s_reg + 1;
        end
    end
    stop:
    begin
        if (s_tick)
        begin
            if (s_reg==(SB_TICK-1))
                begin
                    state_next = idle;
                    rx_done_tick =1'b1;
                end
            else
                s_next = s_reg + 1;
        end
    end
    endcase
end
// output
assign dout = b_reg;

endmodule