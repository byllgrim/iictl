-- See LICENSE file for cc0 license details
with Ada.Command_Line;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions; -- TODO remove
with Ada.Strings.Unbounded;
with Ada.Text_Io;
with ChCtl;
with Posix.Io;
with Srv_Conn;

package body Iictl is
    package ACL renames Ada.Command_Line;
    package ASU renames Ada.Strings.Unbounded;
    package ATIO renames Ada.Text_Io;
    package PIO renames Posix.Io;

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
                               & " [-v]" & " <-n nick>");
            return;
        end;
        end loop;

        -- TODO set file offset to end of channel outs?

        if ASU.Length (Nick) = 0 then
            ATIO.Put_Line ("No nick given");
            -- TODO Print_Usage;
            return;
        end if;

        Verbose_Print ("Iictl: started");

        loop
            Srv_Conn.Reconnect_Servers (Irc_Dir, ASU.To_String (Nick));
                -- TODO rename Server_Reconnection, Connection_Ctrl, ...
            ChCtl.Rejoin_Channels (Irc_Dir);
                -- TODO rename Rejoin_Ctl or something
            -- TODO Srv_Conn.Detect_Quits;
            -- TODO ChCtl.Detect_Parts;
            delay 1.0; -- TODO remove? speed up?
        end loop;
    end Iictl;

    procedure Verbose_Print (Msg : String) is -- TODO rename Debug_Print?
    begin
        if Verbose then
            -- TODO prepend with "Iictl: "?
            ATIO.Put_Line (Msg);
            -- TODO print to stderr?
        end if;
    end Verbose_Print;

    function Is_Fifo_Up (Srv_Path : String) Return Boolean is
        -- TODO rename Is_Fifo_Up as Is_In_Fifo_Up?
        -- TODO rename Srv_Path as Dir_Path?

        -- TODO take Posix_String?
        use type Posix.Error_Code;

        In_Path : Posix.Posix_String
                := Posix.To_Posix_String (Srv_Path & "/in");
        Fd : PIO.File_Descriptor;
    begin
        -- It's up if it's possible to open wronly without error

        -- TODO Is_Pathname ()?

        -- TODO check ps environ TODO relying on FIFO is stupid: Check PIDs

        Fd := PIO.Open (In_Path, PIO.Write_Only, PIO.Non_Blocking);

        -- TODO Close
        return True;
    exception
        when Error : Posix.Posix_Error =>
            if Posix.Get_Error_Code = Posix.Enxio then
                return False; -- Fifo is down
            else
                raise Posix.Posix_Error with Exception_Message (Error);
                -- TODO better solution
            end if;
            -- TODO NO_SUCH_FILE_OR_DIRECTORY => return False;
    end Is_Fifo_Up;

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
