----------------------------------------------------------------------------------------------------
-- @brief GeneralOutputs
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
use ieee.math_real.all;
library surf;
use surf.StdRtlPkg.all;

----------------------------------------------------------------------------------------------------
entity GeneralOutputs is
   generic (
      TPD_G          : time    := 1 ns; -- simulated propagation delay
      OUTPUT_WIDTH_G : natural := 4;
      SYNC_STAGES_G  : natural := 2;
      HW_POLARITY_G  : sl      := '1' 
   );
   port (
      clk_i : in sl;
      rst_i : in sl;

      fwOutputs_i : in  slv(OUTPUT_WIDTH_G - 1 downto 0); -- Outputs (from firmware)
      hwOutputs_o : out slv(OUTPUT_WIDTH_G - 1 downto 0)  -- Synced Physical Outputs (to hardware)
   );
end GeneralOutputs;
----------------------------------------------------------------------------------------------------   
architecture rtl of GeneralOutputs is

---------------------------------------------------------------------------------------------------
begin

   -- synchronize outputs
   u_OutputsSync : entity surf.SynchronizerVector
      generic map (
         TPD_G          => TPD_G,
         WIDTH_G        => OUTPUT_WIDTH_G,
         STAGES_G       => SYNC_STAGES_G,
         OUT_POLARITY_G => HW_POLARITY_G
      )
      port map (
         clk     => clk_i,
         rst     => rst_i,
         dataIn  => fwOutputs_i,
         dataOut => hwOutputs_o
      );

end rtl;
----------------------------------------------------------------------------------------------------