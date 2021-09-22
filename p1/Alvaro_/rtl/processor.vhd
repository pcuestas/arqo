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
  signal reg_RD       : std_logic_vector(4 downto 0);

  signal Regs_eq_branch : std_logic;
  signal PC_next        : std_logic_vector(31 downto 0);
  signal PC_reg         : std_logic_vector(31 downto 0);
  signal IF_PC_plus4,ID_PC_plus4,EX_PC_plus4       : std_logic_vector(31 downto 0);

  signal IF_Instruction, ID_Instruction    : std_logic_vector(31 downto 0); -- La instrucción desde lamem de instr
  signal ID_Inm_ext,EX_Inm_ext        : std_logic_vector(31 downto 0); -- La parte baja de la instrucción extendida de signo
  signal ID_reg_RS,EX_reg_RS,EX_reg_RT,ID_reg_RT,MEM_reg_RT : std_logic_vector(31 downto 0);

  signal MEM_dataIn_Mem,WB_dataIn_Mem     : std_logic_vector(31 downto 0); --From Data Memory
  signal EX_Addr_Branch,MEM_Addr_Branch    : std_logic_vector(31 downto 0);

  signal Ctrl_Jump, Ctrl_Branch, Ctrl_MemWrite, Ctrl_MemRead,  Ctrl_ALUSrc, Ctrl_RegDest, Ctrl_MemToReg, Ctrl_RegWrite : std_logic;

  -- señales de ejecucion (se extienden al menos hasta el registro ID/EX)
  signal EX_Ctrl_Branch, EX_Ctrl_MemWrite, EX_Ctrl_MemRead,  EX_Ctrl_ALUSrc, EX_Ctrl_RegDest, EX_Ctrl_MemToReg, EX_Ctrl_RegWrite: std_logic;

  -- señales de memoria (se extienden al menos hasta el registro EX/MEM)
  signal MEM_Ctrl_Branch, MEM_Ctrl_MemWrite, MEM_Ctrl_MemRead, MEM_Ctrl_MemToReg, MEM_Ctrl_RegWrite: std_logic;

  --señales de writeback (se extienden hasat el registro MEM/WB)
  signal WB_Ctrl_MemToReg, WB_Ctrl_RegWrite : std_logic;


  signal Ctrl_ALUOP,EX_Ctrl_ALUOP     : std_logic_vector(2 downto 0);

  signal Addr_Jump      : std_logic_vector(31 downto 0);
  signal Addr_Jump_dest : std_logic_vector(31 downto 0);
  signal desition_Jump  : std_logic;
  signal Alu_Res,MEM_Alu_Res,WB_Alu_Res        : std_logic_vector(31 downto 0);

  -- señales para manejar la dirección del registro de escritura (con las diferentes opciones a lo largo del data-path)
  signal MEM_Dest,WB_Dest,EX_Dest,EX_Dest1,EX_Dest2:  std_logic_vector(4 downto 0);

begin

  PC_next <= Addr_Jump_dest when desition_Jump = '1' else IF_PC_plus4;




  --Siguiente instrucción a leer
  PC_reg_proc: process(Clk, Reset)
  begin
    if Reset = '1' then
      PC_reg <= (others => '0');
    elsif rising_edge(Clk) then
      PC_reg <= PC_next;
    end if;
  end process;
      


  --registro bloque Instruction fetch / Instruction decode
  IF_ID_reg: process(clk,reset)
  begin
    if reset = '1' then
      ID_PC_plus4 <= (others=>'0');
      ID_Instruction <= (others=>'0');

    elsif rising_edge(clk) then
      ID_PC_plus4 <= IF_PC_plus4;
      ID_Instruction <= IF_Instruction;
    end if;
end process;


-- registro bloque Instruction decode / Execution
ID_EX_reg: process(clk,reset)
begin
  if reset = '1' then
      EX_Dest1 <= (others=>'0');
      EX_Dest2 <= (others=>'0');
      EX_reg_RS <= (others=>'0');
      EX_reg_RT <= (others => '0');
      EX_Inm_ext <= (others =>'0');
      EX_PC_plus4 <= (others =>'0');

      
      EX_Ctrl_Branch  <= '0';
      EX_Ctrl_MemToReg <= '0';
      EX_Ctrl_MemWrite <= '0';
      EX_Ctrl_MemRead  <= '0';
      EX_Ctrl_ALUSrc  <= '0';
      EX_Ctrl_RegWrite <='0';
      EX_Ctrl_RegDest  <= '0';
      
      EX_Ctrl_ALUOP   <= (others=>'0');
  elsif rising_edge(clk) then
      EX_Dest1 <= ID_Instruction(20 downto 16);
      EX_Dest2 <= ID_Instruction(15 downto 11);
      EX_Inm_ext <= ID_Inm_ext;


      EX_reg_RS <= ID_reg_RS;
      EX_reg_RT <= ID_reg_RT;

      EX_PC_plus4 <=  ID_PC_plus4;


     
      EX_Ctrl_Branch   <= Ctrl_Branch;
      EX_Ctrl_MemToReg <= Ctrl_MemToReg;
      EX_Ctrl_MemWrite <= Ctrl_MemWrite;
      EX_Ctrl_MemRead  <= Ctrl_MemRead;
      EX_Ctrl_ALUSrc   <= Ctrl_ALUSrc;
      EX_Ctrl_ALUOP    <= Ctrl_ALUOP;
      EX_Ctrl_RegWrite <= Ctrl_RegWrite;
      EX_Ctrl_RegDest   <= Ctrl_RegDest;
      

  end if;
end process;


-- registro bloque Execution / Memory
EX_MEM_reg: process(clk,reset)
begin
  if reset='1' then
    MEM_Ctrl_Branch  <= '0';
    MEM_Ctrl_MemToReg <= '0';
    MEM_Ctrl_MemWrite <= '0';
    MEM_Ctrl_MemRead  <= '0';
    MEM_Ctrl_RegWrite <= '0';

    Regs_eq_branch <= '0';

    MEM_Alu_res <= (others =>'0');

    MEM_dest <= (others =>'0');
    MEM_reg_RT <= (others =>'0');
    MEM_Addr_Branch <= (others =>'0');
  elsif rising_edge(clk) then
    MEM_Ctrl_Branch  <= EX_Ctrl_Branch;
    MEM_Ctrl_MemToReg <= EX_Ctrl_MemToReg;
    MEM_Ctrl_MemWrite <= EX_Ctrl_MemWrite;
    MEM_Ctrl_MemRead  <= EX_Ctrl_MemRead;
    MEM_Ctrl_RegWrite <= EX_Ctrl_RegWrite;

    Regs_eq_branch <= ALU_IGUAL;

    MEM_Alu_res <= Alu_res;

    MEM_dest <= EX_dest;
    MEM_reg_RT <= EX_reg_RT;
    MEM_Addr_Branch <= EX_Addr_Branch;
  end if;

end process;


--registro bloque Memory / WriteBack
MEM_WB_reg: process(clk,reset)
begin
  if reset='1' then
    WB_dest <= (others=>'0');
    WB_dataIn_Mem <= (others=>'0');
    WB_Alu_Res <= (others =>'0');
    WB_Ctrl_MemToReg <= '0';
    WB_Ctrl_RegWrite <= '0';
  elsif rising_edge(clk) then
    WB_dest <= MEM_dest;
    WB_dataIn_Mem <= MEM_dataIn_Mem;
    WB_Alu_Res <= MEM_Alu_Res;
    WB_Ctrl_MemToReg <= MEM_Ctrl_MemToReg;
    WB_Ctrl_RegWrite <= MEM_Ctrl_RegWrite;
  end if;
end process;

  --Multiplexer para elegir dirreccion de destino
  EX_Dest <= EX_Dest1 when EX_Ctrl_RegDest='0' else EX_Dest2;



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
    A3    => WB_dest,
    Wd3   => reg_RD_data,
    We3   => WB_Ctrl_RegWrite
  );

  UnidadControl : control_unit
  port map(
    Instr   => ID_Instruction,
    -- Señales para el PC
    Jump     => Ctrl_Jump,
    Branch   => Ctrl_Branch,
    -- Señales para la memoria
    MemToReg => Ctrl_MemToReg,
    MemWrite => Ctrl_MemWrite,
    MemRead  => Ctrl_MemRead,
    -- Señales para la ALU
    ALUSrc   => Ctrl_ALUSrc,
    ALUOP    => Ctrl_ALUOP,
    -- Señales para el GPR
    RegWrite => Ctrl_RegWrite,
    RegDst   => Ctrl_RegDest
  );

  -- extensión del dato inmediato contenido en las instrucciones tipo I
  ID_Inm_ext <= x"FFFF" & ID_Instruction(15 downto 0) when ID_Instruction(15)='1' else
           x"0000" & ID_Instruction(15 downto 0); -- sign extend
  

  Addr_Jump      <= EX_PC_plus4(31 downto 28) & ID_Instruction(25 downto 0) & "00"; -- revisar
  EX_Addr_Branch    <= EX_PC_plus4 + ( EX_Inm_ext(29 downto 0) & "00");

  
  desition_Jump  <= Ctrl_Jump or (MEM_Ctrl_Branch and Regs_eq_branch);  --revisar Ctrl_Jump
  Addr_Jump_dest <= Addr_Jump   when Ctrl_Jump='1' else
                    MEM_Addr_Branch when MEM_Ctrl_Branch='1' else
                    (others =>'0');

  Alu_control_i: alu_control
  port map(
    -- Entradas:
    ALUOp  => EX_Ctrl_ALUOP, -- Codigo de control desde la unidad de control
    Funct  => EX_Inm_ext (5 downto 0), -- Campo "funct" de la instruccion CAMBIADO!!!!!
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


  --Multiplexor para ver el argumento del ALU
  Alu_Op2    <= EX_reg_RT when EX_Ctrl_ALUSrc = '0' else EX_Inm_ext;

  --reg_RD     <= Instruction(20 downto 16) when Ctrl_RegDest = '0' else Instruction(15 downto 11);

  DAddr      <= MEM_Alu_Res;
  DDataOut   <= MEM_reg_RT;
  DWrEn      <= MEM_Ctrl_MemWrite;
  dRdEn      <= MEM_Ctrl_MemRead;
  MEM_dataIn_Mem <= DDataIn;

  reg_RD_data <= WB_dataIn_Mem when WB_Ctrl_MemToReg = '1' else WB_Alu_Res;

end architecture;
