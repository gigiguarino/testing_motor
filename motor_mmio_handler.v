module motor_mmio_handler(

        /*** APB3 BUS INTERFACE ***/
        input              PCLK,    // clock
        input              PRESERN, // system reset
        input              PSEL,    // peripheral select
        input              PENABLE, // distinguishes access phase
        output wire        PREADY,  // peripheral ready signal
        output wire        PSLVERR, // error signal
        input              PWRITE,  // distinguishes read and write cycles
        input       [31:0] PADDR,   // I/O address
        input       [31:0] PWDATA,  // data from processor to I/O device (32 bits)
        output reg  [31:0] PRDATA,  // data to processor from I/O device (32-bits)

        input [31:0] x_counter_in,
        input        x_dir_in,
        input [31:0] y_counter_in,
        input        y_dir_in,

        output reg  [31:0] x_counter_out,
        output reg         x_dir_out,
        output reg  [31:0] y_counter_out,
        output reg         y_dir_out,

        output wire FABINT
    );

    reg n_x_dir_out, n_y_dir_out;
    reg [31:0] n_x_counter_out, n_y_counter_out;
    
    wire write;
    wire read;

    wire x_done;
    wire y_done;
    wire x_zero;
    wire y_zero;
    reg last_x_zero;
    reg last_y_zero;

    assign x_zero = (x_counter_in == 0);
    assign y_zero = (y_counter_in == 0);

    assign x_done = (x_zero & ~last_x_zero);
    assign y_done = (y_zero & ~last_y_zero);

    assign FABINT = x_done | y_done;

    assign PRDATA = 0;
    assign PSLVERR = 0;
    assign PREADY  = 1;
    
    assign writex = (PSEL & PENABLE & PWRITE & ~PADDR[2]);
    assign readx = (PSEL & PENABLE & ~PWRITE & ~PADDR[2]);
    assign writey = (PSEL & PENABLE & PWRITE & PADDR[2]);
    assign ready = (PSEL & PENABLE & ~PWRITE & PADDR[2]);

    always @* begin
       
    end


    always @(posedge PCLK) begin
      if (!PRESETN) begin
      end else begin
        
        if (writex) begin
          x_counter_out <=    
        else if (writey) begin
          x_counter_out <=
          y_counter_out <=
          x_dir_out <=
          y_dir_out <= 
        end else begin
          x_counter_out <= n_x_counter_out;
          y_counter_our <= n_y_counter_out;
          x_dir_out <= n_x_dir_out;
          y_dir_out <= n_y_dir_out;
        end
      end
      
    end


                    if(~PADDR[2]) begin
                        x_dir_out     <= ~PWDATA[31];
                        x_counter_out <= (~PWDATA[31])? PWDATA : ~PWDATA + 1;
                    end
                    else begin
                        y_dir_out     <= ~PWDATA[31];
                        y_counter_out <= (~PWDATA[31])? PWDATA : ~PWDATA + 1;
                else begin
                    if(~PADDR[2]) begin
                        PRDATA <= (x_dir_in)? x_counter_in : ~x_counter_in + 1;
                    end
                    else begin
                        PRDATA <= (y_dir_in)? y_counter_in : ~y_counter_in + 1;
endmodule
