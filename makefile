build:
	ghdl -a --workdir=work --work=work src/external_controller/score_calc.vhd	
	ghdl -a --workdir=work --work=work src/utils/custom_types.vhd	
	ghdl -a --workdir=work --work=work src/external_controller/single_call_catcher.vhd	
	ghdl -a --workdir=work --work=work src/external_controller/call_catcher.vhd	
	ghdl -a --workdir=work --work=work src/external_controller/call_dispatcher.vhd	
	ghdl -a --workdir=work --work=work src/external_controller/scheduler.vhd	
	ghdl -a --workdir=work --work=work src/external_controller/scheduler.vhd	
	ghdl -a --workdir=work --work=work src/internal_controller/elevator/door.vhd	
	ghdl -a -fsynopsys --workdir=work --work=work src/internal_controller/elevator/move_counter.vhd	
	ghdl -a --workdir=work --work=work src/internal_controller/elevator/simple_elevator.vhd	
	ghdl -a --workdir=work --work=work src/internal_controller/at_destination_calculator.vhd
	ghdl -a --workdir=work --work=work src/internal_controller/next_floor_calculator.vhd
	ghdl -a -fsynopsys --workdir=work --work=work src/internal_controller/in_controller.vhd
	ghdl -a -fsynopsys --workdir=work --work=work src/top.vhd
	ghdl -a --workdir=work --work=work testing/tb_top.vhd
	ghdl -e --workdir=work --work=work tb_top
	ghdl -r --workdir=work --work=work tb_top --vcd=tb_top.vcd
