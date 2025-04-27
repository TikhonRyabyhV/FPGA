
`include "pseudo_asm.v"
`timescale 1ns/100ps

module new_test;
    parameter  DATA_DEPTH = 1024;

    reg clk;
    reg KEY0;
    reg [DATA_DEPTH - 1: 0][15: 0] data_frames_in;
    wire                         frame_being_sent;

    integer i; 
    integer k; 
    integer file;
    integer status;

    reg  [15: 0]              instruction;     
    reg  [15: 0]                  tm_line;
    reg  [15: 0]               data_input;
    wire [19: 0]               input_addr;



/// for outfiles
	reg [8 * 29: 1] output_file;
	reg [     3: 0]    bank_num;
	reg [     1: 0]        flag;
    reg [15:0] temp_data;

	integer h, out_dsp, infile;
/// for outfiles

    always 
        #1 clk = ~clk;
 


    task send_tm_line(input [15:0] instruction, input integer j);
        begin
            // Проверка на допустимый индекс
            if (j >= 0 && j <= 1023) begin
                $display ("before write: instruction: %h , number %d", instruction, j);
                data_frames_in[j] = instruction; // Запись инструкции в массив
                $display ("after writing     data_frames_in[%d] = %h ", j, data_frames_in[j]);
            end else begin
                $display("Ошибка: индекс вне диапазона!");
            end
        end
    endtask


    gpu gpu (
             .clk        (       clk ),
             .KEY0       (      KEY0 ),
             .data_input ( data_input),
             .input_addr ( input_addr)
    );


    initial begin
        clk          <= 0;
        KEY0         <= 1;
    end

    initial begin
        // Открываем входной файл
        infile = $fopen("src_data/bin_shader.bin", "r");
        if (infile == 0) begin
            $display("Ошибка: не удалось открыть файл.");
            $finish;
        end

        // Считываем данные из файла
        for (i = 0; i < DATA_DEPTH; i = i + 1) begin
            // Читаем одно 16-битное число в temp_data
            if ($fscanf(infile, "%b\n", temp_data) != 1) begin
                $display("Ошибка при чтении данных. Возможно, файл закончился, i = %d", i);
                i = DATA_DEPTH; // Выходим из цикла, если данных больше нет
            end
            
            // Записываем считанное значение в массив
            data_frames_in[i] = temp_data;
        end
        
        // Закрываем файл
        $fclose(infile);
        $display("Данные успешно загружены.");
    end
	

    initial begin 
		$dumpfile("dump.vcd"); $dumpvars(0, new_test);
        #10;
        for (i = 224; i < 1024; i = i + 1) begin
            data_frames_in[i] = 0;
        end
    end
    

    always @(posedge clk) begin
        data_input <= data_frames_in[input_addr];
    end



    initial begin 
        #10;
        KEY0 = 0;
        #3;
        KEY0 = 1;

/*
        for (integer j = 0; j < 1024; j = j + 1) begin
            data_input <= data_frames_in[j];
            #2;

        end
*/

        #10;

        #20;
        #190;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;
        #450;


        #40500;
        KEY0 = 0;
        #1;
        KEY0 = 1;
        #450;
        $finish;
    end
endmodule

