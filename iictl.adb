with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
begin
	Ada.Text_IO.Put_Line ("Hello, iictl!");
	SrvCtl.List_Servers;

	-- Outline/Sketch of program
		-- Scan for (disconnected) server directories
		-- Instantiate ii for each server directory
		-- Scan for channel directories
		-- Join all discovered channels
		-- Loop
		-- Listen for server exit command
		-- Delete server dir if exit command
		-- Listen for channel exit command
		-- Delete channel dir if exit command
		-- Scan for disconnected servers
		-- Reconnect (instantiate ii) if any
		-- Scan for disconnected channels
		-- Reconnect (join) if any
		-- Goto Loop
	-- Last chunk of loop is same as chunk before loop. Fix it.
end Iictl;
