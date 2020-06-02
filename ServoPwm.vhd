

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ServoPWM is
	
	port(
		i_clock    : in std_logic;
		o_pwm      : out std_logic;
		o_position : out integer range 45 to 135       --Va desde pi/4 hasta 3pi/4 (45 grados a 135)
		);                                             --Facilmente modificable de 0 a 180
	
end entity ServoPWM;

architecture RTL of ServoPWM is
											
	constant c_incremento    : integer   := 3333333;           		--Contamos hasta aqui para actualizar el servo cada 33 mS
	constant c_aumentopw     : integer   := 1111;		   		--Aumentamos el pw 1111 para contar;
	constant c_pwm_freq      : integer   := 2000000;	        	--2 millones de ciclos de reloj para el periodo de 50 hz
	constant c_3pi_over4     : integer   := 200000;           		--Anchura de pulso de 2 mS lo pone a la posicion 3 pi cuartos
	signal pw_counter        : integer range 0 to c_3pi_over4 - 1 := 0;	--Contador Anchura de pulso
	signal freq_counter      : integer range 0 to c_pwm_freq - 1 := 0;
	signal incrementos	 : integer range 0 to 180 := 0;			--Maximo 180 grados(180 incrementos
	signal increment_counter : integer range 0 to c_incremento - 1 := 0;
	signal r_posicion        : integer range 45 to 135;
	
	type t_rom is array (0 to 89) of integer range 100000 to 200000;
	
	--Rom con los valores que hay que tomar cuando se va incrementando el pulse width, en 1 mS lo ponemos en pi/4
	constant rom_cont : t_rom := (
								  100000, 101111, 102222, 103333, 104444, 105555, 106666, 107777, 108888,
								  109999, 111110, 112221, 113332, 114443, 115554, 116665, 117776, 118887,
								  119998, 121109, 122220, 123331, 124442, 125553, 126664, 127775, 128886,
								  129997, 131108, 132219, 133330, 134441, 135552, 136663, 137774, 138885,
								  139996, 141107, 142218, 143329, 144440, 145551, 146662, 147773, 148884,
								  149995, 151106, 152217, 153328, 154439, 155550, 156661, 157772, 158883,
								  159994, 161105, 162216, 163327, 164438, 165549, 166660, 167771, 168882,
								  169993, 171104, 172215, 173326, 174437, 175548, 176659, 177770, 178881,
								  179992, 181103, 182214, 183325, 184436, 185547, 186658, 187769, 188880,
								  189991, 191102, 192213, 193324, 194435, 195546, 196657, 197768, 198879
								);

begin
	
	
	
	
	main : process(i_clock) is
		variable address : integer range 0 to 89 := 0;
	begin
		
		if(rising_edge(i_clock)) then
			
			--Hacemos 1 grados a la derecha en 90 incrementos 
			if(incrementos < 90) then
				
				if(increment_counter < c_incremento - 1) then
					increment_counter <= increment_counter + 1;
					
					if(freq_counter < c_pwm_freq - 1) then
						freq_counter <= freq_counter + 1;
						
						if(pw_counter < rom_cont(address)) then
							pw_counter <= pw_counter + 1;
							o_pwm <= '1';
						else
							o_pwm <= '0';
						end if;
						
					else
						freq_counter <= 0;
						pw_counter   <= 0;
					end if;
				else
					increment_counter <= 0;
					incrementos <= incrementos + 1;			--Aumentamos de grado en grado
					r_posicion  <= r_posicion  + 1;
					address := address + 1;
					pw_counter <= pw_counter + c_aumentopw; 	--Aumentamos para que no vuelva a contar(y poner o_pwm = '1' durante ese incremento solo de tiempo),
				end if;
			
			--Hacemos 180 grados a la izquierda en 90 incrementos
			elsif(incrementos >= 90 and incrementos < 180) then
				
				if(increment_counter < c_incremento - 1) then
					increment_counter <= increment_counter + 1;
					
					if(freq_counter < c_pwm_freq - 1) then
						freq_counter <= freq_counter + 1;
						
						if(pw_counter < rom_cont(address)) then				--Anchura pwm
							pw_counter <= pw_counter + 1;
							o_pwm <= '1';
						else
							o_pwm <= '0';
						end if;
						
					else
						freq_counter <= 0;
						pw_counter   <= 0;
					end if;
				else
					increment_counter <= 0;
					incrementos <= incrementos + 1;			--Aumentamos de dos en dos grados(ahora hacia el otro lado por disminuir el ancho de pulso)
					r_posicion  <= r_posicion  - 1;
					address := address - 1;
				end if;
			
			else							 	--Ya estamos otra vez en el punto inicial pues reseteamos
				incrementos <= 0;					--Ponemos los incrementos a 0
				r_posicion  <= 45;
				address := 0;
			end if;
		
		end if;
		
	end process main;

	o_position <= r_posicion;

end architecture RTL;
