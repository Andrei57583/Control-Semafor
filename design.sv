//autor: Gheorghe Andrei
//data: 12 mar 2026

//descriere:

//===== car green ================= car yellow ==== car red ============================ car green ===
//==== human red === human button============================human green ==== human red ==============
module Semafor_control #(

parameter start_intermitent_mode = 3, //hour where intermitent_mode starts
parameter stop_intermitent_mode  = 6, //hour where intermitent_mode ends
parameter blink_freq             = 10 //frequency of the yellow bulb blink
)(
input          clk         ,
input          rst_n       ,

input buton_pietoni        , // apasat de pietoni, dupa "car_green_reg" sec culoarea se schimba din Rosu in verde pe semafor pieton
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

output logic [10-1:0] durata_display, //un indicator LED care arata masinilor cat timp mai au de asteptat
output logic          lampa         , //lampa care ilumineaza trecerea de pietoni // activ pe senzor_lumina = 0
output logic          buzzer_pietoni  //buzer pentru persoane cu dizabilitati de vedere //activ pe pieton = 1
);
//registri acceesibili prin APB                  // pentru reconfigurare/ setari
reg  [8-1:0]   car_green_reg;  //0
reg  [8-1:0]   car_yellow_reg; //1
reg  [8-1:0]   car_red_reg;    //2

reg start_cycle_counter;       // semnalul care porneste ciclul
reg [10-1:0] cycle_counter ;   //full transition of the semaphore counter     //count = cycle_counter
reg [10-1:0] full_cycle;       //durata complecta a ciclului
reg [10-1:0] display_counter;

reg buton_pietoni_Prev;
reg buton_pietoni_en; //   1/2 conditie pentru pornirea ciclului
reg buton_pietoni_delay_1;
reg buton_pietoni_delay_2; // 2/2 conditie pentru pornirea ciclului 

assign full_cycle = car_green_reg + car_yellow_reg + car_red_reg;


reg [5-1:0] interminent_counter; //counter for intermitent mode
reg         intermitent_mode;    // enable signal that prevents the semaphore cycle to function



 //scrierea registrilor prin APB
  always @(posedge clk or negedge rst_n)                    // setarii implicite
     if (~rst_n) begin
       car_green_reg  <= 8'd3;
       car_yellow_reg <= 8'd7;
       car_red_reg    <= 8'd10;
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
  
// \/----------------------falling edge activation of button ----------------------\/
always_ff @(posedge clk)begin // falling edge detector - cycle starts only when the buton is released
  buton_pietoni_Prev <= buton_pietoni;
  buton_pietoni_en <= (!buton_pietoni && buton_pietoni_Prev);
  end
 always @(posedge clk or negedge rst_n) begin // delaying the buton signal by 2 clock periods so we can implement an AND gate between buton_pietoni_delay_2 and buton_pietoni_en to start the cycle counter
  buton_pietoni_delay_1 <= buton_pietoni;
  buton_pietoni_delay_2 <= buton_pietoni_delay_1;
end 
// /\---------------------- falling edge activation of button ----------------------/\

// \/---------------------- button press activation ----------------------\/
always @(posedge clk or negedge rst_n) begin // when buton_pietoni is active (button pressed) start_cycle_counter becomes HIGH until cycle_counter reches it s max value (full_cycle)
  if (!rst_n)
    start_cycle_counter <= 1'b0;

  else if (buton_pietoni_delay_2 && buton_pietoni_en)
    start_cycle_counter <= 1'b1; 
    
  else if(cycle_counter == full_cycle)
    start_cycle_counter <= 1'b0;
end
// /\---------------------- button press activation ----------------------/\

always@(posedge clk)
begin
  if(start_cycle_counter)
    buton_pietoni_delay_2 <= 'bx;
end

// \/---------------------- cycle counter ----------------------\/
always@(posedge clk or negedge rst_n) 
begin
   if(~rst_n)begin  
      cycle_counter   <= 0;
      display_counter <= full_cycle;
      end
    else if(start_cycle_counter == 1) begin //sem car red // counter starts
      cycle_counter <= cycle_counter + 1'b1;
      display_counter <= display_counter - 1'b1;
      if (cycle_counter == full_cycle)begin
        cycle_counter <= 0;
        display_counter <= full_cycle;
        end
    end
end
// /\---------------------- cycle counter ----------------------/\
// \/------------------ semaphore transitions ------------------\/  
always@(posedge clk or negedge rst_n) 
begin 
    if (~rst_n) begin
        semafor_masini  <= 'b001;
        semafor_pietoni <= 'b10;
    end  
    
   if(cycle_counter > 0 && cycle_counter < car_green_reg && ~intermitent_mode)begin //sem car green 
		semafor_masini <= 'b001;
    end

	else if(cycle_counter > car_green_reg && cycle_counter < car_yellow_reg && ~intermitent_mode)begin //sem car yellow  
		semafor_masini <= 'b010;
    end

	else if(cycle_counter > car_yellow_reg && ~intermitent_mode)begin //sem car green
		semafor_pietoni <= 'b01;
		semafor_masini <= 'b100;
	end

	else if(cycle_counter == 0)begin //sem car green
    semafor_masini  <= 'b001;
    semafor_pietoni <= 'b10;
	end
end
// /\------------------ semaphore transitions ------------------/\

// \/-------------------- display counter --------------------\/
  always@(posedge clk) 
  begin
    if (~rst_n) begin
    durata_display <= 'b0;
  end
   if(cycle_counter > car_yellow_reg && ~intermitent_mode)
    durata_display <= display_counter;
  
end
// /\-------------------- display counter --------------------/\

// \/-------------------- buzzer --------------------\/
always@(posedge clk or negedge rst_n)begin
  if (~rst_n) begin
    buzzer_pietoni <= 'b0;
  end
    if(cycle_counter > car_yellow_reg) // car = red -> human = green
      buzzer_pietoni <= 'b1; //buzzer pasiv
    else if (cycle_counter == 0)
      buzzer_pietoni <= 'b0;
end
// /\-------------------- buzzer --------------------/\

// \/-------------------- lumina --------------------\/
always@(posedge clk or negedge rst_n)begin
  if (~rst_n) begin
    lampa          <= 'b0;
  end
    if(senzor_lumina) 
      lampa <= 'b1; 
    else if (~senzor_lumina)
      lampa <= 'b0; 
end
// /\-------------------- lumina --------------------/\
  
// \/-------------------- ignora butonul in mod intermitent ----------------------\/
always@(posedge clk)
begin
  if(intermitent_mode)
    start_cycle_counter <= 'bx;
end
// /\-------------------- ignora butonul in mod intermitent ----------------------/\
// \/-------------------- intermitent intre orele xx si XX ----------------------\/    
always@(posedge clk)
begin
  if (~rst_n)
  begin
    interminent_counter <= 0;
    semafor_masini     <= 'b000;  // semafor car     off on all colors
    semafor_pietoni    <= 'b00;  // semafor pietoni off on all colors
    intermitent_mode <= 'b0;
  end    // activare intre       ora            si                      ora            daca ciclul s-a oprit
  else if(ora_curenta >= start_intermitent_mode && ora_curenta < stop_intermitent_mode && cycle_counter == 'b0)
  begin
    intermitent_mode <= 'b1;
    interminent_counter <= interminent_counter + 1;

    if (interminent_counter % 2 == 1)
      begin
        semafor_masini  <= 'b010; 
        semafor_pietoni <= 'b00;
      end
    else 
      begin               
        semafor_masini  <= 'b000;
        semafor_pietoni <= 'b00;
      end
  end
    if(~(ora_curenta >= start_intermitent_mode && ora_curenta < stop_intermitent_mode && cycle_counter == 0))
    intermitent_mode <= 'b0;
end 
// /\-------------------- intermitent intre orele xx si XX ----------------------/\  
endmodule

                                    //graveyard of past ideas

  //counter descrescator, deoarece daca apasam butonul count numara doar pana la 1, porneste counterul care tine butonul in 1
//always@(posedge clk or negedge rst_n) 
//begin
//   if(buton_pietoni)  
//    pushed_button_counter <= full_cycle;
//    if(pushed_button_counter != 0'b1)
//      pushed_button_counter <= pushed_button_counter - 1'b1;
//end


  //
//always@(posedge clk or negedge rst_n) 
//begin
//   if(rst_n)    //Set Counter to Zero
//      buton_pietoni_intarziat <= 0;
//      else
//      buton_pietoni_intarziat <= buton_pietoni;
//      
//      assign buton_pietoni_apasat = buton_pietoni && ~buton_pietoni_intarziat;
//  end


//    // ========================= dead buton after press =========================
//  always@(posedge clk) 
//begin
//  if(count != full_cycle || count != 0) 
//    buton <= 'b0;
//    
//   // assign Data = (buton == 1'b1) ? (car_yellow_reg || car_red_reg : {(n){1'bz}};
//end

//wire time_green;
//wire time_yellow;
//wire time_red;
//
//assign time_green = display_counter - (full_cycle - car_green_reg);
//assign time_yellow = display_counter - (full_cycle - car_yellow_reg);
//assign time_red = display_counter - (full_cycle - car_red_reg);

  // assign car_green_reg = 3; test
  //assign car_yellow_reg = 7;   
  // assign car_red_reg = 10;
  
  //parameter full_cycle             = 20 //MUST be less than 256 // timp incare butonul nu mai ia valori dupa apasarea butonului si dureaza pana cand rosu se schimba in verde semafor masina