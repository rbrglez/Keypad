----------------------------------------------------------------------------------------------------
-- @brief GeneralInputs
--
-- @author Rene Brglez (rene.brglez@gmail.com)
--
-- @date December 2022
-- 
-- @version v0.1
--
-- @file GeneralInputs.vhd
--
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library surf;
use surf.StdRtlPkg.all;

----------------------------------------------------------------------------------------------------
entity GeneralInputs is
   generic (
      TPD_G             : time    := 1 ns; -- simulated propagation delay
      INPUT_WIDTH_G     : natural := 4;
      CLK_FREQ_G        : real    := 100.0E6;
      SYNC_STAGES_G     : natural := 3;
      DEBOUNCE_PERIOD_G : real    := 20.0E-3;
      HW_POLARITY_G     : sl      := '0';
      FW_POLARITY_G     : sl      := '0'
   );
   port (
      clk_i : in sl;
      rst_i : in sl;

      hwInputs_i : in  slv(INPUT_WIDTH_G - 1 downto 0); -- Physical inputs (from hardware)
      fwInputs_o : out slv(INPUT_WIDTH_G - 1 downto 0)  -- Synced and Debounced Inputs (to firmware)
   );
end GeneralInputs;
----------------------------------------------------------------------------------------------------   
architecture rtl of GeneralInputs is

   signal hwSync : slv(INPUT_WIDTH_G - 1 downto 0);

---------------------------------------------------------------------------------------------------
begin

   -- synchronize inputs
   u_InputsSync : entity surf.SynchronizerVector
      generic map (
         TPD_G    => TPD_G,
         STAGES_G => SYNC_STAGES_G,
         WIDTH_G  => INPUT_WIDTH_G
      )
      port map (
         clk     => clk_i,
         rst     => rst_i,
         dataIn  => hwInputs_i,
         dataOut => hwSync
      );

   -- debounce inputs
   GEN_DEBOUNCE : for I in INPUT_WIDTH_G - 1 downto 0 generate
      ux_Debouncer : entity surf.Debouncer
         generic map (
            TPD_G             => TPD_G,
            CLK_FREQ_G        => CLK_FREQ_G,
            DEBOUNCE_PERIOD_G => DEBOUNCE_PERIOD_G,
            INPUT_POLARITY_G  => HW_POLARITY_G,
            OUTPUT_POLARITY_G => FW_POLARITY_G,
            SYNCHRONIZE_G     => false
         )
         port map (
            clk => clk_i,
            rst => rst_i,
            i   => hwSync(I),
            o   => fwInputs_o(I)
         );
   end generate GEN_DEBOUNCE;

end rtl;
----------------------------------------------------------------------------------------------------