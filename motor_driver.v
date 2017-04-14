module motor_driver(
        input clk,
        input PRESERN,
        input fabint,
        input [31:0] counter_in,
        input dir_in,
        output reg [3:0] hb_state,
        output [3:0] hb_state_debug,
        output reg [31:0] counter,
        output reg dir,
        output done
    );
    reg [31:0] n_counter;
    reg n_dir;
    reg [3:0] n_hb_state;

    assign hb_state_debug = hb_state;

    // H-bridge control logic
    always @* begin
        n_counter = counter;
        n_hb_state = hb_state;
        n_dir = dir;

        if (done && fabint) begin
          n_counter = counter_in;
          n_dir = dir_in;
          done = 1'b0;
        end 

        if(~dir && ~done) begin // REVERSE
            done = 1'b0;
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
                    if(n_counter > 0) begin   // continue movement
                        n_hb_state = 4'b1010;
                    end
                    else begin
                        done = 1'b1;
                        n_hb_state = 4'b0000;
                    end
                end
                default: begin// 4'b0000 TODO IS THIS COAST? SHOULD IT BE BRAKE?
                    if(n_counter > 0) begin   // start movement
                        n_hb_state = 4'b1010;
                    end
                    else begin                // keep looking
                        done = 1'b1;
                        n_hb_state = 4'b0000;
                    end
                end
            endcase
        end

        else if (~done) begin // FORWARD
            done = 1'b0;
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
                    if(n_counter > 0) begin   // continue movement
                        n_hb_state = 4'b1001;
                    end
                    else begin                // end movement
                        done = 1'b1;
                        n_hb_state = 4'b0000;
                    end
                end
                default: begin// 4'b0000 TODO IS THIS COAST? SHOULD IT BE BRAKE?
                    if(n_counter > 0) begin   // start movement
                        n_hb_state = 4'b1001;
                    end else begin
                        done = 1'b1;
                        n_hb_state = 4'b0000;
                    end
                end
            endcase
        end

        else begin
            done = 1'b0;
        end
    end

    always @(posedge clk) begin
        if(!PRESERN) begin
            dir       <= 1'b1;
            counter   <= 32'b0;
            hb_state  <= 4'b0000;
        end else begin
            dir      <= n_dir;
            counter  <= n_counter;
            hb_state <= n_hb_state;
        end
    end
endmodule
