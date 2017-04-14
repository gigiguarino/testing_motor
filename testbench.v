module testbench;

reg clk;
reg reset, en, sel, ready, error, fabint, pwrite;
reg dir_in, dir_out, other_dir_in, other_dir_out;
reg [31:0] counter_in, counter_out, other_counter_in, other_counter_out;
reg [3:0] statex1, statex2;
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
  counter_in,
  dir_in,
  other_counter_in,
  other_dir_in,
  counter_out,
  dir_out,
  other_counter_out,
  other_dir_out,
  fabint
);

motor_driver m(
  clk,
  reset,
  counter_out,
  dir_out,
  statex1,
  statex2,
  counter_in,
  dir_in
);

always begin
  #5
  clk = ~clk;
end

task print_stuff;
  $display("-----------");
  $display("INPUTS");
  $display("-----------");
  $display("counter_in: %d", counter_out);
  $display("dir_in: %b", dir_out);
  $display("-----------");
  $display("OUTPUTS");
  $display("-----------");
  $display("counter_out: %d", counter_in);
  $display("dir_out: %b", dir_in);
  $display("state: %b", statex1);
  $display("-----------");
  $display("-----------");
  $display("-----------");
  $display("-----------");
endtask


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
    @(negedge clk);
    print_stuff;
  end
  
  $finish;  
end


endmodule
