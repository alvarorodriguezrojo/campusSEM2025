`timescale 1ns / 1ps


// *********************************  UNIDAD FUNCIONAL  ************************** //

//No implemento los bits "C" y "V" ya que las instrucciones no los utilizan //


module UF (UF_out, Z, N, FS, A_bus, B_bus);

output [15:0] UF_out;
output  Z, N;

input [15:0]  A_bus, B_bus;
input [3:0] FS;

assign #10 UF_out =  (FS == 4'h0) ? A_bus					:
					 (FS == 4'h1) ? A_bus+1					:
		             (FS == 4'h2) ? A_bus + B_bus			:
		             (FS == 4'h3) ? A_bus + B_bus + 1		:
		             (FS == 4'h4) ? A_bus + (~ B_bus)   	:
                     (FS == 4'h5) ? A_bus + (~ B_bus) + 1	:
                     (FS == 4'h6) ? A_bus + 16'hFFFF    	:	
					 (FS == 4'h7) ? A_bus               	:
					 (FS == 4'h8) ? A_bus & B_bus       	:
					 (FS == 4'h9) ? A_bus | B_bus       	:
					 (FS == 4'hA) ? A_bus ^ B_bus       	:
					 (FS == 4'hB) ? ~A_bus              	:
					 (FS == 4'hC) ? B_bus					:
					 (FS == 4'hD) ? B_bus >> 1				:
					 (FS == 4'hE) ? B_bus << 1				:
					  16'bxxxxxxxxxxxxxxxx					;
					  
assign N = UF_out[15];
assign #2 Z = ~|UF_out;

endmodule



// *********************************  BANCO DE REGISTROS  ************************** //


module banco_reg (A_bus, B0_bus, D_bus, A_address, B0_address, D_address, RW, Clock);

output [15:0] A_bus, B0_bus;

input [15:0] D_bus;
input [2:0] A_address, B0_address, D_address;
input RW, Clock;

reg [15:0] R0, R1, R2, R3, R4, R5, R6, R7;

//Ahora es la parte de escritura síncrona en los registros

always @ (posedge Clock)  
	begin
		if (RW)
			begin
				case (D_address)
					
					3'b000: R0 <= #5 D_bus;
					3'b001: R1 <= #5 D_bus;
					3'b010: R2 <= #5 D_bus;
					3'b011: R3 <= #5 D_bus;
					3'b100: R4 <= #5 D_bus;
					3'b101: R5 <= #5 D_bus;
					3'b110: R6 <= #5 D_bus;
					3'b111: R7 <= #5 D_bus;
					default: ;
				
				endcase
			end
	end

//Ahora es la parte de lectura asíncrona de los registros

assign #3 A_bus =	(A_address == 3'b000) ? R0: 
					(A_address == 3'b001) ? R1:
					(A_address == 3'b010) ? R2:
					(A_address == 3'b011) ? R3:
					(A_address == 3'b100) ? R4:
					(A_address == 3'b101) ? R5:
					(A_address == 3'b110) ? R6:
					(A_address == 3'b111) ? R7: 16'bxxxxxxxxxxxxxxxx;

assign #3 B0_bus =  (B0_address == 3'b000) ? R0:
	       	        (B0_address == 3'b001) ? R1:
	       	        (B0_address == 3'b010) ? R2:
	       	        (B0_address == 3'b011) ? R3:
	       	        (B0_address == 3'b100) ? R4:
	       	        (B0_address == 3'b101) ? R5:
	       	        (B0_address == 3'b110) ? R6:
	       	        (B0_address == 3'b111) ? R7: 16'bxxxxxxxxxxxxxxxx;


endmodule



// *********************************  MUX 2 a 1  ************************** //

module mux_2 (Z_bus, X_bus, Y_bus, select);

output [15:0] Z_bus;

input [15:0] X_bus, Y_bus;
input select;

assign #2 Z_bus = (select == 1'b0) ? X_bus:
				  (select == 1'b1) ? Y_bus: 16'bxxxxxxxxxxxxxxxx;

endmodule



// *********************************  MEMORIA_DATOS  ************************** //

module mem_data (Out, In, MW, Address, Clock);

output [15:0] Out;

input [15:0] In, Address;
input Clock, MW;

reg [15:0] mem2 [65535:0];  //Definimos una memoria de 2^16 direcciones y 16 bit de longitud de palabra

always @ (posedge Clock)
	begin
		if(MW)
		mem2 [Address] <= #10 In; 		
	end

assign #10 Out = mem2[Address];

initial mem2[0]=16'h000F;   //Número que meto en la posición 0 de la memoria de datos para hallar su raíz cuadrada.

endmodule


// *********************************  Contador de Programa y control para saltos  ************************** //

module program_counter (Out, In, N, Z, Clock, PL, JB, BC);

output [15:0] Out;
reg [15:0] Out;

input Clock, PL, JB, N, Z;
input[5:0] In;
input [2:0] BC;

wire [15:0] In_Extended;


assign In_Extended = (In[5]==0) ? {10'b0000000000, In} : {10'b1111111111, In};


initial Out = 16'h0000;   // Aquí se incializa el PC en valor 0 al arrancar la máquina.

always @ (posedge Clock)
	begin
		if (PL==0) Out <= #5 Out+1;
		else if (JB==1'b1) Out <= #5 Out+In_Extended;
		else
			begin
				case (BC)
					3'b001: Out <= #5 (N == 1) ? Out + In_Extended : Out+1;
					3'b011: Out <= #5 (Z == 1) ? Out + In_Extended : Out+1;
					3'b101: Out <= #5 (N == 0) ? Out + In_Extended : Out+1;
					3'b111: Out <= #5 (Z == 0) ? Out + In_Extended : Out+1;
					default: Out <= #5 Out+1;
				endcase
			end
	end

endmodule



// *********************************  Memoria de programa  ************************** //

module ROM (Instruction_out, Address);

output [15:0] Instruction_out;
input [15:0] Address;

reg [15:0] mem [65535:0];   //Definimos una memoria de 2^16 direcciones y 16 bit de longitud de palabra


initial					// Escribimos el programa en la memoria de instrucciones
	begin
		mem[0]  = 16'h9800;  // LDI R0, OP=0;  		R0 ← 0;
		mem[1]  = 16'h2000;  // LD R0, R0; 			R0 ← M[R0];
		mem[2]  = 16'h1440;  // XOR R1, R0, R0;		R1 ← R0 XOR R0;
		mem[3]  = 16'h0088;  // MOVA R2, R1;		R2 ← R1;
		mem[4]  = 16'h0290;  // INC R2, R2;			R2 ← R2 + 1;
		mem[5]  = 16'h1CC1;  // SHL R3, R1;			R3 ← shl R1; 
		mem[6]  = 16'h0493;  // ADD R2, R2, R3;		R2 ← R2 + R3;
		mem[7]  = 16'h0248;  // INC R1, R1;			R1 ← R1 + 1;
		mem[8]  = 16'h0AC2;	 // SUB R3, R0, R2;		R3 ← R0 - R2;
		mem[9]  = 16'hCBDB;  // BRNN R3, seAD=-5;	if R3>=0 PC ← PC-5, if R3<0 PC ← PC+1;
		mem[10] = 16'h0C48;  // DEC R1, R1;			R1 ← R1 - 1;
		mem[11] = 16'h98C1;  // LDI R3, OP=1;		R3 ← 1;   
		mem[12] = 16'h4018;  // ST R3, R0;			M[R3] ← R0;
		mem[13] = 16'h0CD8;  // DEC R3, R3;			R3 ← R3 - 1;
		mem[14] = 16'h4019;  // ST R3, R1;			M[R3] ← R1;
		mem[15] = 16'hE000;  // JMP seAD=0;			PC ← PC;
	end
	

assign #10 Instruction_out=mem[Address];
		
endmodule


//******************************************* Máquina completa **************************************************//

module maquina_completa (Clock);
input Clock;

wire [15:0] Instruction, D_bus, A_bus, B1_bus, B_bus, F_bus, Mem_out_bus, PC_Out;
wire Z, N;

ROM Mem_Instrucciones (Instruction, PC_Out);
banco_reg Banco_Registros (A_bus, B1_bus, D_bus, Instruction[5:3], Instruction[2:0], Instruction[8:6], ~Instruction[14], Clock);
mux_2 Mux_B (B_bus,B1_bus,{13'd0,Instruction[2:0]},Instruction[15]);
UF Unidad_Funciones (F_bus, Z, N, {Instruction[12]&(~(Instruction[15]&Instruction[14])),Instruction[11]&(~(Instruction[15]&Instruction[14])),Instruction[10]&(~(Instruction[15]&Instruction[14])),Instruction[9]&(~(Instruction[15]&Instruction[14]))}, A_bus, B_bus);
mux_2 Mux_D (D_bus, F_bus, Mem_out_bus, Instruction[13]);
program_counter Prog_Counter (PC_Out, {Instruction[8:6],Instruction[2:0]}, N, Z, Clock, Instruction[15]&Instruction[14], Instruction[13], Instruction[11:9]);
mem_data Mem_Datos (Mem_out_bus, B_bus, (~Instruction[15])&Instruction[14], A_bus, Clock);

endmodule


//*************************** Testbench *********************************//

module testbench;

maquina_completa modulo_padre (Clock);

reg Clock;

initial Clock = 0;

always
#70 Clock = ~ Clock;

initial #5500 $finish;

initial
begin
$dumpfile("final.vcd");
$dumpvars(0, modulo_padre);
end
endmodule

