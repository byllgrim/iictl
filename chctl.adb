with Ada.Directories;
with Ada.Text_Io; -- TODO unecessary?
with Iictl;

package body ChCtl is
    package AD renames Ada.Directories;
    package ATIO renames Ada.Text_Io;

    procedure Rejoin_Channels (Irc_Dir : String) is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
    begin
        AD.Start_Search (Search, Irc_Dir, "");

        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);

            Scan_Server (AD.Full_Name (Dir_Ent));
        end loop;

        AD.End_Search (Search);
    end Rejoin_Channels;

    procedure Scan_Server (Srv_Path : String) is
        -- TODO rename Scan_Server_Channels?
    begin
        Iictl.Verbose_Print ("Iictl: Scan_Server: Scanning " & Srv_Path);
        -- TODO for channel in server
            -- TODO rejoin if fifo "in" is down?
    end Scan_Server;
end ChCtl;
