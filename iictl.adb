-- See LICENSE file for cc0 license details
with Ada.Command_Line;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions; -- TODO remove
with Ada.Strings.Unbounded;
with Ada.Text_Io;
with Ch_Conn;
with Posix.Io;
with Posix.Process_Identification;
with Posix.User_Database;
with Srv_Conn;
with Srv_Quit;

package body Iictl is
    package ACL renames Ada.Command_Line;
    package ASU renames Ada.Strings.Unbounded;
    package ATIO renames Ada.Text_Io;
    package PIO renames Posix.Io;
    package PPI renames Posix.Process_Identification;
    package PUD renames Posix.User_Database;

    Verbose : Boolean := False; -- TODO make private or something

    procedure Iictl is
        I : Integer := 1;
        Irc_Dir : ASU.Unbounded_String := Default_Irc_Dir;
            -- TODO different directories for different servers?
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
            elsif ACL.Argument (I) = "-i" then
                I := I + 1;
                Irc_Dir := ASU.To_Unbounded_String (ACL.Argument (I));
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
        Verbose_Print ("Nick = " & ASU.To_String (Nick));
        Verbose_Print ("Irc_Dir = " & ASU.To_String (Irc_Dir));

        loop
            Srv_Conn.Reconnect_Servers (ASU.To_String (Irc_Dir),
                                        ASU.To_String (Nick));
                -- TODO rename Server_Reconnection, Connection_Ctrl, ...
            Ch_Conn.Rejoin_Channels (ASU.To_String (Irc_Dir));
                -- TODO rename Rejoin_Ctl or something
            Srv_Quit.Detect_Quits (ASU.To_String (Irc_Dir));
                -- TODO make Irc_Dir accessible from e.g. Iictl?
            -- TODO Ch_Conn.Detect_Parts;
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

    function Default_Irc_Dir return ASU.Unbounded_String is
        Uid : PPI.User_Id;
        Db_Item : PUD.User_Database_Item;
        -- TODO Home_Dir : Posix.Posix_String
        Home_Dir : ASU.Unbounded_String;
    begin
        Uid := PPI.Get_Effective_User_ID;
        Db_Item := PUD.Get_User_Database_Item (Uid);
        --Home_Dir := PUD.Initial_Directory_Of (Db_Item);
        Home_Dir := ASU.To_Unbounded_String (
                        Posix.To_String (
                            PUD.Initial_Directory_Of (Db_Item)));

        --return ASU.To_Unbounded_String (Posix.To_String (Home_Dir) & "/irc");
        return Home_Dir & ASU.To_Unbounded_String ("/irc");
    end Default_Irc_Dir;
end Iictl;
