--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2021-2022
--
-- (INCLUIR AQUI LA INFORMACION SOBRE LOS AUTORES)
--
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity processor is
   port(
      Clk         : in  std_logic; -- Reloj activo en flanco subida
      Reset       : in  std_logic; -- Reset asincrono activo nivel alto
      -- Instruction memory
      IAddr      : out std_logic_vector(31 downto 0); -- Direccion Instr
      IDataIn    : in  std_logic_vector(31 downto 0); -- Instruccion leida
      -- Data memory
      DAddr      : out std_logic_vector(31 downto 0); -- Direccion
      DRdEn      : out std_logic;                     -- Habilitacion lectura
      DWrEn      : out std_logic;                     -- Habilitacion escritura
      DDataOut   : out std_logic_vector(31 downto 0); -- Dato escrito
      DDataIn    : in  std_logic_vector(31 downto 0)  -- Dato leido
   );
end processor;

architecture rtl of processor is

  component alu
    port(
      OpA      : in std_logic_vector (31 downto 0);
      OpB      : in std_logic_vector (31 downto 0);
      Control  : in std_logic_vector (3 downto 0);
      Result   : out std_logic_vector (31 downto 0);
      Signflag : out std_logic;
      Zflag    : out std_logic
    );
  end component;

  component reg_bank
     port (
        Clk   : in std_logic; -- Reloj activo en flanco de subida
        Reset : in std_logic; -- Reset as�ncrono a nivel alto
        A1    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd1
        Rd1   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd1
        A2    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Rd2
        Rd2   : out std_logic_vector(31 downto 0); -- Dato del puerto Rd2
        A3    : in std_logic_vector(4 downto 0);   -- Direcci�n para el puerto Wd3
        Wd3   : in std_logic_vector(31 downto 0);  -- Dato de entrada Wd3
        We3   : in std_logic -- Habilitaci�n de la escritura de Wd3
     );
  end component reg_bank;

  component control_unit
     port (
        -- Entrada = codigo de operacion en la instruccion:
        Instr   : in  std_logic_vector (31 downto 0);
        -- Seniales para el PC
        Branch   : out  std_logic; -- 1 = Ejecutandose instruccion branch
        Jump     : out  std_logic; -- 1 = Ejecutandose instruccion jump
        -- Seniales relativas a la memoria
        MemToReg : out  std_logic; -- 1 = Escribir en registro la salida de la mem.
        MemWrite : out  std_logic; -- Escribir la memoria
        MemRead  : out  std_logic; -- Leer la memoria
        -- Seniales para la ALU
        ALUSrc   : out  std_logic;                     -- 0 = oper.B es registro, 1 = es valor inm.
        ALUOp    : out  std_logic_vector (2 downto 0); -- Tipo operacion para control de la ALU
        -- Seniales para el GPR
        RegWrite : out  std_logic; -- 1 = Escribir registro
        RegDst   : out  std_logic  -- 0 = Reg. destino es rt, 1=rd
     );
  end component;

  component alu_control is
   port (
      -- Entradas:
      ALUOp  : in std_logic_vector (2 downto 0); -- Codigo de control desde la unidad de control
      Funct  : in std_logic_vector (5 downto 0); -- Campo "funct" de la instruccion
      -- Salida de control para la ALU:
      ALUControl : out std_logic_vector (3 downto 0) -- Define operacion a ejecutar por la ALU
   );
 end component alu_control;

  signal Alu_Op2      : std_logic_vector(31 downto 0);
  
  signal ALU_Igual    : std_logic;
  signal AluControl   : std_logic_vector(3 downto 0);
  signal reg_RD_data  : std_logic_vector(31 downto 0);
  signal ID_add_RD1, EX_add_RD1, EX_add_RD, MEM_add_RD      : std_logic_vector(4 downto 0);
  signal ID_add_RT, EX_add_RT       : std_logic_vector(4 downto 0);

  signal Regs_eq_branch : std_logic;
  signal EX_PC_next, MEM_PC_next        : std_logic_vector(31 downto 0);
  signal PC_reg         : std_logic_vector(31 downto 0);
  signal ID_PC_plus4, IF_PC_plus4, EX_PC_plus4       : std_logic_vector(31 downto 0);

  signal IF_Instruction, ID_Instruction    : std_logic_vector(31 downto 0); -- La instrucción desde lamem de instr
  signal ID_Inm_ext, EX_Inm_ext        : std_logic_vector(31 downto 0); -- La parte baja de la instrucción extendida de signo
  signal ID_reg_RS, EX_reg_RS, ID_reg_RT, EX_reg_RT, MEM_reg_RT : std_logic_vector(31 downto 0);

  signal dataIn_Mem     : std_logic_vector(31 downto 0); --From Data Memory
  signal Addr_Branch    : std_logic_vector(31 downto 0);

  signal ID_Ctrl_ALUSrc,   EX_Ctrl_ALUSrc : std_logic;
  signal ID_Ctrl_ALUOP,    EX_Ctrl_ALUOP    : std_logic_vector(2 downto 0);
  signal ID_Ctrl_RegDest,  EX_Ctrl_RegDest : std_logic;
  signal ID_Ctrl_Jump,     EX_Ctrl_Jump,      MEM__Ctrl_Jump : std_logic;
  signal ID_Ctrl_Branch,   EX_Ctrl_Branch,    MEM__Ctrl_Branch : std_logic;
  signal ID_Ctrl_MemWrite, EX_Ctrl_MemWrite,  MEM__Ctrl_MemWrite : std_logic;
  signal ID_Ctrl_MemRead,  EX_Ctrl_MemRead,   MEM__Ctrl_MemRead  : std_logic;
  signal ID_Ctrl_MemToReg, EX_Ctrl_MemToReg,  MEM__Ctrl_MemToReg : std_logic;
  signal ID_Ctrl_RegWrite, EX_Ctrl_RegWrite,  MEM__Ctrl_RegWrite: std_logic;

  signal Addr_Jump      : std_logic_vector(31 downto 0);
  signal Addr_Jump_dest : std_logic_vector(31 downto 0);
  signal desition_Jump  : std_logic;
  signal Alu_Res        : std_logic_vector(31 downto 0);

  --Nuevas señales  
  signal ID_Funct, EX_Funct : std_logic_vector(5 downto 0);
begin

  ID_add_RD1 <= ID_Instruction(20 downto 16);
  ID_add_RT <= ID_Instruction(15 downto 11);

  EX_PC_next <= Addr_Jump_dest when desition_Jump = '1' else EX_PC_plus4;

  PC_reg_proc: process(Clk, Reset)
  begin
    if Reset = '1' then
      PC_reg <= (others => '0');
    elsif rising_edge(Clk) then
      PC_reg <= PC_next;
    end if;
  end process;

  IF_PC_plus4    <= PC_reg + 4;
  IAddr       <= PC_reg;
  IF_Instruction <= IDataIn;

  RegsMIPS : reg_bank
  port map (
    Clk   => Clk,
    Reset => Reset,
    A1    => ID_Instruction(25 downto 21),
    Rd1   => ID_reg_RS,
    A2    => ID_Instruction(20 downto 16),
    Rd2   => ID_reg_RT,
    A3    => MEM_add_RD, --la que viene de la ultima etapa
    Wd3   => reg_RD_data,
    We3   => Ctrl_RegWrite
  );

  UnidadControl : control_unit
  port map(
    Instr   => ID_Instruction,
    -- Señales para el PC
    Jump     => ID_Ctrl_Jump,
    Branch   => ID_Ctrl_Branch,
    -- Señales para la memoria
    MemToReg => ID_Ctrl_MemToReg,
    MemWrite => ID_Ctrl_MemWrite,
    MemRead  => ID_Ctrl_MemRead,
    -- Señales para la ALU
    ALUSrc   => ID_Ctrl_ALUSrc,
    ALUOP    => ID_Ctrl_ALUOP,
    -- Señales para el GPR
    RegWrite => ID_Ctrl_RegWrite,
    RegDst   => ID_Ctrl_RegDest
  );
  ID_Funct <= ID_Instruction(5 downto 0);
  ID_Inm_ext     <= x"FFFF" & ID_Instruction(15 downto 0) when ID_Instruction(15)='1' else
                    x"0000" & ID_Instruction(15 downto 0); -- sign extend
  EX_Addr_Jump      <= EX_PC_plus4(31 downto 28) & EX_Instruction(25 downto 0) & "00";
  Addr_Branch    <= EX_PC_plus4 + (EX_Inm_ext(29 downto 0) & "00");

  --Ctrl_Jump      <= '0'; --nunca salto incondicional

  Regs_eq_branch <= ALU_IGUAL;
  desition_Jump  <= MEM_Ctrl_Jump or (MEM_Ctrl_Branch and Regs_eq_branch);
  Addr_Jump_dest <= Addr_Jump   when MEM_Ctrl_Jump='1' else
                    Addr_Branch when MEM_Ctrl_Branch='1' else
                    (others =>'0');

  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp  => EX_Ctrl_ALUOP, -- Codigo de control desde la unidad de control
    Funct  => EX_Funct, -- Campo "funct" de la instruccion
    -- Salida de control para la ALU:
    ALUControl => AluControl -- Define operacion a ejecutar por la ALU
  );

  Alu_MIPS : alu
  port map (
    OpA      => EX_reg_RS,
    OpB      => Alu_Op2,
    Control  => AluControl,
    Result   => Alu_Res,
    Signflag => open,
    Zflag    => ALU_IGUAL
  );

  Alu_Op2    <= EX_reg_RT when EX_Ctrl_ALUSrc = '0' else EX_Inm_ext;

  DAddr      <= Alu_Res;
  DDataOut   <= MEM_reg_RT;
  DWrEn      <= Ctrl_MemWrite;
  dRdEn      <= Ctrl_MemRead;
  dataIn_Mem <= DDataIn;

  reg_RD_data <= dataIn_Mem when Ctrl_MemToReg = '1' else Alu_Res;
  EX_add_RD <= EX_add_RD1 when EX_Ctrl_RegDest = '0' else EX_add_RT;


  IF_ID_Reg: process(Clk,reset)
    begin
      if reset = '1' then
        ID_PC_plus4 <= (others=>'0');
        ID_Instruction <= (others => '0');
      else rising_edge(clk) then 
        ID_Instruction <= IF_Instruction;
        ID_PC_plus4 <= IF_PC_plus4;
      end if;
    end process;
  ID_EX_Reg: process(Clk,reset)
    begin
      if reset = '1' then
        
      else rising_edge(clk) then 
        EX_add_RD1 <= ID_add_RD1;
        EX_add_RT <= ID_add_RT;
        EX_Inm_ext <= ID_Inm_ext;
        EX_PC_plus4 <= ID_PC_plus4;
        EX_reg_RS <= ID_reg_RS;
        EX_reg_RT <= ID_reg_RT;
        
        EX_Addr_Jump <= ID_Instruction(25 downto 0);

        EX_Ctrl_ALUOP <= ID__Ctrl_ALUOP; 
        EX_Ctrl_ALUSrc <= ID__Ctrl_ALUSrc;
        EX_Ctrl_Branch <= ID__Ctrl_Branch;
        EX_Ctrl_Jump <= ID__Ctrl_Jump;
        EX_Ctrl_MemRead <= ID__Ctrl_MemRead;
        EX_Ctrl_MemToReg <= ID__Ctrl_MemToReg;
        EX_Ctrl_MemWrite <= ID__Ctrl_MemWrite;
        EX_Ctrl_RegDest <= ID__Ctrl_RegDest;
        EX_Ctrl_RegWrite <= ID__Ctrl_RegWrite;
      end if;
    end process;
  ID_EX_Reg: process(Clk,reset)
    begin
      if reset = '1' then
        
      else rising_edge(clk) then
        MEM_PC_next <= EX_PC_next;
        MEM_add_RD <= EX_add_RD;
        MEM_reg_RT <= EX_reg_RT;
      end if;
    end process;
end architecture;
