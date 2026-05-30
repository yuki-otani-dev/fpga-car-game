`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/01/20 20:42:41
// Design Name: 
// Module Name: receive
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


module receive(

input clk_fpga,
input reset,
input RxD,
output [7:0]RxData,
output [11:0] SEG
    );
    
reg shift;
reg state, nextstate;
reg [3:0] bit_counter;
reg [1:0] sample_counter;
reg [13:0] baudrate_counter;
reg [9:0] rxshift_reg;
reg clear_bitcounter, inc_bitcounter, inc_samplecounter, clear_samplecounter;

parameter clk_freq = 100_000_000;
parameter baud_rate = 921_600;
parameter div_sample = 4;
parameter div_counter = clk_freq / (baud_rate * div_sample);
parameter mid_sample = (div_sample / 2);
parameter div_bit = 10;

reg [12:0] temp_seg;
reg [7:0] temp_seg0 = 8'b11111111;
reg [7:0] temp_seg1;
reg [7:0] temp_seg2;
reg [7:0] temp_seg3;
reg [7:0] temp_seg4;
reg [7:0] temp_seg5;
reg [7:0] temp_seg6;
reg [7:0] temp_seg7;
reg [7:0] temp_seg8;

reg [7:0] seg1;
reg [7:0] seg2;
reg [7:0] seg3;
reg [7:0] seg4;

reg [19:0] c_cnt;
reg [2:0] WE_out, WE_buff;
reg [20:0] count;
reg [30:0] shift_count;
reg [3:0] statement;
reg [4:0] shift_state = 4'b0;

reg [12:0] shift_reg1 = 12'b011100000000;
reg [12:0] shift_reg2 = 12'b101100000000;
reg [12:0] shift_reg3 = 12'b110100000000;
reg [12:0] shift_reg4 = 12'b111000000000;
 
assign RxData = rxshift_reg [8:1];

always @ (posedge clk_fpga)
    begin
        if(reset)begin
            state <= 0;
            bit_counter <= 0;
            baudrate_counter <= 0;
            sample_counter <= 0;
         end else begin
            baudrate_counter <= baudrate_counter + 1;
            if(baudrate_counter >= div_counter - 1) begin
                baudrate_counter <= 0;
                state <= nextstate;
                if(shift)rxshift_reg <= {RxD, rxshift_reg[9:1]};
                if(clear_samplecounter) sample_counter <= 0;
                if(inc_samplecounter) sample_counter <= sample_counter + 1;
                if(clear_bitcounter) bit_counter <= 0;
                if(inc_bitcounter)bit_counter <= bit_counter + 1;
            end
        end
    end
always @ (posedge clk_fpga)
begin
    shift <= 0;
    clear_samplecounter <= 0;
    inc_samplecounter <= 0;
    clear_bitcounter <= 0;
    inc_bitcounter <= 0;
    nextstate <= 0;
    case(state)
        0:begin
            if(RxD)
                begin
                nextstate <= 0;
                end
            else begin
                nextstate <= 1;
                clear_bitcounter <= 1;
                clear_samplecounter <= 1;
            end
        end
        1:begin
            nextstate <= 1;
            if(sample_counter == mid_sample - 1) shift <= 1;
                if(sample_counter == div_sample - 1)begin
                    if(bit_counter == div_bit - 1) begin
                nextstate <= 0;
                end
                inc_bitcounter <= 1;
                clear_samplecounter <= 1;
            end else inc_samplecounter <= 1;
        end
        default: nextstate <= 0;
    endcase
end 

always@ (posedge clk_fpga or negedge reset) begin
    if(reset)
        c_cnt <= 20'b0;
    else
        c_cnt <= c_cnt + 1'b1;
end

always@ (posedge clk_fpga) begin
    if(c_cnt == 0)
        WE_out <= RxData;
end

always@(posedge clk_fpga or negedge reset) begin
    if(reset)
        WE_buff <= 20'b0;
    else
        WE_buff <= WE_out;
end

assign WE = WE_out & ~WE_buff;

always @ (posedge clk_fpga)
    begin
        if(RxData == 8'b00110001) //right
        begin
            temp_seg1 <= 8'b1_0101111;
            temp_seg2 <= 8'b1_1001111;
            temp_seg3 <= 8'b1_1000010;
            temp_seg4 <= 8'b1_0001001;
            temp_seg5 <= 8'b1_0000111;
            temp_seg6 <= temp_seg0;
            temp_seg7 <= temp_seg0;
            temp_seg8 <= temp_seg0;
        end
        else if(RxData == 8'b00110010) //left
        begin
            temp_seg1 <= 8'b1_1000111;
            temp_seg2 <= 8'b1_0000110;
            temp_seg3 <= 8'b1_0001110;
            temp_seg4 <= 8'b1_0000111;
            temp_seg5 <= temp_seg0;
            temp_seg6 <= temp_seg0;
            temp_seg7 <= temp_seg0;
            temp_seg8 <= temp_seg0;
        end
        else if(RxData == 8'b00110011) //straight
        begin
            temp_seg1 <= 8'b1_0010010;
            temp_seg2 <= 8'b1_0000111;
            temp_seg3 <= 8'b1_0101111;
            temp_seg4 <= 8'b1_0001000;           
            temp_seg5 <= 8'b1_1001111;
            temp_seg6 <= 8'b1_1000010;
            temp_seg7 <= 8'b1_0001001;
            temp_seg8 <= 8'b1_0000111;
        end     
    end  

always@ (posedge clk_fpga)
begin
    shift_count <= shift_count + 30'd1000000;
    if(shift_count == 30'd1000000)
    begin
        shift_count = 0;
        shift_state <= shift_state + 1'b1;
    end
    if(shift_state == 4'b0001)
    begin
        count <= count + 1'b1;
        if(count == 20'd10000)
        begin
            seg1 <= temp_seg1;
            seg2 <= temp_seg2;
            seg3 <= temp_seg3;
            seg4 <= temp_seg4;
            count <= 0;
            statement = statement + 1'b1;
            if(statement == 0)
                temp_seg <= {shift_reg1 + seg1};
            else if(statement == 1)
                temp_seg <= {shift_reg2 + seg2};
            else if(statement == 2)
                temp_seg <= {shift_reg3 + seg3};
            else if(statement == 3)
                temp_seg <= {shift_reg4 + seg4};
        end
    end
    if(shift_state == 4'b0010)
    begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg2;
                seg2 <= temp_seg3;
                seg3 <= temp_seg4;
                seg4 <= temp_seg5;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
        end
        if(shift_state == 4'b0011)
        begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg3;
                seg2 <= temp_seg4;
                seg3 <= temp_seg5;
                seg4 <= temp_seg6;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
        end
        if(shift_state == 4'b0100)
        begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg4;
                seg2 <= temp_seg5;
                seg3 <= temp_seg6;
                seg4 <= temp_seg7;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
        end
        if(shift_state == 4'b0101)
        begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg5;
                seg2 <= temp_seg6;
                seg3 <= temp_seg7;
                seg4 <= temp_seg8;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
        end
        if(shift_state == 4'b0110)
        begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg6;
                seg2 <= temp_seg7;
                seg3 <= temp_seg8;
                seg4 <= temp_seg0;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
        end
        if(shift_state == 4'b0111)
        begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg7;
                seg2 <= temp_seg8;
                seg3 <= temp_seg0;
                seg4 <= temp_seg1;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
        end
        if(shift_state == 4'b1000)
        begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg8;
                seg2 <= temp_seg0;
                seg3 <= temp_seg1;
                seg4 <= temp_seg2;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
         end
        if(shift_state == 4'b1001)
                begin
            count <= count + 1'b1;
            if(count == 20'd10000)
            begin
                seg1 <= temp_seg0;
                seg2 <= temp_seg1;
                seg3 <= temp_seg2;
                seg4 <= temp_seg3;
                count <= 0;
                statement = statement + 1'b1;
                if(statement == 0)
                    temp_seg <= {shift_reg1 + seg1};
                else if(statement == 1)
                    temp_seg <= {shift_reg2 + seg2};
                else if(statement == 2)
                    temp_seg <= {shift_reg3 + seg3};
                else if(statement == 3)
                    temp_seg <= {shift_reg4 + seg4};
             end
         end
         if(shift_state == 4'b1010)
            shift_state = 1;        
     end
assign SEG = temp_seg;
endmodule
