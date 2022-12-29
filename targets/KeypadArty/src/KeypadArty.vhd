---------------------------------------------------------------------------------------------------
--! @brief  
--! @details 
--!
--! @author 
--!
--! @file KeypadArty.vhd
--!
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
library surf;
use surf.StdRtlPkg.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.MarkDebugPkg.all;

entity KeypadArty is
   generic (
      TPD_G : time := 1 ns
   );
   port (
      CLK100MHZ : in sl;
      ck_rst    : in sl;

      -- white LEDs
      led : out slv(3 downto 0);
      sw  : in  slv(3 downto 0);

      -- 4x4 button matrix
      ck_io26 : in sl; -- Pin 8
      ck_io27 : in sl; -- Pin 7
      ck_io28 : in sl; -- Pin 6
      ck_io29 : in sl; -- Pin 5

      ck_io38 : out sl; -- Pin 4
      ck_io39 : out sl; -- Pin 3
      ck_io40 : out sl; -- Pin 2
      ck_io41 : out sl; -- Pin 1

      --------------------------------------------------------------------------
      -- ChipKit Outer Digital Header
      --------------------------------------------------------------------------
      -- Inputs (H5 - H8)
      ck_io0 : in sl; -- H8
      ck_io1 : in sl; -- H7
      ck_io2 : in sl; -- H6
      ck_io3 : in sl; -- H5

      -- Outputs (H1 - H4)
      ck_io8  : out sl; -- H4
      ck_io9  : out sl; -- H3
      ck_io10 : out sl; -- H2
      ck_io11 : out sl  -- H1
   );
end KeypadArty;
---------------------------------------------------------------------------------------------------    
architecture rtl of KeypadArty is

   -- constants
   constant CLK_FREQ_C : real := 100.0E6;


   constant H1_C : natural := 0;
   constant H2_C : natural := 1;
   constant H3_C : natural := 2;
   constant H4_C : natural := 3;

   constant H5_C : natural := 0;
   constant H6_C : natural := 1;
   constant H7_C : natural := 2;
   constant H8_C : natural := 3;

   signal clk : sl;
   signal rst : sl;

   signal col : slv(4 - 1 downto 0);
   signal row : slv(4 - 1 downto 0);

   signal actCol : slv(4 - 1 downto 0);
   signal actRow : slv(4 - 1 downto 0);
   signal err    : sl;


   -- test
   -- Header 1 to 4
   signal fwHeader14 : slv(4 - 1 downto 0);
   signal hwHeader14 : slv(4 - 1 downto 0);

   -- Header 5 to 8
   signal fwHeader58 : slv(4 - 1 downto 0);
   signal hwHeader58 : slv(4 - 1 downto 0);


   signal fwSwitch : slv(4 - 1 downto 0);

   -----------------------------------------------------------------------------
   -- Debug declarations
   -----------------------------------------------------------------------------
   attribute mark_debug : string;

   attribute mark_debug of actCol : signal is TOP_C;
   attribute mark_debug of actRow : signal is TOP_C;
   attribute mark_debug of err    : signal is TOP_C;

   attribute mark_debug of row : signal is TOP_C;
   attribute mark_debug of col : signal is TOP_C;

   attribute mark_debug of clk : signal is TOP_C;

   -- Test
   attribute mark_debug of fwHeader14 : signal is TOP_C;
   attribute mark_debug of hwHeader14 : signal is TOP_C;
   attribute mark_debug of fwHeader58 : signal is TOP_C;
   attribute mark_debug of hwHeader58 : signal is TOP_C;

   attribute mark_debug of fwSwitch : signal is TOP_C;

---------------------------------------------------------------------------------------------------
begin

   --
   clk <= CLK100MHZ;
   rst <= not(ck_rst);

   led <= "0101";

   row <= (ck_io26 & ck_io27 & ck_io28 & ck_io29);

   ck_io38 <= row(3);
   ck_io39 <= row(2);
   ck_io40 <= row(1);
   ck_io41 <= row(0);

   u_KeyboardDecoder : entity work.KeyboardDecoder
      generic map (
         TPD_G       => TPD_G,
         ROW_WIDTH_G => 4,
         COL_WIDTH_G => 4
      )
      port map (
         clk_i => clk,
         rst_i => rst,
         en_i  => '1',

         row_i => row,
         col_o => col,

         actCol_o => actCol,
         actRow_o => actRow,
         err_o    => err
      );


   -----------------------------------------------------------------------------
   -- "cORE"
   -----------------------------------------------------------------------------


   fwHeader14 <= fwSwitch;
   -----------------------------------------------------------------------------
   --
   -----------------------------------------------------------------------------
   u_SwitchInputs : entity work.GeneralInputs
      generic map (
         TPD_G             => TPD_G,
         INPUT_WIDTH_G     => 4,
         CLK_FREQ_G        => CLK_FREQ_C,
         SYNC_STAGES_G     => 3,
         DEBOUNCE_PERIOD_G => 20.0E-3,
         HW_POLARITY_G     => '1',
         FW_POLARITY_G     => '1'
      )
      port map (
         clk_i      => clk,
         rst_i      => rst,
         hwInputs_i => sw,
         fwInputs_o => fwSwitch
      );

   u_Header58Inputs : entity work.GeneralInputs
      generic map (
         TPD_G             => TPD_G,
         INPUT_WIDTH_G     => 4,
         CLK_FREQ_G        => CLK_FREQ_C,
         SYNC_STAGES_G     => 3,
         DEBOUNCE_PERIOD_G => 20.0E-3,
         HW_POLARITY_G     => '1',
         FW_POLARITY_G     => '1'
      )
      port map (
         clk_i      => clk,
         rst_i      => rst,
         hwInputs_i => hwHeader58,
         fwInputs_o => fwHeader58
      );

   hwHeader58(H5_C) <= ck_io3;
   hwHeader58(H6_C) <= ck_io2;
   hwHeader58(H7_C) <= ck_io1;
   hwHeader58(H8_C) <= ck_io0;


   u_Header14Outputs : entity work.GeneralOutputs
      generic map (
         TPD_G          => TPD_G,
         OUTPUT_WIDTH_G => 4,
         SYNC_STAGES_G  => 2,
         HW_POLARITY_G  => '1'
      )
      port map (
         clk_i       => clk,
         rst_i       => rst,
         fwOutputs_i => fwHeader14,
         hwOutputs_o => hwHeader14
      );


   ck_io11 <= hwHeader14(H1_C);
   ck_io10 <= hwHeader14(H2_C);
   ck_io9  <= hwHeader14(H3_C);
   ck_io8  <= hwHeader14(H4_C);

end rtl;
---------------------------------------------------------------------------------------------------