//autor: Gheorghe Andrei
//data: 12 mar 2026

//descriere:


//===== car green ================= car yellow ==== car red ============================ car green ===
//==== human red === human button============================human green ==== human red ==============
module Semafor_control #(
//parameter wait_button       = 10; //semafor car green  -> yellow
//parameter wait_car_yellow   = 10; //semafor car yellow -> red
//parameter wait_car_red      = 10; //semafor car red    -> green 
parameter start_intermitent_mode = 3,
parameter stop_intermitent_mode  = 6,
parameter blink_freq             = 24,
parameter full_cycle             = 100 // timp incare butonul nu mai ia valori dupa apasarea butonului si dureaza pana cand rosu se schimba in verde semafor masina
)(

input          clk         ,
input          rst_n       ,

input buton_pietoni        , // apasat de pietoni, dupa --N-- sec culoarea se schimba din Rosu in verde pe semafor pieton
input senzor_lumina        , // senzor de lumina
input [5-1:0] ora_curenta  , // la o anumita ora intra in intermitent

input        [2-1:0] Paddr,
input 				       Pwrite,
input 				       Psel,
input 				       Penable,
input        [8-1:0] Pwdata,
output logic [8-1:0] Prdata,
output logic 		     Pready,
output logic 		     Pslverr,
                                      //       10          01
output logic [2-1:0] semafor_pietoni, // MSB = red, LSB = green, 1 activ
                                      //    100            010           001
output logic [3-1:0] semafor_masini, // MSB red, middle = yellow, LSB = green

output logic [8-1:0] durata_display, //un indicator LED care arata masinilor cat timp mai au de asteptat
output               lampa         , //lampa care ilumineaza trecerea de pietoni // activ pe senzor_lumina = 0
output               buzer_pietoni  //buzer pentru persoane cu dizabilitati de vedere //activ pe pieton = 1
);



/*
task sgsggsggdg//////////////////////////////////////////////////////////////////////////////////////////////////
//registri acceesibili prin APB
reg  [8-1:0]   car_green_reg;  //0
reg  [8-1:0]   car_yellow_reg; //1
reg  [8-1:0]   car_red_reg;    //2

reg buton_pietoni_intarziat;
wire buton_pietoni_apasat;
//semnale interne
//reg    pieton_semafor_reg,

reg [blink_freq-1 : 0] interminent_counter;
reg            [8-1:0] count ;   

//scrierea registrilor prin APB
 always @(posedge clk or negedge rst_n)
    if (~rst_n) begin
    count <= 'd0;
    end
    else 
    if(Pwrite == 1 && Psel == 1 && Penable == 0)// suntem in primul tact al tranzactiei de scriere
    case(Paddr)
      0:car_green_reg  <= Pwdata;
      1:car_yellow_reg <= Pwdata;
      2:car_red_reg    <= Pwdata;
      default: $warning("adresa invalida");
    endcase  

 
// citirea registrilor prin APB
 always @(posedge clk or negedge rst_n)
    if (~rst_n) 
		Prdata <= 0;
	else begin
      if(Psel && !Penable && !Pwrite)begin // suntem in primul tact al tranzactiei de citire
        case (Paddr)
			0: Prdata <= car_green_reg ;       
			1: Prdata <= car_yellow_reg;       
			2: Prdata <= car_red_reg   ;       
			default: $warning("adresa nealocata");
		endcase
      end
    end
	
//Modelarea semnalului de eroare	
//"1" cand se aceseaza o adresa care nu este asignata unui registru
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		Pslverr <= 0;
	else 
	  if(Pslverr)
	  Pslverr <= 0;
  else if(Psel == 1 && Penable == 0 && Paddr > 2)
	Pslverr <= 1;
	
//Modelarea semnalului Pready
//Arata ca DUT ul acepta tranzactia si se activeaza tt timpul in al 2lea tact al tranzactiei	
always @(posedge clk or negedge rst_n)
	if (~rst_n)
		Pready <= 0;
		else 
	  if(Pready)
	  Pready <= 0;
	else if(Psel == 1 && Penable == 0 )
	Pready <= 'b1;
endtask////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ========================= apasarea butonului si tranzitii =========================
//assign buton_pietoni  = 'b0   ;
//assign semafor_pieton = 'b10  ;
//assign semafor_masini = 'b001 ;

always@(posedge clk or negedge rst_n) 
begin
//tranzitii
   if(rst_n)    //Set Counter to Zero
      count <= 0;
    else if(buton_apasat == 'b1)  //sem car red
      count <= count + 1'b1;
   // if (count == full_cycle)
    //  count <= 0;
   if(count > car_green_reg) //sem car green 
		semafor_masini <= 'b100;
    
	if(count > car_yellow_reg) //sem car yellow  
		semafor_masini <= 'b010;
		
	if(count > car_red_reg) //sem car green
		semafor_pietoni <= 'b10 ;
		semafor_masini <= 'b001;
	
  end
  
  //counter descrescator, deoarece daca apasam butonul count numara doar pana la 1
always@(posedge clk or negedge rst_n) 
begin
//tranzitii
   if(rst_n)    //Set Counter to Zero
      counter <= 0;
      
      else // numara descrescator, cat timp numara count initial numara
  
  
  
  always@(posedge clk or negedge rst_n) 
begin
   if(rst_n)    //Set Counter to Zero
      buton_pietoni_intarziat <= 0;
      else
      buton_pietoni_intarziat <= buton_pietoni;
      
      assign buton_pietoni_apasat = buton_pietoni && ~buton_pietoni_intarziat;
  end
  
  /*
    // ========================= dead buton after press =========================
  always@(posedge clk) 
begin
  if(count != full_cycle || count != 0) 
    buton <= 'b0;
    
   // assign Data = (buton == 1'b1) ? (car_yellow_reg || car_red_reg : {(n){1'bz}};
end

  // ========================= display numbers =========================
  always@(posedge clk) 
  durata_display <= count;
  end

  
  // ========================= buzzer si lumini =========================
  if(car_green_reg != 0)
  buzer <= 'b1;
  
  if(senzor_lumina == 1) // senzor lumina
  lampa <= 'b1;
  
  // ========================= intermitent intre orele xx si XX =========================
  
    always@(posedge clk) 
  begin
  if(ora_curenta > start_intermitent_mode && ora_curenta < stop_intermitent_mode)
    
    always_ff @(posedge clk or posedge rst_n) begin
        if (rst_n) 
        begin
            interminent_counter <= 0;
            semafor_masini     <= 'b000;  // semafor off on all colors
        end else 
        begin
            interminent_counter <= interminent_counter + 1;
                                                                                                  //blink_freq-1 = max size of the register
            if (interminent_counter >=  (blink_freq-1)/2 && interminent_counter !(blink_freq-1)) // counter reaches middlepoint, yellow light on
                semafor_masini <= car_yellow_reg;                                               // counter reaches middlepoint, yellow light on
            if (interminent_counter == blink_freq-1)  //  counter overflows, yellow light off
                semafor_masini <= 'b000;
            
            //interminent_counter ====================================/2======================================
            //yellow color        off =============================off=on===================================on
        end
    end
  end
  */  
endmodule

//00000   1
//00001   2 
//00010   3
//00011   4
//00100   5
//00101   7
//00110   8
//00111   9
//01000  10
//01001  11
//01010  12
//01011  13
//01100  14
//01101  15
//01110  16
//01111  17
//10000  18
//10001  19
//10010  20
//10011  21
//10100  22
//10101  23
//10110  24