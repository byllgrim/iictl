with Ada.Directories;

package ChCtl is
    procedure Rejoin_Channels (Irc_Dir : String);
    procedure Scan_Server (Dir_Ent : Ada.Directories.Directory_Entry_Type);
end ChCtl;
