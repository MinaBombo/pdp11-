library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package LAO is
-------------------------------------------------------------------------------------------------------
function shift_logic_right(arg : std_logic_vector)return std_logic_vector;
-- Result subtype: std_logic_vector(arg'length-1 downto 0)
-- Result: Performs a shift-right on an std_logic_vector.
--         The vacated bit is filled with '0'.
--         The rightmost element is lost.
-------------------------------------------------------------------------------------------------------
function shift_arith_right(arg : std_logic_vector)return std_logic_vector;
-- Result subtype: std_logic_vector(arg'length-1 downto 0)
-- Result: Performs a shift-right on an std_logic_vector.
--         The vacated bit is filled with the leftmost element, arg'left.
--         The rightmost element is lost.
-------------------------------------------------------------------------------------------------------
function rotate_right_carry(arg : std_logic_vector; carry : std_logic)return std_logic_vector;
-- Result subtype: std_logic_vector(arg'length-1 downto 0)
-- Result: Performs a rotate-right of an std_logic_vector and leftmost bit is filled with carry.
-------------------------------------------------------------------------------------------------------
function shift_logic_left(arg : std_logic_vector)return std_logic_vector;
-- Result subtype: std_logic_vector(arg'length-1 downto 0)
-- Result: Performs a shift-left on an std_logic_vector.
--         The vacated bit is filled with '0'.
--         The leftmost element is lost.
-------------------------------------------------------------------------------------------------------
function rotate_left_carry(arg : std_logic_vector; carry : std_logic)return std_logic_vector;
-- Result subtype: std_logic_vector(arg'length-1 downto 0)
-- Result: Performs a rotate-left of an std_logic_vector and rightmost bit is filled with carry.
-------------------------------------------------------------------------------------------------------
end LAO;

package body LAO is
-------------------------------------------------------------------------------------------------------
function shift_logic_right(arg : std_logic_vector)return std_logic_vector is
begin
    return '0' & arg(arg'length-1 downto 1); 
end shift_logic_right;
-------------------------------------------------------------------------------------------------------
function shift_arith_right(arg : std_logic_vector)return std_logic_vector is
begin
    return arg(arg'length-1) & arg(arg'length-1 downto 1); 
end shift_arith_right;
-------------------------------------------------------------------------------------------------------
function rotate_right_carry(arg : std_logic_vector; carry : std_logic)return std_logic_vector is
begin
    return carry & arg(arg'length-1 downto 1); 
end rotate_right_carry;
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
function shift_logic_left(arg : std_logic_vector)return std_logic_vector is
begin
    return arg(arg'length-2 downto 0) & '0'; 
end shift_logic_left;
-------------------------------------------------------------------------------------------------------
function rotate_left_carry(arg : std_logic_vector; carry : std_logic)return std_logic_vector is
begin
    return arg(arg'length-2 downto 0) & carry;
end rotate_left_carry;
-------------------------------------------------------------------------------------------------------
end LAO;