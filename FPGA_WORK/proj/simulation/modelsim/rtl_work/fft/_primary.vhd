library verilog;
use verilog.vl_types.all;
entity fft is
    port(
        rst_n           : in     vl_logic;
        clk             : in     vl_logic;
        data1           : in     vl_logic_vector(7 downto 0);
        fft_go          : in     vl_logic;
        fft_done        : out    vl_logic;
        fft_res         : out    vl_logic_vector(15 downto 0)
    );
end fft;
