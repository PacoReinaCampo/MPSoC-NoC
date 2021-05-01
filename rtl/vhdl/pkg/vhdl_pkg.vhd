-- Converted from pkg/vhdl_pkg.sv
-- by verilog2vhdl - QueenField

--//////////////////////////////////////////////////////////////////////////////
--                                            __ _      _     _               //
--                                           / _(_)    | |   | |              //
--                __ _ _   _  ___  ___ _ __ | |_ _  ___| | __| |              //
--               / _` | | | |/ _ \/ _ \ '_ \|  _| |/ _ \ |/ _` |              //
--              | (_| | |_| |  __/  __/ | | | | | |  __/ | (_| |              //
--               \__, |\__,_|\___|\___|_| |_|_| |_|\___|_|\__,_|              //
--                  | |                                                       //
--                  |_|                                                       //
--                                                                            //
--                                                                            //
--              Package                                                       //
--              Hardware Description Language                                 //
--              Bus Interface                                                 //
--                                                                            //
--//////////////////////////////////////////////////////////////////////////////

-- Copyright (c) 2017-2018 by the author(s)
-- *
-- * Permission is hereby granted, free of charge, to any person obtaining a copy
-- * of this software and associated documentation files (the "Software"), to deal
-- * in the Software without restriction, including without limitation the rights
-- * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- * copies of the Software, and to permit persons to whom the Software is
-- * furnished to do so, subject to the following conditions:
-- *
-- * The above copyright notice and this permission notice shall be included in
-- * all copies or substantial portions of the Software.
-- *
-- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- * THE SOFTWARE.
-- *
-- * =============================================================================
-- * Author(s):
-- *   Paco Reina Campo <pacoreinacampo@queenfield.tech>
-- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package vhdl_pkg is

  --////////////////////////////////////////////////////////////////
  --
  -- Types
  --
  type std_logic_matrix is array (natural range <>) of std_logic_vector;
  type std_logic_3array is array (natural range <>) of std_logic_matrix;
  type std_logic_4array is array (natural range <>) of std_logic_3array;
  type std_logic_5array is array (natural range <>) of std_logic_4array;
  type std_logic_6array is array (natural range <>) of std_logic_5array;
  type std_logic_7array is array (natural range <>) of std_logic_6array;
  type std_logic_8array is array (natural range <>) of std_logic_7array;
  type std_logic_9array is array (natural range <>) of std_logic_8array;

  type xy_std_logic        is array (natural range <>, natural range <>) of std_logic;
  type xy_std_logic_vector is array (natural range <>, natural range <>) of std_logic_vector;
  type xy_std_logic_matrix is array (natural range <>, natural range <>) of std_logic_matrix;
  type xy_std_logic_3array is array (natural range <>, natural range <>) of std_logic_3array;
  type xy_std_logic_4array is array (natural range <>, natural range <>) of std_logic_4array;
  type xy_std_logic_5array is array (natural range <>, natural range <>) of std_logic_5array;
  type xy_std_logic_6array is array (natural range <>, natural range <>) of std_logic_6array;
  type xy_std_logic_7array is array (natural range <>, natural range <>) of std_logic_7array;
  type xy_std_logic_8array is array (natural range <>, natural range <>) of std_logic_8array;
  type xy_std_logic_9array is array (natural range <>, natural range <>) of std_logic_9array;

  type xyz_std_logic        is array (natural range <>, natural range <>, natural range <>) of std_logic;
  type xyz_std_logic_vector is array (natural range <>, natural range <>, natural range <>) of std_logic_vector;
  type xyz_std_logic_matrix is array (natural range <>, natural range <>, natural range <>) of std_logic_matrix;
  type xyz_std_logic_3array is array (natural range <>, natural range <>, natural range <>) of std_logic_3array;
  type xyz_std_logic_4array is array (natural range <>, natural range <>, natural range <>) of std_logic_4array;
  type xyz_std_logic_5array is array (natural range <>, natural range <>, natural range <>) of std_logic_5array;
  type xyz_std_logic_6array is array (natural range <>, natural range <>, natural range <>) of std_logic_6array;
  type xyz_std_logic_7array is array (natural range <>, natural range <>, natural range <>) of std_logic_7array;
  type xyz_std_logic_8array is array (natural range <>, natural range <>, natural range <>) of std_logic_8array;
  type xyz_std_logic_9array is array (natural range <>, natural range <>, natural range <>) of std_logic_9array;

  function to_stdlogic (input : boolean) return std_logic;
  function reduce_and (reduce_and_in : std_logic_vector) return std_logic;
  function reduce_nand (reduce_nand_in : std_logic_vector) return std_logic;
  function reduce_nor (reduce_nor_in : std_logic_vector) return std_logic;
  function reduce_or (reduce_or_in : std_logic_vector) return std_logic;
  function reduce_xor (reduce_xor_in : std_logic_vector) return std_logic;
  function ternary (a : integer; b : integer; selection : integer) return integer;

end vhdl_pkg;

package body vhdl_pkg is
  --////////////////////////////////////////////////////////////////
  --
  -- Functions
  --
  function to_stdlogic (
    input : boolean
    ) return std_logic is
  begin
    if input then
      return('1');
    else
      return('0');
    end if;
  end function to_stdlogic;

  function reduce_and (
    reduce_and_in : std_logic_vector
    ) return std_logic is
    variable reduce_and_out : std_logic := '0';
  begin
    for i in reduce_and_in'range loop
      reduce_and_out := reduce_and_out and reduce_and_in(i);
    end loop;
    return reduce_and_out;
  end reduce_and;

  function reduce_nand (
    reduce_nand_in : std_logic_vector
  ) return std_logic is
    variable reduce_nand_out : std_logic := '0';
  begin
    for i in reduce_nand_in'range loop
      reduce_nand_out := reduce_nand_out nand reduce_nand_in(i);
    end loop;
    return reduce_nand_out;
  end reduce_nand;

  function reduce_nor (
    reduce_nor_in : std_logic_vector
    ) return std_logic is
    variable reduce_nor_out : std_logic := '0';
  begin
    for i in reduce_nor_in'range loop
      reduce_nor_out := reduce_nor_out nor reduce_nor_in(i);
    end loop;
    return reduce_nor_out;
  end reduce_nor;

  function reduce_or (
    reduce_or_in : std_logic_vector
    ) return std_logic is
    variable reduce_or_out : std_logic := '0';
  begin
    for i in reduce_or_in'range loop
      reduce_or_out := reduce_or_out or reduce_or_in(i);
    end loop;
    return reduce_or_out;
  end reduce_or;

  function reduce_xor (
    reduce_xor_in : std_logic_vector
    ) return std_logic is
    variable reduce_xor_out : std_logic := '0';
  begin
    for i in reduce_xor_in'range loop
      reduce_xor_out := reduce_xor_out xor reduce_xor_in(i);
    end loop;
    return reduce_xor_out;
  end reduce_xor;

  function ternary (
    a : integer;
    b : integer;
    selection : integer
    ) return integer is
  begin
    if selection > 0 then
      return a;
    else
      return b;
    end if;
  end function ternary;

end vhdl_pkg;
