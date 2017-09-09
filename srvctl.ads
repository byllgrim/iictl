with Ada.Directories;
with Posix;

package SrvCtl is
    procedure Reconnect_Servers (Irc_Dir : in String);
    procedure Maintain_Connection
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type);
    procedure Spawn_Client (Srv_Name : String);
    function Is_Up
        (Srv_Path : String) return Boolean;
    function Is_Srv_Dir
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type) return Boolean;
    -- TODO use private?
    -- TODO sort
end SrvCtl;
