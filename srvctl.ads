with Ada.Directories;

package SrvCtl is
    procedure Reconnect_Servers (Irc_Dir : in String);
    procedure Maintain_Connection
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type);
    function Is_Up (Srv_Path : in String) return Boolean;
    function Is_Srv_Dir
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type) return Boolean;
end SrvCtl;
