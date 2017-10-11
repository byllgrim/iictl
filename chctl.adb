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
            Scan_Server (Dir_Ent);
        end loop;

        AD.End_Search (Search);
    end Rejoin_Channels;

    procedure Scan_Server (Dir_Ent : AD.Directory_Entry_Type) is
        -- TODO rename Scan_Server_Channels?

        Srv_Path : String := AD.Full_Name (Dir_Ent);
        Srv_Name : String := AD.Simple_Name (Dir_Ent);
    begin
        if Srv_Name(Srv_Name'First) = '.' then
            return;
        end if;

        Iictl.Verbose_Print ("Iictl: Scan_Server: Scanning " & Srv_Name);
        -- TODO for channel in server
            -- TODO rejoin if fifo "in" is down?
    end Scan_Server;
end ChCtl;
