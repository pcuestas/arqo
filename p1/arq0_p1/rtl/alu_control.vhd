--------------------------------------------------------------------------------
-- Bloque de control para la ALU. Arq0 2021-2022.
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES, Quitar este mensaje)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
end alu_control;

architecture rtl of alu_control is
  -- Tipo para los codigos de control de la ALU:
  subtype t_aluControl is std_logic_vector (3 downto 0);
  subtype t_aluOp is std_logic_vector (2 downto 0);
  -- Codigos de control:
  constant ALU_OR   : t_aluControl := "0111";
  constant ALU_NOT  : t_aluControl := "0101";
  constant ALU_XOR  : t_aluControl := "0110";
  constant ALU_AND  : t_aluControl := "0100";
  constant ALU_SUB  : t_aluControl := "0001";
  constant ALU_ADD  : t_aluControl := "0000";
  constant ALU_SLT  : t_aluControl := "1010";
  constant ALU_S16  : t_aluControl := "1101";
  -- Operaciones de datos inmediatos:
  constant AO_ADD   : t_aluOp := "000";
  constant AO_SUB   : t_aluOp := "001";
  constant AO_AND   : t_aluOp := "100";
  constant AO_SLT   : t_aluOp := "110";

begin

  AluControl <= ALU_ADD when AluOp = AO_ADD else -- addi, lw o sw, que hace una suma
                ALU_S16 when AluOp = "011" else -- lui,
                ALU_SUB when AluOp = AO_SUB; -- beq
                ALU_AND when AluOp = AO_AND; -- andi
                ALU_SLT when AluOp = AO_SLT; -- slti
                ALU_ADD when AluOp = "010" and Funct = "100000" else -- add
                ALU_SUB when AluOp = "010" and Funct = "100010" else -- sub
                ALU_AND when AluOp = "010" and Funct = "100100" else -- and
                ALU_OR  when AluOp = "010" and Funct = "100101" else -- or
                ALU_SLT when AluOp = "010" and Funct = "101010" else -- slt
                ALU_NOT;-- when AluOP_IDEX = "10" and Inm_ext_IDEX(5 downto 0) = "100110"; -- xor

end architecture;
