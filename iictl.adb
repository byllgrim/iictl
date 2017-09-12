-- See LICENSE file for cc0 license details
with Ada.Command_Line;
with Ada.Directories;
with Ada.Strings.Unbounded;
with Ada.Text_IO; -- TODO remove
With SrvCtl;

procedure Iictl is
    package ACL renames Ada.Command_Line;
    package ASU renames Ada.Strings.Unbounded;

    I : Integer := 1;
    Irc_Dir : String := Ada.Directories.Current_Directory;
    Nick : ASU.Unbounded_String;
begin
    -- TODO output procedure information when -v?
    -- TODO same opts as ii?

    -- TODO make separate subprogram
    while I <= ACL.Argument_Count loop
    begin
        if ACL.Argument (I) = "-n" then
            I := I + 1;
            Nick := ASU.To_Unbounded_String (ACL.Argument (I));
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
        SrvCtl.Reconnect_Servers (Irc_Dir, ASU.To_String (Nick));
        -- TODO ChCtl.Rejoin_Channels;
        -- TODO SrvCtl.Detect_Quits;
        -- TODO ChCtl.Detect_Parts;
    end loop;
end Iictl;
