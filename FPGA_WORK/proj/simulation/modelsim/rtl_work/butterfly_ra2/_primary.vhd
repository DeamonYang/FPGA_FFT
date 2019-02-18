library verilog;
use verilog.vl_types.all;
entity butterfly_ra2 is
    port(
        rst_n           : in     vl_logic;
        clk             : in     vl_logic;
        bf_go           : in     vl_logic;
        bf_done         : out    vl_logic;
        wx              : in     vl_logic_vector(7 downto 0);
        wy              : in     vl_logic_vector(7 downto 0);
        x1              : in     vl_logic_vector(7 downto 0);
        y1              : in     vl_logic_vector(7 downto 0);
        x2              : in     vl_logic_vector(7 downto 0);
        y2              : in     vl_logic_vector(7 downto 0);
        bfx1            : out    vl_logic_vector(8 downto 0);
        bfy1            : out    vl_logic_vector(8 downto 0);
        bfx2            : out    vl_logic_vector(8 downto 0);
        bfy2            : out    vl_logic_vector(8 downto 0)
    );
end butterfly_ra2;
