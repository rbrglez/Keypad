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

      -- 4x4 button matrix
      ck_io26 : in sl; -- Pin 8
      ck_io27 : in sl; -- Pin 7
      ck_io28 : in sl; -- Pin 6
      ck_io29 : in sl; -- Pin 5

      ck_io38 : out sl; -- Pin 4
      ck_io39 : out sl; -- Pin 3
      ck_io40 : out sl; -- Pin 2
      ck_io41 : out sl  -- Pin 1
   );
end KeypadArty;
---------------------------------------------------------------------------------------------------    
architecture rtl of KeypadArty is

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

---------------------------------------------------------------------------------------------------
begin

   -- Test
   fwHeader14 <= x"A";
   hwHeader14 <= x"5";

   fwHeader58 <= x"D";
   hwHeader58 <= x"6";


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

end rtl;
---------------------------------------------------------------------------------------------------