`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:55:55 05/03/2016 
// Design Name: 
// Module Name:    PicoBlaze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PicoBlaze(
input clk,
input [7:0] Switch_port,
output [7:0] an,
output reg [7:0] dis_port
    );
//control display
assign an=8'b11111110;

// Señales

wire	[11:0]	address;
wire	[17:0]	instruction;
wire			bram_enable;
wire	[7:0]		port_id;
wire	[7:0]		out_port;
reg	[7:0]		in_port;
wire			write_strobe;
wire			k_write_strobe;
wire			read_strobe;
wire			interrupt;            //See note above
wire			interrupt_ack;
wire			kcpsm6_sleep;         //See note above
wire			kcpsm6_reset;         //See note above


wire			rdl;


// PicoBlaze

 kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))
  processor (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe 	(k_write_strobe),
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk)); 
	
  assign kcpsm6_sleep = 1'b0;
  assign interrupt = 1'b0;

// Memoria de datos
display #(
	.C_FAMILY		   ("7S"),   	//Family 'S6' or 'V6' or 7S series-7
	.C_RAM_SIZE_KWORDS	(1),  	//Program size '1', '2' or '4'
	.C_JTAG_LOADER_ENABLE	(1))  	//Include JTAG Loader when set to '1' 
  program_rom (    				//Name to match your PSM file
 	.rdl 			(kcpsm6_reset),
	.enable 		(bram_enable),
	.address 		(address),
	.instruction 	(instruction),
	.clk 			(clk));

// Programa

  always @ (posedge clk)
  begin

      case (port_id[1:0]) 

        // Read input_port_b at port address 01 hex
        2'b00 : in_port <= Switch_port;
		  
        default : in_port <= 8'bXXXXXXXX ;  

      endcase

  end



  always @ (posedge clk)
  begin

      // 'k_write_strobe' is used to qualify all writes to constant output ports.
      if (write_strobe == 1'b1) begin

        // Write to output_port_k at port address 01 hex
        if (port_id[1:0] == 2'b00) begin
           dis_port<= out_port;
        end

      end
  end

endmodule
