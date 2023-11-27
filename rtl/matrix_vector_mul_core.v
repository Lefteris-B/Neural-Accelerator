module matrix_vector_mul_core
(
    input clk,
    input rstn,
    input cen,
    input signed [(Rows*Columns*Width)-1:0] x1,
    input signed [(Columns*Width)-1:0] x2,
    output signed [Rows*Width-1:0] y
);

    // Parameters
    parameter Rows = ...; // Placeholder value
    parameter Columns = ...; // Placeholder value
    parameter Width = 8; // 8-bit signed numbers

    // Calculate bin_tree_depth
    localparam bin_tree_depth = $clog2(Columns);

    // Calculate Collumn_padding
    localparam Collumn_padding = 1 << bin_tree_depth;

    // 3D array for binary addition tree
    reg signed [Rows-1:0][bin_tree_depth:0][Collumn_padding-1:0] tree;

    // Temporary variables for multiplication
    reg signed [Rows*Width-1:0] temp_mul;

    // Populate first layer of tree (multiplication results)
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            temp_mul <= 0;
        else if (cen) begin
            for (int i = 0; i < Rows; i = i + 1) begin
                for (int j = 0; j < Columns; j = j + 1) begin
                    tree[i][0][j] <= x1[i*Width + j] * x2[j];
                end
            end
        end
    end

    // Binary tree addition for summing up multiplication results
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < Rows; i = i + 1)
                for (int d = 0; d <= bin_tree_depth; d = d + 1)
                    for (int j = 0; j < Collumn_padding/(2**d); j = j + 1)
                        tree[i][d][j] <= 0;
        end
        else if (cen) begin
            for (int i = 0; i < Rows; i = i + 1) begin
                for (int d = 1; d <= bin_tree_depth; d = d + 1) begin
                    for (int j = 0; j < Collumn_padding/(2**d); j = j + 1) begin
                        tree[i][d][j] <= tree[i][d-1][2*j] + tree[i][d-1][2*j+1];
                    end
                end
            end
        end
    end

    // Assign output values
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < Rows; i = i + 1) begin
                y[i*Width + Width - 1:i*Width] <= 0;
            end
        end
        else if (cen) begin
            for (int i = 0; i < Rows; i = i + 1) begin
                y[i*Width + Width - 1:i*Width] <= tree[i][bin_tree_depth][0];
            end
        end
    end

endmodule
