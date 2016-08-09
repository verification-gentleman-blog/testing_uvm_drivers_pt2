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


interface vgm_axi_interface(input bit ACLK, input bit ARESETn);
  logic [3:0] AWID;
  logic [31:0] AWADDR;
  logic [3:0] AWLEN;
  logic AWVALID;
  logic AWREADY;

  logic [3:0] WID;
  logic [31:0] WDATA;
  logic WLAST;
  logic WVALID;
  logic WREADY;

  logic [3:0] BID;
  logic [1:0] BRESP;
  logic BVALID;
  logic BREADY;
endinterface
