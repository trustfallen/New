module add_arr_tb#(
 parameter DATA_WIDTH=32,
 parameter N = 9, //очень большое
 parameter T_CLK = 10
 )();
 
logic                   EN; 
logic                   CLK;
logic                   NRESET;
logic [DATA_WIDTH-1:0]  FPA_NUMBERS [N:0];
logic [DATA_WIDTH-1:0]  FPA_RESULT;
logic [1:0]             FPA_OPERATION;
logic                   FPA_OVERFLOW;
logic                   FPA_UNDERFLOW;
logic                   FPA_EXCEPTION; 

logic                    FPA_DATA_VALID; 


add_arr add_arr_tb(
.iEN(EN),
.iCLK(CLK),
.iNRESET(NRESET),
.iFPA_NUMBERS(FPA_NUMBERS),
.oFPA_RESULT(FPA_RESULT),
.iFPA_OPERATION(FPA_OPERATION),
.oFPA_OVERFLOW(FPA_OVERFLOW),
.oFPA_UNDERFLOW(FPA_UNDERFLOW),
.oFPA_EXCEPTION(FPA_EXCEPTION), 
.oFPA_DATA_VALID(FPA_DATA_VALID) 

);


always  #T_CLK CLK = ~CLK;
initial begin
EN = 0;
CLK = 0;
NRESET = 0;
#50 
NRESET = 1;

for (int i = 0; i < N; i = i +1 ) begin
    FPA_NUMBERS[i] <= $urandom_range(0, 2**DATA_WIDTH - 1);
end

EN = 1;

wait(FPA_DATA_VALID);
display("The sum is: ", FPA_RESULT);
$finish;
end
 
endmodule



