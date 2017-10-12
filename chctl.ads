with Ada.Directories;

package ChCtl is
    procedure Rejoin_Channels (Irc_Dir : String);
    procedure Scan_Server (Srv_Dir : Ada.Directories.Directory_Entry_Type);
    procedure Maintain_Channel_Connection
        (Srv_Dir : Ada.Directories.Directory_Entry_Type;
         Ch_Dir : Ada.Directories.Directory_Entry_Type);
    procedure Rejoin_Channel
        (Srv_Dir : Ada.Directories.Directory_Entry_Type;
         Ch_Dir : Ada.Directories.Directory_Entry_Type);
end ChCtl;
