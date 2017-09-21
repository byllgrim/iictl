-- See LICENSE file for cc0 license details
with Ada.Command_Line;
with Ada.Directories;
with Ada.Strings.Unbounded;
with Ada.Text_Io; -- TODO remove
With SrvCtl;

package body Iictl is
    procedure Iictl is
        package ACL renames Ada.Command_Line;
        package ASU renames Ada.Strings.Unbounded;

        I : Integer := 1;
        Irc_Dir : String := Ada.Directories.Current_Directory;
        Nick : ASU.Unbounded_String;
        Verbose : Boolean := False;
begin
        -- TODO same opts as ii?

        -- TODO refactor to separate subprogram TODO move to Main
        -- TODO initialize I more locally
        while I <= ACL.Argument_Count loop
        begin
            if ACL.Argument (I) = "-n" then
                I := I + 1;
                Nick := ASU.To_Unbounded_String (ACL.Argument (I));
            elsif ACL.Argument (I) = "-v" then -- TODO use case
                Verbose := True;
            else
                raise CONSTRAINT_ERROR; -- TODO different exception
            end if;

            I := I + 1;
        exception
            when CONSTRAINT_ERROR =>
                Ada.Text_Io.Put_Line ("usage: " & ACL.Command_Name
                                      & " [-v]" & " [-n nick]");
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
end Iictl;
