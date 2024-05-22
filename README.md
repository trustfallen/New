# Сложение чисел с плавающей точкой

### Задание: 
_Возьми любую открытую библиотеку, реализующую floating point арифметику на Verilog или System Verilog_

В рамках задания мной была выбрана библиотека, содержащая в себе АЛУ, выполняящая операции сложения, вычитания, умножения и деления чисел формата flat point:
https://github.com/parnabghosh1004/Floating-Point-ALU/tree/master

![image](https://github.com/trustfallen/New/assets/170412908/da4086f6-01a6-4443-a4d0-f7115b704fa0)

_Покажи, как ей пользоваться: напиши модуль на System Verilog, складывающий два числа типа float32_

Модуль, который я использую для подключения к АЛУ:
```systemverilog
module test #(
 parameter DATA_WIDTH=32)
(
input   logic [DATA_WIDTH-1:0]  iFP_NUMBER1,
input   logic [DATA_WIDTH-1:0]  iFP_NUMBER2,
output  logic [DATA_WIDTH-1:0]  oFP_RESULT,
input   logic [1:0]             iFP_OPERATION,
output  logic                   oFP_OVERFLOW,
output  logic                   oFP_UNDERFLOW,
output  logic                   oFP_EXCEPTION  
);

Main m(
.n1(iFP_NUMBER1),
.n2(iFP_NUMBER2),
.oper(iFP_OPERATION),
.result(oFP_RESULT),
.Overflow(oFP_OVERFLOW),
.Underflow(oFP_UNDERFLOW),
.Exception(oFP_EXCEPTION)

);

endmodule
```
Тестбенч, который складывает два числа и выводит результат в консоль:
```systemverilog
`timescale 1ns / 1ps

module fp_tb
#(
 parameter DATA_WIDTH=32
)
();

logic [DATA_WIDTH-1:0]  FP_NUMBER1;
logic [DATA_WIDTH-1:0]  FP_NUMBER2;
logic [DATA_WIDTH-1:0]  FP_RESULT;
logic [1:0]             FP_OPERATION;
logic                   FP_OVERFLOW;
logic                   FP_UNDERFLOW;
logic                   FP_EXCEPTION; 


test t(

.iFP_NUMBER1(FP_NUMBER1),
.iFP_NUMBER2(FP_NUMBER2),
.oFP_RESULT(FP_RESULT),
.iFP_OPERATION(FP_OPERATION),
.oFP_OVERFLOW(FP_OVERFLOW),
.oFP_UNDERFLOW(FP_UNDERFLOW),
.oFP_EXCEPTION(FP_EXCEPTION)
  
);

initial begin
		// Initialize Inputs
		FP_NUMBER1 = 32'b0_10000110_00011111000111101011100;    // 143.56
		FP_NUMBER2 = 32'b1_10000101_01011101101111110111110;    // -87.437


		FP_OPERATION = 2'd0; #50;

		$display("Addtion result : %b",FP_RESULT);
		$display("Overflow : %b , Underflow : %b , Exception : %b",FP_OVERFLOW,FP_UNDERFLOW,FP_EXCEPTION);		


	end



endmodule

```
Получили времянки:
![image](https://github.com/trustfallen/New/assets/170412908/d0411d7b-b17e-4ac8-86d0-ba2ad5447321)

Таким образом мы удостоверились что модуль рабочий, хотя бы для двух значений

_C помощью найденной тобой библиотеки напиши модуль на Verilog или System
Verilog, редуцирующий ряд из N вещественных чисел, где N достаточно большое, в одно число - сумму
ряда. Как добиться минимальной утилизации аппаратных ресурсов при решении данной задачи? На
каком такте твоего решения ответ будет корректным?_

Первое, что мне пришло в голову - итерационно складывать каждый элемент массива. Для данного способа реализации нам потребуется целых N тактов, чтобы получить сумму всех элементов массива. Где N - размер массива. Очень сильно проигрываем во времени, зато просто и понятно. 
```systemverilog
Main m(
.n1(FP_NUMBER1),
.n2(FP_NUMBER2),
.oper(iFP_OPERATION),
.result(FULL_RESULT),
.Overflow(oFP_OVERFLOW),
.Underflow(oFP_UNDERFLOW),
.Exception(oFP_EXCEPTION)

);

// Часть блока с always, выше объявление проводов, входов и выходов модуля
always@ (posedge iCLK | iNRESET) begin //Каждый положительный фронт CLK
    if (~iNRESET) begin  i = 0; FP_NUMBER1 = 0; FP_NUMBER2 = 0; OLD_RESULT = 0; end //Если ресет = 0, то обнуляем провода и каунтер
    else if (iEN) begin // Если сигнал разрешения работы модуля в единице то разрешаем работу логики

     if(i <= N-1) begin 
        FP_NUMBER1 = OLD_RESULT; // подаем на первый вход АЛУ старое значение, полученное на предыдущей итерации суммирования
        FP_NUMBER2 = iFPA_NUMBERS[i]; // подаем на второй вход АЛУ значение с массива 
        OLD_RESULT = FULL_RESULT;     // записываем в регистр промежуточный результат вычисления
        i = i + 1;                    // инкерементируем для следующего значения в массиве
     end
     else begin         
        oFPA_DATA_VALID <= 1;         // как только мы досчитали до конца массива данные действительны
        oFPA_RESULT <= FULL_RESULT;   // вместе с сигналом вэлид подаем и выходные данные 
     end

end
```
Так же, можно попарно складывать элементы массива. Например [0] и [1], [2] и [3] и т.д. Тогда мы получим N/2 сумм, которые так же можно будет сложить попарно. В итоге количество итераций для получения итоговой суммы будет равно log2(N). Складываем элементы попарно в исходном массиве - N/2 сумм, складываем попарно полученные суммы - N/4 итераций, еще раз складываем поулченные суммы попарно - N/8 итераций и т.д
Единственная загвостка, чем больше итераций - тем больше понадобится регистров чтобы хранить промежуточные данные. Как раз log2(N) регистров, что может быть дорого. Но зато намного быстрее. 

```systemverilog
module add_arr#(
 parameter DATA_WIDTH=32,
 parameter N = 9999999 
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

// Вспомогательные "провода"
logic [31:0] FULL_RESULT;
logic [31:0] FP_NUMBER2;
logic [31:0] OLD_RESULT;
logic [31:0] FP_NUMBER1;
logic [31:0] i1;
logic [31:0] i2;

// Подключение АЛУ
Main m(
.n1(FP_NUMBER1),
.n2(FP_NUMBER2),
.oper(iFP_OPERATION),
.result(FULL_RESULT),
.Overflow(oFP_OVERFLOW),
.Underflow(oFP_UNDERFLOW),
.Exception(oFP_EXCEPTION)

);

// Регистры для промежуточных результатов
logic [31:0] DUO_SUM [N/2:0];

always@ (posedge iCLK | iNRESET) begin
   
    if (~iNRESET) begin  i1 = 0; i2 = 0; FP_NUMBER1 = 0;FP_NUMBER2 = 0; OLD_RESULT = 0; oFPA_DATA_VALID <= 0; end
    else if (iEN) begin
         if (i1 <= N/2) begin
                FP_NUMBER1      = iFPA_NUMBERS[i1]; // На первый вход АЛУ подаем элементы исходного массива с четными индексами
                FP_NUMBER2      = iFPA_NUMBERS[i1+1]; // На второй вход АЛУ подаем элементы исходного массива с нечетными индексами
                DUO_SUM[i1/2]   = FULL_RESULT; 	// Записываем результат во временный регистр
                i1 = i1 + 2;	//Итеррируем на 2 чтобы складывать попарно
         end
             else begin // Когда нашли суммы всех пар

                FP_NUMBER1 = DUO_SUM[i2]; // На первый вход АЛУ подаем элемент массива сумм пар первого массива
                FP_NUMBER2 = OLD_RESULT; // На второй вход АЛУ подаем результат прошлого суммирования(для 0 элемента это 0)
       
                OLD_RESULT = FULL_RESULT; // Сохраняем старый результат, чтобы использовать его на следующей итерации в новом
        
                i2 = i2 + 1;         // Следующая итерация

                if(i2 == N/2) begin // Досчитали до массива сумм
                    oFPA_DATA_VALID <= 1; // Говорим, что данные валидны
                    oFPA_RESULT <= FULL_RESULT; // Подаем данные на выход
        end
        end
    end
    
end

endmodule



```
Тестбенч для проверки модулей

```systemverilog
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
    FPA_NUMBERS[i] <= $urandom_range(0, 2**DATA_WIDTH - 1); // Генерация рандомного числа от 32'h0 до 32'hFFFFFFFF
end

EN = 1;

wait(FPA_DATA_VALID);
//TO_DO Реализовать логику проверки
// if(sum(float32 FPA_NUMBERS) != FPA_RESULT)  $display(!!!ERROR!!!);
//
$display("The sum is: ", FPA_RESULT);
$finish;
end
 
endmodule
```
## Необходимо упомянуть 
![image](https://github.com/trustfallen/New/assets/170412908/e85bc1c9-eb4e-4bef-928c-37a5f4449e46)

При работе с арифметичекими опеарциях с числами с плавающей точкой необходимо помнить про такие вещи как: мантисса, порядок числа, округление, сдвиг, машинная ошибка и т.д  

Для выполнения сложения двух таких чисел необходимо выполнить следующие шаги:
1. Выделить биты порядка и мантиссы.
2. Присоединить неявную старшую единицу к мантиссе.
3. Сравнить порядки.
4. При необходимости сдвинуть мантиссу числа, имеющего меньший порядок.
5. Сложить мантиссы.
6. При необходимости нормализовать мантиссу и порядок.
7. Округлить результат.
8. Собрать обратно порядок и мантиссу в итоговое число с плавающей точкой.

Необходимо помнить, что, например, перед тем как два числа будут сложены, они должны быть приведены к единому порядку, а то, что при сложении выйдет за мантиссу будет отброшено. Таким образом, было бы хорошим тоном перед поэлементном сложении массива упорядочить  его по возрастанию. Числа с похожими порядками будут стоять рядом, что уменьшит количество округлений, свдигов и ошибок. 
