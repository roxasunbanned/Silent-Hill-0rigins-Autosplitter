/*
*	SH 0rigins IGT Display v1.02 (19/11/2023)
*	GitHub: https://github.com/roxasunbanned/Silent-Hill-0rigins-Autosplitter
*	Currently supports:
*		PPSSPP: 64-bit executable, v1.4-v1.14.1 and v1.15-v1.16.6
*		Game: US [ULUS10285], JP [ULJM05281], EU [ULES00869]
*	Contributors:
*		Parik: Emulator version detection via signature scanning
*	Notes:
*		- (optional) Install ASLVarViewer [https://github.com/hawkerm/LiveSplit.ASLVarViewer] & LiveSplit [https://github.com/LiveSplit/LiveSplit]
*		- It is advised to have PPSSPP and the game running before opening LiveSplit
*/

state("PPSSPPWindows64", "unknown") { 
	float IGT: 0;
}
state("PPSSPPWindows64", "PPSSPP detected") { 
	float IGT: 0;
}

startup {
	vars.EmulatorVersion = "unknown";
}

init {

	// Refresh Rate
	refreshRate = 1000/30;

	// Check Game Region
	if(game.MainWindowTitle.Contains("ULUS10285")) {
		// US [ULUS10285]
		vars.IGT_offset = 0x8D8AD34;
	} else if(game.MainWindowTitle.Contains("ULJM05281")) {
		// JP [ULJM05281]
		vars.IGT_offset = 0x8D8B1B4;
	} else {
		// EU [ULES00869]
		vars.IGT_offset = 0x8D8AD34;
	}

	// Attempt Signature Scan
	var page = modules.First();
	vars.watchers = new MemoryWatcherList();
	var scanner = new SignatureScanner(game, page.BaseAddress, page.ModuleMemorySize);
	IntPtr ptr = scanner.Scan(new SigScanTarget(22, "41 B9 ?? 05 00 00 48 89 44 24 20 8D 4A FC E8 ?? ?? ?? FF 48 8B 0D ?? ?? ?? 00 48 03 CB"));
	
	// Automatic MemorySpaceOffset
	if (ptr != IntPtr.Zero)
	{
		vars.MemorySpaceOffset = (int) ((long)ptr - (long)page.BaseAddress + game.ReadValue<int>(ptr) + 0x4);
		version = "PPSSPP detected";
		vars.EmulatorVersion = modules.First().FileVersionInfo.FileVersion;
	}
	// Manual MemorySpaceOffset if Signature scan fails
	else
	{
		var fileVersion = modules.First().FileVersionInfo.FileVersion;
		switch (fileVersion)
		{
			// Add new versions to the top.
			case "v1.16.6" : vars.MemorySpaceOffset = 0xF71E30; break;			
			case "v1.16.5" : vars.MemorySpaceOffset = 0xF71E60; break;			
			case "v1.16.4" : vars.MemorySpaceOffset = 0xF70E60; break;			
			case "v1.16.3" : vars.MemorySpaceOffset = 0xF6EE60; break;
			case "v1.16.2" : vars.MemorySpaceOffset = 0xF6CE60; break;
			case "v1.16.1" : vars.MemorySpaceOffset = 0xF6CE60; break;			
			case "v1.16"   : vars.MemorySpaceOffset = 0xF6CD60; break;
			case "v1.15.4" : vars.MemorySpaceOffset = 0xEFECC0; break;
			case "v1.15.3" : vars.MemorySpaceOffset = 0xEFED20; break;
			case "v1.15.2" : vars.MemorySpaceOffset = 0xEFED20; break;
			case "v1.15.1" : vars.MemorySpaceOffset = 0xEFED20; break;
			case "v1.15"   : vars.MemorySpaceOffset = 0xEFCD20; break;
			case "v1.14.1" : vars.MemorySpaceOffset = 0xDF5DD8; break;
			case "v1.14"   : vars.MemorySpaceOffset = 0xDF5C68; break;
			case "v1.13.2" : vars.MemorySpaceOffset = 0xDF10F0; break;
			case "v1.13.1" : vars.MemorySpaceOffset = 0xDEA130; break;
			case "v1.13"   : vars.MemorySpaceOffset = 0xDE90F0; break;
			case "v1.12.3" : vars.MemorySpaceOffset = 0xD96108; break;
			case "v1.12.2" : vars.MemorySpaceOffset = 0xD96108; break;
			case "v1.12.1" : vars.MemorySpaceOffset = 0xD97108; break;
			case "v1.12"   : vars.MemorySpaceOffset = 0xD960F8; break;
			case "v1.11.3" : vars.MemorySpaceOffset = 0xC6A440; break;
			case "v1.11.2" : vars.MemorySpaceOffset = 0xC6A440; break;
			case "v1.11.1" : vars.MemorySpaceOffset = 0xC6A440; break;
			case "v1.11"   : vars.MemorySpaceOffset = 0xC68320; break;
			case "v1.10.3" : vars.MemorySpaceOffset = 0xC54CB0; break;
			case "v1.10.2" : vars.MemorySpaceOffset = 0xC53CB0; break;
			case "v1.10.1" : vars.MemorySpaceOffset = 0xC53B00; break;
			case "v1.10"   : vars.MemorySpaceOffset = 0xC53AC0; break;
			case "v1.9.3"  : vars.MemorySpaceOffset = 0xD8C010; break;
			case "v1.9"    : vars.MemorySpaceOffset = 0xD8AF70; break;
			case "v1.8.0"  : vars.MemorySpaceOffset = 0xDC8FB0; break;
			case "v1.7.4"  : vars.MemorySpaceOffset = 0xD91250; break;
			case "v1.7.1"  : vars.MemorySpaceOffset = 0xD91250; break;
			case "v1.7"    : vars.MemorySpaceOffset = 0xD90250; break;
			default        : vars.MemorySpaceOffset = 0       ; break;
		}
		if (vars.MemorySpaceOffset != 0)
		{
			vars.EmulatorVersion = fileVersion;
			version = "PPSSPP detected";
		}
		else
		{
			vars.EmulatorVersion = "unknown";
			version = "unknown";
		}
	}

	// Add IGT to MemoryWatchers
	vars.MemoryWatchers = new MemoryWatcherList();
	vars.MemoryWatchers.Add(new MemoryWatcher<float>(new DeepPointer(vars.MemorySpaceOffset, vars.IGT_offset)) { Name = "IGT" });										
}

update {
	// Update Memory Watchers to get the new value of IGT.
	vars.MemoryWatchers.UpdateAll(game);
	current.IGT = vars.MemoryWatchers["IGT"].Current;

	// Convert IGT float to minutes and seconds
	var time = Math.Round(vars.MemoryWatchers["IGT"].Current, 0);
	var minutes = Math.Floor(time / 60);
	var seconds =  time - minutes * 60;
	vars.IGT = minutes.ToString("00") + "m " + seconds.ToString("00") + "s";
	
	return true;
}

gameTime {
	// Push current IGT value to gameTime
	return TimeSpan.FromSeconds((double)(new decimal(current.IGT)));
}

split {
}
