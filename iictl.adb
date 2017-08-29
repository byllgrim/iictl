-- See LICENSE file for cc0 license details
with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
begin
	Ada.Text_IO.Put_Line ("Hello, iictl!");

	loop
		SrvCtl.List_Servers;
	end loop;

	-- Outline/Sketch of program
		-- Loop
		-- Scan for disconnected servers
		-- Reconnect (instantiate ii) if any
		-- Scan for disconnected channels
		-- Reconnect (join) if any
		-- Listen for server exit command
		-- Delete server dir if exit command
		-- Listen for channel exit command
		-- Delete channel dir if exit command
		-- Goto Loop
end Iictl;
