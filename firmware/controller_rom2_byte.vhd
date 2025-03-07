
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_rom2 is
generic
	(
		ADDR_WIDTH : integer := 15 -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(31 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(31 downto 0) := X"00000000";
	we : in std_logic := '0';
	bytesel : in std_logic_vector(3 downto 0) := "1111"
);
end entity;

architecture rtl of controller_rom2 is

	signal addr1 : integer range 0 to 2**ADDR_WIDTH-1;

	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t:=
	(

     0 => (x"00",x"00",x"00",x"60"),
     1 => (x"18",x"30",x"60",x"40"),
     2 => (x"01",x"03",x"06",x"0c"),
     3 => (x"59",x"7f",x"3e",x"00"),
     4 => (x"00",x"3e",x"7f",x"4d"),
     5 => (x"7f",x"06",x"04",x"00"),
     6 => (x"00",x"00",x"00",x"7f"),
     7 => (x"71",x"63",x"42",x"00"),
     8 => (x"00",x"46",x"4f",x"59"),
     9 => (x"49",x"63",x"22",x"00"),
    10 => (x"00",x"36",x"7f",x"49"),
    11 => (x"13",x"16",x"1c",x"18"),
    12 => (x"00",x"10",x"7f",x"7f"),
    13 => (x"45",x"67",x"27",x"00"),
    14 => (x"00",x"39",x"7d",x"45"),
    15 => (x"4b",x"7e",x"3c",x"00"),
    16 => (x"00",x"30",x"79",x"49"),
    17 => (x"71",x"01",x"01",x"00"),
    18 => (x"00",x"07",x"0f",x"79"),
    19 => (x"49",x"7f",x"36",x"00"),
    20 => (x"00",x"36",x"7f",x"49"),
    21 => (x"49",x"4f",x"06",x"00"),
    22 => (x"00",x"1e",x"3f",x"69"),
    23 => (x"66",x"00",x"00",x"00"),
    24 => (x"00",x"00",x"00",x"66"),
    25 => (x"e6",x"80",x"00",x"00"),
    26 => (x"00",x"00",x"00",x"66"),
    27 => (x"14",x"08",x"08",x"00"),
    28 => (x"00",x"22",x"22",x"14"),
    29 => (x"14",x"14",x"14",x"00"),
    30 => (x"00",x"14",x"14",x"14"),
    31 => (x"14",x"22",x"22",x"00"),
    32 => (x"00",x"08",x"08",x"14"),
    33 => (x"51",x"03",x"02",x"00"),
    34 => (x"00",x"06",x"0f",x"59"),
    35 => (x"5d",x"41",x"7f",x"3e"),
    36 => (x"00",x"1e",x"1f",x"55"),
    37 => (x"09",x"7f",x"7e",x"00"),
    38 => (x"00",x"7e",x"7f",x"09"),
    39 => (x"49",x"7f",x"7f",x"00"),
    40 => (x"00",x"36",x"7f",x"49"),
    41 => (x"63",x"3e",x"1c",x"00"),
    42 => (x"00",x"41",x"41",x"41"),
    43 => (x"41",x"7f",x"7f",x"00"),
    44 => (x"00",x"1c",x"3e",x"63"),
    45 => (x"49",x"7f",x"7f",x"00"),
    46 => (x"00",x"41",x"41",x"49"),
    47 => (x"09",x"7f",x"7f",x"00"),
    48 => (x"00",x"01",x"01",x"09"),
    49 => (x"41",x"7f",x"3e",x"00"),
    50 => (x"00",x"7a",x"7b",x"49"),
    51 => (x"08",x"7f",x"7f",x"00"),
    52 => (x"00",x"7f",x"7f",x"08"),
    53 => (x"7f",x"41",x"00",x"00"),
    54 => (x"00",x"00",x"41",x"7f"),
    55 => (x"40",x"60",x"20",x"00"),
    56 => (x"00",x"3f",x"7f",x"40"),
    57 => (x"1c",x"08",x"7f",x"7f"),
    58 => (x"00",x"41",x"63",x"36"),
    59 => (x"40",x"7f",x"7f",x"00"),
    60 => (x"00",x"40",x"40",x"40"),
    61 => (x"0c",x"06",x"7f",x"7f"),
    62 => (x"00",x"7f",x"7f",x"06"),
    63 => (x"0c",x"06",x"7f",x"7f"),
    64 => (x"00",x"7f",x"7f",x"18"),
    65 => (x"41",x"7f",x"3e",x"00"),
    66 => (x"00",x"3e",x"7f",x"41"),
    67 => (x"09",x"7f",x"7f",x"00"),
    68 => (x"00",x"06",x"0f",x"09"),
    69 => (x"61",x"41",x"7f",x"3e"),
    70 => (x"00",x"40",x"7e",x"7f"),
    71 => (x"09",x"7f",x"7f",x"00"),
    72 => (x"00",x"66",x"7f",x"19"),
    73 => (x"4d",x"6f",x"26",x"00"),
    74 => (x"00",x"32",x"7b",x"59"),
    75 => (x"7f",x"01",x"01",x"00"),
    76 => (x"00",x"01",x"01",x"7f"),
    77 => (x"40",x"7f",x"3f",x"00"),
    78 => (x"00",x"3f",x"7f",x"40"),
    79 => (x"70",x"3f",x"0f",x"00"),
    80 => (x"00",x"0f",x"3f",x"70"),
    81 => (x"18",x"30",x"7f",x"7f"),
    82 => (x"00",x"7f",x"7f",x"30"),
    83 => (x"1c",x"36",x"63",x"41"),
    84 => (x"41",x"63",x"36",x"1c"),
    85 => (x"7c",x"06",x"03",x"01"),
    86 => (x"01",x"03",x"06",x"7c"),
    87 => (x"4d",x"59",x"71",x"61"),
    88 => (x"00",x"41",x"43",x"47"),
    89 => (x"7f",x"7f",x"00",x"00"),
    90 => (x"00",x"00",x"41",x"41"),
    91 => (x"0c",x"06",x"03",x"01"),
    92 => (x"40",x"60",x"30",x"18"),
    93 => (x"41",x"41",x"00",x"00"),
    94 => (x"00",x"00",x"7f",x"7f"),
    95 => (x"03",x"06",x"0c",x"08"),
    96 => (x"00",x"08",x"0c",x"06"),
    97 => (x"80",x"80",x"80",x"80"),
    98 => (x"00",x"80",x"80",x"80"),
    99 => (x"03",x"00",x"00",x"00"),
   100 => (x"00",x"00",x"04",x"07"),
   101 => (x"54",x"74",x"20",x"00"),
   102 => (x"00",x"78",x"7c",x"54"),
   103 => (x"44",x"7f",x"7f",x"00"),
   104 => (x"00",x"38",x"7c",x"44"),
   105 => (x"44",x"7c",x"38",x"00"),
   106 => (x"00",x"00",x"44",x"44"),
   107 => (x"44",x"7c",x"38",x"00"),
   108 => (x"00",x"7f",x"7f",x"44"),
   109 => (x"54",x"7c",x"38",x"00"),
   110 => (x"00",x"18",x"5c",x"54"),
   111 => (x"7f",x"7e",x"04",x"00"),
   112 => (x"00",x"00",x"05",x"05"),
   113 => (x"a4",x"bc",x"18",x"00"),
   114 => (x"00",x"7c",x"fc",x"a4"),
   115 => (x"04",x"7f",x"7f",x"00"),
   116 => (x"00",x"78",x"7c",x"04"),
   117 => (x"3d",x"00",x"00",x"00"),
   118 => (x"00",x"00",x"40",x"7d"),
   119 => (x"80",x"80",x"80",x"00"),
   120 => (x"00",x"00",x"7d",x"fd"),
   121 => (x"10",x"7f",x"7f",x"00"),
   122 => (x"00",x"44",x"6c",x"38"),
   123 => (x"3f",x"00",x"00",x"00"),
   124 => (x"00",x"00",x"40",x"7f"),
   125 => (x"18",x"0c",x"7c",x"7c"),
   126 => (x"00",x"78",x"7c",x"0c"),
   127 => (x"04",x"7c",x"7c",x"00"),
   128 => (x"00",x"78",x"7c",x"04"),
   129 => (x"44",x"7c",x"38",x"00"),
   130 => (x"00",x"38",x"7c",x"44"),
   131 => (x"24",x"fc",x"fc",x"00"),
   132 => (x"00",x"18",x"3c",x"24"),
   133 => (x"24",x"3c",x"18",x"00"),
   134 => (x"00",x"fc",x"fc",x"24"),
   135 => (x"04",x"7c",x"7c",x"00"),
   136 => (x"00",x"08",x"0c",x"04"),
   137 => (x"54",x"5c",x"48",x"00"),
   138 => (x"00",x"20",x"74",x"54"),
   139 => (x"7f",x"3f",x"04",x"00"),
   140 => (x"00",x"00",x"44",x"44"),
   141 => (x"40",x"7c",x"3c",x"00"),
   142 => (x"00",x"7c",x"7c",x"40"),
   143 => (x"60",x"3c",x"1c",x"00"),
   144 => (x"00",x"1c",x"3c",x"60"),
   145 => (x"30",x"60",x"7c",x"3c"),
   146 => (x"00",x"3c",x"7c",x"60"),
   147 => (x"10",x"38",x"6c",x"44"),
   148 => (x"00",x"44",x"6c",x"38"),
   149 => (x"e0",x"bc",x"1c",x"00"),
   150 => (x"00",x"1c",x"3c",x"60"),
   151 => (x"74",x"64",x"44",x"00"),
   152 => (x"00",x"44",x"4c",x"5c"),
   153 => (x"3e",x"08",x"08",x"00"),
   154 => (x"00",x"41",x"41",x"77"),
   155 => (x"7f",x"00",x"00",x"00"),
   156 => (x"00",x"00",x"00",x"7f"),
   157 => (x"77",x"41",x"41",x"00"),
   158 => (x"00",x"08",x"08",x"3e"),
   159 => (x"03",x"01",x"01",x"02"),
   160 => (x"00",x"01",x"02",x"02"),
   161 => (x"7f",x"7f",x"7f",x"7f"),
   162 => (x"00",x"7f",x"7f",x"7f"),
   163 => (x"1c",x"1c",x"08",x"08"),
   164 => (x"7f",x"7f",x"3e",x"3e"),
   165 => (x"3e",x"3e",x"7f",x"7f"),
   166 => (x"08",x"08",x"1c",x"1c"),
   167 => (x"7c",x"18",x"10",x"00"),
   168 => (x"00",x"10",x"18",x"7c"),
   169 => (x"7c",x"30",x"10",x"00"),
   170 => (x"00",x"10",x"30",x"7c"),
   171 => (x"60",x"60",x"30",x"10"),
   172 => (x"00",x"06",x"1e",x"78"),
   173 => (x"18",x"3c",x"66",x"42"),
   174 => (x"00",x"42",x"66",x"3c"),
   175 => (x"c2",x"6a",x"38",x"78"),
   176 => (x"00",x"38",x"6c",x"c6"),
   177 => (x"60",x"00",x"00",x"60"),
   178 => (x"00",x"60",x"00",x"00"),
   179 => (x"5c",x"5b",x"5e",x"0e"),
   180 => (x"86",x"fc",x"0e",x"5d"),
   181 => (x"f3",x"c2",x"7e",x"71"),
   182 => (x"c0",x"4c",x"bf",x"d0"),
   183 => (x"c4",x"1e",x"c0",x"4b"),
   184 => (x"c4",x"02",x"ab",x"66"),
   185 => (x"c2",x"4d",x"c0",x"87"),
   186 => (x"75",x"4d",x"c1",x"87"),
   187 => (x"ee",x"49",x"73",x"1e"),
   188 => (x"86",x"c8",x"87",x"e1"),
   189 => (x"ef",x"49",x"e0",x"c0"),
   190 => (x"a4",x"c4",x"87",x"ea"),
   191 => (x"f0",x"49",x"6a",x"4a"),
   192 => (x"c8",x"f1",x"87",x"f1"),
   193 => (x"c1",x"84",x"cc",x"87"),
   194 => (x"ab",x"b7",x"c8",x"83"),
   195 => (x"87",x"cd",x"ff",x"04"),
   196 => (x"4d",x"26",x"8e",x"fc"),
   197 => (x"4b",x"26",x"4c",x"26"),
   198 => (x"71",x"1e",x"4f",x"26"),
   199 => (x"d4",x"f3",x"c2",x"4a"),
   200 => (x"d4",x"f3",x"c2",x"5a"),
   201 => (x"49",x"78",x"c7",x"48"),
   202 => (x"26",x"87",x"e1",x"fe"),
   203 => (x"1e",x"73",x"1e",x"4f"),
   204 => (x"b7",x"c0",x"4a",x"71"),
   205 => (x"87",x"d3",x"03",x"aa"),
   206 => (x"bf",x"d0",x"d9",x"c2"),
   207 => (x"c1",x"87",x"c4",x"05"),
   208 => (x"c0",x"87",x"c2",x"4b"),
   209 => (x"d4",x"d9",x"c2",x"4b"),
   210 => (x"c2",x"87",x"c4",x"5b"),
   211 => (x"fc",x"5a",x"d4",x"d9"),
   212 => (x"d0",x"d9",x"c2",x"48"),
   213 => (x"c1",x"4a",x"78",x"bf"),
   214 => (x"a2",x"c0",x"c1",x"9a"),
   215 => (x"87",x"e6",x"ec",x"49"),
   216 => (x"4f",x"26",x"4b",x"26"),
   217 => (x"c4",x"4a",x"71",x"1e"),
   218 => (x"49",x"72",x"1e",x"66"),
   219 => (x"fc",x"87",x"f0",x"eb"),
   220 => (x"1e",x"4f",x"26",x"8e"),
   221 => (x"c3",x"48",x"d4",x"ff"),
   222 => (x"d0",x"ff",x"78",x"ff"),
   223 => (x"78",x"e1",x"c0",x"48"),
   224 => (x"c1",x"48",x"d4",x"ff"),
   225 => (x"c4",x"48",x"71",x"78"),
   226 => (x"08",x"d4",x"ff",x"30"),
   227 => (x"48",x"d0",x"ff",x"78"),
   228 => (x"26",x"78",x"e0",x"c0"),
   229 => (x"5b",x"5e",x"0e",x"4f"),
   230 => (x"f0",x"0e",x"5d",x"5c"),
   231 => (x"48",x"a6",x"c8",x"86"),
   232 => (x"ec",x"4d",x"78",x"c0"),
   233 => (x"80",x"fc",x"7e",x"bf"),
   234 => (x"bf",x"d0",x"f3",x"c2"),
   235 => (x"4c",x"bf",x"e8",x"78"),
   236 => (x"bf",x"d0",x"d9",x"c2"),
   237 => (x"87",x"e9",x"e4",x"49"),
   238 => (x"ca",x"49",x"ee",x"cb"),
   239 => (x"4b",x"70",x"87",x"d6"),
   240 => (x"e2",x"e7",x"49",x"c7"),
   241 => (x"05",x"98",x"70",x"87"),
   242 => (x"49",x"6e",x"87",x"c8"),
   243 => (x"c1",x"02",x"99",x"c1"),
   244 => (x"4d",x"c1",x"87",x"c1"),
   245 => (x"c2",x"7e",x"bf",x"ec"),
   246 => (x"49",x"bf",x"d0",x"d9"),
   247 => (x"73",x"87",x"c2",x"e4"),
   248 => (x"87",x"fc",x"c9",x"49"),
   249 => (x"d7",x"02",x"98",x"70"),
   250 => (x"c8",x"d9",x"c2",x"87"),
   251 => (x"b9",x"c1",x"49",x"bf"),
   252 => (x"59",x"cc",x"d9",x"c2"),
   253 => (x"87",x"fb",x"fd",x"71"),
   254 => (x"c9",x"49",x"ee",x"cb"),
   255 => (x"4b",x"70",x"87",x"d6"),
   256 => (x"e2",x"e6",x"49",x"c7"),
   257 => (x"05",x"98",x"70",x"87"),
   258 => (x"6e",x"87",x"c7",x"ff"),
   259 => (x"05",x"99",x"c1",x"49"),
   260 => (x"75",x"87",x"ff",x"fe"),
   261 => (x"e3",x"c0",x"02",x"9d"),
   262 => (x"d0",x"d9",x"c2",x"87"),
   263 => (x"ba",x"c1",x"4a",x"bf"),
   264 => (x"5a",x"d4",x"d9",x"c2"),
   265 => (x"0a",x"7a",x"0a",x"fc"),
   266 => (x"c0",x"c1",x"9a",x"c1"),
   267 => (x"d5",x"e9",x"49",x"a2"),
   268 => (x"49",x"da",x"c1",x"87"),
   269 => (x"c8",x"87",x"f0",x"e5"),
   270 => (x"78",x"c1",x"48",x"a6"),
   271 => (x"bf",x"d0",x"d9",x"c2"),
   272 => (x"87",x"e9",x"c0",x"05"),
   273 => (x"ff",x"c3",x"49",x"74"),
   274 => (x"c0",x"1e",x"71",x"99"),
   275 => (x"87",x"d4",x"fc",x"49"),
   276 => (x"b7",x"c8",x"49",x"74"),
   277 => (x"c1",x"1e",x"71",x"29"),
   278 => (x"87",x"c8",x"fc",x"49"),
   279 => (x"fd",x"c3",x"86",x"c8"),
   280 => (x"87",x"c3",x"e5",x"49"),
   281 => (x"e4",x"49",x"fa",x"c3"),
   282 => (x"d1",x"c7",x"87",x"fd"),
   283 => (x"c3",x"49",x"74",x"87"),
   284 => (x"b7",x"c8",x"99",x"ff"),
   285 => (x"74",x"b4",x"71",x"2c"),
   286 => (x"87",x"df",x"02",x"9c"),
   287 => (x"bf",x"cc",x"d9",x"c2"),
   288 => (x"87",x"dc",x"c7",x"49"),
   289 => (x"c0",x"05",x"98",x"70"),
   290 => (x"4c",x"c0",x"87",x"c4"),
   291 => (x"e0",x"c2",x"87",x"d3"),
   292 => (x"87",x"c0",x"c7",x"49"),
   293 => (x"58",x"d0",x"d9",x"c2"),
   294 => (x"c2",x"87",x"c6",x"c0"),
   295 => (x"c0",x"48",x"cc",x"d9"),
   296 => (x"c8",x"49",x"74",x"78"),
   297 => (x"87",x"ce",x"05",x"99"),
   298 => (x"e3",x"49",x"f5",x"c3"),
   299 => (x"49",x"70",x"87",x"f9"),
   300 => (x"c0",x"02",x"99",x"c2"),
   301 => (x"f3",x"c2",x"87",x"e9"),
   302 => (x"c0",x"02",x"bf",x"d4"),
   303 => (x"c1",x"48",x"87",x"c9"),
   304 => (x"d8",x"f3",x"c2",x"88"),
   305 => (x"c4",x"87",x"d3",x"58"),
   306 => (x"e0",x"c1",x"48",x"66"),
   307 => (x"6e",x"7e",x"70",x"80"),
   308 => (x"c5",x"c0",x"02",x"bf"),
   309 => (x"49",x"ff",x"4b",x"87"),
   310 => (x"a6",x"c8",x"0f",x"73"),
   311 => (x"74",x"78",x"c1",x"48"),
   312 => (x"05",x"99",x"c4",x"49"),
   313 => (x"c3",x"87",x"ce",x"c0"),
   314 => (x"fa",x"e2",x"49",x"f2"),
   315 => (x"c2",x"49",x"70",x"87"),
   316 => (x"f0",x"c0",x"02",x"99"),
   317 => (x"d4",x"f3",x"c2",x"87"),
   318 => (x"c7",x"48",x"7e",x"bf"),
   319 => (x"c0",x"03",x"a8",x"b7"),
   320 => (x"48",x"6e",x"87",x"cb"),
   321 => (x"f3",x"c2",x"80",x"c1"),
   322 => (x"d3",x"c0",x"58",x"d8"),
   323 => (x"48",x"66",x"c4",x"87"),
   324 => (x"70",x"80",x"e0",x"c1"),
   325 => (x"02",x"bf",x"6e",x"7e"),
   326 => (x"4b",x"87",x"c5",x"c0"),
   327 => (x"0f",x"73",x"49",x"fe"),
   328 => (x"c1",x"48",x"a6",x"c8"),
   329 => (x"49",x"fd",x"c3",x"78"),
   330 => (x"70",x"87",x"fc",x"e1"),
   331 => (x"02",x"99",x"c2",x"49"),
   332 => (x"c2",x"87",x"e9",x"c0"),
   333 => (x"02",x"bf",x"d4",x"f3"),
   334 => (x"c2",x"87",x"c9",x"c0"),
   335 => (x"c0",x"48",x"d4",x"f3"),
   336 => (x"87",x"d3",x"c0",x"78"),
   337 => (x"c1",x"48",x"66",x"c4"),
   338 => (x"7e",x"70",x"80",x"e0"),
   339 => (x"c0",x"02",x"bf",x"6e"),
   340 => (x"fd",x"4b",x"87",x"c5"),
   341 => (x"c8",x"0f",x"73",x"49"),
   342 => (x"78",x"c1",x"48",x"a6"),
   343 => (x"e1",x"49",x"fa",x"c3"),
   344 => (x"49",x"70",x"87",x"c5"),
   345 => (x"c0",x"02",x"99",x"c2"),
   346 => (x"f3",x"c2",x"87",x"ea"),
   347 => (x"c7",x"48",x"bf",x"d4"),
   348 => (x"c0",x"03",x"a8",x"b7"),
   349 => (x"f3",x"c2",x"87",x"c9"),
   350 => (x"78",x"c7",x"48",x"d4"),
   351 => (x"c4",x"87",x"d0",x"c0"),
   352 => (x"e0",x"c1",x"4a",x"66"),
   353 => (x"c0",x"02",x"6a",x"82"),
   354 => (x"fc",x"4b",x"87",x"c5"),
   355 => (x"c8",x"0f",x"73",x"49"),
   356 => (x"78",x"c1",x"48",x"a6"),
   357 => (x"f3",x"c2",x"4d",x"c0"),
   358 => (x"50",x"c0",x"48",x"cc"),
   359 => (x"c2",x"49",x"ee",x"cb"),
   360 => (x"4b",x"70",x"87",x"f2"),
   361 => (x"97",x"cc",x"f3",x"c2"),
   362 => (x"dd",x"c1",x"05",x"bf"),
   363 => (x"c3",x"49",x"74",x"87"),
   364 => (x"c0",x"05",x"99",x"f0"),
   365 => (x"da",x"c1",x"87",x"cd"),
   366 => (x"ea",x"df",x"ff",x"49"),
   367 => (x"02",x"98",x"70",x"87"),
   368 => (x"c1",x"87",x"c7",x"c1"),
   369 => (x"4c",x"bf",x"e8",x"4d"),
   370 => (x"99",x"ff",x"c3",x"49"),
   371 => (x"71",x"2c",x"b7",x"c8"),
   372 => (x"d0",x"d9",x"c2",x"b4"),
   373 => (x"dc",x"ff",x"49",x"bf"),
   374 => (x"49",x"73",x"87",x"c7"),
   375 => (x"70",x"87",x"c1",x"c2"),
   376 => (x"c6",x"c0",x"02",x"98"),
   377 => (x"cc",x"f3",x"c2",x"87"),
   378 => (x"c2",x"50",x"c1",x"48"),
   379 => (x"bf",x"97",x"cc",x"f3"),
   380 => (x"87",x"d6",x"c0",x"05"),
   381 => (x"f0",x"c3",x"49",x"74"),
   382 => (x"c6",x"ff",x"05",x"99"),
   383 => (x"49",x"da",x"c1",x"87"),
   384 => (x"87",x"e3",x"de",x"ff"),
   385 => (x"fe",x"05",x"98",x"70"),
   386 => (x"9d",x"75",x"87",x"f9"),
   387 => (x"87",x"e0",x"c0",x"02"),
   388 => (x"c2",x"48",x"a6",x"cc"),
   389 => (x"78",x"bf",x"d4",x"f3"),
   390 => (x"cc",x"49",x"66",x"cc"),
   391 => (x"48",x"66",x"c4",x"91"),
   392 => (x"7e",x"70",x"80",x"71"),
   393 => (x"c0",x"02",x"bf",x"6e"),
   394 => (x"cc",x"4b",x"87",x"c6"),
   395 => (x"0f",x"73",x"49",x"66"),
   396 => (x"c0",x"02",x"66",x"c8"),
   397 => (x"f3",x"c2",x"87",x"c8"),
   398 => (x"f2",x"49",x"bf",x"d4"),
   399 => (x"8e",x"f0",x"87",x"ce"),
   400 => (x"4c",x"26",x"4d",x"26"),
   401 => (x"4f",x"26",x"4b",x"26"),
   402 => (x"00",x"00",x"00",x"00"),
   403 => (x"00",x"00",x"00",x"00"),
   404 => (x"00",x"00",x"00",x"00"),
   405 => (x"ff",x"4a",x"71",x"1e"),
   406 => (x"72",x"49",x"bf",x"c8"),
   407 => (x"4f",x"26",x"48",x"a1"),
   408 => (x"bf",x"c8",x"ff",x"1e"),
   409 => (x"c0",x"c0",x"fe",x"89"),
   410 => (x"a9",x"c0",x"c0",x"c0"),
   411 => (x"c0",x"87",x"c4",x"01"),
   412 => (x"c1",x"87",x"c2",x"4a"),
   413 => (x"26",x"48",x"72",x"4a"),
   414 => (x"5b",x"5e",x"0e",x"4f"),
   415 => (x"71",x"0e",x"5d",x"5c"),
   416 => (x"4c",x"d4",x"ff",x"4b"),
   417 => (x"c0",x"48",x"66",x"d0"),
   418 => (x"ff",x"49",x"d6",x"78"),
   419 => (x"c3",x"87",x"d5",x"de"),
   420 => (x"49",x"6c",x"7c",x"ff"),
   421 => (x"71",x"99",x"ff",x"c3"),
   422 => (x"f0",x"c3",x"49",x"4d"),
   423 => (x"a9",x"e0",x"c1",x"99"),
   424 => (x"c3",x"87",x"cb",x"05"),
   425 => (x"48",x"6c",x"7c",x"ff"),
   426 => (x"66",x"d0",x"98",x"c3"),
   427 => (x"ff",x"c3",x"78",x"08"),
   428 => (x"49",x"4a",x"6c",x"7c"),
   429 => (x"ff",x"c3",x"31",x"c8"),
   430 => (x"71",x"4a",x"6c",x"7c"),
   431 => (x"c8",x"49",x"72",x"b2"),
   432 => (x"7c",x"ff",x"c3",x"31"),
   433 => (x"b2",x"71",x"4a",x"6c"),
   434 => (x"31",x"c8",x"49",x"72"),
   435 => (x"6c",x"7c",x"ff",x"c3"),
   436 => (x"ff",x"b2",x"71",x"4a"),
   437 => (x"e0",x"c0",x"48",x"d0"),
   438 => (x"02",x"9b",x"73",x"78"),
   439 => (x"7b",x"72",x"87",x"c2"),
   440 => (x"4d",x"26",x"48",x"75"),
   441 => (x"4b",x"26",x"4c",x"26"),
   442 => (x"26",x"1e",x"4f",x"26"),
   443 => (x"5b",x"5e",x"0e",x"4f"),
   444 => (x"86",x"f8",x"0e",x"5c"),
   445 => (x"a6",x"c8",x"1e",x"76"),
   446 => (x"87",x"fd",x"fd",x"49"),
   447 => (x"4b",x"70",x"86",x"c4"),
   448 => (x"a8",x"c2",x"48",x"6e"),
   449 => (x"87",x"f0",x"c2",x"03"),
   450 => (x"f0",x"c3",x"4a",x"73"),
   451 => (x"aa",x"d0",x"c1",x"9a"),
   452 => (x"c1",x"87",x"c7",x"02"),
   453 => (x"c2",x"05",x"aa",x"e0"),
   454 => (x"49",x"73",x"87",x"de"),
   455 => (x"c3",x"02",x"99",x"c8"),
   456 => (x"87",x"c6",x"ff",x"87"),
   457 => (x"9c",x"c3",x"4c",x"73"),
   458 => (x"c1",x"05",x"ac",x"c2"),
   459 => (x"66",x"c4",x"87",x"c2"),
   460 => (x"71",x"31",x"c9",x"49"),
   461 => (x"4a",x"66",x"c4",x"1e"),
   462 => (x"f3",x"c2",x"92",x"d4"),
   463 => (x"81",x"72",x"49",x"d8"),
   464 => (x"87",x"d5",x"ce",x"fe"),
   465 => (x"db",x"ff",x"49",x"d8"),
   466 => (x"c0",x"c8",x"87",x"da"),
   467 => (x"f0",x"e1",x"c2",x"1e"),
   468 => (x"c2",x"e8",x"fd",x"49"),
   469 => (x"48",x"d0",x"ff",x"87"),
   470 => (x"c2",x"78",x"e0",x"c0"),
   471 => (x"cc",x"1e",x"f0",x"e1"),
   472 => (x"92",x"d4",x"4a",x"66"),
   473 => (x"49",x"d8",x"f3",x"c2"),
   474 => (x"cc",x"fe",x"81",x"72"),
   475 => (x"86",x"cc",x"87",x"dc"),
   476 => (x"c1",x"05",x"ac",x"c1"),
   477 => (x"66",x"c4",x"87",x"c2"),
   478 => (x"71",x"31",x"c9",x"49"),
   479 => (x"4a",x"66",x"c4",x"1e"),
   480 => (x"f3",x"c2",x"92",x"d4"),
   481 => (x"81",x"72",x"49",x"d8"),
   482 => (x"87",x"cd",x"cd",x"fe"),
   483 => (x"1e",x"f0",x"e1",x"c2"),
   484 => (x"d4",x"4a",x"66",x"c8"),
   485 => (x"d8",x"f3",x"c2",x"92"),
   486 => (x"fe",x"81",x"72",x"49"),
   487 => (x"d7",x"87",x"dc",x"ca"),
   488 => (x"ff",x"d9",x"ff",x"49"),
   489 => (x"1e",x"c0",x"c8",x"87"),
   490 => (x"49",x"f0",x"e1",x"c2"),
   491 => (x"87",x"c4",x"e6",x"fd"),
   492 => (x"d0",x"ff",x"86",x"cc"),
   493 => (x"78",x"e0",x"c0",x"48"),
   494 => (x"4c",x"26",x"8e",x"f8"),
   495 => (x"4f",x"26",x"4b",x"26"),
   496 => (x"5c",x"5b",x"5e",x"0e"),
   497 => (x"86",x"fc",x"0e",x"5d"),
   498 => (x"d4",x"ff",x"4d",x"71"),
   499 => (x"7e",x"66",x"d4",x"4c"),
   500 => (x"a8",x"b7",x"c3",x"48"),
   501 => (x"87",x"e2",x"c1",x"01"),
   502 => (x"66",x"c4",x"1e",x"75"),
   503 => (x"c2",x"93",x"d4",x"4b"),
   504 => (x"73",x"83",x"d8",x"f3"),
   505 => (x"cc",x"c4",x"fe",x"49"),
   506 => (x"49",x"a3",x"c8",x"87"),
   507 => (x"d0",x"ff",x"49",x"69"),
   508 => (x"78",x"e1",x"c8",x"48"),
   509 => (x"48",x"71",x"7c",x"dd"),
   510 => (x"70",x"98",x"ff",x"c3"),
   511 => (x"c8",x"4a",x"71",x"7c"),
   512 => (x"48",x"72",x"2a",x"b7"),
   513 => (x"70",x"98",x"ff",x"c3"),
   514 => (x"d0",x"4a",x"71",x"7c"),
   515 => (x"48",x"72",x"2a",x"b7"),
   516 => (x"70",x"98",x"ff",x"c3"),
   517 => (x"d8",x"48",x"71",x"7c"),
   518 => (x"7c",x"70",x"28",x"b7"),
   519 => (x"7c",x"7c",x"7c",x"c0"),
   520 => (x"7c",x"7c",x"7c",x"7c"),
   521 => (x"7c",x"7c",x"7c",x"7c"),
   522 => (x"48",x"d0",x"ff",x"7c"),
   523 => (x"c4",x"78",x"e0",x"c0"),
   524 => (x"49",x"dc",x"1e",x"66"),
   525 => (x"87",x"d1",x"d8",x"ff"),
   526 => (x"8e",x"fc",x"86",x"c8"),
   527 => (x"4c",x"26",x"4d",x"26"),
   528 => (x"4f",x"26",x"4b",x"26"),
   529 => (x"00",x"00",x"1b",x"f7"),
		others => (others => x"00")
	);
	signal q1_local : word_t;

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(addr(ADDR_WIDTH-1 downto 0)));

	-- Reorganize the read data from the RAM to match the output
	q(7 downto 0) <= q1_local(3);
	q(15 downto 8) <= q1_local(2);
	q(23 downto 16) <= q1_local(1);
	q(31 downto 24) <= q1_local(0);

	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we = '1') then
				-- edit this code if using other than four bytes per word
				if (bytesel(3) = '1') then
					ram(addr1)(3) <= d(7 downto 0);
				end if;
				if (bytesel(2) = '1') then
					ram(addr1)(2) <= d(15 downto 8);
				end if;
				if (bytesel(1) = '1') then
					ram(addr1)(1) <= d(23 downto 16);
				end if;
				if (bytesel(0) = '1') then
					ram(addr1)(0) <= d(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;
  
end rtl;

