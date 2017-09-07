-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
    Irc_Dir : String := Ada.Directories.Current_Directory;
begin
    -- TODO output procedure information when -v?

    -- TODO set file offset to end of channel outs?

    loop
        SrvCtl.Reconnect_Servers (Irc_Dir);
        -- TODO ChCtl.Rejoin_Channels;
        -- TODO SrvCtl.Detect_Quits;
        -- TODO ChCtl.Detect_Parts;
    end loop;
end Iictl;
