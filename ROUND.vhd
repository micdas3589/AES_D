LIBRARY IEEE;
	USE IEEE.STD_LOGIC_1164.ALL;
	USE IEEE.STD_LOGIC_UNSIGNED.ALL;
	USE IEEE.NUMERIC_STD.ALL;

ENTITY ROUND IS
	PORT (
		CLK			:IN STD_LOGIC;
		INIT			:IN STD_LOGIC;
		RUN			:IN STD_LOGIC;
		STATE_IN		:IN STD_LOGIC_VECTOR(127 downto 0);
		ROUND_KEY	:IN STD_LOGIC_VECTOR(127 downto 0);
		STATE_OUT	:OUT STD_LOGIC_VECTOR(127 downto 0)
	);
END ENTITY;

ARCHITECTURE ARCH_ROUND OF ROUND IS
	TYPE MEMORY_BLOCK IS ARRAY (0 to 15) OF STD_LOGIC_VECTOR(0 to 127);
	CONSTANT SBOX	:MEMORY_BLOCK :=
	(
		 X"52096ad53036a538bf40a39e81f3d7fb"
		,X"7ce339829b2fff87348e4344c4dee9cb"
		,X"547b9432a6c2233dee4c950b42fac34e"
		,X"082ea16628d924b2765ba2496d8bd125"
		,X"72f8f66486689816d4a45ccc5d65b692"
		,X"6c704850fdedb9da5e154657a78d9d84"
		,X"90d8ab008cbcd30af7e45805b8b34506"
		,X"d02c1e8fca3f0f02c1afbd0301138a6b"
		,X"3a9111414f67dcea97f2cfcef0b4e673"
		,X"96ac7422e7ad3585e2f937e81c75df6e"
		,X"47f11a711d29c5896fb7620eaa18be1b"
		,X"fc563e4bc6d279209adbc0fe78cd5af4"
		,X"1fdda8338807c731b11210592780ec5f"
		,X"60517fa919b54a0d2de57a9f93c99cef"
		,X"a0e03b4dae2af5b0c8ebbb3c83539961"
		,X"172b047eba77d626e169146355210c7d"
	);
	CONSTANT MULT09 :MEMORY_BLOCK :=
	(
		 X"0009121b242d363f48415a536c657e77"
		,X"9099828bb4bda6afd8d1cac3fcf5eee7"
		,X"3b3229201f160d04737a6168575e454c"
		,X"aba2b9b08f869d94e3eaf1f8c7ced5dc"
		,X"767f646d525b40493e372c251a130801"
		,X"e6eff4fdc2cbd0d9aea7bcb58a839891"
		,X"4d445f5669607b72050c171e2128333a"
		,X"ddd4cfc6f9f0ebe2959c878eb1b8a3aa"
		,X"ece5fef7c8c1dad3a4adb6bf8089929b"
		,X"7c756e6758514a43343d262f1019020b"
		,X"d7dec5ccf3fae1e89f968d84bbb2a9a0"
		,X"474e555c636a71780f061d142b223930"
		,X"9a938881beb7aca5d2dbc0c9f6ffe4ed"
		,X"0a0318112e273c35424b5059666f747d"
		,X"a1a8b3ba858c979ee9e0fbf2cdc4dfd6"
		,X"3138232a151c070e79706b625d544f46"
	);
	CONSTANT MULT11 :MEMORY_BLOCK :=
	(
		 X"000b161d2c273a3158534e45747f6269"
		,X"b0bba6ad9c978a81e8e3fef5c4cfd2d9"
		,X"7b706d66575c414a2328353e0f041912"
		,X"cbc0ddd6e7ecf1fa9398858ebfb4a9a2"
		,X"f6fde0ebdad1ccc7aea5b8b38289949f"
		,X"464d505b6a617c771e1508033239242f"
		,X"8d869b90a1aab7bcd5dec3c8f9f2efe4"
		,X"3d362b20111a070c656e737849425f54"
		,X"f7fce1eadbd0cdc6afa4b9b28388959e"
		,X"474c515a6b607d761f1409023338252e"
		,X"8c879a91a0abb6bdd4dfc2c9f8f3eee5"
		,X"3c372a21101b060d646f727948435e55"
		,X"010a171c2d263b3059524f44757e6368"
		,X"b1baa7ac9d968b80e9e2fff4c5ced3d8"
		,X"7a716c67565d404b2229343f0e051813"
		,X"cac1dcd7e6edf0fb9299848fbeb5a8a3"
	);
	CONSTANT MULT13 :MEMORY_BLOCK :=
	(
		 X"000d1a1734392e236865727f5c51464b"
		,X"d0ddcac7e4e9fef3b8b5a2af8c81969b"
		,X"bbb6a1ac8f829598d3dec9c4e7eafdf0"
		,X"6b66717c5f524548030e1914373a2d20"
		,X"6d60777a5954434e05081f12313c2b26"
		,X"bdb0a7aa8984939ed5d8cfc2e1ecfbf6"
		,X"d6dbccc1e2eff8f5beb3a4a98a87909d"
		,X"060b1c11323f28256e6374795a57404d"
		,X"dad7c0cdeee3f4f9b2bfa8a5868b9c91"
		,X"0a07101d3e332429626f7875565b4c41"
		,X"616c7b7655584f420904131e3d30272a"
		,X"b1bcaba685889f92d9d4c3ceede0f7fa"
		,X"b7baada0838e9994dfd2c5c8ebe6f1fc"
		,X"676a7d70535e49440f0215183b36212c"
		,X"0c01161b3835222f64697e73505d4a47"
		,X"dcd1c6cbe8e5f2ffb4b9aea3808d9a97"
	);
	CONSTANT MULT14 :MEMORY_BLOCK :=
	(
		 X"000e1c123836242a707e6c624846545a"
		,X"e0eefcf2d8d6c4ca909e8c82a8a6b4ba"
		,X"dbd5c7c9e3edfff1aba5b7b9939d8f81"
		,X"3b352729030d1f114b455759737d6f61"
		,X"ada3b1bf959b8987ddd3c1cfe5ebf9f7"
		,X"4d43515f757b69673d33212f050b1917"
		,X"76786a644e40525c06081a143e30222c"
		,X"96988a84aea0b2bce6e8faf4ded0c2cc"
		,X"414f5d537977656b313f2d230907151b"
		,X"a1afbdb39997858bd1dfcdc3e9e7f5fb"
		,X"9a948688a2acbeb0eae4f6f8d2dccec0"
		,X"7a746668424c5e500a041618323c2e20"
		,X"ece2f0fed4dac8c69c92808ea4aab8b6"
		,X"0c02101e343a28267c72606e444a5856"
		,X"37392b250f01131d47495b557f71636d"
		,X"d7d9cbc5efe1f3fda7a9bbb59f91838d"
	);
		
	SIGNAL COUNTER 	:STD_LOGIC_VECTOR(3 downto 0) := (OTHERS => '0');
	SIGNAL STATE		:STD_LOGIC_VECTOR(127 downto 0) := (OTHERS => '0');
	SIGNAL ROUND_NR	:STD_LOGIC_VECTOR(3 downto 0) := (OTHERS => '0');
BEGIN
	PROCESS(CLK, INIT)
	BEGIN
		IF INIT = '1' THEN
			COUNTER	<= (OTHERS => '0');
			STATE		<= (OTHERS => '0');
			ROUND_NR	<= (OTHERS => '0');
		ELSIF CLK = '1' AND CLK'EVENT THEN
			IF RUN = '1' THEN
				COUNTER	<= COUNTER + 1;
			ELSE
				COUNTER	<= X"F";
			END IF;
		
			IF ROUND_NR = X"0" AND COUNTER = X"1" THEN
				STATE	<= STATE_IN XOR ROUND_KEY;
				ROUND_NR	<= ROUND_NR + 1;
				COUNTER	<= (OTHERS => '0');
			END IF;
			IF ROUND_NR > X"0" AND ROUND_NR < X"B" THEN
				IF COUNTER = X"0" THEN -- INV SHIFT ROWS
					STATE	<= STATE(127 downto 120) &
								STATE(23  downto  16) &
								STATE(47  downto  40) &
								STATE(71  downto  64) &
								STATE(95  downto  88) &
								STATE(119 downto 112) &
								STATE(15  downto   8) &
								STATE(39  downto  32) &
								STATE(63  downto  56) &
								STATE(87  downto  80) &
								STATE(111 downto 104) &
								STATE(7   downto   0) &
								STATE(31  downto  24) &
								STATE(55  downto  48) &
								STATE(79  downto  72) &
								STATE(103 downto  96);
				END IF;
				IF COUNTER = X"1" THEN -- SUB BYTES
					STATE(127 downto 120) <= SBOX(CONV_INTEGER(STATE(127 downto 124)))(CONV_INTEGER(STATE(123 downto 120) & "000") to CONV_INTEGER(STATE(123 downto 120) & "000")+7);
					STATE(119 downto 112) <= SBOX(CONV_INTEGER(STATE(119 downto 116)))(CONV_INTEGER(STATE(115 downto 112) & "000") to CONV_INTEGER(STATE(115 downto 112) & "000")+7);
					STATE(111 downto 104) <= SBOX(CONV_INTEGER(STATE(111 downto 108)))(CONV_INTEGER(STATE(107 downto 104) & "000") to CONV_INTEGER(STATE(107 downto 104) & "000")+7);
					STATE(103 downto  96) <= SBOX(CONV_INTEGER(STATE(103 downto 100)))(CONV_INTEGER(STATE(99  downto  96) & "000") to CONV_INTEGER(STATE(99  downto  96) & "000")+7);
					STATE(95  downto  88) <= SBOX(CONV_INTEGER(STATE(95  downto  92)))(CONV_INTEGER(STATE(91  downto  88) & "000") to CONV_INTEGER(STATE(91  downto  88) & "000")+7);
					STATE(87  downto  80) <= SBOX(CONV_INTEGER(STATE(87  downto  84)))(CONV_INTEGER(STATE(83  downto  80) & "000") to CONV_INTEGER(STATE(83  downto  80) & "000")+7);
					STATE(79  downto  72) <= SBOX(CONV_INTEGER(STATE(79  downto  76)))(CONV_INTEGER(STATE(75  downto  72) & "000") to CONV_INTEGER(STATE(75  downto  72) & "000")+7);
					STATE(71  downto  64) <= SBOX(CONV_INTEGER(STATE(71  downto  68)))(CONV_INTEGER(STATE(67  downto  64) & "000") to CONV_INTEGER(STATE(67  downto  64) & "000")+7);
					STATE(63  downto  56) <= SBOX(CONV_INTEGER(STATE(63  downto  60)))(CONV_INTEGER(STATE(59  downto  56) & "000") to CONV_INTEGER(STATE(59  downto  56) & "000")+7);
					STATE(55  downto  48) <= SBOX(CONV_INTEGER(STATE(55  downto  52)))(CONV_INTEGER(STATE(51  downto  48) & "000") to CONV_INTEGER(STATE(51  downto  48) & "000")+7);
					STATE(47  downto  40) <= SBOX(CONV_INTEGER(STATE(47  downto  44)))(CONV_INTEGER(STATE(43  downto  40) & "000") to CONV_INTEGER(STATE(43  downto  40) & "000")+7);
					STATE(39  downto  32) <= SBOX(CONV_INTEGER(STATE(39  downto  36)))(CONV_INTEGER(STATE(35  downto  32) & "000") to CONV_INTEGER(STATE(35  downto  32) & "000")+7);
					STATE(31  downto  24) <= SBOX(CONV_INTEGER(STATE(31  downto  28)))(CONV_INTEGER(STATE(27  downto  24) & "000") to CONV_INTEGER(STATE(27  downto  24) & "000")+7);
					STATE(23  downto  16) <= SBOX(CONV_INTEGER(STATE(23  downto  20)))(CONV_INTEGER(STATE(19  downto  16) & "000") to CONV_INTEGER(STATE(19  downto  16) & "000")+7);
					STATE(15  downto   8) <= SBOX(CONV_INTEGER(STATE(15  downto  12)))(CONV_INTEGER(STATE(11  downto   8) & "000") to CONV_INTEGER(STATE(11  downto   8) & "000")+7);
					STATE(7   downto   0) <= SBOX(CONV_INTEGER(STATE(7   downto   4)))(CONV_INTEGER(STATE(3   downto   0) & "000") to CONV_INTEGER(STATE(3   downto   0) & "000")+7);
				END IF;
				IF COUNTER = X"2" THEN
					STATE		<= STATE XOR ROUND_KEY;
				END IF;
				IF COUNTER = X"3" THEN
					ROUND_NR	<= ROUND_NR + 1;
					COUNTER	<= (OTHERS => '0');
				END IF;
				IF COUNTER = X"3" AND ROUND_NR /= X"A" THEN -- INV MIX COLUMNS
					-- 127-96
					STATE(127 downto 120)	<= MULT14(CONV_INTEGER(STATE(127 downto 124)))(CONV_INTEGER(STATE(123 downto 120) & "000") to CONV_INTEGER(STATE(123 downto 120) & "000")+7)
												  XOR MULT11(CONV_INTEGER(STATE(119 downto 116)))(CONV_INTEGER(STATE(115 downto 112) & "000") to CONV_INTEGER(STATE(115 downto 112) & "000")+7)
												  XOR MULT13(CONV_INTEGER(STATE(111 downto 108)))(CONV_INTEGER(STATE(107 downto 104) & "000") to CONV_INTEGER(STATE(107 downto 104) & "000")+7)
												  XOR MULT09(CONV_INTEGER(STATE(103 downto 100)))(CONV_INTEGER(STATE(99  downto  96) & "000") to CONV_INTEGER(STATE(99  downto  96) & "000")+7);
					STATE(119 downto 112)	<= MULT09(CONV_INTEGER(STATE(127 downto 124)))(CONV_INTEGER(STATE(123 downto 120) & "000") to CONV_INTEGER(STATE(123 downto 120) & "000")+7)
												  XOR MULT14(CONV_INTEGER(STATE(119 downto 116)))(CONV_INTEGER(STATE(115 downto 112) & "000") to CONV_INTEGER(STATE(115 downto 112) & "000")+7)
												  XOR MULT11(CONV_INTEGER(STATE(111 downto 108)))(CONV_INTEGER(STATE(107 downto 104) & "000") to CONV_INTEGER(STATE(107 downto 104) & "000")+7)
												  XOR MULT13(CONV_INTEGER(STATE(103 downto 100)))(CONV_INTEGER(STATE(99  downto  96) & "000") to CONV_INTEGER(STATE(99  downto  96) & "000")+7);
					STATE(111 downto 104)	<= MULT13(CONV_INTEGER(STATE(127 downto 124)))(CONV_INTEGER(STATE(123 downto 120) & "000") to CONV_INTEGER(STATE(123 downto 120) & "000")+7)
												  XOR MULT09(CONV_INTEGER(STATE(119 downto 116)))(CONV_INTEGER(STATE(115 downto 112) & "000") to CONV_INTEGER(STATE(115 downto 112) & "000")+7)
												  XOR MULT14(CONV_INTEGER(STATE(111 downto 108)))(CONV_INTEGER(STATE(107 downto 104) & "000") to CONV_INTEGER(STATE(107 downto 104) & "000")+7)
												  XOR MULT11(CONV_INTEGER(STATE(103 downto 100)))(CONV_INTEGER(STATE(99  downto  96) & "000") to CONV_INTEGER(STATE(99  downto  96) & "000")+7);
					STATE(103 downto 96)		<= MULT11(CONV_INTEGER(STATE(127 downto 124)))(CONV_INTEGER(STATE(123 downto 120) & "000") to CONV_INTEGER(STATE(123 downto 120) & "000")+7)
												  XOR MULT13(CONV_INTEGER(STATE(119 downto 116)))(CONV_INTEGER(STATE(115 downto 112) & "000") to CONV_INTEGER(STATE(115 downto 112) & "000")+7)
												  XOR MULT09(CONV_INTEGER(STATE(111 downto 108)))(CONV_INTEGER(STATE(107 downto 104) & "000") to CONV_INTEGER(STATE(107 downto 104) & "000")+7)
												  XOR MULT14(CONV_INTEGER(STATE(103 downto 100)))(CONV_INTEGER(STATE(99  downto  96) & "000") to CONV_INTEGER(STATE(99  downto  96) & "000")+7);
					
					-- 95-64
					STATE(95 downto 88)	<= MULT14(CONV_INTEGER(STATE(95  downto  92)))(CONV_INTEGER(STATE(91  downto  88) & "000") to CONV_INTEGER(STATE(91  downto  88) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(87  downto  84)))(CONV_INTEGER(STATE(83  downto  80) & "000") to CONV_INTEGER(STATE(83  downto  80) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(79  downto  76)))(CONV_INTEGER(STATE(75  downto  72) & "000") to CONV_INTEGER(STATE(75  downto  72) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(71  downto  68)))(CONV_INTEGER(STATE(67  downto  64) & "000") to CONV_INTEGER(STATE(67  downto  64) & "000")+7);
					STATE(87 downto 80)	<= MULT09(CONV_INTEGER(STATE(95  downto  92)))(CONV_INTEGER(STATE(91  downto  88) & "000") to CONV_INTEGER(STATE(91  downto  88) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(87  downto  84)))(CONV_INTEGER(STATE(83  downto  80) & "000") to CONV_INTEGER(STATE(83  downto  80) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(79  downto  76)))(CONV_INTEGER(STATE(75  downto  72) & "000") to CONV_INTEGER(STATE(75  downto  72) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(71  downto  68)))(CONV_INTEGER(STATE(67  downto  64) & "000") to CONV_INTEGER(STATE(67  downto  64) & "000")+7);
					STATE(79 downto 72)	<= MULT13(CONV_INTEGER(STATE(95  downto  92)))(CONV_INTEGER(STATE(91  downto  88) & "000") to CONV_INTEGER(STATE(91  downto  88) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(87  downto  84)))(CONV_INTEGER(STATE(83  downto  80) & "000") to CONV_INTEGER(STATE(83  downto  80) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(79  downto  76)))(CONV_INTEGER(STATE(75  downto  72) & "000") to CONV_INTEGER(STATE(75  downto  72) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(71  downto  68)))(CONV_INTEGER(STATE(67  downto  64) & "000") to CONV_INTEGER(STATE(67  downto  64) & "000")+7);
					STATE(71 downto 64)	<= MULT11(CONV_INTEGER(STATE(95  downto  92)))(CONV_INTEGER(STATE(91  downto  88) & "000") to CONV_INTEGER(STATE(91  downto  88) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(87  downto  84)))(CONV_INTEGER(STATE(83  downto  80) & "000") to CONV_INTEGER(STATE(83  downto  80) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(79  downto  76)))(CONV_INTEGER(STATE(75  downto  72) & "000") to CONV_INTEGER(STATE(75  downto  72) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(71  downto  68)))(CONV_INTEGER(STATE(67  downto  64) & "000") to CONV_INTEGER(STATE(67  downto  64) & "000")+7);
					
					-- 63-32
					STATE(63 downto 56)	<= MULT14(CONV_INTEGER(STATE(63  downto  60)))(CONV_INTEGER(STATE(59  downto  56) & "000") to CONV_INTEGER(STATE(59  downto  56) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(55  downto  52)))(CONV_INTEGER(STATE(51  downto  48) & "000") to CONV_INTEGER(STATE(51  downto  48) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(47  downto  44)))(CONV_INTEGER(STATE(43  downto  40) & "000") to CONV_INTEGER(STATE(43  downto  40) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(39  downto  36)))(CONV_INTEGER(STATE(35  downto  32) & "000") to CONV_INTEGER(STATE(35  downto  32) & "000")+7);
					STATE(55 downto 48)	<= MULT09(CONV_INTEGER(STATE(63  downto  60)))(CONV_INTEGER(STATE(59  downto  56) & "000") to CONV_INTEGER(STATE(59  downto  56) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(55  downto  52)))(CONV_INTEGER(STATE(51  downto  48) & "000") to CONV_INTEGER(STATE(51  downto  48) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(47  downto  44)))(CONV_INTEGER(STATE(43  downto  40) & "000") to CONV_INTEGER(STATE(43  downto  40) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(39  downto  36)))(CONV_INTEGER(STATE(35  downto  32) & "000") to CONV_INTEGER(STATE(35  downto  32) & "000")+7);
					STATE(47 downto 40)	<= MULT13(CONV_INTEGER(STATE(63  downto  60)))(CONV_INTEGER(STATE(59  downto  56) & "000") to CONV_INTEGER(STATE(59  downto  56) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(55  downto  52)))(CONV_INTEGER(STATE(51  downto  48) & "000") to CONV_INTEGER(STATE(51  downto  48) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(47  downto  44)))(CONV_INTEGER(STATE(43  downto  40) & "000") to CONV_INTEGER(STATE(43  downto  40) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(39  downto  36)))(CONV_INTEGER(STATE(35  downto  32) & "000") to CONV_INTEGER(STATE(35  downto  32) & "000")+7);
					STATE(39 downto 32)	<= MULT11(CONV_INTEGER(STATE(63  downto  60)))(CONV_INTEGER(STATE(59  downto  56) & "000") to CONV_INTEGER(STATE(59  downto  56) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(55  downto  52)))(CONV_INTEGER(STATE(51  downto  48) & "000") to CONV_INTEGER(STATE(51  downto  48) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(47  downto  44)))(CONV_INTEGER(STATE(43  downto  40) & "000") to CONV_INTEGER(STATE(43  downto  40) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(39  downto  36)))(CONV_INTEGER(STATE(35  downto  32) & "000") to CONV_INTEGER(STATE(35  downto  32) & "000")+7);
					
					-- 31-0
					STATE(31 downto 24)	<= MULT14(CONV_INTEGER(STATE(31  downto  28)))(CONV_INTEGER(STATE(27  downto  24) & "000") to CONV_INTEGER(STATE(27  downto  24) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(23  downto  20)))(CONV_INTEGER(STATE(19  downto  16) & "000") to CONV_INTEGER(STATE(19  downto  16) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(15  downto  12)))(CONV_INTEGER(STATE(11  downto   8) & "000") to CONV_INTEGER(STATE(11  downto   8) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(7   downto   4)))(CONV_INTEGER(STATE(3   downto   0) & "000") to CONV_INTEGER(STATE(3   downto   0) & "000")+7);
					STATE(23 downto 16)	<= MULT09(CONV_INTEGER(STATE(31  downto  28)))(CONV_INTEGER(STATE(27  downto  24) & "000") to CONV_INTEGER(STATE(27  downto  24) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(23  downto  20)))(CONV_INTEGER(STATE(19  downto  16) & "000") to CONV_INTEGER(STATE(19  downto  16) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(15  downto  12)))(CONV_INTEGER(STATE(11  downto   8) & "000") to CONV_INTEGER(STATE(11  downto   8) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(7   downto   4)))(CONV_INTEGER(STATE(3   downto   0) & "000") to CONV_INTEGER(STATE(3   downto   0) & "000")+7);
					STATE(15 downto 8)	<= MULT13(CONV_INTEGER(STATE(31  downto  28)))(CONV_INTEGER(STATE(27  downto  24) & "000") to CONV_INTEGER(STATE(27  downto  24) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(23  downto  20)))(CONV_INTEGER(STATE(19  downto  16) & "000") to CONV_INTEGER(STATE(19  downto  16) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(15  downto  12)))(CONV_INTEGER(STATE(11  downto   8) & "000") to CONV_INTEGER(STATE(11  downto   8) & "000")+7)
											  XOR MULT11(CONV_INTEGER(STATE(7   downto   4)))(CONV_INTEGER(STATE(3   downto   0) & "000") to CONV_INTEGER(STATE(3   downto   0) & "000")+7);
					STATE(7 downto 0)		<= MULT11(CONV_INTEGER(STATE(31  downto  28)))(CONV_INTEGER(STATE(27  downto  24) & "000") to CONV_INTEGER(STATE(27  downto  24) & "000")+7)
											  XOR MULT13(CONV_INTEGER(STATE(23  downto  20)))(CONV_INTEGER(STATE(19  downto  16) & "000") to CONV_INTEGER(STATE(19  downto  16) & "000")+7)
											  XOR MULT09(CONV_INTEGER(STATE(15  downto  12)))(CONV_INTEGER(STATE(11  downto   8) & "000") to CONV_INTEGER(STATE(11  downto   8) & "000")+7)
											  XOR MULT14(CONV_INTEGER(STATE(7   downto   4)))(CONV_INTEGER(STATE(3   downto   0) & "000") to CONV_INTEGER(STATE(3   downto   0) & "000")+7);
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	STATE_OUT	<= STATE;
END ARCHITECTURE;