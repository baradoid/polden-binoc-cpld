library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
        
entity one_wire is
        port ( reset : in std_logic;
                        read_byte : in std_logic;
                        write_byte : in std_logic;
								--read_bit : in std_logic;
                        dWire : inout std_logic;
                        --wire_in : in std_logic;
                        presense : out std_logic;
                        busy : out std_logic;
                        in_byte : in std_logic_vector (7 downto 0);
                        out_byte : out std_logic_vector (7 downto 0);
                        clk : in std_logic );
end one_wire;

architecture a of one_wire is
signal count : std_logic;
signal counter : integer range 0 to 127;

begin
process (clk)

type finit_state is (start, delay_reset, wire_read_presense, wire_0, wire_write, wire_read, delay );
variable state : finit_state := start; 

variable n_bit : integer range 0 to 7;
variable f : std_logic;
--variable oneBit : std_logic;

begin
if (clk'event and clk = '1') then
case (state) is
        when start => dWire <= '1'; --'Z';         -- здесь программа посто висит и ждет команд
                                busy <= '0';
                                count <= '0';
                                if (reset = '1') then        -- пришла команда сбросить шину
                                        busy <= '1';
                                        presense <= '0';
                                        state := delay_reset;   -- переходим туда, где эта шина сбрасывается
                                elsif (write_byte = '1') then 
                                        f := '0';
													 --oneBit := '0';
                                        busy <= '1';
                                        state := wire_0;
                                elsif (read_byte = '1') then
                                        f := '1';
													 --oneBit := '0';
                                        busy <= '1';
                                        state := wire_0;
										--  elsif (read_bit = '1') then
										--			 f := '1';
										--			 oneBit := '1';
										--			 busy <= '1';
										--			 state := wire_0;
                                end if;
                                        
        when delay_reset => dWire <= '0';     -- сбрасываем шину, т. е. выставляем 0 и ждем 480 мкс
                                count <= '1';
                                if (counter = 78) then
                                        state := wire_read_presense;
                                        count <= '0';
                                end if;
                        
        when wire_read_presense => dWire <= 'Z';
                                count <= '1';
                                if (counter = 11) then     -- проверяем ответ от устройства
                                        presense <= not dWire;
                                end if;
                                if (counter = 78) then 
                                        state := start;
                                        count <= '0';
                                end if;
                                        
        when wire_0 => dWire <= '0';                    -- инициируем передачу или прием бита
                                if (f = '0') then
                                        state := wire_write;
                                else 
                                        state := wire_read;
                                end if;
                                        
        when wire_write => 
                                if (in_byte(n_bit) = '1') then   -- по-очереди передаем байт
                                        dWire <= '1';
                                end if;
                                state := delay;
                                                                                
        when wire_read => dWire <= 'Z';
                                count <= '1';
                                if (counter = 1) then     
                                        out_byte(n_bit) <= dWire;   -- считываем бит
                                        count <= '0';
                                        state := delay;
                                end if;
                                
        when delay => 
                                count <= '1';
                                if (counter = 8) then     -- задержка перед приемом или передачей следующего бита
                                        count <= '0';
                                        dWire <= '1';
												--	 if (oneBit = '1') then    -- читаем только один бит
                                    --            n_bit := 0;
                                    --            state := start;													 
                                    --    elsif (n_bit = 7) then    -- если все биты приняты/переданы возвращаемся на начало
													 if (n_bit = 7) then    -- если все биты приняты/переданы возвращаемся на начало
                                                n_bit := 0;
                                                state := start;
                                        else n_bit := n_bit + 1;
                                                state := wire_0;
                                        end if;
                                end if;
                                                                
end case;
end if;
end process;

-- счетчик, тикает с периодом 6 мкс, нужен для выдерживания временных интервалов
process (clk)
begin
if (count = '0') then
        counter <= 0;
elsif (clk'event and clk = '1') then
        counter <= counter + 1;
end if;
end process;

end architecture;
