module matrix_vector_mul_core #(
    parameter ROWS=4,               
    parameter COLUMNS=4,           
    parameter WIDTH_ROWS=8,        
    parameter WIDTH_COLUMNS=8,
    parameter BIN_TREE_DEPTH = $clog2(COLUMNS)
) (
    input clk,
    input rstn,                       // Added reset signal
    input clk_enable,                 // Renamed 'cen' to 'clk_enable' for clarity
    input signed [ROWS*WIDTH_ROWS-1:0] x1, // Matrix
    input signed [COLUMNS*WIDTH_COLUMNS-1:0] x2, // Vector
    output reg signed [ROWS*WIDTH_ROWS-1:0] y // Resultant Vector
);

    // Calculate padding for columns
    localparam COLUMN_PADDING = 2 ** $clog2(COLUMNS);

    // Define a 3D array for binary addition tree
    reg signed [WIDTH_ROWS-1:0] tree[0:ROWS-1][0:BIN_TREE_DEPTH][0:COLUMN_PADDING-1];

    integer i, j, k;

     always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            y <= 0;
           end else if (clk_enable) begin
            // Multiplication logic
            for (i = 0; i < ROWS; i = i + 1) begin
                for (j = 0; j < COLUMNS; j = j + 1) begin
                    tree[i][0][j] = x1[i*WIDTH_ROWS + WIDTH_ROWS-1 -: WIDTH_ROWS] * 
                                    x2[j*WIDTH_COLUMNS + WIDTH_COLUMNS-1 -: WIDTH_COLUMNS];
                end
            end
            
            // Binary tree addition logic
            for (k = 1; k <= BIN_TREE_DEPTH; k = k + 1) begin
                for (i = 0; i < ROWS; i = i + 1) begin
                    for (j = 0; j < COLUMN_PADDING/(2**k); j = j + 1) begin
                        tree[i][k][j] = tree[i][k-1][2*j] + tree[i][k-1][2*j+1];
                    end
                end
            end

            // Assign output
            for (i = 0; i < ROWS; i = i + 1) begin
                y[i*WIDTH_ROWS + WIDTH_ROWS-1 -: WIDTH_ROWS] = tree[i][BIN_TREE_DEPTH][0];
            end
        end
    end

endmodule
