library verilog;
use verilog.vl_types.all;
entity butterfly_ra2_seri is
    port(
        rst_n           : in     vl_logic;
        clk             : in     vl_logic;
        bf_go           : in     vl_logic;
        bf_done         : out    vl_logic;
        datax           : in     vl_logic_vector(7 downto 0);
        datay           : in     vl_logic_vector(7 downto 0);
        wx              : in     vl_logic_vector(7 downto 0);
        wy              : in     vl_logic_vector(7 downto 0);
        wren            : out    vl_logic;
        bfx             : out    vl_logic_vector(7 downto 0);
        bfy             : out    vl_logic_vector(7 downto 0)
    );
end butterfly_ra2_seri;
