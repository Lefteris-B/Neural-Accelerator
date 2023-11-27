module tb_skid_buffer;

    // Parameters
    parameter CLK_PERIOD = 10; // 10ns clock period, adjust as needed

    // Signals
    reg clk = 0;
    reg rstn = 0;
    reg valid_in;
    reg [31:0] data_in;
    wire ready_out;
    wire valid_out;
    wire [31:0] data_out;

    // Instance of skid_buffer
    skid_buffer UUT (
        .clk(clk),
        .rstn(rstn),
        .valid_in(valid_in),
        .data_in(data_in),
        .ready_out(ready_out),
        .valid_out(valid_out),
        .data_out(data_out)
    );

    // Clock generation
    always # (CLK_PERIOD/2) clk = ~clk;
  
initial begin 
  $dumpfile("dump.vcd");
  $dumpvars;
end
  
    // Test procedure
    initial begin
        // Reset the design
        rstn = 0;
        valid_in = 0;
        data_in = 0;
        # (CLK_PERIOD * 2); 

        // Release reset
        rstn = 1;
        # (CLK_PERIOD);

        // Test case 1: Write one value and read it
        valid_in = 1;
        data_in = 32'd10;  // Sample data
        # (CLK_PERIOD);
        valid_in = 0;
        # (CLK_PERIOD);
        if (valid_out && data_out == 32'd10) begin
            $display("Test 1 Passed");
        end else begin
            $display("Test 1 Failed");
        end

        // Test case 2: Write two values sequentially without reading
        valid_in = 1;
        data_in = 32'd20;
        # (CLK_PERIOD);
        data_in = 32'd30;
        # (CLK_PERIOD);
        valid_in = 0;
        # (CLK_PERIOD * 3); // Extra delay to ensure both writes were processed
        if (valid_out && data_out == 32'd20) begin
            $display("Test 2 Step 1 Passed");
        end else begin
            $display("Test 2 Step 1 Failed");
        end
        # (CLK_PERIOD * 3);
        if (valid_out && data_out == 32'd30) begin
            $display("Test 2 Step 2 Passed");
        end else begin
            $display("Test 2 Step 2 Failed");
        end

        // Test case 3: Check ready signal when buffer is full
        valid_in = 1;
        data_in = 32'd40;
        # (CLK_PERIOD);
        data_in = 32'd50;
        # (CLK_PERIOD);
        if (!ready_out) begin
            $display("Test 3 Passed");
        end else begin
            $display("Test 3 Failed");
        end

        // End of the test
        $finish;
    end

endmodule
