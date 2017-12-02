// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2015-2016, Lars Asplund lars.anders.asplund@gmail.com

// Small clean-up done by Srini VerifWorks
// Moved typedef to outside class
// Removed extra ; after endfuntion/endtask at few places
//   -- This caused icarus to choke
// Added end-labels for functions and task
// TBD:
//   1. make API extern and separate implementation
//   2. dd labels to begin..end 
//   3. Run in ICARUS
//
//

`define VW_VUNIT_IN_IVLOG
// A string that can carry 256 characters in Verilog style
// `define VW_STRING reg [256*8 - 1 : 0] 
`define VW_STRING string

`include "vw_ivlog_vunit_defines.svh"

package vunit_pkg;

  typedef enum {idle,
                init,
                test_suite_setup,
                test_case_setup,
                test_case,
                test_case_cleanup,
                test_suite_cleanup}
         phase_t;
 
  parameter VW_MAX_NUM_TESTS = 10;

endpackage : vunit_pkg


module test_runner;
  import vunit_pkg::*;
  parameter VW_MAX_NUM_TESTS = 10;

  int tc_cnt_i;
  int tc_cnt_j;

  function automatic int vw_get_string_array_size();
    int arr_size = 0;
    // Walk on this array test_cases_to_run
    foreach (test_cases_to_run[i]) begin : incr_size
      arr_size++;
    end : incr_size
    return arr_size;
  endfunction : vw_get_string_array_size

    phase_t phase;
    `VW_STRING       test_cases_found[VW_MAX_NUM_TESTS];
    `VW_STRING       test_cases_to_run[VW_MAX_NUM_TESTS];
    `VW_STRING       output_path;
    int          test_idx = 0;
    int          exit_without_errors = 0;
    int          exit_simulation = 0;
    int          trace_fd;
 

    initial begin : init_1
	phase = idle;
	$display ("Hello world! Vunit is now live on Icarus!!");
    end : init_1
    function int is_test_case_setup();
       return phase == test_case_setup;
    endfunction : is_test_case_setup
 
    function int is_test_case_cleanup();
       return phase == test_case_cleanup;
    endfunction : is_test_case_cleanup
 
    function int is_test_suite_setup();
       return phase == test_suite_setup;
    endfunction : is_test_suite_setup
 
    function int is_test_suite_cleanup();
       return phase == test_suite_cleanup;
    endfunction : is_test_suite_cleanup


  function automatic string search_replace(
    string original, string old, string replacement);
  `ifdef VW_VUNIT_IN_IVLOG
    replacement = original;
    return original;
    `endif // VW_VUNIT_IN_IVLOG

  `ifndef VW_VUNIT_IN_IVLOG
       // First find the index of the old string
       int 	start_index = 0;
       int 	original_index = 0;
       int 	replace_index = 0;
       bit 	found = 0;
       bit      break_cond = 0;
 
       while(!break_cond) begin
 	 if (original[original_index] == old[replace_index]) begin
             if (replace_index == 0) begin
                start_index = original_index;
             end
             replace_index++;
             original_index++;
             if (replace_index == old.len()) begin
                found = 1;
                break_cond = 1;
             end
 	 end else if (replace_index != 0) begin
             replace_index = 0;
             original_index = start_index + 1;
 	 end else begin
             original_index++;
 	 end
 	 if (original_index == original.len()) begin
             // Not found
             break_cond = 1;
 	 end
       end
 
       if (!found) return original;
 
       return {
 	      original.substr(0, start_index-1),
 	      replacement,
 	      original.substr(start_index+old.len(), original.len()-1)
 	      };
 
    `endif // VW_VUNIT_IN_IVLOG
    endfunction : search_replace
 
    function int setup(string runner_cfg);
/*
       // Ugly hack pending actual dictionary parsing
       string    prefix;
       int       index;
 
       prefix = "enabled_test_cases : ";
       index = -1;
       for (int i=0; i<runner_cfg.len(); i++) begin
 	 if (runner_cfg.substr(i, i+prefix.len()-1) == prefix) begin
 	    index = i + prefix.len();
 	    break_cond = 1;
 	 end
       end
 
       if (index == -1) begin
 	 $error("Internal error: Cannot find 'enabled_test_cases' key");
       end
 
       for (int i=index; i<runner_cfg.len(); i++) begin
 	 if (i == runner_cfg.len()-1) begin
             test_cases_to_run.push_back(runner_cfg.substr(index, i));
 	 end
          else if (runner_cfg[i] == ",") begin
             test_cases_to_run.push_back(runner_cfg.substr(index, i-1));
             index = i+2;
             i++;
             if (runner_cfg[i] != ",") begin
                break_cond = 1;
             end
          end
       end
 
       prefix = "output path : ";
       index = -1;
       for (int i=0; i<runner_cfg.len(); i++) begin
 	 if (runner_cfg.substr(i, i+prefix.len()-1) == prefix) begin
 	    index = i + prefix.len();
 	    break_cond = 1;
 	 end
       end
 
       if (index == -1) begin
 	 $error("Internal error: Cannot find 'output path' key");
       end
 
       for (int i=index; i<runner_cfg.len(); i++) begin
 	 if (i == runner_cfg.len()-1) begin
             output_path = runner_cfg.substr(index, i);
             break_cond = 1;
 	 end
          else if (runner_cfg[i] == ",") begin
             i++;
             if (runner_cfg[i] != ",") begin
                output_path = runner_cfg.substr(index, i-2);
                break_cond = 1;
             end
          end
       end
       output_path = search_replace(output_path, "::", ":");
 
       phase = idle;
       test_idx = 0;
       exit_without_errors = 0;
       exit_simulation = 0;
 
       trace_fd = $fopen({output_path, "vunit_results"}, "w");
       return 1;
*/
    endfunction : setup

    // function void cleanup();
    task cleanup;
       exit_without_errors = 1;
       exit_simulation = 1;
       $stop(0);
    endtask : cleanup
 
    function int loop();
	    bit found = 0;
       int       exit_without_errors;
 
       if (phase == init) begin : init_phase
          if (test_cases_to_run[0] == "__all__") begin : run_all_tests
               test_cases_to_run[0] = test_cases_found[0];
               test_cases_to_run[1] = test_cases_found[1];
             // foreach (test_cases_found [j]) begin : fe_copy
	     for (tc_cnt_i = 0; tc_cnt_i < VW_MAX_NUM_TESTS; tc_cnt_i++) begin : fe_copy
               test_cases_to_run[tc_cnt_i] = test_cases_found[tc_cnt_i];
	     end : fe_copy
          end : run_all_tests
	  else begin : not_all_tests_run
             // foreach (test_cases_to_run[j]) begin : fe_1
	     for (tc_cnt_i = 0; tc_cnt_i < VW_MAX_NUM_TESTS; tc_cnt_i++) begin : fe_1
                found = 0;
                // foreach (test_cases_found[i]) begin : fe_2
	        for (tc_cnt_j = 0; tc_cnt_j < VW_MAX_NUM_TESTS; tc_cnt_j++) begin : fe_2
                   if (test_cases_found[tc_cnt_i] == test_cases_to_run[tc_cnt_j]) begin
                      found = 1;
                   end
                end: fe_2
                if (!found) begin : no_tests
                   $error("Found no \"%s\" test case", test_cases_to_run[tc_cnt_i]);
                   cleanup();
                   return 0;
                end : no_tests
             end : fe_1
          end : not_all_tests_run
       end : init_phase
       if (phase == test_case_cleanup) begin : cleanup_phase
          test_idx++;
          // if (test_idx < test_cases_to_run.size()) begin
          if (test_idx < vw_get_string_array_size()) begin
             phase = test_case_setup;
          end else begin
             phase = test_suite_cleanup;
          end
       end  : cleanup_phase
       else if (phase == test_suite_cleanup) begin : suite_cleanup_phase
          $fwrite(trace_fd, "test_suite_done\n");
          cleanup();
          return 0;
       end : suite_cleanup_phase 
       else begin : goto_next_phase
          // phase = phase_t'(phase + 1);
          phase++;
       end : goto_next_phase
       return 1;
  endfunction : loop

  function int run(string test_name);
       if (phase == init) begin
          // VW Fix this later
	  test_cases_found[0] = test_name;
          return 0;
       end else if (phase == test_case && test_name == test_cases_to_run[test_idx]) begin
          $fwrite(trace_fd, "test_start:%s\n", test_name);
          return 1;
       end else begin
          return 0;
       end
  endfunction : run
 
 
  task automatic watchdog(realtime timeout);
       fork : wait_or_timeout
          begin
             #timeout;
             $error("Timeout waiting finish after %.3f ns", timeout / 1ns);
             disable wait_or_timeout;
          end
          begin
             @(posedge exit_without_errors);
             disable wait_or_timeout;
          end
       join
  endtask : watchdog
 
 

endmodule : test_runner


