module add_arr#(
 parameter DATA_WIDTH=32,
 parameter N = 16 //очень большое
 )
(
input   logic                   iEN,
input   logic                   iCLK,
input   logic                   iNRESET,
input   logic [DATA_WIDTH-1:0]  iFPA_NUMBERS [N:0],
output  logic [DATA_WIDTH-1:0]  oFPA_RESULT,
input   logic [1:0]             iFPA_OPERATION,
output  logic                   oFPA_OVERFLOW,
output  logic                   oFPA_UNDERFLOW,
output  logic                   oFPA_EXCEPTION, 

output logic                    oFPA_DATA_VALID 


    );
    
    
logic [31:0] FULL_RESULT;
logic [31:0] FP_NUMBER1;
logic [31:0] FP_NUMBER2;
logic [31:0] OLD_RESULT;
logic [31:0] FP_NUMBER1;
logic [31:0] i1;
logic [31:0] i2;


Main m(
.n1(FP_NUMBER1),
.n2(FP_NUMBER2),
.oper(iFP_OPERATION),
.result(FULL_RESULT),
.Overflow(oFP_OVERFLOW),
.Underflow(oFP_UNDERFLOW),
.Exception(oFP_EXCEPTION)

);

logic [31:0] DUO_SUM [N/2:0];

always@ (posedge iCLK | iNRESET) begin // каждый положительный фронт CLK 
   
    if (~iNRESET) begin  i1 = 0; i2 = 0; FP_NUMBER2 = 1; FP_NUMBER2 = 0; OLD_RESULT = 0; FULL_RESULT = 0; OLD_RESULT = 0; end 
    else if (iEN) begin
            if (i1 <= N/2) begin  //
                FP_NUMBER1      = iFPA_NUMBERS[i1];
                FP_NUMBER2      = iFPA_NUMBERS[i1+1];
                DUO_SUM[i1/2]   = FULL_RESULT;
                i1 = i1 + 2;
             end
             else begin

                FP_NUMBER1 = DUO_SUM[i2]; 
                FP_NUMBER2 = OLD_RESULT;
       
                OLD_RESULT = FULL_RESULT;
        
                i2 = i2 + 1;         

                if(i2 == N/2) begin
                    oFPA_DATA_VALID <= 1;
                    oFPA_RESULT <= FULL_RESULT;
        end
        end
    end
    
end
    
    
endmodule


