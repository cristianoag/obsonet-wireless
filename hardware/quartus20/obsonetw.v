module obsonetw(msx_sltsl, msx_cs1, msx_iorq, msx_wr, msx_rd, msx_reset, msx_data, msx_adr, msx_clk, flash_ce, flash_oe, flash_wr, onet_bt1, clk50m, debug);

	//MSX control signals
	input 	msx_sltsl; 			//MSX slot select
	input 	msx_cs1;				//MSX ROM page 4000h-7FFFh select signal
	input		msx_iorq;			//MSX iorq
	input 	msx_wr;				//MSX write
	input 	msx_rd;				//MSX read
	input  	msx_reset;			//MSX reset
	input 	[7:0] msx_adr;  	//MSX first 8 digits of the MSX adr
	input 	msx_clk;				//MSX clock
	inout    [7:0] msx_data; 	//MSX data bus 
	output   debug;


	//Flash memory control signals
	output 	flash_ce;	//Flash chip enable
	output 	flash_oe;	//Flash output enable
	output  	flash_wr;   //Flash write enable
	 
	//Obsonet board signals
	input 	onet_bt1; 	//Button to avoid flash enablement
    
	//Board clock signal
	input 	clk50m;		//50MHz clock signal
    
	//-------------------- Flash memory control --------------------
	assign flash_ce = (!onet_bt1) || msx_sltsl; //assigns the slot select signal to enable the flash, only if the button on the board is not pushed
	assign flash_oe = msx_cs1; //selects the 4000h-7FFFh (16K) rom page
	assign flash_wr = msx_wr;  //assigns the write signal to the flash write signal
   //TODO: we may need to assign the data and address signals to the flash memory, depending on the use of 3.3V or 5V flash memory

	//-------------------- Port F2 control --------------------
	// Port F2 keeps status when the computer suffers soft reset
	reg [7:0] portF2 = 8'hFF;  		// Initialize all bits to 1, default value for F2
	reg debug_t = 1;

	always @(posedge msx_clk) 
	begin
		// Write to data bus to port F2
		if (!msx_iorq && !msx_wr && (msx_adr == 8'hF2)) begin
				portF2 <= msx_data;
		end  
		//just for debug - remove later
		if (!msx_iorq && !msx_rd && (msx_adr == 8'hF2)) begin //debug 
				//debug_t = 1; //debug
		end 
	end

	// assign portF2 to msx bus if IORQ and RD is low and the right port address is provided
	// otherwise the msx data bus stays in low impedance mode
	assign msx_data = (!msx_iorq && !msx_rd && (msx_adr == 8'hF2))? portF2 : 8'bz;
	assign debug = debug_t; //assigns the debug signal
	
	//-------------------- ESP ports 06-07h --------------------
	reg [7:0] esp_dout_s = 8'hFF; 	// Initialize to all 1s
	reg [7:0] dbo;
	reg esp_wait_s = 1'b1;           // Initialize to 1
	wire esp_tx_i;                   // Assuming this is an input
	wire esp_rx_o;                   // Assuming this is an output

	always @(posedge clk50m)
	begin
	
		if (!msx_iorq && !msx_wr && (msx_adr[7:1] == 7'b0000011)) begin 
			dbo <= esp_dout_s;
			//dbo <= msx_data;
			debug_t = 0;

		end
		
		if (!msx_iorq && !msx_rd && (msx_adr[7:1] == 7'b0000011)) begin 
			debug_t = 1;

		end
	
	end
	
	assign msx_data = (!msx_iorq && !msx_rd && (msx_adr[7:1] == 7'b0000011))? dbo : 8'bz;

	// wifi Module instantiation
	wifi uwifi (
    .clk_i(clk50m),
    .wait_o(esp_wait_s), //todo implement the wait logic
    .reset_i(msx_reset),          
    .iorq_i(msx_iorq),
    .wrt_i(msx_wr),
    .rd_i(msx_rd),
    .tx_i(esp_tx_i),
    .rx_o(esp_rx_o),
    .adr_i(msx_adr),
    .db_i(msx_data),
    .db_o(esp_dout_s)
	);

	// Continuous assignments for the ESPP8266 board
	//assign esp_tx_i = pUsbP1;
	//assign pUsbN1 = esp_rx_o;
    
endmodule
