with Ada.Directories;

package SrvCtl is
    procedure Reconnect_Servers;
    procedure Maintain_Connection (Name : in String);
    function Is_Up (Name : in String) return Boolean;
    function Is_Srv_Dir
        (Dir_Ent : Ada.Directories.Directory_Entry_Type) return Boolean;
end SrvCtl;
