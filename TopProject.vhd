

--


library ieee;
use ieee.std_logic_1164.all;


entity top_sonar is

    port(
         i_clock 	  : in std_logic;
         i_clear 	  : in std_logic;
         o_hsync 	  : out std_logic;
         o_vsync 	  : out std_logic;
         o_vga_red    : out std_logic_vector(3 downto 0);
         o_vga_blue   : out std_logic_vector(3 downto 0);
         o_vga_green  : out std_logic_vector(3 downto 0);
         o_pwm   	  : out std_logic
         );
         
end top_sonar;

architecture behavioral of top_sonar is
	
	
	component servopwm
		port(
			i_clock    : in  std_logic;
			o_pwm      : out std_logic;
			o_position : out integer range 45 to 135   	  --con esto podemos hablar a el radar de vga pra hacer una linea que se vaya moviendo.
			);                                            
	end component servopwm;
	
	component vga_ctrl
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
	end component vga_ctrl;
    
    component draw_vga
    	port(
    		i_clock      : in  std_logic;
    		i_filaactiva : in  integer range 0 to 480;
    		i_colactiva  : in  integer range 0 to 640;
    		i_disp_ena   : in  std_logic;
    		i_servo_pos  : in  integer range 45 to 135;
    		o_vga_red    : out std_logic_vector(3 downto 0);
    		o_vga_green  : out std_logic_vector(3 downto 0);
    		o_vga_blue   : out std_logic_vector(3 downto 0)
    	);
    end component draw_vga;
     
    signal w_pos_servo : integer range 45 to 135; 
    signal w_colactiva : integer range 0  to 640;
    signal w_filactiva : integer range 0  to 480;
    signal w_disp_en   : std_logic;

begin


   --controla el servo   
   servo_ctrl : servopwm port map( i_clock    => i_clock,
   								   o_pwm      => o_pwm,
   								   o_position => w_pos_servo
   								  );                                        
    
    --controlador vga
    vga_controller : vga_ctrl port map(	i_clock      => i_clock, 
						    			i_clear      => i_clear,
						    			o_hsync      => o_hsync,
						    			o_vsync      => o_vsync,
						    			o_disp_ena   => w_disp_en,
						    			o_filaactiva => w_filactiva,
						    			o_colactiva  => w_colactiva
						    			);
						    
	--dibujador de simbolos
	symbol_gen : draw_vga	port  map( i_clock      => i_clock,
									   i_filaactiva => w_filactiva,
									   i_colactiva  => w_colactiva,
									   i_disp_ena   => w_disp_en,
									   i_servo_pos  => w_pos_servo,
									   o_vga_red    => o_vga_red,
									   o_vga_green  => o_vga_green,
									   o_vga_blue   => o_vga_blue
									);
	

end behavioral;
