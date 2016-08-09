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


typedef enum bit [3:0] { LENGTH_[1:16] } length_e;
typedef class transfer;



class sequence_item extends uvm_sequence_item;
  rand bit [3:0] id;
  rand bit [31:0] address;
  rand length_e length;
  rand transfer transfers[];

  rand int unsigned delay;


  constraint num_of_transfers {
    transfers.size() == length + 1;
  }

  constraint default_delay {
    delay inside { [0:10] };
  }


  function void pre_randomize();
    transfers = new[16] (transfers);
    foreach (transfers[i])
      if (transfers[i] == null)
        transfers[i] = transfer::type_id::create($sformatf("transfers[%0d]", i),
          null, get_full_name());
  endfunction


  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils_begin(vgm_axi::sequence_item)
    `uvm_field_int(id, UVM_ALL_ON)
    `uvm_field_int(address, UVM_ALL_ON)
    `uvm_field_enum(vgm_axi::length_e, length, UVM_ALL_ON)
    `uvm_field_array_object(transfers, UVM_ALL_ON)
    `uvm_field_int(delay, UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end
endclass



class transfer extends uvm_sequence_item;
  rand bit[31:0] data;

  rand int unsigned delay;


  constraint default_delay {
    delay inside { [0:10] };
  }


  function new(string name = get_type_name());
    super.new(name);
  endfunction

  `uvm_object_utils_begin(vgm_axi::transfer)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(delay, UVM_ALL_ON | UVM_DEC)
  `uvm_object_utils_end
endclass
