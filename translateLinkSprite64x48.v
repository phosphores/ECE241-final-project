<<<<<<< HEAD
module translateLinkSprite64x64(input [5:0]x, input [5:0] y, output reg[11:0]mem_address);
	always@(*)begin
		mem_address = ({1'b0, y, 6'd0} + x);
	end
=======
module translateLinkSprite64x64(input [5:0]x, input [5:0] y, output reg[11:0]mem_address);
	always@(*)begin
		mem_address = ({1'b0, y, 6'd0} + x);
	end
>>>>>>> 398b6163507d39e01f657ddec45dfebff234a280
endmodule