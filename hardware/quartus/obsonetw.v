module obsonetw(msx_sltsl, msx_cs1, msx_iorq, msx_wr, msx_data, msx_adr, flash_ce, flash_oe, flash_wr, onet_bt1, clk50m);

    //MSX control signals
    input 	msx_sltsl; 		//MSX slot select
    input 	msx_cs1;			//MSX ROM page 4000h-7FFFh select signal
    input	msx_iorq;		//MSX iorq
    input 	msx_wr;			//MSX write
    input 	[7:0] msx_adr;  //MSX first 8 digits of the MSX adr
    inout 	[7:0] msx_data; //MSX data bus 
    
    //Flash memory control signals
    output 	flash_ce;	//Flash chip enable
    output 	flash_oe;	//Flash output enable
    output  flash_wr;
	 
    //Obsonet board signals
    input 	onet_bt1; 	//Button to avoid flash enablement
    
    //Clock signal
    input 	clk50m;
    
    //Flash memory control logic
    assign flash_ce = (!onet_bt1) || msx_sltsl; //assigns the slot select signal to enable the flash, only if the button on the board is not pushed
    assign flash_oe = msx_cs1; //selects the 4000h-7FFFh (16K) rom page
	 assign flash_wr = msx_wr;
    
    // Port F2 device (ESP8266 BIOS)
    reg [7:0] portF2 = 8'hFF;  // Initialize all bits to 1

    // Assign true to portF2_req if msx_adr is equal to F2 in hexadecimal and we have an iorq
    wire portF2_req = (msx_adr == 8'hF2) && (msx_iorq == 0);
    
	 assign msx_data = (portF2_req && !msx_wr) ? portF2 : 8'bz;
	 
    //When portF2_req is true
    always @(posedge clk50m) begin
        if ((portF2_req) && (msx_wr))
                portF2 = msx_data;
    end
    
endmodule
