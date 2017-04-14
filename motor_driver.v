module motor_driver(
        input clk,
        input PRESERN,
        input [31:0] counter_in,
        input dir_in,
        output reg [3:0] hb_state,
        output [3:0] hb_state_debug,
        output reg [31:0] counter,
        output reg dir
    );
    reg [31:0] n_counter;
    reg n_dir, change;
    reg [3:0] n_hb_state;

    assign hb_state_debug = hb_state;

    // H-bridge control logic
    always @* begin
        n_counter = counter;
        n_hb_state = hb_state;
        n_dir = dir;
        change = 0;

        if(!dir) begin // REVERSE

            case(hb_state)
                4'b1010: begin
                    n_hb_state = 4'b0110;
                end
                4'b0110: begin
                    n_hb_state = 4'b0101;
                end
                4'b0101: begin
                    n_hb_state = 4'b1001;
                end
                4'b1001: begin
                    n_counter = counter - 1;
                    if(counter > 0) begin   // continue movement
                        n_hb_state = 4'b1010;
                    end
                    else begin
                        change = 1'b1;
                    end
                end
                default: begin// 4'b0000 TODO IS THIS COAST? SHOULD IT BE BRAKE?
                    if(counter > 0) begin   // start movement
                        n_hb_state = 4'b1010;
                    end
                    else begin                // keep looking
                        change = 1'b1;
                    end
                end
            endcase

        end
        else begin // FORWARD

            case(hb_state)
                4'b1001: begin
                    n_hb_state = 4'b0101;
                end
                4'b0101: begin
                    n_hb_state = 4'b0110;
                end
                4'b0110: begin
                    n_hb_state = 4'b1010;
                end
                4'b1010: begin
                    n_counter = counter - 1;
                    if(counter > 0) begin   // continue movement
                        n_hb_state = 4'b1001;
                    end
                    else begin                // end movement
                        change = 1'b1;
                    end
                end
                default: begin// 4'b0000 TODO IS THIS COAST? SHOULD IT BE BRAKE?
                    if(counter > 0) begin   // start movement
                        n_hb_state = 4'b1001;
                    end
                    else begin                // keep looking
                        change = 1'b1;
                    end
                end
            endcase

        end
    end

    always @(posedge clk) begin
        if(!PRESERN) begin
            dir       <= 1'b1;
            counter   <= 32'b0;
            hb_state  <= 4'b0000;
        end
        else if (change) begin
            if (dir_in) begin
              dir <= dir_in;
              counter <= counter_in;
              hb_state <= 4'b1010;
            end else begin
              dir <= dir_in;
              counter <= counter_in;
              hb_state <= 4'b1001;
            end
        end
        else begin
            dir      <= n_dir;
            counter  <= n_counter;
            hb_state <= n_hb_state;
        end
    end
endmodule
