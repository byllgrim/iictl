with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
begin
	Ada.Text_IO.Put_Line ("Hello, iictl!");
	SrvCtl.List_Servers;
end Iictl;
