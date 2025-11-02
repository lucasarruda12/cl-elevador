WORK_DIR = work

build:
	@mkdir -p $(WORK_DIR)
	ghdl -a --workdir=$(WORK_DIR) --work=work src/external_controller/score_calc.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/utils/custom_types.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/external_controller/single_call_catcher.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/external_controller/call_catcher.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/external_controller/call_dispatcher.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/external_controller/scheduler.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/elevator/move_counter.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/elevator/door.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/elevator/simple_elevator.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/next_floor_calculator.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/at_destination_calculator.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/call_manager.vhd
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/in_controller.vhd
	ghdl -a -fsynopsys --workdir=$(WORK_DIR) --work=work src/top.vhd

# Testes
test_simple: build
	@echo "Executando teste simples..."
	ghdl -a --workdir=$(WORK_DIR) --work=work testing/tb_simple.vhd
	ghdl -e --workdir=$(WORK_DIR) --work=work tb_simple
	ghdl -r --workdir=$(WORK_DIR) --work=work tb_simple --vcd=tb_simple.vcd

test_concurrent: build
	@echo "Executando teste concorrente..."
	ghdl -a --workdir=$(WORK_DIR) --work=work testing/tb_concurrent.vhd
	ghdl -e --workdir=$(WORK_DIR) --work=work tb_concurrent
	ghdl -r --workdir=$(WORK_DIR) --work=work tb_concurrent --vcd=tb_concurrent.vcd

test_in_controller: build
	@echo "Executando teste para controlador interno..."
	ghdl -a --workdir=$(WORK_DIR) --work=work src/internal_controller/testbenchs/in_controller_tb.vhd
	ghdl -e --workdir=$(WORK_DIR) --work=work in_controller_tb
	ghdl -r --workdir=$(WORK_DIR) --work=work in_controller_tb --vcd=tb_concurrent.vcd

# Limpeza 
clean:
	rm -rf $(WORK_DIR)
	rm -f *.vcd
	rm -f tb_simple tb_concurrent

# Ajuda
help:
	@echo "Targets disponíveis:"
	@echo "  build              - Compila todos os arquivos VHDL"
	@echo "  test_simple        - Executa teste simples"
	@echo "  test_concurrent    - Executa teste concorrente"
	@echo "  test_in_controller - Executa teste do controlador interno"
	@echo "  clean              - Remove arquivos gerados"
	@echo "  help               - Mostra esta ajuda"

.PHONY: build test_simple test_concurrent clean help
