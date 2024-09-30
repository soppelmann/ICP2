//------------------------------------------------------------------------------
// SERIAL_DATA uVC sequence driver 
//
// The driver generates serial data according to the configuration of the
// serial_data_config object and activates the start bit when specified.
// The driver can generate parity bits if parity_enable is set.
// 
//  The configuration of the serial interface is provided via the
//  serial_data_config object.
//
//------------------------------------------------------------------------------
class serial_data_driver extends uvm_driver #(serial_data_seq_item);
    `uvm_component_param_utils(serial_data_driver)

    // SERIAL_DATA uVC configuration object.
    serial_data_config  m_config;

    //------------------------------------------------------------------------------
    // The constructor for the component.
    //------------------------------------------------------------------------------
    function new(string name, uvm_component parent = null);
        super.new(name, parent);
        if (!uvm_config_db #(serial_data_config)::get(this,"","serial_data_config", m_config)) begin
            `uvm_fatal(get_name(),"Cannot find the VC configuration!")
        end
    endfunction

    //------------------------------------------------------------------------------
    // FUNCTION: build
    // The build phase for the component.
    //------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    //------------------------------------------------------------------------------
    // FUNCTION: run_phase
    // The run phase for the component.
    // - Main loop
    // -  Wait for sequence item.
    // -  Perform the requested action
    // -  Send a response back.
    //------------------------------------------------------------------------------
    virtual task run_phase(uvm_phase phase);
        serial_data_seq_item seq_item;

        // Reset signals
        m_config.m_vif.start_bit <= 0;
        m_config.m_vif.serial_data <= 0;
        //TASK 1: Add a parity_enable signal:

        //
        
        forever begin
            // Wait for sequence item
            seq_item_port.get(seq_item);
            // Perform the requested action and send response back.
            `uvm_info(get_name(),$sformatf("Start serial interface transaction. Delay start bit=%0d  Start bit length=%0d  Serial data=%08b", seq_item.start_bit_delay, seq_item.start_bit_length, seq_item.serial_data),UVM_HIGH)
            fork
                begin
                    bit parity_bit = 0;
                    for (int nn=0; nn < 8; nn++) begin
                        @(posedge m_config.m_vif.clk);
                        m_config.m_vif.serial_data <= seq_item.serial_data[nn];
                        `uvm_info(get_name(),$sformatf("Sending serial_data. Bitno=%0d Data=%0d", nn, seq_item.serial_data[nn]), UVM_FULL)
                    end


                    //TASK 3: Implement a 9th bit if parity_enable is enabled.
                    //TASK 4: If the seq_item parity error is 1, flip the parity_bit.
                    
                end
                begin
                    `uvm_info(get_name(),$sformatf("Starting start_bit delay=%0d length=%0d", seq_item.start_bit_delay, seq_item.start_bit_length), UVM_FULL)
                    for (int ii=0; ii < seq_item.start_bit_delay; ii++) begin
                        @(posedge m_config.m_vif.clk);
                    end
                    @(posedge m_config.m_vif.clk);
                    m_config.m_vif.start_bit <= 1;
                    `uvm_info(get_name(),$sformatf("Start bit activated"), UVM_FULL)
                    for (int ii=0; ii < seq_item.start_bit_length; ii++) begin
                        @(posedge m_config.m_vif.clk);
                    end
                    m_config.m_vif.start_bit <= 0;
                    `uvm_info(get_name(),$sformatf("Start bit deactivated"), UVM_FULL)
                end
            join
            seq_item_port.put(seq_item);
        end
    endtask : run_phase
endclass : serial_data_driver
