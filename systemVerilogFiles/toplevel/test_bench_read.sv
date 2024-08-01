// program 1-2-3    CSE141L   
module test_bench;

// connections to DUT: clock, start (request), done (acknowledge) 
  bit  clk,
       start = 'b1;
  wire done;

  logic[ 4:0] Dist, Min, Max;	// current, min, max Hamming distances
  logic[ 4:0] Min1, Min2;	 	// addresses of pair w/ smallest Hamming distance
  logic[ 4:0] Max1, Max2;		// addresses of pair w/ largest Hamming distance
  logic[15:0] Tmp[32];		    // cache of 16-bit values assembled from data_mem
  logic signed[16:0] diff;		// signed difference -- Dist = abs(diff)  pgm 2
  logic signed[31:0] Prod[16];	// caches all 16 4-byte products		  pgm 3

  topLevel D1(.clk  (clk  ),	        // your design goes here
		 .start(start),
		 .done (done )); 

  always begin
    #50ns clk = 'b1;
	#50ns clk = 'b0;
  end

  initial begin
    //add in our instructions
    $readmemb("entireMachineCode.txt", D1.instrMem1.Core);
// load operands for program 1 into data memory
// 32 double-precision operands go into data_mem [0:63]
// first operand = {data_mem[0],data_mem[1]}  
//   endian order doesn't matter for program 1, as long as consistent for all values (why?)
// 1: min & max Hamming distances in double precision data pairs
    #100ns;
	Min = 'd16;						         // start test bench Min at max value
	Max = 'd0;						         // start test bench Max at min value
    $readmemb("test1_2.txt",D1.dataMemory.Core);

    for(int i=0; i<32; i++) begin
      Tmp[i] = {D1.dataMemory.Core[2*i],D1.dataMemory.Core[2*i+1]};
      $display("%d:  %b",i,Tmp[i]);
	end
// DUT data memory preloads beyond [63] (next 3 lines of code)
    D1.dataMemory.Core[64] = 'd16;		             // preset DUT final Min to max possible
    for(int r=65; r<256; r++)
	  D1.dataMemory.Core[r] = 'd0;		             // preset DUT final Max to min possible 
// 	compute correct answers
    for(int j=0; j<32; j++) begin
      for(int k=j+1; k<32; k++) begin
	    #1ns Dist = ham(Tmp[j],Tmp[k]);
		$display("dist=%d",Dist); 
        if(Dist<Min) begin                   // update Hamming minimum
          Min = Dist;						 //   value
		  Min2 = j;							 //	  location of data pair
		  Min1 = k;							 //         "
		end  
		if(Dist>Max) begin 			         // update Hamming maximum
		  Max = Dist;						 //   value
		  Max2 = j;							 //   location of data pair
		  Max1 = k;							 //			"
        end
	  end
    end   
	#200ns start = 'b0; 
    #200ns wait (done);						 // avoid false done signals on startup

// check results in data_mem[64] and [65] (Minimum and Maximum distances, respectively)
    if(Min == D1.dataMemory.Core[64]) $display("good Min = %d",Min);
	else                      $display("fail Min: Correct = %d; Yours = %d",Min,D1.dataMemory.Core[64]);
                              $display("Min addr = %d, %d",Min1, Min2);
							  $display("Min valu = %b, %b",Tmp[Min1],Tmp[Min2]);//{D1.dataMemory.Core[2*Min1],D1.dataMemory.Core[2*Min1+1]},{D1.dataMemory.Core[2*Min2],D1.dataMemory.Core[2*Min2+1]});
	if(Max == D1.dataMemory.Core[65]) $display("good Max = %d",Max);
	else                      $display("MAD  Max: Correct = %d; Yours = %d",Max,D1.dataMemory.Core[65]);
	                          $display("Max pair = %d, %d",Max1, Max2);
							  $display("Max valu = %b, %b",Tmp[Max1],Tmp[Max2]);// {D1.dataMemory.Core[2*Max1],D1.dataMemory.Core[2*Max1+1]},{D1.dataMemory.Core[2*Max2],D1.dataMemory.Core[2*Max2+1]});
    #200ns start = 'b1;
// to do: load operands for program 2 into data memory (reuse program 1 operands is fine here)
	#200ns start = 'b0;

// program 2    CSE141L   min & max arithmetic distances in double precision data pairs

// load operands for program 2 into data memory
// 32 double-precision operands go into data_mem [0:63]
// first operand = {data_mem[0],data_mem[1]}  
//   endian order doesn't matter for program 1, as long as consistent for all values (why?)
    #100ns;
    $readmemb("test2_2.txt",D1.dataMemory.Core);
	Min = 'hffff;						     // start test bench Min at max value
	Max = 'h0;						         // start test bench Max at min value
    for(int i=0; i<32; i++) begin
      Tmp[i] = {D1.dataMemory.Core[2*i],D1.dataMemory.Core[2*i+1]};	  // load values into mem, copy to Tmp array
      $display("%d:  %d",i,Tmp[i]);
	end
// do not preload Core[64:65] -- these are used by program 1
    D1.dataMemory.Core[66] = 'hffff;		         // preset DUT final Min to max possible
    D1.dataMemory.Core[67] = 'hffff;
    for(int r=68; r<256; r++)
	  D1.dataMemory.Core[r] = 'd0;		             // preset DUT final Max to min possible 
// 	compute correct answers
    for(int j=0; j<32; j++) begin			 // triangular half of 32x32 matrix, minus the major diagonal
      for(int k=j+1; k<32; k++) begin		 // steps through all 2-different-element combinations (not permutations)
	    #1ns Dist = abs(Tmp[j],Tmp[k]);		 // call abs subroutine, which computes magnitude of difference between two values
        if(Dist<Min) begin                   // update arithmetic minimum
          Min = Dist;						 //   value
		  Min2 = j;							 //	  location of data pair
		  Min1 = k;							 //         "
		end  
		if(Dist>Max) begin 			         // update arithmetic maximum
		  Max = Dist;						 //   value
		  Max2 = j;							 //   location of data pair
		  Max1 = k;							 //			"
        end
	  end
    end   
	#200ns start = 'b0; 
    #200ns wait (done);						 // avoid false done signals on startup

// check results in data_mem[66:67] and [68:69] (Minimum and Maximum distances, respectively)
    if(Min == {D1.dataMemory.Core[66],D1.dataMemory.Core[67]}) 
                              $display("good Min = %d",Min);     // your DUT put correct answer into Core[66:67]
	else                      $display("fail Min = %d",Min);	 // your DUT put wrong answer into Core[66:67]
                              $display("Min addr = %d, %d",Min1, Min2);
							  $display("Min valu = %d %d",Tmp[Min1], Tmp[Min2]);
							  //{D1.dataMemory.Core[2*Min1],D1.dataMemory.Core[2*Min1+1]},{D1.dataMemory.Core[2*Min2],D1.dataMemory.Core[2*Min2+1]});
	if(Max == {D1.dataMemory.Core[68],D1.dataMemory.Core[69]}) 
	                          $display("good Max = %d",Max);	 // your DUT put correct answer into Core[68:69]
	else                      $display("MAD  Max = %d",Max);	 // your DUT put wrong answer into Core[68:69]
	                          $display("Max pair = %d, %d",Max1, Max2);
							  $display("Max valu = %d, %d",Tmp[Max1], Tmp[Max2]);
							  //{D1.dataMemory.Core[2*Max1],D1.dataMemory.Core[2*Max1+1]},{D1.dataMemory.Core[2*Max2],D1.dataMemory.Core[2*Max2+1]});
    #200ns start = 'b1;
// load operands for program 3 into data memory 
    #100ns;
    $readmemh("test3_2.txt",D1.dataMemory.Core);
    for(int i=0; i<32; i++) begin
      Tmp[i] = {D1.dataMemory.Core[2*i],D1.dataMemory.Core[2*i+1]};	  // load values into mem, copy to Tmp array
      $display("%d:  %d",i,Tmp[i]);
	end
// 	compute correct answers
    for(int j=0; j<16; j++) 			              // pull pairs of operands from memory
	    #1ns Prod[j] = Tmp[2*j+1]*Tmp[2*j];		      // compute prod.
	#200ns start = 'b0; 							  
    #200ns wait (done);						          // avoid false done signals on startup
	for(int k=0; k<16; k++)
	  if({D1.dataMemory.Core[64+4*k],D1.dataMemory.Core[65+4*k],D1.dataMemory.Core[66+4*k],D1.dataMemory.Core[67+4*k]} == Prod[k])
	    $display("Yes! %d * %d = %d",Tmp[2*k+1],Tmp[2*k],Prod[k]);
	  else
	    $display("Boo! %d * %d should = %d",Tmp[2*k+1],Tmp[2*k],Prod[k]);    
// check results in data_mem[66:69], ..., [124:127] (Prods)
    #200ns start = 'b1;
	$stop;
  end

// magnitude of distance between two 16-bit numbers 
  function[15:0] abs(input signed[15:0] a, b);
                 diff = a-b;      	   // raw difference (two's comp)
    if(diff[16]) abs  = -diff;		   // absolute magnitude of diff
    else       	 abs  =  diff;
  endfunction

// Hamming distance (anticorrelation) between two 16-bit numbers 
  function[4:0] ham(input[15:0] a, b);
    ham = 'b0;
    for(int q=0;q<16;q++)
      if(a[q]^b[q]) ham++;	                // count number of bits for which a[i] = !b[i]
  endfunction

endmodule