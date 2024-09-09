`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2024 11:35:42 PM
// Design Name: 
// Module Name: fft_top
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


module fft_top(
    input        aclk,
    input        aresetn,
    
    input [31:0]  in_data, // Input data stream
    input         in_valid,
    input         in_last,
    output        in_ready, 
    
    input [7:0]   config_data, // Config Data Stream, 
    input         config_valid, 
    output        config_ready,
    
    
    output [31:0] out_data, // Output Data Stream
    //output [15:0] out_data_real, // Real part of FFT Output
    //output [15:0] out_data_imag, // Imaginary part of FFT Output
    output         out_valid,
    output         out_last,
    input          out_ready
    );
    
    wire [31:0]    data_fft; // FFT IP takes 32 bit data, so padding the upper 32-bits with 0's 
    // assign data_fft[31:16] = 16'h0;
    assign         data_fft [31:0] = in_data; // Real data from the input stream 
    
    wire [31:0] out_fft; // Output of FFT is 32 bit 
    
    wire
    event_frame_started,
    event_tlast_unexpected,
    event_tlast_missing,
    event_status_channel_halt,
    event_data_in_channel_halt,
    event_data_out_channel_halt; // Additional Event Signals 
    
   FFT FFT_IP (
      .aclk(aclk),                                                // input wire aclk
      .aresetn(aresetn),                                          // input wire aresetn
      
      .s_axis_config_tdata(config_data),                          // input wire [7 : 0] s_axis_config_tdata
      .s_axis_config_tvalid(config_valid),                        // input wire s_axis_config_tvalid
      .s_axis_config_tready(config_ready),                        // output wire s_axis_config_tready
      
      .s_axis_data_tdata(data_fft),                               // input wire [31 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(in_valid),                              // input wire s_axis_data_tvalid
      .s_axis_data_tready(in_ready),                              // output wire s_axis_data_tready
      .s_axis_data_tlast(in_last),                                // input wire s_axis_data_tlast
      
      .m_axis_data_tdata(out_fft),                                // output wire [31 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(out_valid),                             // output wire m_axis_data_tvalid
      .m_axis_data_tready(out_ready),                             // input wire m_axis_data_tready
      .m_axis_data_tlast(out_last),                               // output wire m_axis_data_tlast
      
      .event_frame_started(event_frame_started),                  // output wire event_frame_started
      .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
      .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
      .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
      .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
      .event_data_out_channel_halt(event_data_out_channel_halt)   // output wire event_data_out_channel_halt
);

assign out_data = out_fft[31:0];    

endmodule