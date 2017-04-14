module testbench;

reg clk;
reg reset, en, sel, ready, error, fabint, pwrite;
reg x_dir_in, x_dir_out, y_dir_in, y_dir_out;
reg [31:0] x_counter_in, x_counter_out, y_counter_in, y_counter_out;
reg [3:0] statex1, statex2, statey1, statey2;
reg [31:0] pwdata, pwdata, paddr;

motor_mmio_handler mm0(
  clk,
  reset,
  sel,
  en,
  ready,
  error,
  pwrite,
  paddr,
  pwdata,
  prdata,
  x_counter_in,
  x_dir_in,
  y_counter_in,
  y_dir_in,
  x_counter_out,
  x_dir_out,
  y_counter_out,
  y_dir_out,
  fabint
);

motor_driver mx(
  clk,
  reset,
  fabint,
  x_counter_out,
  x_dir_out,
  statex1,
  statex2,
  x_counter_in,
  x_dir_in
);

motor_driver my(
  clk,
  reset,
  fabint,
  y_counter_out,
  y_dir_out,
  statey1,
  statey2,
  y_counter_in,
  y_dir_in
);

task print_stuff;
  $display("-----------");
  $display("INPUTS TO HANDLER");
  $display("-----------");
  $display("x_counter_in: %d", x_counter_in);
  $display("x_dir_in: %b", x_dir_in);
  $display("y_counter_in: %d", y_counter_in);
  $display("y_dir_in: %b", y_dir_in);
  $display("-----------");
  $display("-----------");
  $display("OUTPUTS OF HANDLER");
  $display("-----------");
  $display("x_counter_out: %d", x_counter_out);
  $display("x_dir_out: %b", x_dir_out);
  $display("y_counter_out: %d", y_counter_out);
  $display("y_dir_out: %b", y_dir_out);
  $display("fabint: %b", fabint);
  $display("-----------");
  $display("-----------");
  $display("INPUTS TO XDRIVER");
  $display("-----------");
  $display("counter_in: %d", x_counter_out);
  $display("dir_in: %b", x_dir_out);
  $display("-----------");
  $display("OUTPUTS OF XDRIVER");
  $display("-----------");
  $display("counter_out: %d", x_counter_in);
  $display("dir_out: %b", x_dir_in);
  $display("state: %b", statex1);
  $display("-----------");
  $display("-----------");
  $display("INPUTS TO YDRIVER");
  $display("-----------");
  $display("counter_in: %d", y_counter_out);
  $display("dir_in: %b", y_dir_out);
  $display("-----------");
  $display("OUTPUTS OF YDRIVER");
  $display("-----------");
  $display("counter_out: %d",y_counter_in);
  $display("dir_out: %b", y_dir_in);
  $display("state: %b", statey1);
  $display("-----------");
  $display("-----------");
  $display("-----------");
  $display("-----------");
  $display("-----------");
  $display("-----------");
  $display("-----------");
endtask


always begin
  #5
  clk = ~clk;
end

always @(posedge clk) begin
  print_stuff;
end


initial begin
  reset = 0;
  clk = 0;
  @(negedge clk);
  reset = 1;
    
  pwdata = 5;
  pwrite = 1;
  paddr = 1;
  en = 1;
  sel = 1;

  @(negedge clk);

  en = 0;
  sel = 0;
  print_stuff;
  
  repeat (100) begin
    @(posedge fabint);
    pwdata = pwdata+1;
    paddr = (paddr == 4) ? 1 : 4;
    en = 1;
    sel = 1;
    @(posedge clk);
    en = 0;
    sel = 0;
  end
  
  $finish;  
end


endmodule
