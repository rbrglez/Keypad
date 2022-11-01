---------------------------------------------------------------------------------------------------
--! @brief 
--!
--! @author Rene Brglez (rene.brglez@cosylab.com)
--!
--! @date November 2022
--! 
--! @version v0.1
--!
--! @file KeyboardDecoder.vhd
--!
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library surf;
use surf.StdRtlPkg.all;

---------------------------------------------------------------------------------------------------
entity KeyboardDecoder is
   generic (
      TPD_G       : time     := 1 ns; -- simulated propagation delay
      ROW_WIDTH_G : positive := 4;
      COL_WIDTH_G : positive := 4
   );
   port (
      clk_i : in sl;
      rst_i : in sl;

      en_i : in sl;

      row_i : in  slv(ROW_WIDTH_G - 1 downto 0);
      col_o : out slv(COL_WIDTH_G - 1 downto 0);

      -- TODO: use generic?
      actCol_o : out slv(4 - 1 downto 0);
      actRow_o : out slv(4 - 1 downto 0);

      err_o : out sl

   );
end KeyboardDecoder;
---------------------------------------------------------------------------------------------------    
architecture rtl of KeyboardDecoder is

   --! FSM state record
   type StateType is (
         IDLE_S,
         RD_ROW_S,
         SET_COL_S,
         ERROR_S,
         DECODE_S
      );

   --! Record containing all FSM outputs and states
   type RegType is record
      col : slv(col_o'range);
      -- TODO: smaller range: log2(COL_WIDTH_G) - 1 downto 0?
      colIdx : unsigned(col_o'range);
      rowIdx : unsigned(row_i'range);

      actColIdx : unsigned(col_o'range);
      actRowIdx : unsigned(row_i'range);

      err : sl;
      --
      state : StateType;
   end record RegType;

   --! Initial and reset values for all register elements
   constant REG_INIT_C : RegType := (
         col    => (others => '0'),
         colIdx => (others => '0'),
         rowIdx => (others => '0'),

         actColIdx => (others => '0'),
         actRowIdx => (others => '0'),

         err => '0',
         --
         state => IDLE_S
      );

   --! Output of registers
   signal r : RegType;

   --! Combinatorial input to registers
   signal rin : RegType;

---------------------------------------------------------------------------------------------------
begin

   p_Comb : process (all) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            --
            v.col    := (others => '0');
            v.colIdx := (others => '0');
            v.rowIdx := (others => '0');

            if (en_i = '1') then
               v.err   := '0';
               v.state := SET_COL_S;
            end if;
         ----------------------------------------------------------------------
         when SET_COL_S =>

            v.col                       := (others => '0');
            v.col(to_integer(r.colIdx)) := '1';
            v.state                     := RD_ROW_S;

         ----------------------------------------------------------------------
         when RD_ROW_S =>
            if (unsigned(row_i) /= to_unsigned(0, row_i'length)) then
               -- at least one row is active
               if (onesCountU(row_i) = to_unsigned(1, row_i'length)) then
                  -- only one row is active
                  v.actColIdx := r.colIdx;
                  -- TODO: use better function
                  for I in 0 to 4 - 1 loop
                     if (row_i(I) = '1') then
                        v.actRowIdx := to_unsigned(I, r.actRowIdx);
                        exit;
                     end if;
                  end loop;

               else
                  -- multiple rows are active
                  v.state := ERROR_S;

               end if;

            else
               -- no row is active

            end if;


            -- TODO: wait here a bit?


            if (r.colIdx = ROW_WIDTH_G) then
               v.state := DECODE_S;
            else
               v.state := SET_COL_S;
            end if;

         ----------------------------------------------------------------------
         when ERROR_S =>
            v.err   := '1';
            v.state := IDLE_S;
         ----------------------------------------------------------------------
         when DECODE_S =>
            v.state := IDLE_S;
         ----------------------------------------------------------------------
         when others =>
            v := REG_INIT_C;
      ----------------------------------------------------------------------
      end case;

      -- Reset
      if (rst_i = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Outputs        
      err_o    <= r.err;
      actCol_o <= slv(r.actColIdx);
      actRow_o <= slv(r.actRowIdx);

      col_o <= r.col;

   end process p_Comb;

   p_Seq : process(clk_i)
   begin
      if rising_edge(clk_i) then
         r <= rin after TPD_G;
      end if;
   end process p_Seq;

end rtl;
---------------------------------------------------------------------------------------------------