module SEQUENCE_DETECTOR(clk, reset, in, out);
  input wire clk, reset, in;
  output reg out;

  reg[2:0] cur_state;

  always @(posedge clk or posedge reset) begin
    if (reset == 1) begin
      cur_state <= 3'b000;
      out <= 0;
    end else begin
      case(cur_state)
        3'b000: begin
          if (in == 1) begin
            cur_state <= 3'b001;
            out <= 0;
          end else begin
            cur_state <= 3'b000;
            out <= 0;
          end
        end
        3'b001: begin
          if (in == 1) begin
            cur_state <= 3'b001;
            out <= 0;
          end else begin
            cur_state <= 3'b010;
            out <= 0;
          end
        end
        3'b010: begin
          if (in == 1) begin
            cur_state <= 3'b011;
            out <= 0;
          end else begin
            cur_state <= 3'b000;
            out <= 0;
          end
        end
        3'b011: begin
          if (in == 1) begin
            cur_state <= 3'b100;
            out <= 1;
          end else begin
            cur_state <= 3'b010;
            out <= 0;
          end
        end
        3'b100: begin
          if (in == 1) begin
            cur_state <= 3'b001;
            out <= 0;
          end else begin
            cur_state <= 3'b010;
            out <= 0;
          end
        end
      endcase
    end
  end
endmodule

module testbench;
  reg clk, reset, in;
  wire out;

  reg[15:0] seq;
  integer i;

  SEQUENCE_DETECTOR duty(clk, reset, in, out);

  initial begin
    clk = 0;
    reset = 1;
    seq = 16'b0110_1010_1101_1100;
    #5 reset = 0;

    for (i = 0; i <= 15; i = i + 1) begin
      in = seq[i];
      #2 clk = 1;
      #2 clk = 0;
      $display("State = ", duty.cur_state, " Input = ", in, " Output = ", out);
    end
  end
endmodule

