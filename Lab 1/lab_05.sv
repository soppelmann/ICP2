module lab_05 #(parameter PERIOD = 10) (
    output logic enable_1,
    output logic enable_2
);


    logic reset;

    logic clk;

    logic [2:0] address;
    logic [7:0] data;


    typedef enum logic [2:0] { ADD, SUB, AND, OR, XOR, MUL, DIV, MOD } operations_t;   
    typedef enum logic [1:0] { REG0, REG1, REG2, REG3 } registers_t;

    operations_t my_operation;
    registers_t my_register;


    initial clk = 0;


    always #(PERIOD/2) clk = ~clk;

    
    covergroup covergroup_1 @(posedge clk);
        c1: coverpoint address;  // This creates automatic bins (7 bins)
        c2: coverpoint data;  // This creates automatic bins (64 bins)
    endgroup: covergroup_1


    covergroup covergroup_2 @(posedge clk);
        c1: coverpoint address;  // This creates automatic bins (7 bins)
        c2: coverpoint data {
            bins data_bin = { 0, 1, 2, 5, 100 };  // This creates custom bins (5 bins)
        }
    endgroup: covergroup_2


    covergroup covergroup_3 @(posedge clk);
        c1: coverpoint address;  // This creates automatic bins (7 bins)
        c2: coverpoint data {
            bins data_bin[] = { 0, 1, 2, 5, 100 };  // This creates custom bins (5 bins)
            bins data_bin_3_4 = { [3:4] };  // Bin 3:4
            bins data_bin_6_99 = { [6:99] };  // Bin 6:99
            bins data_bin_101_255 = { [101:255] };  // Bin 101:255
        }
    endgroup: covergroup_3


    covergroup covergroup_4 @(posedge clk);
        c1: coverpoint address;  // This creates automatic bins (7 bins)
        c2: coverpoint data {
            bins data_bin_low = { [0:127] };  // This creates 1 bin 
            bins data_bin_high = { [128:$] };  // This creates 1 bin 
        }
    endgroup: covergroup_4


    covergroup covergroup_5 @(posedge clk);
        c1: coverpoint my_operation;
        c2: coverpoint my_register;
        operations_x_registers: cross c1, c2; // Cross coverage
    endgroup: covergroup_5


    covergroup_1 cover_inst1 = new();
    covergroup_2 cover_inst2 = new();
    covergroup_3 cover_inst3 = new();
    covergroup_4 cover_inst4 = new();
    covergroup_5 cover_inst5 = new();


    initial begin
        #10 address = 0;
        #10 address = 1;
        #10 address = 2;
        #10 address = 3;
        #10 address = 4;
        #10 address = 5;
        #10 address = 6;
        #10 address = 7;

        for (int i = 0; i < 255; i++) begin
            #10ns;
            data = i;
        end

        // Task 1
        // Change the testbench to achieve 100% coverage for covergroup_1

        // Task 2
        // Change covergroup_2's data coverpoint so that it only creates 1 bin for { 0, 1, 2, 5, 100 } instead of 5 individual bins

        // Task 3
        // Change covergroup_3 and achieve the same functionality without using the 'default' keyword    
        $stop;   
    end


    initial begin
        for (int i = ADD; i <= MOD; i++) begin            
            my_operation = operations_t'(i);
            for (int j = REG0; j <= REG3; j++) begin
                my_register = registers_t'(j);
                #10ns;
                $display(my_register);
            end  
        end

        // Task 4
        // Change the testbench to achieve 100% cross coverage for covergroup_5 
    end

endmodule
