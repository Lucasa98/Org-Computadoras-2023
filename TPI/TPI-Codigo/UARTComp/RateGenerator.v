module rate_gen(
    input wire clk, reset
    output wire tick,
    output wire [38:0]q
);
//conexoes//
reg [38:0] r_reg;
wire [38:0s] r_next;
//body
always @(posedge clk, posedge reset)
    if (reset)
        r_reg <= 0;
    else
        r_reg <= r_next;
// next-state logic
assign r_next = (r_reg==(M-1))? 0 : r_reg+1;
//output logic
assign q = r_reg;
assign tick = (r_reg == (M-1)) ? 1'b1 : 1'b0;
endmodule