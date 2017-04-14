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
  
        input x_done,
        input y_done,

        output reg  [31:0] x_counter_out,
        output reg         x_dir_out,
        output reg  [31:0] y_counter_out,
        output reg         y_dir_out,

        output reg fabint
    );

    reg n_x_dir_out, n_y_dir_out;
    reg [31:0] n_x_counter_out, n_y_counter_out;
    reg start, x_done, y_done;
    
    wire writex, writey;

    assign PRDATA = 0;
    assign PSLVERR = 0;
    assign PREADY  = 1;
    
    assign writex = (PSEL & PENABLE & PWRITE & ~PADDR[2]);
    assign writey = (PSEL & PENABLE & PWRITE & PADDR[2]);
    
    always @* begin
       n_x_counter_out = x_counter_out;
       n_y_counter_out = y_counter_out;
       n_y_dir_out = y_dir_out;
       n_x_dir_out = x_dir_out;
       
       if (x_done && y_done)
       begin
          fabint = 1;
       end
       else begin
          fabint = 0;
       end
    end


    always @(posedge PCLK) begin
      if (!PRESERN) begin
        x_counter_out <= 0;
        y_counter_out <= 0;
        x_dir_out <= 1;
        y_dir_out <= 1;
        start <= 1;
        fabint <= 0;
      end else begin
        if (writex) begin
          x_counter_out <= (~PWDATA[31]) ? PWDATA : ~PWDATA + 1;    
          y_counter_out <= n_y_counter_out;
          x_dir_out <= ~PWDATA[31];
          y_dir_out <= n_y_dir_out;
          start <= 0;
          fabint <= n_fabint;
        end else if (writey) begin
          x_counter_out <= n_x_counter_out;
          y_counter_out <= (~PWDATA[31]) ? PWDATA : ~PWDATA + 1;
          x_dir_out <= n_x_dir_out;
          y_dir_out <= ~PWDATA[31];
          start <= 0;
          fabint <= n_fabint;
        end else begin
          x_counter_out <= n_x_counter_out;
          y_counter_out <= n_y_counter_out;
          x_dir_out <= n_x_dir_out;
          y_dir_out <= n_y_dir_out;
          fabint <= n_fabint;
        end
      end
    end

endmodule
