`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2024 09:12:37 PM
// Design Name: 
// Module Name: fft_top_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// ----------------------------------------------------------- MODULE DECLARATION ----------------------------------------------------------- //
module fft_top_tb();

// ---------------------------------------------------------- REGISTER DECLARATIONS --------------------------------------------------------- //
    reg         aclk                  ;
    reg         aresetn               ;
    
    reg [31:0] in_data                ;
    reg        in_valid               ;
    reg        in_last                ;
    wire       in_ready               ;
    
    reg [7:0]  config_data            ;
    reg        config_valid           ;
    wire       config_ready           ;
    
    wire[31:0] out_data               ; 
    wire       out_valid              ;
    wire       out_last               ; 
    reg        out_ready              ; 
    
    reg [31:0] input_data [15:0]     ; // Creating the rom for the input data to the FFT IP 
    
    reg [31:0] temp_data              ;
    integer    i                      ;
    integer    j                      ;  
    integer    fd_fft_input           ; // File descriptor for saving FFT output data
    integer    fd_fft_output          ; // File descriptor for saving FFT output data
    
// --------------------------------------------------------- COMPONENT DECLARATIONS --------------------------------------------------------- //
    
    fft_top FFT_TOP_INST_0 ( 
        .aclk              ( aclk         ),
        .aresetn           ( aresetn      ),
        
        .in_data           ( in_data      ),
        .in_valid          ( in_valid     ),
        .in_ready          ( in_ready     ),
        .in_last           ( in_last      ),
        
        .config_data       ( config_data  ),
        .config_valid      ( config_valid ),
        .config_ready      ( config_ready ),
       
        .out_data          ( out_data     ),   
        .out_valid         ( out_valid    ),
        .out_last          ( out_last     ),
        .out_ready         ( out_ready    )
   );
   
 // --------------------------------------------------------- CLOCK GENERATORS  -------------------------------------------------------------- //
   always
   begin 
        #5 aclk = ~aclk; 
   end 
 //---------------------------------------------------------- TESTBENCH ---------------------------------------------------------------------- //
   initial begin 
      aclk = 0;
      aresetn = 0; 
      
      in_valid = 1'b0;
      in_data = 32'h0;
      in_last = 1'b0;
      
      out_ready = 1'b1; // Initializing OUT_READY to 1, inorder to tell FFT that outputs can be generated whenewer ready, 
      
      config_data = 8'b0;
      config_valid = 1'b0; 
      
      fd_fft_input = $fopen("fft_input.txt", "r"); 
      fd_fft_output = $fopen("fft_output.txt", "w"); 
      
   end 
   
 // ---------------------------- -------------------LOADING  DATA FROM FILE INTO FFT INPUT  ------------------------------------------------ //

   initial begin 
      #70 // As reset needs to be activated for atleast 2 cycles we have given 70 units of delay
      aresetn = 1;
      
//    input_data[0]  = 16'h0000;  
//    input_data[1]  = 16'h0200;  
//    input_data[2]  = 16'h0400;  
//    input_data[3]  = 16'h0800;  
//    input_data[4]  = 16'h1000;  
//    input_data[5]  = 16'h2000;  
//    input_data[6]  = 16'hFE00; 
//    input_data[7]  = 16'hFC00;  
//    input_data[8]  = 16'hF800;  
//    input_data[9]  = 16'hF000;  
//    input_data[10] = 16'h3800;  
//    input_data[11] = 16'hC800;  
//    input_data[12] = 16'h1C00; 
//    input_data[13] = 16'hE400;  
//    input_data[14] = 16'h0100;  
//    input_data[15] = 16'hFF00;  
      
      for (i = 0; i < 16; i = i + 1) begin
        if (!$fscanf(fd_fft_input, "%h\n", temp_data)) begin
            $display("Error: Unable to read data from input file.");
            $finish;
        end
        input_data[i] = temp_data;
       end
    $fclose(fd_fft_input);  // Close the input data file after reading
    
    end 

      
   initial begin
      #100 
      config_data = 1; // Forward FFT 
      #5 config_valid = 1;
      
      while(config_ready == 0) begin 
        config_valid = 1;
      end 
      #5 config_valid = 0;
      
    end 
  
 // ------------------------------------------- INPUT PORT INITIAL BLOCK ----------------------------------------------------------- //
   initial begin  
     #100
     for (i = 0; i < 16; i=i+1) begin
        #10 
        if (i == 0) begin // Last signal needs to ne generated once the last data is sent 
                          // In this case once we reach the 0th position we can assert last signal to be 1   
            in_last = 1'b1; // Once data is put on the bus make the valid high  
        end   
        
        in_data = input_data[i];
        in_valid = 1'b1;
                       
        while (in_ready == 0) begin  
           in_valid =1'b1; 
        end 
    end 
    #10 
    in_valid = 1'b0; 
    in_last = 1'b0; 
    // Once all the transactions are completed assert the valid and the last to 0 
    end 
   
   
 // ------------------------------------------ OUTPUT PORT INITIAL BLOCK ----------------------------------------------------------- //
   initial begin 
      #100 // Giving delay so that all the data can be stored in ROM 
      
      wait (out_valid == 1); 
      #300 out_ready = 1'b0; // Adding a 600 unit delay so that all the data needs to be sent by data bus
   end 
   
// ------------------------------------------ SAVING DATA FROM FFT OUTPUT --------------------------------------------------------- //
always @(posedge aclk) begin
  if (out_valid && out_ready) begin
      $fwrite(fd_fft_output, "%h\n", out_data); // Write output data to the file in hexadecimal format
  end
end

endmodule
