-- See LICENSE file for cc0 license details
with Ada.Command_Line;
with Ada.Directories;
with Ada.Strings.Unbounded;
with Ada.Text_Io;
With SrvCtl;

package body Iictl is
    package ACL renames Ada.Command_Line;
    package ASU renames Ada.Strings.Unbounded;
    package ATIO renames Ada.Text_Io;

    Verbose : Boolean := False; -- TODO make private or something

    procedure Iictl is
        I : Integer := 1;
        Irc_Dir : String := Ada.Directories.Current_Directory;
            -- TODO different directories for different servers
        Nick : ASU.Unbounded_String;
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
                Verbose_Print ("Iictl: Verbose printing on");
            else
                raise CONSTRAINT_ERROR; -- TODO different exception
            end if;

            I := I + 1;
        exception
            when CONSTRAINT_ERROR =>
                ATIO.Put_Line ("usage: " & ACL.Command_Name
                               & " [-v]" & " [-n nick]");
            return;
        end;
        end loop;

        -- TODO set file offset to end of channel outs?

        Verbose_Print ("Iictl: Nick is '"
                       & ASU.To_String(Nick) & "'"); -- TODO if nick length
        Verbose_Print ("Iictl: started");

        loop
            SrvCtl.Reconnect_Servers (Irc_Dir, ASU.To_String (Nick));
            -- TODO ChCtl.Rejoin_Channels;
            -- TODO SrvCtl.Detect_Quits;
            -- TODO ChCtl.Detect_Parts;
        end loop;
    end Iictl;

    procedure Verbose_Print (Msg : String) is -- TODO rename
    begin
        if Verbose then
            -- TODO prepend with "Iictl: "?
            ATIO.Put_Line (Msg);
            -- TODO print to stderr?
        end if;
    end Verbose_Print;

    function Is_Integral (Text : String) return Boolean is
        Dummy : Integer;
    begin
        Dummy := Integer'Value (Text);
        return True;
    exception
        when others =>
            return False;
    end;
end Iictl;
