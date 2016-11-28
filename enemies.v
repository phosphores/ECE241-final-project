module enemies(
	input clock,
	input reset,

	//state signals from control
	input init,
	input idle,
	input gen_move,
	input apply_move,
	input draw,

	//3 bit wire carrying collision information
	input [2:0] collision,

	//link position for tracking movement
	input	[8:0] link_x_pos,
	input [7:0] link_y_pos,
	
	output reg gen_move_done,

	//enemy position for collision_detector and vga
	output [8:0] enemy_1_x_pos,
	output [7:0] enemy_1_y_pos,

	output [8:0] enemy_2_x_pos,
	output [7:0] enemy_2_y_pos,

	output [8:0] enemy_3_x_pos,
	output [7:0] enemy_3_y_pos,

	output reg [8:0] x_draw,
	output reg [7:0] y_draw,

	//enemy direction data for collision_detector
	output [2:0] enemy_1_direction,
	output [2:0] enemy_2_direction,
	output [2:0] enemy_3_direction,
	
	//memory output data for VGA
	output reg [5:0] colour,

	//output write enable to VGA
	output reg VGA_write,

	//output finished signals
	output reg draw_done
	);

	/** local parameters **/
	parameter	ON 			= 1'b1,
					OFF		 	= 1'b0;

	/** wires and registers **/
	//gen move enable signals for each enemy module
	reg gen_move_1, gen_move_2, gen_move_3;
	
	//draw enable signals for each enemy module
	reg draw_1, draw_2, draw_3;
	
	reg [1:0] gen_count;

	//wires for each enemies
	wire [8:0] enemy_1_x_draw;
	wire [7:0] enemy_1_y_draw;
	wire [5:0] colour_1;
	wire VGA_write_1;
	wire draw_done_1;

	wire [8:0] enemy_2_x_draw;
	wire [7:0] enemy_2_y_draw;
	wire [5:0] colour_2;
	wire VGA_write_2;
	wire draw_done_2;

	wire [8:0] enemy_3_x_draw;
	wire [7:0] enemy_3_y_draw;
	wire [5:0] colour_3;
	wire VGA_write_3;
	wire draw_done_3;

	/** enemy modules **/
	//enemy 1
	single_enemy enemy_1(
		.clock	(clock),
		.reset	(reset),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw					(draw_1),

		.collision			(collision[0]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_y_pos),

		.x_pos				(enemy_1_x_pos),
		.y_pos				(enemy_1_y_pos),
		.x_draw				(enemy_1_x_draw),
		.y_draw				(enemy_1_y_draw),

		.direction			(enemy_1_direction),

		.colour				(colour_1),

		.VGA_write			(VGA_write_1),

		.draw_done			(draw_done_1));
	//using default x, y values

	//enemy 2
	single_enemy enemy_2(
		.clock	(clock),
		.reset	(reset),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw					(draw_2),

		.collision			(collision[1]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_y_pos),

		.x_pos				(enemy_2_x_pos),
		.y_pos				(enemy_2_y_pos),
		.x_draw				(enemy_2_x_draw),
		.y_draw				(enemy_2_y_draw),

		.direction			(enemy_2_direction),

		.colour				(colour_2),

		.VGA_write			(VGA_write_2),

		.draw_done			(draw_done_2));
	//using default x position
	defparam enemy_2.Y_INITIAL = 8'd63;

	//enemy 3
	single_enemy enemy_3(
		.clock	(clock),
		.reset	(reset),
		
		.init					(init),
		.idle					(idle),
		.gen_move			(gen_move),
		.apply_move			(apply_move),
		.draw					(draw_3),

		.collision			(collision[2]),

		.link_x_pos			(link_x_pos),
		.link_y_pos			(link_y_pos),

		.x_pos				(enemy_3_x_pos),
		.y_pos				(enemy_3_y_pos),
		.x_draw				(enemy_3_x_draw),
		.y_draw				(enemy_3_y_draw),

		.direction			(enemy_3_direction),

		.colour				(colour_3),

		.VGA_write			(VGA_write_3),

		.draw_done			(draw_done_3));
	defparam enemy_3.X_INITIAL = 8'd111,
				enemy_3.Y_INITIAL = 8'd159;

	/** sequential logic **/
	always@(posedge clock)
	begin
		if(reset)
		begin
			gen_count <= 2'b0;
			draw_1 <= OFF;
			draw_2 <= OFF;
			draw_3 <= OFF;
			x_draw = 9'b0;
			y_draw = 8'b0;
			colour = 6'b0;
			VGA_write = OFF;
		end
		
		else if(init)
		begin
			gen_count <= 2'b0;
			draw_1 <= OFF;
			draw_2 <= OFF;
			draw_3 <= OFF;
			x_draw = 9'b0;
			y_draw = 8'b0;
			colour = 6'b0;
			VGA_write = OFF;
		end
		
		if(gen_move)
		begin
			gen_count <= gen_count + 1'b1;
			if(gen_count == 2'b00)
			begin
				gen_move_1 <= ON;
				gen_move_2 <= OFF;
				gen_move_3 <= OFF;
				gen_move_done <= OFF;
			end
			if(gen_count == 2'b01)
			begin
				gen_move_1 <= OFF;
				gen_move_2 <= ON;
				gen_move_3 <= OFF;
				gen_move_done <= OFF;
			end
			if(gen_count == 2'b10)
			begin
				gen_move_1 <= OFF;
				gen_move_2 <= OFF;
				gen_move_3 <= ON;
				gen_move_done <= OFF;
			end
			if(gen_count == 2'b11)
			begin
				gen_count <= 2'b0;
				gen_move_1 <= OFF;
				gen_move_2 <= OFF;
				gen_move_3 <= OFF;
				gen_move_done <= ON;				
			end
		end
		
		if(draw)
		begin
			if(!draw_done_1 && !draw_2 && !draw_3)
			begin
				draw_1 <= ON;
				x_draw = enemy_1_x_draw;
				y_draw = enemy_1_y_draw;
				colour = colour_1;
				VGA_write = VGA_write_1;
			end
			
			else if(!draw_done_2 && (draw_done_1 || draw_2))
			begin
				draw_1 <= OFF;
				draw_2 <= ON;
				x_draw = enemy_2_x_draw;
				y_draw = enemy_2_y_draw;
				colour = colour_2;
				VGA_write = VGA_write_2;
			end
			
			else if(!draw_done_3 && (draw_done_2 || draw_3))
			begin
				draw_2 <= OFF;
				draw_3 <= ON;
				x_draw = enemy_3_x_draw;
				y_draw = enemy_3_y_draw;
				colour = colour_3;
				VGA_write = VGA_write_3;
			end
			
			else
			begin
				draw_done <= ON;
				draw_1 <= OFF;
				draw_2 <= OFF;
				draw_3 <= OFF;
				x_draw = 9'b0;
				y_draw = 8'b0;
				colour = 6'b0;
				VGA_write = OFF;
			end
		end
		
		else
			draw_done <= OFF;
	end
			
		
	/** combinational logic **/
//	always@(*)
//	begin
//		if(reset)
//		begin
//			draw_1 = OFF;
//			draw_2 = OFF;
//			draw_3 = OFF;
//		end
//		
//		else if(init)
//		begin
//			draw_1 = OFF;
//			draw_2 = OFF;
//			draw_3 = OFF;
//		end
//		
//		else if(draw)
//		begin
//			//start drawing enemy 1 when draw signal is on
//			draw_1 = ON;
//			//connect colour and VGA_write to enemy 1 while drawing
//			if(!draw_done_1)
//			begin
//				x_draw = enemy_1_x_draw;
//				y_draw = enemy_1_y_draw;
//				colour = colour_1;
//				VGA_write = VGA_write_1;
//			end
//
//			//after enemy 1 is done start drawing draw enemy 2
//			if(draw_done_1)
//				draw_2 = ON;
//				//connect colour and VGA_write to enemy 2 while drawing
//				if(!draw_done_2)
//				begin
//					x_draw = enemy_2_x_draw;
//					y_draw = enemy_2_y_draw;
//					colour = colour_2;
//					VGA_write = VGA_write_2;
//				end
//
//			//after enemy 2 is done start drawing draw enemy 3
//			if(draw_done_2)
//				draw_3 = ON;
//				//connect colour and VGA_write to enemy 3 while drawing
//				if(!draw_done_3)
//				begin
//					x_draw = enemy_3_x_draw;
//					y_draw = enemy_3_y_draw;
//					colour = colour_3;
//					VGA_write = VGA_write_3;
//				end
//
//			//done drawing all, set draw_done to on
//			if(draw_done_3)
//				draw_done = ON;
//		end
//
//		else
//			draw_done = OFF;
//	end


endmodule