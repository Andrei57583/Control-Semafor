// autor: Gheorghe Andrei

module my_dut(pclk,rst_n,paddr,pwdata,prdata,pwrite,psel,penable,pready,pslverr,semafor_masini,semafor_pietoni,lampa,buzzer_pietoni,buton_pietoni,senzor_lumina,ora_curenta);

  //semnale generale
  input        pclk; 
  input        rst_n;
// semnale de date
  input [7:0]  paddr;
  input [7:0]  pwdata;
  output [7:0]  prdata;
  input        pwrite;

// semnale de protocol  
  input        psel;
  input        penable;

// semnalele date de slave
  output        pready;
  output        pslverr;

  // Iesiri DUT
  output  [2:0] semafor_masini;   // [2]=rosu, [1]=galben, [0]=verde
  output  [1:0] semafor_pietoni;  // [1]=rosu, [0]=verde
  output        lampa;
  output        buzzer_pietoni;

  // Intrari externe
  input        buton_pietoni;   // cerere trecere
  input        senzor_lumina;   // 1 = intuneric, 0 = lumina
  input  [4:0] ora_curenta;     // 0 - 23


endmodule