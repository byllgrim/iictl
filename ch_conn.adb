with Ada.Directories;
with Ada.Text_Io; -- TODO unecessary?
with Iictl;

package body Ch_Conn is
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

    procedure Scan_Server (Srv_Dir : AD.Directory_Entry_Type) is
        -- TODO rename Scan_Server_Channels?

        Srv_Path : String := AD.Full_Name (Srv_Dir);
        Srv_Name : String := AD.Simple_Name (Srv_Dir);
        Search : AD.Search_Type;
        Ch_Dir : AD.Directory_Entry_Type;
    begin
        if Srv_Name(Srv_Name'First) = '.' then
            -- TODO if not Is_Srv_Dir?
            return;
        end if;

        Iictl.Verbose_Print ("Iictl: Scan_Server: Scanning " & Srv_Name);
        AD.Start_Search (Search, Srv_Path, "");
        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Ch_Dir);
            Maintain_Channel_Connection (Srv_Dir, Ch_Dir);
        end loop;
        AD.End_Search (Search);
    end Scan_Server;

    procedure Maintain_Channel_Connection
        (Srv_Dir : AD.Directory_Entry_Type; Ch_Dir : AD.Directory_Entry_Type)
    is
        Ch_Path : String := AD.Full_Name (Ch_Dir); -- TODO unused?
        Ch_Name : String := AD.Simple_Name (Ch_Dir);
    begin
        Iictl.Verbose_Print ("Iictl: Maintain_Channel_Connection " & Ch_Path);

        if Ch_Name(Ch_Name'First) /= '#' then
            -- TODO if not Is_Ch_Dir?
            return;
        end if;

        if not Iictl.Is_Fifo_Up (AD.Full_Name (Ch_Dir)) then
            Rejoin_Channel (Srv_Dir, Ch_Dir);
        end if;
    end Maintain_Channel_Connection;

    procedure Rejoin_Channel
        (Srv_Dir : AD.Directory_Entry_Type; Ch_Dir : AD.Directory_Entry_Type)
    is
        Srv_Path : String := AD.Full_Name (Srv_Dir);
        Ch_Name : String := AD.Simple_Name (Ch_Dir);
        Srv_In : ATIO.File_Type;
    begin
        Iictl.Verbose_Print ("Iictl: Rejoin_Channel: Rejoining "
                             & AD.Simple_Name (Ch_Dir));

        ATIO.Open (Srv_In, ATIO.Out_File, Srv_Path & "/in");
        ATIO.Put_Line (Srv_In, "/join " & Ch_Name);
        ATIO.Close (Srv_In);
    end Rejoin_Channel;
end Ch_Conn;
