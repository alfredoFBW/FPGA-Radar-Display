

library ieee;
use ieee.std_logic_1164.all;


entity vga_ctrl is
    generic(
            h_pixels           : integer := 640;                --pixeles a mostrar en horizontal
            v_pixels           : integer := 480;                --pixles a mostrar en vertical  
            h_pulsewidth       : integer := 96;                 --anchura del pulso de syncronismo horizontal en us
            v_pulsewidth       : integer := 2;                  --anchura del pulso en filas
            h_frontporch       : integer := 16;                 --front porch horizontal en us
            v_frontporch       : integer := 10;                 --front porch vertical en filas
            h_backporch        : integer := 48;                 --back porch horizontal en us
            v_backporch        : integer := 29                  --back porch vertical en filas
            );
    port(
         i_clock       : in std_logic;                          --clock principal de la basys 3 100 mhz
         i_clear       : in std_logic;
         o_hsync       : out std_logic;                         --syncronizacion vertical
         o_vsync       : out std_logic;                         --syncronizacion horizontal
         o_disp_ena    : out std_logic;                         --'1' significa display en zona activa, 0 significa display en zona inactiva
         o_filaactiva  : out integer range 0 to 480;            --nos da la fila actual en el periodo en el que esta activa la señal
         o_colactiva   : out integer range 0 to 640             --nos da la columna actual en eñ periodo en el que esta activa la señal
         );
        
end vga_ctrl;

architecture behavioral of vga_ctrl is

    constant h_periodototal : integer := h_pixels + h_pulsewidth + h_frontporch + h_backporch;         --numero total de pixel clocks en una fila, es decir numero total de columnas o pixeles horizontales
    constant v_periodototal : integer := v_pixels + v_pulsewidth + v_frontporch + v_backporch;         --numero total de filas es decir numero total de pixeles verticales
    signal h_count          : integer range 0 to h_periodototal - 1 := 0;                              --señal con el contador horizontal                 
    signal v_count          : integer range 0 to v_periodototal - 1 := 0;                              --señal con el contador vertical

begin



    --objetivo: crear el controlador de vga
    main : process(i_clock, i_clear) is
        variable cont_25mhz : integer range 0 to 3;                     --contamos hasta 4 para obtener el periodo de 25 mhz
    begin
        if(i_clear = '1') then
            h_count      <= 0;
            v_count      <= 0;
            o_filaactiva <= 0;      
            o_colactiva  <= 0;
            o_disp_ena   <= '0';
            o_hsync      <= '1';                                        
            o_vsync      <= '1';                                        
            cont_25mhz   := 0;
            
        elsif(rising_edge(i_clock)) then 

            if(cont_25mhz = 3) then
            
                cont_25mhz  := 0;
                --creamos los contadores de las señales              
                if(h_count = h_periodototal - 1) then
                    if(v_count = v_periodototal -1) then
                        v_count <= 0;
                    else
                        v_count <= v_count + 1;
                    end if;
                    h_count <= 0;
                else
                    h_count <= h_count + 1;
                end if;
                    
                --syncronizacion horizontal como en el clear emepzamos a contar, entonces el cont = 0 sera en el empiece del pulse width
                -- y el cont = 800 y por lo tanto otra vez 0 sera al terminar el front porch
                if(h_count < h_pulsewidth) then
                     o_hsync <= '0';
                else
                     o_hsync <= '1';
                end if;
                     
                --syncronizacion vertical
                if(v_count < v_pulsewidth) then
                     o_vsync <= '0';
                else
                     o_vsync <= '1';
                end if;
          
                --nos da la columna activa actual y la pone en el rango de 0 hasta h_pixels - 1
                if((h_count > h_backporch + h_pulsewidth) and (h_count < h_pixels + h_pulsewidth + h_backporch)) then
                    o_colactiva <= h_count - (h_backporch + h_pulsewidth);  
                end if;
                
                --nos da la fila activa actual y la pone en el rango de 0 hasta v_pixels - 1
                if((v_count > v_backporch + v_pulsewidth) and (v_count < v_pixels + v_pulsewidth + v_backporch)) then
                    o_filaactiva <= v_count - (v_backporch + v_pulsewidth);
                end if;
    
                --logica para activacion del display, estamos en zona de activacion
                if( ((h_count > h_backporch + h_pulsewidth) and (h_count < h_pixels + h_pulsewidth + h_backporch)) and 
                    ((v_count > v_backporch + v_pulsewidth) and (v_count < v_pixels + v_pulsewidth + v_backporch)) ) then
                    o_disp_ena <= '1';
                else
                    o_disp_ena <= '0';
                end if;
                
            else
                cont_25mhz := cont_25mhz + 1;
            end if;
                
        end if;
    
    end process main;
    
end behavioral;
