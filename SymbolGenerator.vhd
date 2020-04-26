


library ieee;
use ieee.std_logic_1164.all;


entity draw_vga is
    port(
         i_clock      : in std_logic;
         i_filaactiva : in integer range 0 to 480;
         i_colactiva  : in integer range 0 to 640;
         i_disp_ena   : in std_logic;
         i_servo_pos  : in integer range 45 to 135;
         o_vga_red    : out std_logic_vector(3 downto 0);
         o_vga_green  : out std_logic_vector(3 downto 0);
         o_vga_blue   : out std_logic_vector(3 downto 0)
         );
end draw_vga;

architecture behavioral of draw_vga is


	--señales para registrar y que asi no dependa tanta logica de las entradas y evitamos delays
    signal r_filaactiva   : integer range 0 to 480 := 0;
    signal r_colactiva    : integer range 0 to 640 := 0;
    signal r_filaactiva_r : integer range 0 to 480 := 0;
    signal r_colactiva_r  : integer range 0 to 640 := 0;
    signal r_pos_servo_r  : integer range 45 to 135 := 45;
    signal r_pos_servo    : integer range 45 to 135 := 45;
    signal r_disp_ena     : std_logic := '0';
    signal r_vga_red      : std_logic_vector(3 downto 0) := (others => '0');		--u
    signal r_vga_blue     : std_logic_vector(3 downto 0) := (others => '0');
    signal r_vga_green    : std_logic_vector(3 downto 0) := (others => '0');	

    type t_rom  is array (0 to 90) of integer;
    
    
    --rom con las tangentes del angulo multiplicadas por 100(esta en orden de pendientes para que vaya barriendo
    constant  tan_rom : t_rom := ( 
    							-100, -103, -107, -111, -115, -119, -123, -127, -132, -137, -143,
 							    -148, -154, -160, -166, -173, -180, -188, -196, -205, -214, -225,
 							    -236, -248, -261, -275, -290, -308, -327, -349, -373, -401, -433,
 							    -470, -514, -567, -631, -712, -814, -951, -1143, -1430, -1908, -2863,
 							    -5729,
 							    0,  			--no se lee
 							    5729, 2863, 1908, 1430, 1143, 951, 814, 712, 631, 567, 514, 470,
 							    433, 401, 373, 349, 327, 308, 290, 275, 261, 248, 236, 225, 214,
 							    205, 196, 188, 180, 173, 166, 160, 154, 148, 143, 137, 132, 127,
 							    123, 119, 115, 111, 107, 103, 100			    
    							);
	
begin


    --registramos dos veces las señales para evitar setup delays, hacemos que la señal recorra menos camino entre flipflops evitando asi setup violations
    sample_coordinates : process(i_clock) is
    begin
        
        if(rising_edge(i_clock)) then
            r_filaactiva_r <= i_filaactiva;
            r_colactiva_r  <= i_colactiva;
            r_filaactiva   <= r_filaactiva_r;
            r_colactiva    <= r_colactiva_r;
            r_pos_servo_r  <= i_servo_pos;
            r_pos_servo    <= r_pos_servo_r;
            r_disp_ena     <= i_disp_ena;
        end if;
    
    end process sample_coordinates;

	--hacer la barra horizontal que se mueva en funcion de la posicion
	main : process(i_clock) is
    begin
    	if(rising_edge(i_clock)) then
    		
            if(r_disp_ena = '1') then
 			
 -----------------------------------circulos superiores-------------------------------------------------------       
                --dibujo de las lineas de radar de anchura 4 pixeles y radio 400, 300, 200 ,100  
                if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 399**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '1');
                     r_vga_blue   <= (others => '0'); 
				else
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '0');
                     r_vga_blue   <= (others => '0');     
                 end if;
                 
                 --si es menor que el radio lo ponemos negro, asi lo de encima se queda verde
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 395**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '0');
                     r_vga_blue   <= (others => '0'); 
                 end if;
                 
                 --ahora queremos poner verde todo hasta el 299
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 299**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '1');
                     r_vga_blue   <= (others => '0'); 
                 end if;
                 
                 --lo volvemos a poner negro todo debajo de 294, como estaba verde encima pos eso
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 295**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '0');
                     r_vga_blue   <= (others => '0');
                 end if;
                 
  -----------------------------------circulos inferiores-----------------------------------------------------
                  --etc
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 199**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '1');
                     r_vga_blue   <= (others => '0');  
                 end if;
                  
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 195**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '0');
                     r_vga_blue   <= (others => '0');  
                 end if;
   
               
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 99**2 ) then 
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '1');
                     r_vga_blue   <= (others => '0');   
                 end if;
                  
                  
                 if( (r_colactiva - 319)**2 + (r_filaactiva - 479)**2 <= 95**2 ) then
                     r_vga_red    <= (others => '0');
                     r_vga_green  <= (others => '0');
                     r_vga_blue   <= (others => '0');  
                 end if;               
	
-------------------------------algoritmo del arco usando tangente------------------------------------------
			
				if( r_pos_servo > 90) then
					
					--cuando estemos en la posicion de tangente positivia(anchura 4 pixeles)
					if( (tan_rom(r_pos_servo - 45))*(r_colactiva - 322) <= 100*(r_filaactiva - 480) and
						(tan_rom(r_pos_servo - 45))*(r_colactiva - 318) >= 100*(r_filaactiva - 480) ) then
                		  
						r_vga_red    <= (others => '1');
	                	r_vga_green  <= (others => '1');
    	            	r_vga_blue   <= (others => '1');              --lo pintamos blanco
   	            	
	                end if;	              
	                
	            elsif(r_pos_servo < 90) then
	            	
	            	--cuando estemos en la posicion de tangente negativa
					if( (tan_rom(r_pos_servo - 45))*(r_colactiva - 318) <= 100*(r_filaactiva - 480) and
						(tan_rom(r_pos_servo - 45))*(r_colactiva - 322) >= 100*(r_filaactiva - 480) ) then		
												
						r_vga_red    <= (others => '1');
	                	r_vga_green  <= (others => '1');
    	            	r_vga_blue   <= (others => '1');              --lo pintamos blanco    	

	                end if;	                
	
	          	 else
	           		--cuando estemos en la posicion 90 
					if((r_colactiva >= 318) and (r_colactiva <= 322)) then
					 
						r_vga_red    <= (others => '1');
	                	r_vga_green  <= (others => '1');
    	            	r_vga_blue   <= (others => '1');              --lo pintamos blanco
    	            		        
	                end if;								           		
	             	
			  	end if;
				
			  else
			  	
                r_vga_red    <= (others => '0');
                r_vga_blue   <= (others => '0');
                r_vga_green  <= (others => '0');

			end if;
			
            o_vga_red   <= r_vga_red;   --metemos un registro de por medio para evitar porblemas de timing
            o_vga_green <= r_vga_green;
            o_vga_blue  <= r_vga_blue;
            
        end if;
    end process main;
        

        
 end behavioral;