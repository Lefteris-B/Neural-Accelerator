module skid_buffer
(
    input clk,
    input rstn,
    input valid_in,               // Indicate new data is available for writing
    input [31:0] data_in,         // Data to be stored in the buffer
    output reg ready_out,         // Indicate buffer is ready for new data
    output reg valid_out,         // Indicate data is available for reading
    output reg [31:0] data_out    // Data to be read from the buffer
);

    // State enumeration
    typedef enum {
        EMPTY,
        ONE_FULL,
        TWO_FULL
    } buffer_state_t;

    buffer_state_t current_state, next_state;

    reg [31:0] slot1, slot2;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            current_state <= EMPTY;
        end else begin
            current_state <= next_state;
        end
    end

    always @(current_state or valid_in) begin
        case (current_state)
            EMPTY: begin
                ready_out = 1;
                valid_out = 0;
                if (valid_in) begin
                    slot1 = data_in;
                    next_state = ONE_FULL;
                end else begin
                    next_state = EMPTY;
                end
            end

            ONE_FULL: begin
                ready_out = 1;
                valid_out = 1;
                data_out = slot1;
                if (valid_in) begin
                    slot2 = data_in;
                    next_state = TWO_FULL;
                end else begin
                    next_state = ONE_FULL;
                end
            end

            TWO_FULL: begin
                ready_out = 0; // Not ready for new data
                valid_out = 1;
                data_out = slot1;
                if (!valid_in) begin
                    slot1 = slot2;
                    next_state = ONE_FULL;
                end else begin
                    next_state = TWO_FULL;
                end
            end

            default: begin
                ready_out = 0;
                valid_out = 0;
                next_state = EMPTY;
            end
        endcase
    end

endmodule
