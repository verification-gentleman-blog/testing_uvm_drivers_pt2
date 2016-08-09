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

  vgm_axi_interface intf(clk, rst);

  default clocking @(posedge clk);
  endclocking


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
    -> driver.reset;
    sequencer.flush();
  endtask


  `define add_item_with(CONSTRAINTS) \
    sequence_item item = new("item"); \
    `FAIL_UNLESS(item.randomize() with { \
      soft delay == 0; \
      foreach (transfers[i]) \
        soft transfers[i].delay == 0; \
      \
      if (1) \
        CONSTRAINTS \
      \
    }) \
    sequencer.add_item(item); \



  `SVUNIT_TESTS_BEGIN

    `SVTEST(drive_awvalid__with_delay)
      `add_item_with({
        delay == 3;
      })

      repeat (3)
        ##1 `FAIL_UNLESS(intf.AWVALID === 0)
      ##1 `FAIL_UNLESS(intf.AWVALID === 1)
    `SVTEST_END


    `SVTEST(drive_awvalid__held_until_hready)
      `add_item_with({
        delay == 0;
      })
      intf.AWREADY <= 0;

      repeat (4)
        ##1 `FAIL_UNLESS(intf.AWVALID === 1)

      intf.AWREADY <= 1;
      ##1 `FAIL_UNLESS(intf.AWVALID === 1)
      ##1 `FAIL_UNLESS(intf.AWVALID === 0)
    `SVTEST_END


    `SVTEST(drive_write_addr_channel)
      `add_item_with({
        id == 5;
        address == 'h1122_3344;
        length == LENGTH_14;
      })

      // Test bug:
      // Wrong usage of '==' instead of '===' causes the test to always pass.
      // If you're doing TDD you should notice this, but not if you're unit
      // testing after the fact.
      ##1;
      `FAIL_UNLESS(intf.AWID == 5)
      `FAIL_UNLESS(intf.AWADDR == 'h1122_3344)
      `FAIL_UNLESS(intf.AWLEN == 'b1101)
    `SVTEST_END


    `SVTEST(drive_wvalid__with_delay)
      `add_item_with({
        length == LENGTH_4;
        transfers[0].delay == 1;
        transfers[1].delay == 3;
        transfers[2].delay == 2;
        transfers[3].delay == 0;
      })

      // Skip over address phase
      ##1;

      ##1 `FAIL_UNLESS(intf.WVALID === 0)
      ##1 `FAIL_UNLESS(intf.WVALID === 1)

      repeat (3)
        ##1 `FAIL_UNLESS(intf.WVALID === 0)
      ##1 `FAIL_UNLESS(intf.WVALID === 1)

      repeat (2)
        ##1 `FAIL_UNLESS(intf.WVALID === 0)
      ##1 `FAIL_UNLESS(intf.WVALID === 1)

      ##1 `FAIL_UNLESS(intf.WVALID === 1)
    `SVTEST_END


    `SVTEST(drive_write_data_channel)
      `add_item_with({
        length == LENGTH_4;
        transfers[0].data == 'hffff_ffff;
        transfers[1].data == 'h0000_0000;
        transfers[2].data == 'haaaa_aaaa;
        transfers[3].data == 'h5555_5555;
      })

      // Skip over address phase
      ##1;

      ##1 `FAIL_UNLESS(intf.WDATA === 'hffff_ffff)
      ##1 `FAIL_UNLESS(intf.WDATA === 'h0000_0000)
      ##1 `FAIL_UNLESS(intf.WDATA === 'haaaa_aaaa)
      ##1 `FAIL_UNLESS(intf.WDATA === 'h5555_5555)
    `SVTEST_END


    `SVTEST(drive_write_data_channel__data_held_until_wready)
      `add_item_with({
        length == LENGTH_4;
        transfers[0].data == 'hffff_ffff;
        transfers[1].data == 'h0000_0000;
        transfers[2].data == 'haaaa_aaaa;
        transfers[3].data == 'h5555_5555;
      })

      // Skip over address phase
      ##1;

      intf.WREADY <= 0;
      repeat (3)
        ##1 `FAIL_UNLESS(intf.WDATA === 'hffff_ffff)
      intf.WREADY <= 1;
      ##1 `FAIL_UNLESS(intf.WDATA === 'hffff_ffff)

      intf.WREADY <= 0;
      ##1 `FAIL_UNLESS(intf.WDATA === 'h0000_0000)
      intf.WREADY <= 1;
      ##1 `FAIL_UNLESS(intf.WDATA === 'h0000_0000)

      intf.WREADY <= 0;
      repeat (2)
        ##1 `FAIL_UNLESS(intf.WDATA === 'haaaa_aaaa)
      intf.WREADY <= 1;
      ##1 `FAIL_UNLESS(intf.WDATA === 'haaaa_aaaa)

      intf.WREADY <= 0;
      repeat (4)
        ##1 `FAIL_UNLESS(intf.WDATA === 'h5555_5555)
      intf.WREADY <= 1;
      ##1 `FAIL_UNLESS(intf.WDATA === 'h5555_5555)
    `SVTEST_END


    `SVTEST(drive_write_data_channel__wlast_driven_for_last_transfer)
      `add_item_with({
        length == LENGTH_8;
      })

      // Skip over address phase
      ##1;

      // Test bug:
      // Even when not using the '==' uperator, the macros convert expression
      // to 'bit'.
      repeat (7)
        ##1 `FAIL_IF(intf.WLAST)
      ##1 `FAIL_UNLESS(intf.WLAST)
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


  `undef add_item_with
endmodule
