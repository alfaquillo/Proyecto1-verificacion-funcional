`timescale 1ns / 1ps

// =============================================================================
// Module: Triestado
// =============================================================================
// Descripción:
//   Este módulo implementa un buffer de tres estados de 16 bits. Si la señal
//   SEL está activa, OUT toma el valor de IN. 
//   Si la señal SEL está inactiva, la salida queda en alta impedancia (Z).
//
// Entradas:
//   - IN  : dato de entrada de 16 bits
//   - SEL : señal de habilitación del buffer
//
// Salidas:
//   - OUT : salida de 16 bits, puede tomar el valor de IN o alta impedancia (Z)
//
// Parámetros:
//   - No se han definido parámetros configurables
//
// =============================================================================

module triestado( IN, SEL, OUT);
    input [15:0] IN;
    input SEL;
    output wire [15:0] OUT; 
    
    assign OUT = SEL ? IN : 16'bz;
    
endmodule