----------------------------------------------------------------------------------------------------
-- @brief GeneralOutputsTb
--
-- @author Rene Brglez (rene.brglez@gmail.com)
--
-- @date December 2022
-- 
-- @version v0.1
--
-- @file GeneralOutputs.vhd
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
entity GeneralOutputsTb is
end entity GeneralOutputsTb;
-----------------------------------------------------------

architecture testbench of GeneralOutputsTb is

   -- Constants
   constant TPD_C : time := 1 ns;
   constant T_C   : time := 10 ns;

   constant OUTPUT_WIDTH_C : natural := 4;
   constant SYNC_STAGES_C  : natural := 2;
   constant HW_POLARITY_C  : sl      := '1';

   -- Testbench DUT ports
   signal clk_i       : sl;
   signal rst_i       : sl;
   signal fwOutputs_i : slv(OUTPUT_WIDTH_C - 1 downto 0);
   signal hwOutputs_o : slv(OUTPUT_WIDTH_C - 1 downto 0);

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
      fwOutputs_i <= (others => '0');

      wait until rst_i = '0';
      wait for TPD_C;

      wait for 10 * T_C;

      fwOutputs_i <= (others => '1');
      wait for 20 * T_C;

      fwOutputs_i <= (others => '0');
      wait for 20 * T_C;

      assert false report "Simulation completed" severity failure;

   end process p_Sim;
   -----------------------------------------------------------
   -- Entity Under Test
   -----------------------------------------------------------
   dut_GeneralOutputs : entity work.GeneralOutputs
      generic map (
         TPD_G          => TPD_C,
         OUTPUT_WIDTH_G => OUTPUT_WIDTH_C,
         SYNC_STAGES_G  => SYNC_STAGES_C,
         HW_POLARITY_G  => HW_POLARITY_C
      )
      port map (
         clk_i       => clk_i,
         rst_i       => rst_i,
         fwOutputs_i => fwOutputs_i,
         hwOutputs_o => hwOutputs_o
      );

end architecture testbench;