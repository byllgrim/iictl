-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;

package body SrvCtl is
	package AD renames Ada.Directories;
	Package ATIO renames Ada.Text_IO;

	procedure Reconnect_Servers is
		Search : AD.Search_Type;
		Dir_Ent : AD.Directory_Entry_Type;
	begin
		AD.Start_Search (Search, ".", "");
		-- TODO don't assume "." is correct dir?

		while AD.More_Entries (Search) loop
			AD.Get_Next_Entry (Search, Dir_Ent);
			Maintain_Connection (AD.Simple_Name(Dir_Ent));
		end loop;

		AD.End_Search (Search);
	end Reconnect_Servers;

	procedure Maintain_Connection (Name : in String) is
		-- TODO get Dir_Ent as input?
	begin
		ATIO.Put_Line ("Mainting " & Name);
	end Maintain_Connection;
end SrvCtl;
