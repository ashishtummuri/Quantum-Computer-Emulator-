
VERILOG_SRC=$(wildcard ../rtl/*.v) ../testbench/testbench.sv 
GOLDEN_SRC=$(wildcard ../golden_model/*.*v) ../testbench/testbench.sv 
DW_INST=$(shell egrep -oET 'DW[^ ]+' ../rtl/dut.v | sort --unique | column)
DW_SRC_PATH=/mnt/apps/public/COE/synopsys_apps/syn/T-2022.03-SP4/dw/sim_ver
DW_SRC=$(shell find /mnt/apps/public/COE/synopsys_apps/syn/T-2022.03-SP4/dw/sim_ver -name "DW_fp*.v" -printf "%p ")
EPSILON_MULT_TEST1=3.0
NUMBER_OF_TEST1=4
EPSILON_MULT_TEST2=3.0
NUMBER_OF_TEST2=8
EPSILON_MULT_TEST3=3.0
NUMBER_OF_TEST3=6
EPSILON_MULT_TEST4=3.0
NUMBER_OF_TEST4=7
EPSILON_MULT_TEST5=3.0
NUMBER_OF_TEST5=4
EPSILON_MULT_TEST6=3.0
NUMBER_OF_TEST6=4
TEST?=1

TIMEOUT=1000000000

ta:
	echo ${DW_SRC}

debug:
	${MAKE} build-dw build debug-test${TEST} 

grade-464:
	${MAKE} build-dw build eval-464-all

grade-564:
	${MAKE} build-dw build eval-564-all

golden: 
	${MAKE} build-golden eval-564


build-dw:
	/bin/bash -c "vlog ${DW_SRC}"	

build:
	/bin/bash -c "vlog +incdir+../testbench $(VERILOG_SRC)"	

build-golden:
	/bin/bash -c "vlog -sv +incdir+../testbench $(GOLDEN_SRC)"	

eval-464:
	rm -rf logs results 
	$(MAKE) eval-test1 eval-test2 
	mkdir results
	find ./ -name "RESULTS.log" -exec grep Finial {} \; >> results/finial_result.log 

eval-464-all:
	rm -rf logs results 
	$(MAKE) eval-test1 eval-test2 eval-test5
	mkdir results
	find ./ -name "RESULTS.log" -exec grep Finial {} \; >> results/finial_result.log 

eval-564:
	rm -rf logs results 
	$(MAKE) eval-test1 eval-test2 eval-test3 eval-test4
	mkdir results
	find ./ -name "RESULTS.log" -exec grep Finial {} \; >> results/finial_result.log 

eval-564-all:
	rm -rf logs results 
	$(MAKE) eval-test1 eval-test2 eval-test3 eval-test4 eval-test5 eval-test6
	mkdir results
	find ./ -name "RESULTS.log" -exec grep Finial {} \; >> results/finial_result.log 


eval-test1:
	mkdir -p logs logs/test1 
	/bin/bash -c "vsim -c -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST1} +epsilon_mult=${EPSILON_MULT_TEST1}  +input_dir=../inputs/input1 +output_dir=../inputs/output1 -do \"run -all\" | tee logs/test1/output.log " 
	grep -r "INFO" logs/test1/output.log > logs/test1/INFO.log
	grep -r "INFO" logs/test1/output.log | grep  Result > logs/test1/RESULTS.log

eval-test2:
	mkdir -p logs logs/test2 
	/bin/bash -c "vsim -c -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST2} +epsilon_mult=${EPSILON_MULT_TEST2}  +input_dir=../inputs/input2 +output_dir=../inputs/output2 -do \"run -all\" | tee logs/test2/output.log " 
	grep -r "INFO" logs/test2/output.log > logs/test2/INFO.log
	grep -r "INFO" logs/test2/output.log | grep  Result > logs/test2/RESULTS.log

eval-test3:
	mkdir -p logs logs/test3 
	/bin/bash -c "vsim -c -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST3} +epsilon_mult=${EPSILON_MULT_TEST3}  +input_dir=../inputs/input3 +output_dir=../inputs/output3 -do \"run -all\" | tee logs/test3/output.log " 
	grep -r "INFO" logs/test3/output.log > logs/test3/INFO.log
	grep -r "INFO" logs/test3/output.log | grep  Result > logs/test3/RESULTS.log

eval-test4:
	mkdir -p logs logs/test4 
	/bin/bash -c "vsim -c -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST4} +epsilon_mult=${EPSILON_MULT_TEST4}  +input_dir=../inputs/input4 +output_dir=../inputs/output4 -do \"run -all\" | tee logs/test4/output.log " 
	grep -r "INFO" logs/test4/output.log > logs/test4/INFO.log
	grep -r "INFO" logs/test4/output.log | grep  Result > logs/test4/RESULTS.log

eval-test5:
	mkdir -p logs logs/test5 
	/bin/bash -c "vsim -c -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST5} +epsilon_mult=${EPSILON_MULT_TEST5}  +input_dir=../inputs/input5 +output_dir=../inputs/output5 -do \"run -all\" | tee logs/test5/output.log " 
	grep -r "INFO" logs/test5/output.log > logs/test5/INFO.log
	grep -r "INFO" logs/test5/output.log | grep  Result > logs/test5/RESULTS.log

eval-test6:
	mkdir -p logs logs/test6 
	/bin/bash -c "vsim -c -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST6} +epsilon_mult=${EPSILON_MULT_TEST6}  +input_dir=../inputs/input6 +output_dir=../inputs/output6 -do \"run -all\" | tee logs/test6/output.log " 
	grep -r "INFO" logs/test6/output.log > logs/test6/INFO.log
	grep -r "INFO" logs/test6/output.log | grep  Result > logs/test6/RESULTS.log

debug-test1:
	/bin/bash -c "vsim  -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST1} +epsilon_mult=${EPSILON_MULT_TEST1}  +input_dir=../inputs/input1 +output_dir=../inputs/output1" 

debug-test2:
	/bin/bash -c "vsim  -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST2} +epsilon_mult=${EPSILON_MULT_TEST2}  +input_dir=../inputs/input2 +output_dir=../inputs/output2" 

debug-test3:
	/bin/bash -c "vsim  -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST3} +epsilon_mult=${EPSILON_MULT_TEST3}  +input_dir=../inputs/input3 +output_dir=../inputs/output3" 

debug-test4:
	/bin/bash -c "vsim  -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST4} +epsilon_mult=${EPSILON_MULT_TEST4}  +input_dir=../inputs/input4 +output_dir=../inputs/output4" 

debug-test5:
	/bin/bash -c "vsim  -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST5} +epsilon_mult=${EPSILON_MULT_TEST5}  +input_dir=../inputs/input5 +output_dir=../inputs/output5" 

debug-test6:
	/bin/bash -c "vsim -voptargs=+acc tb_top +TIMEOUT=${TIMEOUT} +num_of_testcases=${NUMBER_OF_TEST6} +epsilon_mult=${EPSILON_MULT_TEST6}  +input_dir=../inputs/input6 +output_dir=../inputs/output6" 

clean:
	rm -rf work logs results transcript
