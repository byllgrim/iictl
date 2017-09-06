with Ada.Directories;
with Interfaces.C;

package SrvCtl is
    procedure Reconnect_Servers (Irc_Dir : in String);
    procedure Maintain_Connection
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type);
    function Is_Up
        (Srv_Path : in Interfaces.C.char_array) return Integer;
    pragma Import (C, Is_Up, "is_up"); -- TODO move
    function Is_Srv_Dir
        (Dir_Ent : in Ada.Directories.Directory_Entry_Type) return Boolean;
end SrvCtl;
