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
with Util;
-- TODO check unused withs

package body Iictl is
    package ACL renames Ada.Command_Line;
    package ASU renames Ada.Strings.Unbounded;
    package ATIO renames Ada.Text_Io;
    package PIO renames Posix.Io;
    package PPI renames Posix.Process_Identification;
    package PUD renames Posix.User_Database;
    -- TODO remove unused renames

    Irc_Dir : ASU.Unbounded_String;
        -- TODO different directories for different servers?
    Nick : ASU.Unbounded_String;
        -- TODO package globals in .ads?

    procedure Iictl is
    begin
        Parse_Options;

        -- TODO set file offset to end of channel outs?

        if ASU.Length (Nick) = 0 then
            ATIO.Put_Line ("No nick given");
            -- TODO Print_Usage;
            return;
        end if;

        Util.Verbose_Print ("Iictl: started");
        Util.Verbose_Print ("Nick = " & ASU.To_String (Nick));
        Util.Verbose_Print ("Irc_Dir = " & ASU.To_String (Irc_Dir));

        loop
            Srv_Conn.Reconnect_Servers (ASU.To_String (Irc_Dir),
                                        ASU.To_String (Nick));
                -- TODO rename Server_Reconnection, Connection_Ctrl, ...
            Ch_Conn.Rejoin_Channels (ASU.To_String (Irc_Dir));
                -- TODO rename Rejoin_Ctl or something
            Srv_Quit.Detect_Quits (ASU.To_String (Irc_Dir));
                -- TODO make Irc_Dir accessible from e.g. Iictl?
            -- TODO Ch_Conn.Detect_Parts;
            Delay 1.0; -- TODO remove? speed up? ravenclaw!
        end loop;
    end Iictl;

    procedure Parse_Options is
        I : Integer := 1;
    begin
        Irc_Dir := Default_Irc_Dir;

        -- TODO same opts as ii?
            -- [-i <irc dir>] [-s <host>] [-p <port>]
            -- [-n <nick>] [-k <password>] [-f <fullname>]

        -- TODO move to Util

        -- TODO refactor to separate subprogram TODO move to Main
        -- TODO initialize I more locally
        while I <= ACL.Argument_Count loop
        begin
            if ACL.Argument (I) = "-n" then
                I := I + 1;
                Nick := ASU.To_Unbounded_String (ACL.Argument (I));
            elsif ACL.Argument (I) = "-v" then -- TODO use case
                Util.Verbose := True;
                Util.Verbose_Print ("Iictl: Verbose printing on");
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
    end Parse_Options;

    function Default_Irc_Dir return ASU.Unbounded_String is
        use type Ada.Strings.Unbounded.Unbounded_String;

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
