with Ada.Directories;
with Iictl;
with Posix;

package SrvCtl is
    procedure Reconnect_Servers (Irc_Dir : in String; Nick : in String);
    procedure Maintain_Connection
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type;
         Nick : in String);
    procedure Spawn_Client (Srv_Name : in String; Nick : in String);
    function Is_Up
        (Srv_Path : in String) return Boolean;
    function Is_Srv_Dir
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type) return Boolean;
    -- TODO use private?
    function Scan_Server_Directory (Irc_Dir : in String)
        return Iictl.Vectors.Vector;
    function Scan_Ii_Procs return Iictl.Vectors.Vector;
    -- TODO sort
end SrvCtl;
