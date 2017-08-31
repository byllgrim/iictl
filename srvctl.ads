package SrvCtl is
    procedure Reconnect_Servers;
    procedure Maintain_Connection (Name : in String);
    function Is_Up (Name : in String) return Boolean;
end SrvCtl;
