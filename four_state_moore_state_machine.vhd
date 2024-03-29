-- Quartus II VHDL Template
-- Four-State Moore State Machine

-- A Moore machine's outputs are dependent only on the current state.
-- The output is written only when the state changes.  (State
-- transitions are synchronous.)

--Maquina de estados para RX & TX

library ieee;
use ieee.std_logic_1164.all;

entity four_state_moore_state_machine is
  generic(
    CNT0 : integer := 5208;    -- Needs to be set correctly, PARA BOUND RATE DE 9600
	 CNT1 : integer := 434     -- Needs to be set correctly, PARA BOUND RATE DE 115200
  );

	port(
		clk			: in	std_logic;
		reset			: in std_logic;
		input			: in	std_logic;
		bound_rate	: in  std_logic;
		o_TX_DV     : out std_logic;
		output		: out	std_logic_vector(7 downto 0)
	);

end entity;

architecture rtl of four_state_moore_state_machine is

	-- Build an enumerated type for the state machine
	type state_type is (s0, s1, s2, s3,s4);

	-- Register to hold the current state
	signal state   : state_type;
	signal Contador_CLK0 :integer range 0 to CNT0-1 := 0;
	signal Contador_CLK1 :integer range 0 to CNT1-1 := 0;	
	signal r_RX_Data   : std_logic := '0'; --Dados recebidos pelo RX
	signal Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total,
	signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');--acredito ser contador de bit
	signal r_RX_DV     : std_logic := '0';

begin

	-- Logic to advance to the next state
	process (clk, reset, bound_rate)
	begin
		if (rising_edge(clk)) then
			if bound_rate = '0' then --bound_rate de 9600, usar CNT0
				case state is
					when s0=>
						r_RX_DV     <= '0';
						Contador_CLK0 <= 0;
						Bit_Index <= 0;
					
						if input = '0' then
							state <= s1;
						else
							state <= s0;
						end if;
					when s1=>
						if Contador_CLK0 = (Contador_CLK0-1)/2 then --MEIO PERIODO DE BIT
							state <= s2;
						else
							state <= s1;
						end if;
					when s2=>
						if Contador_CLK0 < Contador_CLK0-1 then
							Contador_CLK0<= Contador_CLK0 +1;
							state <= s2;
						else
							Contador_CLK0 <= 0;
							r_RX_Byte(Bit_Index) <= r_RX_Data;
						--CHECAR SE JÁ CHEGARAM TODOS os bits
							if Bit_Index < 7  then
								Bit_Index <= Bit_Index + 1;
								state <= s2;
							else
								Bit_Index <= 0;
								state <= s3;
							end if;
						end if;
						
					--Último bit
					when s3 =>
						if Contador_CLK0 < Contador_CLK0 -1 then
							Contador_CLK0 <= Contador_CLK0 +1;
							state <= s3;
						else 
							r_RX_DV <= '1';
							Contador_CLK0 <= 0;
							state <= s4;
						end if;
						
					when s4 =>
						state <= s0;
						r_RX_DV <= '0';
						
					when others =>
						state <= s0;
				end case;
				
			else --bound_rate de 115200
				case state is
					when s0=>
						r_RX_DV     <= '0';
						Contador_CLK0 <= 0;
						Bit_Index <= 0;
					
						if input = '0' then
							state <= s1;
						else
							state <= s0;
						end if;
					when s1=>
						if Contador_CLK1 = (Contador_CLK1-1)/2 then --MEIO PERIODO DE BIT
							state <= s2;
						else
							state <= s1;
						end if;
					when s2=>
						if Contador_CLK1 < Contador_CLK1-1 then
							Contador_CLK1<= Contador_CLK1 +1;
							state <= s2;
						else
							Contador_CLK1 <= 0;
							r_RX_Byte(Bit_Index) <= r_RX_Data;
						--CHECAR SE JÁ CHEGARAM TODOS os bits
							if Bit_Index < 7  then
								Bit_Index <= Bit_Index + 1;
								state <= s2;
							else
								Bit_Index <= 0;
								state <= s3;
							end if;
						end if;
						
					--Último bit
					when s3 =>
						if Contador_CLK1 < Contador_CLK1 -1 then
							Contador_CLK1 <= Contador_CLK1 +1;
							state <= s3;
						else 
							r_RX_DV <= '1';
							Contador_CLK1 <= 0;
							state <= s4;
						end if;
						
					when s4 =>
						state <= s0;
						r_RX_DV <= '0';
						
					when others =>
						state <= s0;
				end case;
			end if;
		end if;
	end process;

 o_TX_DV <= r_RX_DV;
 output  <= r_RX_Byte;

end rtl;

