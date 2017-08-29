with Ada.Text_IO;
with Ada.Directories;

package body SrvCtl is
	procedure List_Servers is
	begin
		Ada.Text_IO.Put_Line ("Listing servers");
		Ada.Text_IO.Put_Line (Ada.Directories.Current_Directory);
	end List_Servers;
end SrvCtl;
