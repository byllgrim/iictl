with Ada.Directories;
with Ada.Strings.Unbounded;
with Iictl;
with Posix;
with Util;

package Srv_Conn is
    -- TODO rename Server_Reconnection or something?
    procedure Reconnect_Servers (Irc_Dir : in String; Nick : in String);
    procedure Maintain_Connection
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type;
         Nick : in String);
    procedure Spawn_Client (Srv_Name : in String; Nick : in String);
    procedure Respawn_Clients (Server_List : Util.Unbounded_String_Vector;
                               Process_List : Util.Unbounded_String_Vector);
    procedure Reap_Defunct_Procs;

    function Is_Srv_Dir
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type) return Boolean;
    -- TODO use private?
    function Scan_Server_Directory (Irc_Dir : in String)
        return Util.Unbounded_String_Vector;
    function Scan_Ii_Procs return Util.Unbounded_String_Vector;
    -- TODO sort
    function Is_Ii_Proc (Dir_Ent : in Ada.Directories.Directory_Entry_Type)
        return Boolean;
    function Get_Server_Name (Dir_Ent : in Ada.Directories.Directory_Entry_Type)
        return Ada.Strings.Unbounded.Unbounded_String;
end Srv_Conn;
