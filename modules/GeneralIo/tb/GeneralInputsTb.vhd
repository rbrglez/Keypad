----------------------------------------------------------------------------------------------------
-- @brief GeneralInputsTb
--
-- @author Rene Brglez (rene.brglez@gmail.com)
--
-- @date December 2022
-- 
-- @version v0.1
--
-- @file GeneralInputsTb.vhd
--
----------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
library surf;
use surf.StdRtlPkg.all;

-----------------------------------------------------------
entity GeneralInputsTb is
end entity GeneralInputsTb;
-----------------------------------------------------------

architecture testbench of GeneralInputsTb is

   -- Constants
   constant TPD_C : time := 1 ns;
   constant T_C   : time := 10 ns; -- NS

   constant INPUT_WIDTH_C     : natural := 4;
   constant CLK_FREQ_C        : real    := 100.0E6;
   constant SYNC_STAGES_C     : natural := 3;
   constant DEBOUNCE_PERIOD_C : real    := 1.0E-6;
   constant HW_POLARITY_C     : sl      := '1';
   constant FW_POLARITY_C     : sl      := '1';

   -- dut ports
   signal clk_i      : sl;
   signal rst_i      : sl;
   signal hwInputs_i : slv(INPUT_WIDTH_C - 1 downto 0);
   signal fwInputs_o : slv(INPUT_WIDTH_C - 1 downto 0);

begin
   -----------------------------------------------------------
   -- Clocks and Reset
   -----------------------------------------------------------
   p_ClkGen : process
   begin
      clk_i <= '1';
      wait for T_C / 2;
      clk_i <= '0';
      wait for T_C / 2;
   end process p_ClkGen;

   p_RstGen : process
   begin
      rst_i <= '1',
         '0' after 10 * T_C;
      wait;
   end process p_RstGen;

   -----------------------------------------------------------
   -- Testbench Stimulus
   -----------------------------------------------------------
   p_Sim : process
   begin
      -- initialize inputs
      hwInputs_i <= (others => '0');

      wait until rst_i = '0';
      wait for TPD_C;

      wait for 100 * T_C;

      hwInputs_i <= (others => '1');
      wait for 200 * T_C;

      hwInputs_i <= (others => '0');
      wait for 200 * T_C;

      assert false report "Simulation completed" severity failure;

   end process p_Sim;
   -----------------------------------------------------------
   -- Entity Under Test
   -----------------------------------------------------------
   dut_GeneralInputs : entity work.GeneralInputs
      generic map (
         TPD_G             => TPD_C,
         INPUT_WIDTH_G     => INPUT_WIDTH_C,
         CLK_FREQ_G        => CLK_FREQ_C,
         SYNC_STAGES_G     => SYNC_STAGES_C,
         DEBOUNCE_PERIOD_G => DEBOUNCE_PERIOD_C,
         HW_POLARITY_G     => HW_POLARITY_C,
         FW_POLARITY_G     => FW_POLARITY_C
      )
      port map (
         clk_i      => clk_i,
         rst_i      => rst_i,
         hwInputs_i => hwInputs_i,
         fwInputs_o => fwInputs_o
      );

end architecture testbench;