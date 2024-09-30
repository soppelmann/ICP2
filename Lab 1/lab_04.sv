module lab_04 #(parameter PERIOD = 10) (
    output logic enable_1,
    output logic enable_2
);

    logic a, b, c, d;
    logic [7:0] data;

    logic reset;

    logic clk;

    initial begin
        clk = 0;
    end

    always #(PERIOD/2) clk = ~clk;


    // Assertion to ensure either enable_1 or enable_2 is set @ clock edge
    assert_1 : assert property ( @(posedge clk) enable_1 || enable_2 );


    // Same assertion as above but extacting the property out
    property enables_checker;
        @(posedge clk) enable_1 || enable_2;
    endproperty

    assert_2 : assert property (enables_checker) else 
        $warning("enable_1 and enable_2 are both 0!");


    // Assert that if a is high and b is low, then c must be high in the same cycle; 
    // Otherwise we don't care about c
    assert_3 : assert property ( @(posedge clk) (a && !b) |-> c );


    // Assert that if a is high and b is low, then c must be high in the NEXT cycle
    assert_4 : assert property ( @(posedge clk) (a && !b) |=> c );  


    // Assert that if a is high and next cycle b is high, then c must be high in the cycle after
    // If a is low we don't care
    // If a is high and next cycle b is low, we don't care about c
    property a_b_c_checker;
        @(posedge clk) (a ##1 b) |=> c;
    endproperty

    assert_5 : assert property (a_b_c_checker);


    // Asset that if a and c are high this cycle, then 2 cycles later b must be high
    // But if a and c are high this cycle and reset happens we don't care about b anymore
    assert_6 : assert property ( @(posedge clk) disable iff (reset) (a && c) |-> ##2 b );

    //Assert if b,c and d are high this cycle, then 2 cycles later d must be high
    property b_c_d_checker;
        @(posedge clk) ((b && c && d) |=> ##2 d);
    endproperty

    assert_task1 : assert property (b_c_d_checker) $display("Task 1 case happened"); else $warning("Task 1 case did not happen");

    property b_c_d_checker_reset;
        @(posedge clk) disable iff (reset) ((b && c && d) |=> ##2 d);
    endproperty

    assert_task2 : assert property (b_c_d_checker_reset) $display("Task 2 case happened"); else $warning("Task 2 case did not happen");

    property data200_clk;
        @(posedge clk) data <= 200;
    endproperty

    assert_task3 : assert property (data200_clk) $display("Task 3 case happened"); else $warning("Task 3 case did not happen");

    sequence seq_a_b_c_d;
        @(posedge clk) a  ##1
        @(posedge clk) b  ##1
        @(posedge clk) c  ##1
        @(posedge clk) d;
    endsequence

    property a_b_c_d_checker;
        seq_a_b_c_d;
    endproperty

    assert_task4: assert property(a_b_c_d_checker) $display("Task 4 case happened"); else $warning("Task 4 case did not happen");

    initial begin
        reset = 0;

        a = 0;
        b = 0;
        c = 0;
        d = 0;
        data = 0;

        enable_1 = 1;
        enable_2 = 1;

        #30 enable_2 = 0;
        #20 enable_1 = 0;

        #10 
        enable_1 = 1;
        enable_2 = 1;

        #10
        a = 1;
        b = 0;
        c = 0;

        #10
        c = 1;

        #10
        c = 0;

        #10
        c = 1;

        #10
        b = 1;
        d = 1;

        #10
        c = 0;
        d = 0;
        data = 210;

        #10 
        c = 1;
        d = 1;
        data = 180;

        #10
        b = 0;
        d = 0;

        #10 
        reset = 1;

        // Task 1
        // Add an assertion that checks if b, c, and d are high this cycle, then d must be high 2 cycles later
        #10
        b = 1;
        c = 1;
        d = 1;

        #10
        d = 0;
        
        #20

        #10
        b = 1;
        c = 1;
        d = 1;

        #20
        // Task 2
        // Same as Task 1 except that reset disables the check
        #10
        b = 1;
        c = 1;
        d = 1;

        #10
        d = 0;
        reset = 1;
        #10
        reset = 0;

        #20
        b = 1;
        c = 1;
        d = 1;

        #10
        reset = 1;

        #10
        reset = 0;

        #10
        // Task 3
        // Add an assertion that checks data <= 200 at positive clock edges

        // Task 4
        // Add an assertion that checks if a is high this cycle, and c is high the cycle after, and b is high 2 cycles after a was high, then d must be high 3 cycles after a was high
        // So for example if a is high at cycle 1 and c is high at cycle 2 and b is high at cycle 3 then d must be high at cycle 4
        #10
        a = 1;
        #10
        b = 1;
        #10
        c = 1;
        #10
        d = 1;
        #10
        
         $stop;
    end

endmodule
