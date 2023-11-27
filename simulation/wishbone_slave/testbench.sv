module tb_wishbone_slave;

    // Parameters
    parameter CLK_PERIOD = 10; // Clock period

    // Clock and Reset
    reg clk = 0;
    reg rstn = 1;

    // Wishbone signals
    reg wbs_cyc_i, wbs_stb_i, wbs_we_i;
    reg [3:0] wbs_sel_i;  // assuming a 32-bit bus
    reg [31:0] wbs_dat_i;
    reg [31:0] wbs_adr_i;
    wire wbs_ack_o;
    wire [31:0] wbs_dat_o;

    // Instantiate the wishbone_slave
    wishbone_slave u_wishbone_slave (
        .wb_clk_i(clk),
        .wb_rst_i(rstn),
        .wbs_cyc_i(wbs_cyc_i),
        .wbs_stb_i(wbs_stb_i),
        .wbs_we_i(wbs_we_i),
        .wbs_sel_i(wbs_sel_i),
        .wbs_dat_i(wbs_dat_i),
        .wbs_adr_i(wbs_adr_i),
        .wbs_ack_o(wbs_ack_o),
        .wbs_dat_o(wbs_dat_o)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk = ~clk;
initial begin $dumpfile("dump.vcd"); $dumpvars; end
    // Testbench sequence
    initial begin
        rstn = 0; wbs_cyc_i = 0; wbs_stb_i = 0; wbs_we_i = 0;
        wbs_dat_i = 0; wbs_adr_i = 0;
        #CLK_PERIOD;

        rstn = 1;
        #CLK_PERIOD;

        // Write operation
        wbs_cyc_i = 1;
        wbs_stb_i = 1;
        wbs_we_i = 1;  // Write enable
        wbs_adr_i = 32'h00000010;
        wbs_dat_i = 32'h12345678;
        #CLK_PERIOD;
        
        wbs_stb_i = 0;
        while (!wbs_ack_o) #CLK_PERIOD; // wait for acknowledgment
        wbs_cyc_i = 0;
      #(CLK_PERIOD*3);

        // Read operation
        wbs_cyc_i = 1;
        wbs_stb_i = 1;
        wbs_we_i = 0;  // Read enable
        wbs_adr_i = 32'h00000010;
        #CLK_PERIOD;

        wbs_stb_i = 0;
        while (!wbs_ack_o) #CLK_PERIOD; // wait for acknowledgment
        if (wbs_dat_o !== 32'h12345678) $display("Read Error!");

        // Finish
        $display("Testbench finished.");
        $finish;
    end

endmodule
