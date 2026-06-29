`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2026 03:50:46 PM
// Design Name: 
// Module Name: test_bench
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

`timescale 1ns/1ps

module axi_video_source_tb;

////////////////////////////////////////////////////////////
// CLOCK / RESET
////////////////////////////////////////////////////////////

reg aclk = 0;
reg llc_buffered = 0;
reg aresetn = 0;

always #5  aclk = ~aclk;          // 100 MHz AXI clock
always #13 llc_buffered = ~llc_buffered;  // ~38 MHz ADC clock

////////////////////////////////////////////////////////////
// AXI INPUT TIMING
////////////////////////////////////////////////////////////

reg s_axis_tvalid = 1;
reg s_axis_tuser  = 0;
reg s_axis_tlast  = 0;

wire s_axis_tready;

////////////////////////////////////////////////////////////
// AXI OUTPUT
////////////////////////////////////////////////////////////

wire [47:0] m_axis_tdata;
wire        m_axis_tvalid;
wire        m_axis_tuser;
wire        m_axis_tlast;
reg         m_axis_tready = 1;

////////////////////////////////////////////////////////////
// ADC PIXEL INPUT
////////////////////////////////////////////////////////////

reg [7:0] pix_in;

////////////////////////////////////////////////////////////
// DUT
////////////////////////////////////////////////////////////

axi_video_source DUT
(
    .aclk(aclk),
    .aresetn(aresetn),

    .m_axis_tdata(m_axis_tdata),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tready(m_axis_tready),
    .m_axis_tuser(m_axis_tuser),
    .m_axis_tvalid(m_axis_tvalid),

    .s_axis_tlast(s_axis_tlast),
    .s_axis_tready(s_axis_tready),
    .s_axis_tuser(s_axis_tuser),
    .s_axis_tvalid(s_axis_tvalid),

    .llc_buffered(llc_buffered),
    .pix_in(pix_in)
);

////////////////////////////////////////////////////////////
// FRAME PARAMETERS
////////////////////////////////////////////////////////////

parameter H_ACTIVE = 720;
parameter V_ACTIVE = 240;

integer x;
integer y;

////////////////////////////////////////////////////////////
// TASK : SEND SAV
////////////////////////////////////////////////////////////

task send_sav;
begin
    @(posedge llc_buffered); pix_in <= 8'hFF;
    @(posedge llc_buffered); pix_in <= 8'h00;
    @(posedge llc_buffered); pix_in <= 8'h00;
    @(posedge llc_buffered); pix_in <= 8'h00; // SAV (bit4=0 bit5=0)
end
endtask

////////////////////////////////////////////////////////////
// TASK : SEND EAV
////////////////////////////////////////////////////////////

task send_eav;
begin
    @(posedge llc_buffered); pix_in <= 8'hFF;
    @(posedge llc_buffered); pix_in <= 8'h00;
    @(posedge llc_buffered); pix_in <= 8'h00;
    @(posedge llc_buffered); pix_in <= 8'h10; // EAV (bit4=1)
end
endtask

////////////////////////////////////////////////////////////
// TASK : SEND PIXELS
////////////////////////////////////////////////////////////

task send_pixels;
input integer count;
integer i;
begin

for(i=0;i<count;i=i+1)
begin

    @(posedge llc_buffered) pix_in <= $random;
    @(posedge llc_buffered) pix_in <= $random;
    @(posedge llc_buffered) pix_in <= $random;
    @(posedge llc_buffered) pix_in <= $random;

end

end
endtask

////////////////////////////////////////////////////////////
// FRAME GENERATION
////////////////////////////////////////////////////////////

task send_frame;

begin

for(y=0; y<V_ACTIVE; y=y+1)
begin

    send_sav;

    send_pixels(H_ACTIVE);

    send_eav;

end

end

endtask

////////////////////////////////////////////////////////////
// RESET
////////////////////////////////////////////////////////////

initial
begin

pix_in = 0;

#200
aresetn = 1;

end

////////////////////////////////////////////////////////////
// TEST SEQUENCE
////////////////////////////////////////////////////////////

initial
begin

wait(aresetn);

#200

$display("Sending Frame...");

send_frame();

#100000

$display("Simulation finished");

$stop;

end

////////////////////////////////////////////////////////////
// AXI MONITOR
////////////////////////////////////////////////////////////

integer pixel_count = 0;
integer line_count  = 0;

always @(posedge aclk)
begin

if(m_axis_tvalid && m_axis_tready)
begin

    pixel_count = pixel_count + 1;

    if(m_axis_tlast)
    begin
        line_count = line_count + 1;
        pixel_count = 0;
        $display("Line %d transmitted", line_count);
    end

    if(m_axis_tuser)
    begin
        $display("Start of frame detected at time %t", $time);
    end

end

end

endmodule