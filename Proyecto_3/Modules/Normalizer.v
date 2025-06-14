`timescale 1ns / 1ps

module normalizer(
    input  [24:0] sum_result,
    input  [7:0]  exponent_in,
    input         overflow_flag, 
    output reg [23:0] mantissa_out,
    output reg [7:0]  exponent_out,
    output reg        underflow,
    output reg        overflow
);
    wire [4:0] leading_zeros;

    // Priority encoder de 24 bits (sum_result[23:0])
    assign leading_zeros = 
        sum_result[23] ? 5'd0  :
        sum_result[22] ? 5'd1  :
        sum_result[21] ? 5'd2  :
        sum_result[20] ? 5'd3  :
        sum_result[19] ? 5'd4  :
        sum_result[18] ? 5'd5  :
        sum_result[17] ? 5'd6  :
        sum_result[16] ? 5'd7  :
        sum_result[15] ? 5'd8  :
        sum_result[14] ? 5'd9  :
        sum_result[13] ? 5'd10 :
        sum_result[12] ? 5'd11 :
        sum_result[11] ? 5'd12 :
        sum_result[10] ? 5'd13 :
        sum_result[9]  ? 5'd14 :
        sum_result[8]  ? 5'd15 :
        sum_result[7]  ? 5'd16 :
        sum_result[6]  ? 5'd17 :
        sum_result[5]  ? 5'd18 :
        sum_result[4]  ? 5'd19 :
        sum_result[3]  ? 5'd20 :
        sum_result[2]  ? 5'd21 :
        sum_result[1]  ? 5'd22 :
        sum_result[0]  ? 5'd23 :
        5'd24;

    always @(*) begin
        underflow = 0;
        overflow = 0;
        mantissa_out = 0;
        exponent_out = 0;
        
        if (sum_result == 0) begin
            // Caso cero
            exponent_out = 0;
            mantissa_out = 0;
        end
        else if (sum_result[24] || overflow_flag) begin
            // Caso overflow (carry extra)
            mantissa_out = sum_result[24:1];  // shift right 1
            exponent_out = exponent_in + 1;
            
            // Detectar overflow
            if (exponent_out >= 8'hFF) begin
                overflow = 1;
                exponent_out = 8'hFF;
                mantissa_out = 0;
            end
        end else begin
            // Normalización
            exponent_out = exponent_in - leading_zeros;
            mantissa_out = sum_result[23:0] << leading_zeros;
            
            if (exponent_out[7] == 1'b1) begin  // Si es negativo (underflow)
                underflow = 1;
                exponent_out = 0;
                // Ajustar mantisa para subnormal
                mantissa_out = sum_result[23:0] << (leading_zeros + exponent_in - 1);
            end
        end
    end
endmodule