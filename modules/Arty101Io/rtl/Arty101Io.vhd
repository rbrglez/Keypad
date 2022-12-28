----------------------------------------------------------------------------------------------------
-- @brief Arty101Io
--
-- @author Rene Brglez (rene.brglez@gmail.com)
--
-- @date December 2022
-- 
-- @version v0.1
--
-- @file Arty101Io.vhd
--
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library surf;
use surf.StdRtlPkg.all;

----------------------------------------------------------------------------------------------------
entity Arty101Io is
   generic (
      TPD_G             : time := 1 ns;
      CLK_FREQ_G        : real := 100.0E6;
      DEBOUNCE_PERIOD_G : real := 20.0E-3
   );
   port (
      --------------------------------------------------------------------------
      -- Inputs
      --------------------------------------------------------------------------
      -- Clock
      hwClk_i : in  sl;
      fwClk_o : out sl;
      -- Reset
      hwRst_i : in  sl;
      fwRst_o : out sl;
      -- Buttons
      hwBtns_i : in  slv(4 - 1 downto 0);
      fwBtns_o : out slv(4 - 1 downto 0);
      -- Switches
      hwSwitch_i : in  slv(4 - 1 downto 0);
      fwSwitch_o : out slv(4 - 1 downto 0);

      --------------------------------------------------------------------------
      -- Outputs
      --------------------------------------------------------------------------
      -- Leds
      fwLeds_i : in  slv(4 - 1 downto 0);
      hwLeds_o : out slv(4 - 1 downto 0);
      -- Rgb Leds
      fwRgbLeds_i : in  slv(12 - 1 downto 0);
      hwRgbLeds_o : out slv(12 - 1 downto 0)
   );
end Arty101Io;
----------------------------------------------------------------------------------------------------   
architecture rtl of Arty101Io is

   signal clk : sl;
   signal rst : sl;

---------------------------------------------------------------------------------------------------
begin

   -----------------------------------------------------------------------------
   -- Inputs
   -----------------------------------------------------------------------------
   -- Clock
   clk     <= hwClk_i;
   fwClk_o <= clk;

   -- Reset
   fwRst_o <= rst;
   u_RstInput : entity work.GeneralInputs
      generic map (
         TPD_G             => TPD_G,
         INPUT_WIDTH_G     => 1,
         CLK_FREQ_G        => CLK_FREQ_G,
         SYNC_STAGES_G     => 3,
         DEBOUNCE_PERIOD_G => DEBOUNCE_PERIOD_G,
         HW_POLARITY_G     => '0',
         FW_POLARITY_G     => '1'
      )
      port map (
         clk_i         => clk,
         rst_i         => '0',
         hwInputs_i(0) => hwRst_i,
         fwInputs_o(0) => rst
      );

   -- Buttons
   u_ButtonInputs : entity work.GeneralInputs
      generic map (
         TPD_G             => TPD_G,
         INPUT_WIDTH_G     => 4,
         CLK_FREQ_G        => CLK_FREQ_G,
         SYNC_STAGES_G     => 3,
         DEBOUNCE_PERIOD_G => DEBOUNCE_PERIOD_G,
         HW_POLARITY_G     => '1',
         FW_POLARITY_G     => '1'
      )
      port map (
         clk_i      => clk,
         rst_i      => rst,
         hwInputs_i => hwBtns_i,
         fwInputs_o => fwBtns_o
      );

   -- Switches
   u_SwitchInputs : entity work.GeneralInputs
      generic map (
         TPD_G             => TPD_G,
         INPUT_WIDTH_G     => 4,
         CLK_FREQ_G        => CLK_FREQ_G,
         SYNC_STAGES_G     => 3,
         DEBOUNCE_PERIOD_G => DEBOUNCE_PERIOD_G,
         HW_POLARITY_G     => '1',
         FW_POLARITY_G     => '1'
      )
      port map (
         clk_i      => clk,
         rst_i      => rst,
         hwInputs_i => hwSwitch_i,
         fwInputs_o => fwSwitch_o
      );

   -----------------------------------------------------------------------------
   -- Outputs
   -----------------------------------------------------------------------------
   -- Leds
   u_LedOutputs : entity work.GeneralOutputs
      generic map (
         TPD_G          => TPD_G,
         OUTPUT_WIDTH_G => 4,
         SYNC_STAGES_G  => 2,
         HW_POLARITY_G  => '1'
      )
      port map (
         clk_i       => clk,
         rst_i       => rst,
         fwOutputs_i => fwLeds_i,
         hwOutputs_o => hwLeds_o
      );

   -- Rgb Leds
   u_RgbLedOutputs : entity work.GeneralOutputs
      generic map (
         TPD_G          => TPD_G,
         OUTPUT_WIDTH_G => 12,
         SYNC_STAGES_G  => 2,
         HW_POLARITY_G  => '1'
      )
      port map (
         clk_i       => clk,
         rst_i       => rst,
         fwOutputs_i => fwRgbLeds_i,
         hwOutputs_o => hwRgbLeds_o
      );

end rtl;
----------------------------------------------------------------------------------------------------