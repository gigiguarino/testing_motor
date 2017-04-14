# make          <- runs simv (after compiling simv if needed)
# make all      <- runs simv (after compiling simv if needed)
# make simv     <- compile simv if needed (but do not run)
# make syn      <- runs syn_simv (after synthesizing if needed then 
#                                 compiling synsimv if needed)
# make clean    <- remove files created during compilations (but not synthesis)
# make nuke     <- remove all files created during compilation and synthesis
#
# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be 
# similar to the information in those scripts but that seems hard to avoid.
#
#t

VCS = SW_VCS=2015.09 vcs -sverilog +vc +lint=PCWM +lint=TFIPC-L -Mupdate -line -full64
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

# For visual debugger
VISFLAGS = -lncurses


##############################################################
###################### FINAL MAKE ############################
##############################################################


all: simv
	./simv | tee program.out


SIMFILES  = motor_driver.v motor_mmio_handler.v

SYNFILES = motor_driver.vg

TESTBENCH = testbench.v

simv: $(SIMFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SIMFILES) -o simv

syn_simv: $(SYNFILES) $(TESTBENCH) 
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv

syn_dve: $(SYNFILES) $(TESTBENCH)
	$(VCS) +memcbk $(TESTBENCH) $(SYNFILES) $(LIB) -o dve -R -gui


syn: syn_simv
	./syn_simv | tee syn_program.out

motor_driver.vg: motor_driver.tcl
	dc_shell-t -f ./motor_driver.tcl | tee synth.out

clean:
	rm -rf simv simv.daidir csrc vcs.key program.out writeback.out debug.out
	rm -rf vis_simv vis_simv.daidir
	rm -rf dve*
	rm -rf syn_simv syn_simv.daidir syn_program.out
	rm -rf synsimv synsimv.daidir csrc vcdplus.vpd vcs.key synprog.out pipeline.out writeback.out vc_hdrs.h
	rm -rf simv* syn_simv*
	rm -f tempfile

nuke:	clean
	rm -f synth/*.vg synth/*.rep synth/*.pvl synth/*.syn synth/*.ddc synth/*.chk synth/command.log
	rm -f synth/*.out command.log synth/*.db synth/*.svf
	rm -rf synth/*.mr
