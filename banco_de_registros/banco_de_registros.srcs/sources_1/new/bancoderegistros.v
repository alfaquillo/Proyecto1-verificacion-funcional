`timescale 1ns / 1ps

// =============================================================================
// Module: BancoDeRegistros
// =============================================================================
// Descripción:
//   Este módulo implementa un banco de registros con capacidad de lectura y 
//   escritura controlada por señales externas. 
//
// Entradas:
//   - CLK : señal de reloj
//   - RST : señal de reset (activo en alto)
//   - RD  : señal de lectura
//   - WR  : señal de escritura
//   - SEL : selección de registro (4 bits)
//
// Salidas:
//   - DATA: bus de datos de 16 bits
//
// Parámetros:
//   - No se han definido parámetros configurables
//
// =============================================================================
module bancoderegistros(
    input        CLK,
    input        RST,
    input        RD,
    input        WR,
    input  [3:0] SEL,
    inout  [15:0] DATA
);
    // Señales internas
    wire [11:0] WE;
    wire [7:0]  AL, CL, DL, BL, AH, CH, DH, BH;
    wire [15:0] SP, BP, SI, DI;
    wire [15:0] mux_out;

    // Decodificador de escritura (mejorado)
    decodificadorwr deco (
        .WR(WR),
        .SEL(SEL),
        .WE(WE)
    );
    
    // Banco de registros físico
    registros regs(
        .CLK(CLK),
        .RST(RST),
        .DATA(DATA),
        .WE(WE),
        .AL(AL), .CL(CL), .DL(DL), .BL(BL),
        .AH(AH), .CH(CH), .DH(DH), .BH(BH),
        .SP(SP), .BP(BP), .SI(SI), .DI(DI)
    );

    // Multiplexor con organización mejorada
    multiplexor16x16 mux(
        // Registros combinados (AX-DX) en primeras posiciones
        .A0({AH, AL}),    // SEL=0: AX
        .A1({CH, CL}),    // SEL=1: CX
        .A2({DH, DL}),    // SEL=2: DX
        .A3({BH, BL}),    // SEL=3: BX
        
        // Partes bajas
        .A4({8'b0, AL}),  // SEL=4: AL
        .A5({8'b0, CL}),  // SEL=5: CL
        .A6({8'b0, DL}),  // SEL=6: DL
        .A7({8'b0, BL}),  // SEL=7: BL
        
        // Partes altas
        .A8({8'b0, AH}),  // SEL=8: AH
        .A9({8'b0, CH}),  // SEL=9: CH
        .A10({8'b0, DH}), // SEL=A: DH
        .A11({8'b0, BH}), // SEL=B: BH
        
        // Registros índice/segmento
        .A12(SP),         // SEL=C: SP
        .A13(BP),         // SEL=D: BP
        .A14(SI),         // SEL=E: SI
        .A15(DI),         // SEL=F: DI
        
        .SEL(SEL),
        .OUT(mux_out)
    );

    // Buffer tri-state con control mejorado
    triestado tri_buf(
        .IN(mux_out),
        .SEL(RD & ~WR),  // Evita conflicto RD/WR simultáneos
        .OUT(DATA)
    );

    // Protección contra escritura/lectura simultánea
    always @(posedge CLK) begin
        if (WR && RD)
            $warning("Conflicto RD/WR simultáneo en ciclo %t", $time);
    end
endmodule