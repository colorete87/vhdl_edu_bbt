-- libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

-- entity
entity tb_bb_modulator is
end entity tb_bb_modulator;

-- architecture
architecture rtl of tb_bb_modulator is

  -- components
  component bb_modulator is
    port
    (
      -- clk, en, rst
      clk_i         : in  std_logic;
      en_i          : in  std_logic;
      srst_i        : in  std_logic;
      -- Input Stream
      is_data_i     : in  std_logic_vector(7 downto 0);
      is_dv_i       : in  std_logic;
      is_rfd_o      : out std_logic;
      -- Output Stream
      os_data_o     : out std_logic_vector(9 downto 0);
      os_dv_o       : out std_logic;
      os_rfd_i      : in  std_logic;
      -- Control and report IOs
      n_bytes_i     : in  std_logic_vector(7 downto 0);
      n_pre_i       : in  std_logic_vector(7 downto 0);
      n_sfd_i       : in  std_logic_vector(7 downto 0);
      send_i        : in  std_logic;
      tx_rdy_o      : out std_logic
    );
  end component bb_modulator;

  -- signals
  signal tb_dut_clk_i      : std_logic := '1';                   
  signal tb_dut_en_i       : std_logic;                    
  signal tb_dut_srst_i     : std_logic;                   
  signal tb_dut_is_data_i  : std_logic_vector(7 downto 0);                            
  signal tb_dut_is_dv_i    : std_logic;
  signal tb_dut_is_rfd_o   : std_logic;
  signal tb_dut_os_data_o  : std_logic_vector(9 downto 0);                            
  signal tb_dut_os_dv_o    : std_logic;
  signal tb_dut_os_rfd_i   : std_logic;
  signal tb_dut_send_i     : std_logic;
  signal tb_dut_tx_rdy_o   : std_logic;

  constant SAMPLE_PERIOD : time    := 62500 ps;
  constant N_TX          : integer := 10;
  constant N_ZEROS       : integer := 123;
                             
begin

  ------------------------------------------------------------
  -- BEGIN DUT
  ------------------------------------------------------------
  dut : bb_modulator
  port map (
    -- clk, en, rst
    clk_i         => tb_dut_clk_i,
    en_i          => tb_dut_en_i,
    srst_i        => tb_dut_srst_i,
    -- Input Stream
    is_data_i     => tb_dut_is_data_i,
    is_dv_i       => tb_dut_is_dv_i,
    is_rfd_o      => tb_dut_is_rfd_o,
    -- Output Stream
    os_data_o     => tb_dut_os_data_o,
    os_dv_o       => tb_dut_os_dv_o,
    os_rfd_i      => tb_dut_os_rfd_i,
    -- Control and report IOs
    n_bytes_i     => X"04",
    n_pre_i       => X"10",
    n_sfd_i       => X"02", 
    send_i        => tb_dut_send_i,
    tx_rdy_o      => tb_dut_tx_rdy_o
  );
  ------------------------------------------------------------
  -- END DUT
  ------------------------------------------------------------


  ------------------------------------------------------------
  -- BEGIN STIMULUS
  ------------------------------------------------------------
  -- clock
  tb_dut_clk_i <= not tb_dut_clk_i after SAMPLE_PERIOD/2;
  -- Enable and reset Stimulus
  process
  begin
    tb_dut_en_i       <= '1';
    tb_dut_srst_i     <= '1';
    wait until rising_edge(tb_dut_clk_i);
    wait until rising_edge(tb_dut_clk_i);
    wait until rising_edge(tb_dut_clk_i);
    tb_dut_en_i       <= '1';
    tb_dut_srst_i     <= '0';
    wait;
  end process;
  --
  -- Control Stimulus
  process
    variable l      : line;
  begin
    tb_dut_send_i <= '0';
    for i in 1 to N_TX loop
      -- Wait for TX Ready signal
      if tb_dut_tx_rdy_o = '0' then
        wait until tb_dut_tx_rdy_o = '1';
      end if;
      -- Wait N_ZEROS clocks
      for j in 1 to N_ZEROS loop
        wait until rising_edge(tb_dut_clk_i);
      end loop;
      -- Send data and then return signal to 0
      tb_dut_send_i <= '1';
      wait until rising_edge(tb_dut_clk_i);
      wait until rising_edge(tb_dut_clk_i);
      tb_dut_send_i <= '0';
    end loop;
    --
    -- END OF SIMULATION
    write(l,string'("                                ")); writeline(output,l); -- COLO
    write(l,string'("#################################")); writeline(output,l); -- COLO
    write(l,string'("#                               #")); writeline(output,l); -- COLO
    write(l,string'("#  ++====    ++\  ++    ++=\\   #")); writeline(output,l); -- COLO
    write(l,string'("#  ||        ||\\ ||    ||  \\  #")); writeline(output,l); -- COLO
    write(l,string'("#  ||===     || \\||    ||  ||  #")); writeline(output,l); -- COLO
    write(l,string'("#  ||        ||  \||    ||  //  #")); writeline(output,l); -- COLO
    write(l,string'("#  ++====    ++   ++    ++=//   #")); writeline(output,l); -- COLO
    write(l,string'("#                               #")); writeline(output,l); -- COLO
    write(l,string'("#################################")); writeline(output,l); -- COLO
    write(l,string'("                                ")); writeline(output,l); -- COLO
    assert false -- este assert se pone para abortar la simulacion
      report "Fin de la simulacion"
      severity failure;
  end process;
  --
  -- Input Stream Stimulus
  process
    variable byte_v : integer := 0;
  begin
    tb_dut_is_data_i <= std_logic_vector(to_unsigned(byte_v,8));
    tb_dut_is_dv_i   <= '1';
    loop
      wait until rising_edge(tb_dut_clk_i);
      if tb_dut_is_rfd_o = '1' then
        byte_v := byte_v+1;
        tb_dut_is_data_i <= std_logic_vector(to_unsigned(byte_v,8));
      end if;
    end loop;
  end process;
  --
  -- Output Stream Stimulus
  process
  begin
    tb_dut_os_rfd_i   <= '1';
    wait;
  end process;
  ------------------------------------------------------------
  -- END STIMULUS
  ------------------------------------------------------------

end architecture;



