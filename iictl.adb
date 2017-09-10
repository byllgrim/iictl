-- See LICENSE file for cc0 license details
with Ada.Command_Line;
with Ada.Directories;
with Ada.Text_IO; -- TODO remove
With SrvCtl;

procedure Iictl is
    package ACL renames Ada.Command_Line;

    I : Integer := 1;
    Irc_Dir : String := Ada.Directories.Current_Directory;
begin
    -- TODO output procedure information when -v?
    -- TODO same opts as ii?

    while I <= ACL.Argument_Count loop
    begin
        if ACL.Argument (I) = "-n" then
            I := I + 1;
            Ada.Text_IO.Put_Line ("Nickname is " & ACL.Argument (I));
        else
            raise CONSTRAINT_ERROR; -- TODO different exception
        end if;

        I := I + 1;
    exception
        when CONSTRAINT_ERROR =>
            Ada.Text_IO.Put_Line ("usage: " & ACL.Command_Name & " [-n nick]");
        return;
    end;
    end loop;

    -- TODO set file offset to end of channel outs?

    loop
        SrvCtl.Reconnect_Servers (Irc_Dir);
        -- TODO ChCtl.Rejoin_Channels;
        -- TODO SrvCtl.Detect_Quits;
        -- TODO ChCtl.Detect_Parts;
    end loop;
end Iictl;
