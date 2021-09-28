--------------------------------------------------------------------------------
-- Unidad de control principal del micro. Arq0 2021-2022
--
-- Pablo Cuesta Sierra, Álvaro Zamanillo Sáez
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_unit is
   port (
      -- Entrada = codigo de operacion en la instruccion:
      Instr  : in  std_logic_vector (31 downto 0);
      -- Seniales para el PC
      Branch : out  std_logic; -- 1 = Ejecutandose instruccion branch
      Jump   : out  std_logic; -- 1 = Ejecutandose instruccion jump
      -- Seniales relativas a la memoria
      MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
      MemWrite : out  std_logic; -- Escribir la memoria
      MemRead  : out  std_logic; -- Leer la memoria
      -- Seniales para la ALU
      ALUSrc : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
      ALUOp  : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
      -- Seniales para el GPR
      RegWrite : out  std_logic; -- 1=Escribir registro
      RegDst   : out  std_logic  -- 0=Reg. destino es rt, 1=rd
   );
end control_unit;

architecture rtl of control_unit is
   signal OPCode : std_logic_vector (5 downto 0); 


   -- Tipo para los codigos de operacion:
   subtype t_opCode is std_logic_vector (5 downto 0);
   subtype t_aluOp is std_logic_vector (2 downto 0);
   -- Codigos de operacion para las diferentes instrucciones:
   constant OP_RTYPE  : t_opCode := "000000";
   constant OP_BEQ    : t_opCode := "000100";
   constant OP_SW     : t_opCode := "101011";
   constant OP_LW     : t_opCode := "100011";
   constant OP_LUI    : t_opCode := "001111";

   constant OP_ADDI   : t_opCode := "001000";
   constant OP_ANDI   : t_opCode := "001100";
   constant OP_SLTI   : t_opCode := "001010";
   constant OP_J      : t_opCode := "000010";
   -- Operaciones de datos inmediatos (AluOp):
   constant AO_ADD   : t_aluOp := "000";
   constant AO_SUB   : t_aluOp := "001";
   constant AO_AND   : t_aluOp := "100";
   constant AO_SLT   : t_aluOp := "110";

begin

OPCode <= Instr(31 downto 26); -- 6 most significant bits

Branch   <= '1' when opCode = OP_BEQ else '0';

ALUSrc   <= '0' when opCode = OP_RTYPE else -- R-type
            '0' when opCode = OP_BEQ   else -- beq
            '1'; -- lw, sw

RegDst   <= '1' when opCode = OP_RTYPE else -- R-type
            '0'; -- lw, sw, beq, j, I-type

RegWrite <= '0' when opCode = OP_SW  else -- sw
            '0' when opCode = OP_BEQ else -- bew
            '0' when Instr = x"0000" else
            '0' when opCode = OP_J else -- j
            '1'; -- R-type, lw, I-type, jal

MemRead  <= '1' when opCode = OP_LW else --lw
            '0';

MemWrite <= '1' when opCode = OP_SW else -- sw
            '0'; 

MemToReg <= '1' when opCode = OP_LW else -- lw
            '0'; -- R-type, sw, beq, j, jal, I-type

ALUOP    <= AO_ADD when opCode = OP_LW  else -- lw
            AO_ADD when opCode = OP_SW  else -- sw
            AO_SUB when opCode = OP_BEQ else -- beq
            "011"  when opCode = OP_LUI else -- lui
            AO_AND when opCode = OP_ANDI else -- andi
            AO_ADD when opCode = OP_ADDI else -- addi
            AO_SLT when opCode = OP_SLTI else -- slti
            "010"; -- r-type;

Jump <= '1' when opCode = OP_J     else -- j
        '1' when opCode = "000011" else --jal
        '0';


end architecture;
