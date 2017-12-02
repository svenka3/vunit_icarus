// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this file,
// You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2015-2016, Lars Asplund lars.anders.asplund@gmail.com

`define WATCHDOG(runtime) \
   initial begin \
      test_runner.watchdog(runtime); \
   end

// `define TEST_SUITE \
`define TEST_SUITE_FROM_PARAMETER(parameter_name) \
  parameter parameter_name = "default_test"; \
  import vunit_pkg::*; \
  initial \
    if (test_runner.setup(parameter_name)) \
      while (test_runner.loop())

`define TEST_SUITE `TEST_SUITE_FROM_PARAMETER(runner_cfg)

`define NESTED_TEST_SUITE `TEST_SUITE_FROM_PARAMETER(nested_runner_cfg)

`define TEST_CASE(test_name) if (test_runner.run(test_name))

`define TEST_SUITE_SETUP if (test_runner.is_test_suite_setup())
`define TEST_SUITE_CLEANUP if (test_runner.is_test_suite_cleanup())

`define TEST_CASE_SETUP if (test_runner.is_test_case_setup())
`define TEST_CASE_CLEANUP if (test_runner.is_test_case_cleanup())
`define CHECK_EQUAL(got,expected,msg=__none__) \
        assert ((got) === (expected)) else \
          begin \
             string __none__; \
             string got_str; \
             string expected_str; \
             string full_msg; \
             int index; \
             got_str = "";\
             expected_str ="";\
             $swrite(got_str, got); \
             $swrite(expected_str, expected); \
               for (int i=0; i<got_str.len(); i++) begin \
                  if (got_str[i] != " ") begin \
                     got_str = got_str.substr(i, got_str.len()-1); \
                     break; \
                  end \
               end \
               for (int i=0; i<expected_str.len(); i++) begin \
                  if (expected_str[i] != " ") begin \
                     expected_str = expected_str.substr(i, expected_str.len()-1); \
                     break; \
                  end \
               end \
             full_msg = {"CHECK_EQUAL failed! Got ",`"got`", "=",  got_str, " expected ", expected_str, ". ", msg}; \
             $error(full_msg); \
          end
