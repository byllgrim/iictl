-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
    Irc_Dir : String := Ada.Directories.Current_Directory;

    Procedure Hello_C;
    pragma Import
        (Convention => C,
        Entity => Hello_C,
        External_Name => "hello_c");
begin
    -- TODO output procedure information when -v?
    Hello_C;

    loop
        SrvCtl.Reconnect_Servers (Irc_Dir);
        -- TODO ChCtl.Rejoin_Channels;
        -- TODO SrvCtl.Detect_Quits;
        -- TODO ChCtl.Detect_Parts;
    end loop;
end Iictl;
