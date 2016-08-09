// Copyright 2016 Tudor Timisescu (verificationgentleman.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.



`include "svunit_uvm_mock_pkg.sv"


module master_driver_unit_test;
  import svunit_pkg::svunit_testcase;
  import svunit_uvm_mock_pkg::*;
  `include "svunit_defines.svh"

  import vgm_svunit_utils::*;

  string name = "master_driver_ut";
  svunit_testcase svunit_ut;

  import vgm_axi::*;
  import uvm_pkg::*;

  master_driver driver;


  sequencer_stub #(sequence_item) sequencer;

  bit rst = 1;
  bit clk;
  always #1 clk = ~clk;

  vgm_axi_interface intf(rst, clk);


  function void build();
    svunit_ut = new(name);

    driver = new("driver", null);
    sequencer = new("sequencer", null);
    driver.seq_item_port.connect(sequencer.seq_item_export);
    driver.intf = intf;

    svunit_deactivate_uvm_component(driver);
  endfunction


  task setup();
    svunit_ut.setup();
    reset_signals();
    svunit_activate_uvm_component(driver);
    svunit_uvm_test_start();
  endtask


  task teardown();
    svunit_ut.teardown();
    svunit_uvm_test_finish();
    svunit_deactivate_uvm_component(driver);
  endtask



  `SVUNIT_TESTS_BEGIN

    `SVTEST(debug)
      `FAIL_IF(1)
    `SVTEST_END

  `SVUNIT_TESTS_END


  task reset_signals();
    intf.AWID = 'x;
    intf.AWADDR = 'x;
    intf.AWLEN = 'x;
    intf.AWVALID = 'x;
    intf.AWREADY = 1;

    intf.WID = 'x;
    intf.WDATA = 'x;
    intf.WLAST = 'x;
    intf.WVALID = 'x;
    intf.WREADY = 1;

    intf.BID = 0;;
    intf.BRESP = 0;
    intf.BVALID = 0;
    intf.BREADY = 'x;
  endtask

endmodule
