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
		ATIO.Put_Line ("Listing servers");
		ATIO.Put_Line (AD.Current_Directory);

		AD.Start_Search (Search, ".", "");
		while AD.More_Entries (Search) loop
			AD.Get_Next_Entry (Search, Dir_Ent);
			ATIO.Put_Line (AD.Simple_Name(Dir_Ent));
		end loop;
		--TODO stop search?
	end Reconnect_Servers;
end SrvCtl;
