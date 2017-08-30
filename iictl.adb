-- See LICENSE file for cc0 license details
with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
begin
	Ada.Text_IO.Put_Line ("Hello, iictl!");

	loop
		SrvCtl.Reconnect_Servers;
		-- Scan for servers
		-- Check server disconnection
		-- Reconnect (instantiate ii) disconnected srvs

		-- Scan for disconnected channels
		-- Reconnect (join) disconnected chs
		-- Listen for server exit command
		-- Delete server dir if exit command
		-- Listen for channel exit command
		-- Delete channel dir if exit command
	end loop;
end Iictl;
