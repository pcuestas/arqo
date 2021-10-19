--------------------------------------------------------------------------------
-- Procesador MIPS con pipeline curso Arquitectura 2021-2022
--
-- Pablo Cuesta Sierra and Álvaro Zamanillo Sáez
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

  signal Alu_Op2,Alu_Op1      : std_logic_vector(31 downto 0);
  
  signal EX_ZFlag    : std_logic;
  signal AluControl   : std_logic_vector(3 downto 0);
  signal reg_RD_data  : std_logic_vector(31 downto 0);
  signal ID_add_RD1, EX_add_RD1, EX_add_RD, MEM_add_RD, WB_add_RD      : std_logic_vector(4 downto 0);
  signal ID_add_RT, EX_add_RT, MEM_add_RT       : std_logic_vector(4 downto 0);
  signal ID_add_RS, EX_add_RS       : std_logic_vector(4 downto 0);

  signal PC_reg         : std_logic_vector(31 downto 0);
  signal ID_PC_plus4, IF_PC_plus4, EX_PC_plus4       : std_logic_vector(31 downto 0);

  signal IF_Instruction, ID_Instruction    : std_logic_vector(31 downto 0); -- La instrucción desde lamem de instr
  signal ID_Inm_ext, EX_Inm_ext        : std_logic_vector(31 downto 0); -- La parte baja de la instrucción extendida de signo
  signal ID_reg_RS, EX_reg_RS, ID_reg_RT, EX_reg_RT, MEM_reg_RT : std_logic_vector(31 downto 0);

  signal MEM_dataIn_Mem, WB_dataIn_Mem     : std_logic_vector(31 downto 0); --From Data Memory
  
  signal ID_Ctrl_ALUSrc,   EX_Ctrl_ALUSrc  : std_logic;
  signal ID_Ctrl_ALUOP,    EX_Ctrl_ALUOP   : std_logic_vector(2 downto 0);
  signal ID_Ctrl_RegDest,  EX_Ctrl_RegDest : std_logic;
  signal ID_Ctrl_Jump,     EX_Ctrl_Jump: std_logic;
  signal ID_Ctrl_Branch,   EX_Ctrl_Branch      : std_logic;
  signal ID_Ctrl_MemWrite, EX_Ctrl_MemWrite,  MEM_Ctrl_MemWrite : std_logic;
  signal ID_Ctrl_MemRead,  EX_Ctrl_MemRead,   MEM_Ctrl_MemRead  : std_logic;
  signal ID_Ctrl_MemToReg, EX_Ctrl_MemToReg,  MEM_Ctrl_MemToReg, WB_Ctrl_MemToReg : std_logic;
  signal ID_Ctrl_RegWrite, EX_Ctrl_RegWrite,  MEM_Ctrl_RegWrite, WB_Ctrl_RegWrite: std_logic;
  
  signal ID_Addr_Branch, EX_Addr_Branch   : std_logic_vector(31 downto 0);
  signal ID_Addr_Jump, EX_Addr_Jump     : std_logic_vector(31 downto 0);
  signal EX_Addr_Jump_dest, MEM_Addr_Jump_dest : std_logic_vector(31 downto 0);
  signal EX_PCSrc, Branch_Flush  : std_logic;
  signal EX_Alu_Res, MEM_Alu_Res, WB_Alu_Res        : std_logic_vector(31 downto 0);


  signal ForwardA, ForwardB : std_logic_vector(1 downto 0);
  signal AluOp2_MuxResult   : std_logic_vector (31 downto 0);

  --Nuevas señales  
  signal ID_Funct, EX_Funct : std_logic_vector(5 downto 0);

  signal PCWrite, IF_ID_Write, ID_EX_Clear : std_logic;

begin

  ID_add_RS <= ID_Instruction(25 downto 21);
  ID_add_RT <= ID_Instruction(20 downto 16);
  ID_add_RD1 <= ID_Instruction(15 downto 11);

  PC_reg_proc: process(Clk, Reset)
  begin
    if Reset = '1' then
      PC_reg <= (others => '0');
    elsif (rising_edge(Clk) and PCWrite = '1') then
      if EX_PCSrc = '1' then 
        PC_reg <= EX_Addr_Jump_dest;
      else
        PC_reg <=  IF_PC_plus4;
      end if;
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
    A3    => WB_add_RD, --la que viene de la ultima etapa
    Wd3   => reg_RD_data,
    We3   => WB_Ctrl_RegWrite
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
  ID_Addr_Jump      <= ID_PC_plus4(31 downto 28) & ID_Instruction(25 downto 0) & "00";
  ID_Addr_Branch    <= ID_PC_plus4 + (ID_Inm_ext(29 downto 0) & "00");

  --Ctrl_Jump      <= '0'; --nunca salto incondicional

  EX_PCSrc  <= EX_Ctrl_Jump or (EX_Ctrl_Branch and EX_ZFlag); -- 1 si se va a saltar
  EX_Addr_Jump_dest <=  EX_Addr_Jump   when EX_Ctrl_Jump='1' else
                        EX_Addr_Branch when EX_Ctrl_Branch='1' else
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
    OpA      => Alu_Op1,
    OpB      => Alu_Op2,
    Control  => AluControl,
    Result   => EX_Alu_Res,
    Signflag => open,
    Zflag    => EX_ZFlag
  );

  DDataOut   <= MEM_reg_RT;
  DAddr      <= MEM_Alu_Res;
  DWrEn      <= MEM_Ctrl_MemWrite;
  dRdEn      <= MEM_Ctrl_MemRead;
  MEM_dataIn_Mem <= DDataIn;

  reg_RD_data <= WB_dataIn_Mem when WB_Ctrl_MemToReg = '1' else WB_Alu_Res;
  EX_add_RD <= EX_add_RT when EX_Ctrl_RegDest = '0' else EX_add_RD1;


  Branch_Flush <= EX_PCSrc;

  HazardDetection: process(EX_Ctrl_MemRead, EX_add_RT, ID_add_RS, ID_add_RT)
    begin
      if (EX_Ctrl_MemRead='1' and (EX_add_RT = ID_add_RS or EX_add_RT = ID_add_RT)) then
          PCWrite <= '0'; IF_ID_Write <= '0'; ID_EX_Clear <= '1';
      else     
          PCWrite <= '1'; IF_ID_Write <= '1'; ID_EX_Clear <= '0';
      end if;
    end process;

  
  Forwarding_unit: process(MEM_Ctrl_RegWrite, WB_Ctrl_RegWrite,
                          MEM_add_RD, EX_add_RS, EX_add_RT, WB_add_RD)
    begin
      if ((MEM_Ctrl_RegWrite = '1') and (MEM_add_RD /= "00000") and (MEM_add_RD = EX_add_RS)) then 
        ForwardA <= "10";
      elsif  ((WB_Ctrl_RegWrite = '1') and (WB_add_RD /= "00000") and (WB_add_RD = EX_add_RS)) then
        ForwardA <= "01";
      else ForwardA <= "00"; 
    end if;

      if ((MEM_Ctrl_RegWrite = '1') and (MEM_add_RD /= "00000") and (MEM_add_RD = EX_add_RT)) then
        ForwardB <= "10";
      elsif ((WB_Ctrl_RegWrite = '1') and (WB_add_RD /= "00000") and (WB_add_RD = EX_add_RT)) then
        ForwardB <= "01";
      else ForwardB <= "00"; 
      end if;
    end process;  

  Alu_Op1 <= EX_reg_RS when ForwardA = "00" else  
             reg_RD_data when ForwardA = "01" else
             MEM_Alu_Res;

  AluOp2_MuxResult <= EX_reg_RT when ForwardB = "00" else  
                      reg_RD_data when ForwardB = "01" else
                      MEM_Alu_Res;

  Alu_Op2 <= AluOp2_MuxResult when EX_Ctrl_ALUSrc = '0' else EX_Inm_ext;
    
  -- PIPELINED PROCESSOR REGISTERS
  IF_ID_Reg: process(Clk,reset)
    begin
      if reset = '1' or (rising_edge(clk) and Branch_Flush= '1') then
        ID_PC_plus4 <= (others => '0');
        ID_Instruction <= (others => '0');
      elsif (rising_edge(clk) and IF_ID_Write = '1') then 
        ID_Instruction <= IF_Instruction;
        ID_PC_plus4 <= IF_PC_plus4;
      end if;
    end process;
  ID_EX_Reg: process(Clk,reset,ID_EX_Clear)
    begin
      if reset = '1' or (rising_edge(clk) and (ID_EX_Clear = '1' or Branch_Flush = '1')) then
        EX_add_RD1 <= (others => '0');
        EX_add_RT <= (others => '0');
        EX_add_RS <= (others => '0');
        EX_Inm_ext <= (others => '0');
        EX_PC_plus4 <= (others => '0');
        EX_reg_RS <= (others => '0');
        EX_reg_RT <= (others => '0');
        EX_Ctrl_ALUOP <= (others => '0'); 
        EX_Ctrl_ALUSrc <= '0';
        EX_Ctrl_RegDest <= '0';
        EX_Ctrl_Branch <= '0';
        EX_Ctrl_Jump <= '0';
        EX_Ctrl_MemRead <= '0';
        EX_Ctrl_MemToReg <= '0';
        EX_Ctrl_MemWrite <= '0';
        EX_Ctrl_RegWrite <= '0';
        EX_Addr_Branch <= (others => '0');        
        EX_Addr_Jump <= (others => '0');        
      elsif rising_edge(clk) then 
        EX_add_RD1 <= ID_add_RD1;
        EX_add_RT <= ID_add_RT;
        EX_add_RS <= ID_add_RS;
        EX_Inm_ext <= ID_Inm_ext;
        EX_PC_plus4 <= ID_PC_plus4;
        EX_reg_RS <= ID_reg_RS;
        EX_reg_RT <= ID_reg_RT;
        EX_Funct <= ID_Instruction(5 downto 0);

        EX_Ctrl_ALUOP <= ID_Ctrl_ALUOP; 
        EX_Ctrl_ALUSrc <= ID_Ctrl_ALUSrc;
        EX_Ctrl_RegDest <= ID_Ctrl_RegDest;
        EX_Ctrl_Branch <= ID_Ctrl_Branch;
        EX_Ctrl_Jump <= ID_Ctrl_Jump;
        EX_Ctrl_MemRead <= ID_Ctrl_MemRead;
        EX_Ctrl_MemToReg <= ID_Ctrl_MemToReg;
        EX_Ctrl_MemWrite <= ID_Ctrl_MemWrite;
        EX_Ctrl_RegWrite <= ID_Ctrl_RegWrite;
        EX_Addr_Branch <= ID_Addr_Branch;        
        EX_Addr_Jump <= ID_Addr_Jump;
      end if;
    end process;
  EX_MEM_Reg: process(Clk,reset)
    begin
      if reset = '1' then
        MEM_add_RD <= (others => '0');
        MEM_add_RT <= (others => '0');
        MEM_reg_RT <= (others => '0');
        MEM_Alu_Res <= (others => '0');
        MEM_Ctrl_MemRead <= '0';
        MEM_Ctrl_MemToReg <= '0';
        MEM_Ctrl_MemWrite <= '0';
        MEM_Ctrl_RegWrite <= '0';
        
      elsif rising_edge(clk) then
        MEM_add_RD <= EX_add_RD;
        MEM_add_RT <= EX_add_RT;
        MEM_reg_RT <= AluOp2_MuxResult;
        MEM_Alu_Res <= EX_Alu_Res;

        MEM_Ctrl_MemRead <= EX_Ctrl_MemRead;
        MEM_Ctrl_MemToReg <= EX_Ctrl_MemToReg;
        MEM_Ctrl_MemWrite <= EX_Ctrl_MemWrite;
        MEM_Ctrl_RegWrite <= EX_Ctrl_RegWrite;
      end if;
    end process;
  MEM_WB_Reg: process(Clk,reset)
    begin
      if reset = '1' then
        WB_Ctrl_MemToReg <= '0';
        WB_Ctrl_RegWrite <= '0';
        WB_dataIn_Mem <= (others => '0');
        WB_Alu_Res <= (others => '0');
        WB_add_RD <= (others => '0');        
      elsif rising_edge(clk) then
        WB_Ctrl_MemToReg <= MEM_Ctrl_MemToReg;
        WB_Ctrl_RegWrite <= MEM_Ctrl_RegWrite;
        WB_dataIn_Mem <= MEM_dataIn_Mem;
        WB_Alu_Res <= MEM_Alu_Res;
        WB_add_RD <= MEM_add_RD;
      end if;
    end process;
end architecture;