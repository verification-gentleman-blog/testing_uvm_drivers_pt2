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


class master_driver extends uvm_driver #(sequence_item);
  virtual vgm_axi_interface intf;
  event reset;


  virtual task run_phase(uvm_phase phase);
    forever begin
      fork
        get_and_drive();
        @(reset);
      join_any
      disable fork;
    end
  endtask


  virtual protected task get_and_drive();
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask


  virtual protected task drive();
    drive_write_addr_channel();
    drive_write_data_channel();
  endtask


  virtual protected task drive_write_addr_channel();
    intf.AWVALID <= 0;
    repeat (req.delay)
      @(posedge intf.ACLK);

    intf.AWID <= req.id;
    intf.AWADDR <= req.address;
    intf.AWLEN <= req.length;
    intf.AWVALID <= 1;

    @(posedge intf.ACLK iff intf.AWREADY);
    intf.AWVALID <= 0;
  endtask


  virtual protected task drive_write_data_channel();
    intf.WID <= req.id;

    foreach (req.transfers[i]) begin
      intf.WLAST <= (i == req.transfers.size() - 1);
      drive_write_transfer(req.transfers[i]);
    end
  endtask


  virtual protected task drive_write_transfer(transfer t);
    intf.WVALID <= 0;
    repeat (t.delay)
      @(posedge intf.ACLK);

    intf.WDATA <= t.data;
    intf.WVALID <= 1;

    @(posedge intf.ACLK iff intf.WREADY);
    intf.WVALID <= 0;
  endtask


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  `uvm_component_utils(vgm_axi::master_driver)
endclass
