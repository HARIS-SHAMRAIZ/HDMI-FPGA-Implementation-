
//module axi_video_source
//(
//    input  wire        aclk,
//    input  wire        aresetn,

//    // AXI OUTPUT (to HDMI)
//    output reg  [47:0] m_axis_tdata,
//    output wire        m_axis_tlast,
//    input  wire        m_axis_tready,
//    output wire        m_axis_tuser,
//    output             m_axis_tvalid,

//    // AXI INPUT timing passthrough
//    input  wire        s_axis_tlast,
//    output wire        s_axis_tready,
//    input  wire        s_axis_tuser,
//    input  wire        s_axis_tvalid,
    
//    input  wire        llc_buffered,
//    input  wire [7:0]  pix_in
//);

//////////////////////////////////////////////////////////////
//// FIFO SIGNALS
//////////////////////////////////////////////////////////////

//wire [7:0] fifo_dout;
//reg  [7:0] fifo_din;

//wire fifo_full;
//wire fifo_empty;

//wire rd_en;

//wire wr_rst_busy;
//wire rd_rst_busy;

//reg fifo_empty_r;
//reg rd_rst_busy_r;
//reg fifo_full_r;
//reg wr_rst_busy_r;

//////////////////////////////////////////////////////////////
//// PIXEL REGISTERS
//////////////////////////////////////////////////////////////
//reg blk_wr_en;
//////////////////////////////////////////////////////////////
//// STATE MACHINE
//////////////////////////////////////////////////////////////
//localparam ST_WAIT_SAV    = 2'd0,
//           ST_PACK_PIXELS = 2'd1;

//reg [1:0] state;
//////////////////////////////////////////////////////////////
//// CONTROL CODE DETECTION
//////////////////////////////////////////////////////////////

//reg [7:0] r1,r2,r3;

//wire parity_ok ,H_bit, F_bit; 

//wire xyz_detect = (r3 == 8'hFF) && (r2 == 8'h00) && (r1 == 8'h00);

//wire sav_detect = xyz_detect && (pix_in[4] == 1'b0);
//wire eav_detect = xyz_detect && (pix_in[4] == 1'b1);
////wire Field_p = parity_ok && (pix_in[6] == 1'b1);
//wire Field_p =   xyz_detect && (pix_in[6] == 1'b1);
//assign parity_ok =
//       (pix_in[3] == (v_bit ^ H_bit)) &&
//       (pix_in[2] == (F_bit ^ H_bit)) &&
//       (pix_in[1] == (F_bit ^ v_bit)) &&
//       (pix_in[0] == (F_bit ^ v_bit ^ H_bit));
       
//assign H_bit = xyz_detect && pix_in[4];
//assign v_bit = xyz_detect && pix_in[5];
//assign F_bit = xyz_detect && pix_in[6];       
//////////////////////////////////////////////////////////////
//// FRAME START DETECTION
//////////////////////////////////////////////////////////////

//wire frame_start = /*F_prev  && */ Field_p;
//wire field_start = /*v_prev  && */ v_bit;
//wire H_start     = /*H_prev  && */ H_bit;

//////////////////////////////////////////////////////////////
//// LINE COUNTERS
//////////////////////////////////////////////////////////////

////reg [10:0] total_line_cnt;
////reg [10:0] total_line_F2;
////reg [10:0] Blank_line_cnt;
////reg [10:0] H_Blank_cnt;
////reg [10:0] H_Active_cnt;
//reg [0:0]  Frame_reset;
//reg [0:0] start_reset = 1;

//////////////////////////////////////////////////////////////
//// PIXEL POSITION
//////////////////////////////////////////////////////////////

//reg [10:0] x_pos;
//reg [10:0] y_pos;

//////////////////////////////////////////////////////////////
//// PIXEL REGISTERS
//////////////////////////////////////////////////////////////

//reg [7:0] cb_reg;
//reg [7:0] cr_reg;
//reg [7:0] y_reg;

//reg [1:0] byte_idx;

//////////////////////////////////////////////////////////////
//// MAIN PROCESS
//////////////////////////////////////////////////////////////

//always @(posedge llc_buffered)
//begin
//    if(!aresetn)
//    begin

//        r1 <= 0;
//        r2 <= 0;
//        r3 <= 0;

////        total_line_cnt         <= 0;
////        total_line_F2          <= 0;
////        Blank_line_cnt         <= 0;
////        H_Blank_cnt            <= 0;
////        H_Active_cnt           <= 0;

//        x_pos <= 0;
//        y_pos <= 0;

//        state <= ST_WAIT_SAV;

//        byte_idx <= 0;

//        blk_wr_en <= 0;
//        Frame_reset <= 0;

//    end
//    else
//    begin
//        ////////////////////////////////////////////////////
//        // SHIFT REGISTER
//        ////////////////////////////////////////////////////
//        r3 <= r2;
//        r2 <= r1;
//        r1 <= pix_in;
        
//            if ((y_pos == 0 && x_pos == 0) /*|| (y_pos == 262 && x_pos == 0)*/)
//            Frame_reset <= 1;
//            else 
//            Frame_reset <=0;
            
//        case(state)
//        ////////////////////////////////////////////////////
//        // WAIT FOR SAV
//        ////////////////////////////////////////////////////
//        ST_WAIT_SAV:
//        begin 
//            if(sav_detect)
//            begin
//                x_pos <= 0;
//                if(!v_bit)
//                begin
//                    state    <= ST_PACK_PIXELS;
//                    byte_idx <= 0;
//                end
//            end
//        end
//        ////////////////////////////////////////////////////
//        // PIXEL PACKING
//        ////////////////////////////////////////////////////
//        ST_PACK_PIXELS:
//        begin
//            case(byte_idx)
//            2'd0:
//            begin
//                cb_reg   <= pix_in;
//                byte_idx <= 1;
//                blk_wr_en <= 0; 
//            end
//            2'd1:
//            begin

//                fifo_din <= pix_in;
//                if((y_pos > 9 && y_pos <= 249)  && x_pos < 720)
//                    blk_wr_en <= 1;
//                    else 
//                     blk_wr_en <= 0;
                                   
//                x_pos <= x_pos + 1;
//                byte_idx <= 2;
//            end
//            2'd2:
//            begin
//                cr_reg   <= pix_in;
//                byte_idx <= 3;
//                blk_wr_en <= 0;
//            end
//            2'd3:
//            begin
//                fifo_din <= pix_in;
//                if((y_pos > 9 && y_pos <= 249)  && x_pos < 720)
//                    blk_wr_en <= 1;
//                    else 
//                     blk_wr_en <= 0;  
                                                        
//                x_pos <= x_pos + 1;
//                byte_idx <= 0;
//            end
//            endcase
//            ////////////////////////////////////////////////////
//            // END OF LINE
//            ////////////////////////////////////////////////////
//            if(eav_detect)
//            begin
//                state <= ST_WAIT_SAV;
//                x_pos <= 0;
//                y_pos <= (v_bit)? 0 : y_pos + 1;
//            end
//        end
//        endcase
//    end
//end

//assign m_axis_tlast  = s_axis_tlast;
//assign m_axis_tuser  = s_axis_tuser;
//assign s_axis_tready = m_axis_tready;
//assign m_axis_tvalid = s_axis_tvalid ;
//wire pixel_fire = m_axis_tvalid && m_axis_tready;
//////////////////////////////////////////////////////////////
//// AXI PASSTHROUGH SIGNALS
//////////////////////////////////////////////////////////////
////reg s_axis_tuser1 = 0;
////reg s_axis_tlast1 = 0;
////assign m_axis_tlast  = s_axis_tlast1;
////assign m_axis_tuser  = s_axis_tuser1;
////assign s_axis_tready = m_axis_tready;
////assign m_axis_tvalid = 1 ;
////assign m_axis_tvalid = !fifo_empty_r /*&& !rd_rst_busy_r*/;
////wire pixel_fire = m_axis_tvalid && m_axis_tready;
//////////////////////////////////////////////////////////////
//// AXI VIDEO CONTROL
//////////////////////////////////////////////////////////////
//reg [9:0] line_count1  = 0;
//reg [9:0] pixel_count1 = 0;
//always @(posedge aclk) begin

//if (line_count1 ==0 && pixel_count1 == 1)
//start_reset <= 0;

//    if (!aresetn) begin
//        line_count1   <= 0;
//        pixel_count1  <= 0;
////        s_axis_tlast1 <= 0;
////        s_axis_tuser1 <= 0;

//    end
//    else if (pixel_fire) begin

//        line_count1 <= (line_count1 == 10'd239 && s_axis_tlast) ?
//                        0 :
//                        (s_axis_tlast) ?
//                        line_count1 + 1 :
//                        line_count1;

//        pixel_count1 <= (pixel_count1 == 10'd719) ?
//                        0 :
//                        pixel_count1 + 1;

////        if (line_count1 == 10'd239 && pixel_count1 == 10'd719)
////            s_axis_tuser1 <= 1;
////        else
////            s_axis_tuser1 <= 0;

////        if (pixel_count1 == 10'd718)
////            s_axis_tlast1 <= 1;
////        else
////            s_axis_tlast1 <= 0;
//    end
//end

//////////////////////////////////////////////////////////////
//// FIFO STATUS REGISTERS
//////////////////////////////////////////////////////////////

//always @(posedge aclk) begin
//    fifo_full_r   <= fifo_full;
//    wr_rst_busy_r <= wr_rst_busy;
//end

//always @(posedge aclk) begin
//    fifo_empty_r  <= fifo_empty;
//    rd_rst_busy_r <= rd_rst_busy;
//end

//assign rd_en = pixel_fire && !fifo_empty_r/* &&!rd_rst_busy_r*/;
//////////////////////////////////////////////////////////////
//// GRAY → RGB
//////////////////////////////////////////////////////////////
//always @(posedge aclk) begin
//    if (!aresetn)
//        m_axis_tdata <= 0;
//    else if (pixel_fire)
//    begin
//        m_axis_tdata <= (fifo_full)  ? {8'hff,8'h0,8'h0,8'hff,8'h0,8'h0}
//                                     : {fifo_dout,fifo_dout,
//                                        fifo_dout,fifo_dout,
//                                        fifo_dout,fifo_dout};                        
//                         end
//end

//fifo_generator_0 image_fifo
//(
//    .srst(!aresetn /*|| Frame_reset || start_reset*/),

//    .wr_clk(llc_buffered),
//    .rd_clk(aclk),

//    .din(fifo_din),

//    .wr_en(blk_wr_en),
//    .rd_en(rd_en),

//    .dout(fifo_dout),

//    .full(fifo_full),
//    .empty(fifo_empty),

//    .wr_rst_busy(wr_rst_busy),
//    .rd_rst_busy(rd_rst_busy)
//);
//endmodule

////////////////////////////////////////////////////////////////
////// Y_POS == 0 PULSE GENERATION (LLC DOMAIN)
////////////////////////////////////////////////////////////////
////reg y0_d;
////wire y0_pulse_llc;
////////////////////////////////////////////////////////////////
////// FIFO INSTANCE
////////////////////////////////////////////////////////////////
////// Synchronize frame start from llc_buffered to aclk
////reg y0_sync1, y0_sync2;
////wire y0_pulse_aclk = y0_sync1 & ~y0_sync2;
////////////////////////////////////////////////////////////////
////// CDC: LLC → ACLK  (y==0 pulse crossing clock domain)
////////////////////////////////////////////////////////////////
////always @(posedge aclk)
////begin
////    if (!aresetn)
////    begin
////        y0_sync1 <= 1'b0;
////        y0_sync2 <= 1'b0;
////    end
////    else
////    begin
////        y0_sync1 <= Frame_reset;
////        y0_sync2 <= y0_sync1;
////    end
////end
////////////////////////////////////////////////////////////////
////// COUNTER 1 : Y==0 FRAME PERIOD
////////////////////////////////////////////////////////////////
////reg [31:0] y0_period_cnt;
////reg [31:0] y0_period_latched;

////always @(posedge aclk)
////begin
////    if (!aresetn)
////    begin
////        y0_period_cnt     <= 32'd0;
////        y0_period_latched <= 32'd0;
////    end
////    else
////    begin
////        y0_period_cnt <= y0_period_cnt + 1;

////        if (y0_pulse_aclk)
////        begin
////            y0_period_latched <= y0_period_cnt;
////            y0_period_cnt     <= 32'd0;
////        end
////    end
////end
////////////////////////////////////////////////////////////////
////// TUSER POSEDGE DETECTOR
////////////////////////////////////////////////////////////////
////reg tuser_d1;
////always @(posedge aclk)
////begin
////    if (!aresetn)
////        tuser_d1 <= 1'b0;
////    else
////        tuser_d1 <= s_axis_tuser;
////end

////// detect rising edge
////wire tuser_pulse;
////assign tuser_pulse = s_axis_tuser & ~tuser_d1;
////////////////////////////////////////////////////////////////
////// COUNTER 2 : TUSER FRAME PERIOD
////////////////////////////////////////////////////////////////
////reg [31:0] tuser_period_cnt;
////reg [31:0] tuser_period_latched;
////always @(posedge aclk)
////begin
////    if (!aresetn)
////    begin
////        tuser_period_cnt     <= 32'd0;
////        tuser_period_latched <= 32'd0;
////    end
////    else
////    begin
////        tuser_period_cnt <= tuser_period_cnt + 1;

////        if (tuser_pulse)
////        begin
////            tuser_period_latched <= tuser_period_cnt;
////            tuser_period_cnt     <= 32'd0;
////        end
////    end
////end
////////////////////////////////////////////////////////////////
////// ILA DEBUG
////////////////////////////////////////////////////////////////
////ila_0 Debug
////(
////    .clk(aclk),
////    .probe0({
//////        frame_start,H_start,field_start,parity_ok,
//////        eav_detect,sav_detect,xyz_detect,
//////        active_line_cnt_prv,Frame_reset,start_reset,
//////        total_line_cnt,total_line_F2,
//////          active_line_cnt,Blank_line_cnt, 
//////        H_bit, F_bit,v_bit,Field_p,
//////          blk_wr_cnt, pixel_cnt,tuser_pulse,   
////        y0_period_cnt,tuser_period_cnt,y0_pulse_aclk,
//////          m_axis_tlast,s_axis_tready, m_axis_tuser,
////        m_axis_tvalid,s_axis_tuser1, s_axis_tlast1,pixel_fire,
//////        line_count1, pixel_count1,in_frame_gap,
//////        y_pos,x_pos,blk_wr_en,Frame_reset,
//////        H_Blank_cnt, H_Active_cnt,
////        fifo_full,fifo_empty,rd_en,
////        wr_rst_busy, rd_rst_busy,fifo_full_r,wr_rst_busy_r
////    })
////);

module axi_video_source
(
    input  wire        aclk,
    input  wire        aresetn,

    // AXI OUTPUT (to HDMI)
    output reg  [47:0] m_axis_tdata,
    output wire        m_axis_tlast,
    input  wire        m_axis_tready,
    output wire        m_axis_tuser,
    output wire        m_axis_tvalid,

    // AXI INPUT timing passthrough (HDMI timing reference)
    input  wire        s_axis_tlast,
    output wire        s_axis_tready,
    input  wire        s_axis_tuser,
    input  wire        s_axis_tvalid,

    // ADC / BT.656 side
    input  wire        llc_buffered,
    input  wire [7:0]  pix_in
);

////////////////////////////////////////////////////////////
// FIFO SIGNALS
////////////////////////////////////////////////////////////
wire [7:0] fifo_dout;
reg  [7:0] fifo_din;

wire fifo_full;
wire fifo_empty;
wire wr_rst_busy;
wire rd_rst_busy;

wire  rd_en;
reg  fifo_rst;

////////////////////////////////////////////////////////////
// AXI PASSTHROUGH
////////////////////////////////////////////////////////////
assign m_axis_tlast  = s_axis_tlast;
assign m_axis_tuser  = s_axis_tuser;
assign s_axis_tready = m_axis_tready;
assign m_axis_tvalid = s_axis_tvalid;

wire pixel_fire = m_axis_tvalid && m_axis_tready;

////////////////////////////////////////////////////////////
// TUSER EDGE DETECT (ACLK DOMAIN)
////////////////////////////////////////////////////////////
reg s_axis_tuser_d;
wire tuser_pulse;

always @(posedge aclk) begin
    if (!aresetn)
        s_axis_tuser_d <= 1'b0;
    else
        s_axis_tuser_d <= s_axis_tuser;
end

assign tuser_pulse = s_axis_tuser & ~s_axis_tuser_d;

////////////////////////////////////////////////////////////
// FRAME CONTROL (ACLK DOMAIN)
////////////////////////////////////////////////////////////
// first 9 frames: FIFO reset + HDMI black
// 10th frame: release FIFO reset, arm capture, still HDMI black
// 11th frame: start FIFO read
////////////////////////////////////////////////////////////
reg [15:0] hdmi_frame_cnt;   // counts s_axis_tuser pulses
reg       blank_output;     // send black to HDMI
reg       read_enable;      // allow FIFO read on/after 11th frame
reg       capture_arm_toggle; // toggle sent to LLC domain at 10th frame

always @(posedge aclk) begin
    if (!aresetn) begin
        hdmi_frame_cnt    <= 16'd0;
        fifo_rst          <= 1'b1;
        blank_output      <= 1'b1;
        read_enable       <= 1'b0;
        capture_arm_toggle <= 1'b0;
    end
    else begin
        if (tuser_pulse) begin
            if (hdmi_frame_cnt < 16'd1500)
                hdmi_frame_cnt <= hdmi_frame_cnt + 1'b1;
                else 
                hdmi_frame_cnt <= hdmi_frame_cnt;

            case (hdmi_frame_cnt)
                16'd0,16'd1,16'd2,16'd3,16'd4,16'd5,16'd6,16'd7,16'd8: begin
                    // 1st to 9th tuser
                    fifo_rst     <= 1'b1;
                    blank_output <= 1'b1;
                    read_enable  <= 1'b0;
                end

                16'd1400: begin
                    // 10th tuser
                    // release FIFO reset, arm capture in LLC domain
                    fifo_rst           <= 1'b0;
//                    blank_output       <= 1'b1;
//                    read_enable        <= 1'b0;
                    capture_arm_toggle <= 1'b1;
                end
                16'd1401: begin
                    // 10th tuser
                    // release FIFO reset, arm capture in LLC domain
//                    fifo_rst           <= 1'b0;
                    blank_output       <= 1'b0;
                    read_enable        <= 1'b1;
//                    capture_arm_toggle <= ~capture_arm_toggle;
                end

//                default: begin
//                    // 11th and onward
//                    fifo_rst     <= 1'b0;
//                    blank_output <= 1'b0;
//                    read_enable  <= 1'b1;
//                end
            endcase
        end
    end
end

////////////////////////////////////////////////////////////
// LLC DOMAIN: BT.656 DETECTION
////////////////////////////////////////////////////////////
reg [7:0] r1, r2, r3;

wire xyz_detect = (r3 == 8'hFF) && (r2 == 8'h00) && (r1 == 8'h00);
wire sav_detect = xyz_detect && (pix_in[4] == 1'b0);
wire eav_detect = xyz_detect && (pix_in[4] == 1'b1);

wire H_bit = xyz_detect && pix_in[4];
wire v_bit = xyz_detect && pix_in[5];
wire F_bit = xyz_detect && pix_in[6];

////////////////////////////////////////////////////////////
// PIXEL / LINE TRACKING (LLC DOMAIN)
////////////////////////////////////////////////////////////
localparam ST_WAIT_SAV    = 1'b0;
localparam ST_PACK_PIXELS = 1'b1;

reg        state;
reg [1:0]  byte_idx;
reg [10:0] x_pos;
reg [10:0] y_pos;

reg        blk_wr_en;

////////////////////////////////////////////////////////////
// CAPTURE CONTROL (LLC DOMAIN)
////////////////////////////////////////////////////////////
// After 10th tuser, wait until next ADC frame start (y=0,x=0)
// then start writing pixels into FIFO
////////////////////////////////////////////////////////////
reg capture_active;
reg adc_frame_start;

always @(posedge llc_buffered) begin
        if (fifo_rst ) 
            capture_active <= 1'b0;
        else 
            if (capture_arm_toggle && adc_frame_start) 
                capture_active <= 1'b1;        
    end

////////////////////////////////////////////////////////////
// LLC DOMAIN MAIN PROCESS
////////////////////////////////////////////////////////////
always @(posedge llc_buffered) begin
    if (!aresetn) begin
        r1       <= 8'd0;
        r2       <= 8'd0;
        r3       <= 8'd0;

        x_pos    <= 11'd0;
        y_pos    <= 11'd0;
        state    <= ST_WAIT_SAV;
        byte_idx <= 2'd0;
        blk_wr_en <= 1'b0;
        adc_frame_start <= 1'b0;
        fifo_din <= 8'd0;
    end
    else begin
        // shift register
        r3 <= r2;
        r2 <= r1;
        r1 <= pix_in;

        case (state)
            ////////////////////////////////////////////////////
            // WAIT FOR SAV
            ////////////////////////////////////////////////////
            ST_WAIT_SAV: begin
                if (sav_detect) begin
                    x_pos <= 11'd0;
                    adc_frame_start <= 0; 

                    if (!v_bit) begin
                        state    <= ST_PACK_PIXELS;
                        byte_idx <= 2'd0;
                    end
                end
            end

            ////////////////////////////////////////////////////
            // PACK PIXELS
            ////////////////////////////////////////////////////
            ST_PACK_PIXELS: begin
                case (byte_idx)
                    2'd0: begin
                        // Cb
                        byte_idx <= 2'd1;
                        blk_wr_en <= 1'b0;
                    end

                    2'd1: begin
                        // Y0
                        fifo_din <= pix_in;
//                            if      (x_pos < 11'd90)   fifo_din <= 8'h00;
//                            else if (x_pos < 11'd180)  fifo_din <= 8'h20;
//                            else if (x_pos < 11'd270)  fifo_din <= 8'h40;
//                            else if (x_pos < 11'd360)  fifo_din <= 8'h60;
//                            else if (x_pos < 11'd450)  fifo_din <= 8'h80;
//                            else if (x_pos < 11'd540)  fifo_din <= 8'hA0;
//                            else if (x_pos < 11'd630)  fifo_din <= 8'hC0;
//                            else                       fifo_din <= 8'hFF;
                            // Active video window for 240 lines x 720 pixels
                            if ((y_pos > 11'd9) && (y_pos <= 11'd249) && (x_pos < 11'd720) && !fifo_full)
                                blk_wr_en <= capture_active;
                                else 
                                blk_wr_en <= 1'b0;

                        x_pos    <= x_pos + 1'b1;
                        byte_idx <= 2'd2;
                    end

                    2'd2: begin
                        // Cr
                        byte_idx <= 2'd3;
                        blk_wr_en <= 1'b0;
                    end

                    2'd3: begin
                        // Y1
                        fifo_din <= pix_in;
//                            if      (x_pos < 11'd90)   fifo_din <= 8'h00;
//                            else if (x_pos < 11'd180)  fifo_din <= 8'h20;
//                            else if (x_pos < 11'd270)  fifo_din <= 8'h40;
//                            else if (x_pos < 11'd360)  fifo_din <= 8'h60;
//                            else if (x_pos < 11'd450)  fifo_din <= 8'h80;
//                            else if (x_pos < 11'd540)  fifo_din <= 8'hA0;
//                            else if (x_pos < 11'd630)  fifo_din <= 8'hC0;
//                            else                       fifo_din <= 8'hFF;
                            if ((y_pos > 11'd9) && (y_pos <= 11'd249) && (x_pos < 11'd720) && !fifo_full)
                                blk_wr_en <= capture_active;
                                else 
                                blk_wr_en <= 1'b0;

                        x_pos    <= x_pos + 1'b1;
                        byte_idx <= 2'd0;
                    end
                endcase

                // End of line
                if (eav_detect) begin
                    state <= ST_WAIT_SAV;
                    x_pos  <= 11'd0;

                    if (v_bit)
                    begin 
                        y_pos <= 11'd0;
                        adc_frame_start <= 1;
                        end 
                    else
                    begin
                        y_pos <= y_pos + 1'b1;
                        adc_frame_start <= 0; 
                        end 
                end
            end
        endcase
    end
end

////////////////////////////////////////////////////////////
// HDMI OUTPUT DATA
////////////////////////////////////////////////////////////
assign rd_en = pixel_fire && read_enable  && !fifo_empty && !rd_rst_busy;

always @(posedge aclk) begin
    if (!aresetn) begin
        m_axis_tdata <= 48'd0;
    end
    else if (pixel_fire) begin
        if (blank_output || fifo_empty) begin
            // Output black until read starts or FIFO empty
            m_axis_tdata <= 48'd0;
        end
        else begin
            // Gray -> RGB 16-bit per channel (duplicate 8-bit)
            m_axis_tdata <= {fifo_dout, fifo_dout,
                             fifo_dout, fifo_dout,
                             fifo_dout, fifo_dout};
        end
    end
end

////////////////////////////////////////////////////////////
// FIFO INSTANCE
////////////////////////////////////////////////////////////
fifo_generator_0 image_fifo
(
    .srst(fifo_rst),

    .wr_clk(llc_buffered),
    .rd_clk(aclk),

    .din(fifo_din),
    .wr_en(blk_wr_en ),
    .rd_en(rd_en ),

    .dout(fifo_dout),

    .full(fifo_full),
    .empty(fifo_empty),

    .wr_rst_busy(wr_rst_busy),
    .rd_rst_busy(rd_rst_busy)
);

/*////////////////////////////////////////////////////////////
// Y_POS == 0 PULSE GENERATION (LLC DOMAIN)
////////////////////////////////////////////////////////////
reg y0_d;
wire y0_pulse_llc;
////////////////////////////////////////////////////////////
// FIFO INSTANCE
////////////////////////////////////////////////////////////
// Synchronize frame start from llc_buffered to aclk
reg y0_sync1, y0_sync2;
wire y0_pulse_aclk = y0_sync1 & ~y0_sync2;
////////////////////////////////////////////////////////////
// CDC: LLC → ACLK  (y==0 pulse crossing clock domain)
////////////////////////////////////////////////////////////
always @(posedge aclk)
begin
    if (!aresetn)
    begin
        y0_sync1 <= 1'b0;
        y0_sync2 <= 1'b0;
    end
    else
    begin
        y0_sync1 <= adc_frame_start;
        y0_sync2 <= y0_sync1;
    end
end
////////////////////////////////////////////////////////////
// COUNTER 1 : Y==0 FRAME PERIOD
////////////////////////////////////////////////////////////
reg [31:0] y0_period_cnt;
reg [31:0] y0_period_latched;

always @(posedge aclk)
begin
    if (!aresetn)
    begin
        y0_period_cnt     <= 32'd0;
        y0_period_latched <= 32'd0;
    end
    else
    begin
        y0_period_cnt <= y0_period_cnt + 1;

        if (y0_pulse_aclk)
        begin
            y0_period_latched <= y0_period_cnt;
            y0_period_cnt     <= 32'd0;
        end
    end
end

////////////////////////////////////////////////////////////
// COUNTER 2 : TUSER FRAME PERIOD
////////////////////////////////////////////////////////////
reg [31:0] tuser_period_cnt;
reg [31:0] tuser_period_latched;
always @(posedge aclk)
begin
    if (!aresetn)
    begin
        tuser_period_cnt     <= 32'd0;
        tuser_period_latched <= 32'd0;
    end
    else
    begin
        tuser_period_cnt <= tuser_period_cnt + 1;

        if (tuser_pulse)
        begin
            tuser_period_latched <= tuser_period_cnt;
            tuser_period_cnt     <= 32'd0;
        end
    end
end

ila_0 Debug
(
    .clk(aclk),
    .probe0({
            y0_period_cnt,tuser_period_cnt,y0_pulse_aclk,
           *//*hdmi_frame_cnt,fifo_din, pix_in,*//*
             blank_output, read_enable,capture_arm_toggle,
             xyz_detect ,sav_detect,eav_detect ,H_bit,v_bit,F_bit,capture_active,
             s_axis_tuser_d ,tuser_pulse,adc_frame_start
                 
    })
    );*/
endmodule