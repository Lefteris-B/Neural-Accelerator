module matrix_vector_mul_top (
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i, 
    input [31:0] wbs_dat_i,  // Assuming 32-bit bus width for Wishbone
    input [31:0] wbs_adr_i,  // Assuming 32-bit address for Wishbone
    input clk, 
    input rstn,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    output wbs_rdy_o
);

    // Parameter definitions based on your requirements
    parameter Rows = ...;
    parameter Columns = ...;
    parameter Width = 8; // 8-bit signed numbers

    // Split the incoming data into Matrix x1 and Vector x2
    wire [(Rows*Columns*Width)-1:0] x1 = wbs_dat_i[(Rows*Columns*Width + Columns*Width)-1 : Columns*Width];
    wire [(Columns*Width)-1:0] x2 = wbs_dat_i[Columns*Width-1 : 0];

    // Outputs from the matrix-vector multiplication
    wire [Rows*Width-1:0] y;

    // Matrix-Vector Multiplication Block
    matrix_vector_mul_core mv_core (
        .clk(clk),
        .rstn(rstn),
        .cen(/* Clock enable logic */),
        .x1(x1),
        .x2(x2),
        .y(y)
    );

    // Wishbone slave interface
    wishbone_slave wb_slave (
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_stb_i(wbs_stb_i),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_adr_i(wbs_adr_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o),
        .wbs_rdy_o(wbs_rdy_o),
        // Additional connections to Matrix-Vector Mul core
    );

    // Skid buffer (you'd define the internal workings)
    skid_buffer sk_buffer (
        // Inputs/outputs as required
    );

endmodule
