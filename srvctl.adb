-- See LICENSE file for cc0 license details
with Ada.Containers.Vectors;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions; -- TODO remove
with Ada.Strings;
with Ada.Strings.Maps.Constants;
with Ada.Strings.Unbounded; -- TODO needed?
with Ada.Text_Io;
with Iictl;
with Posix.Io;
with Posix.Process_Identification;
with Posix.Process_Primitives;
with Posix.Unsafe_Process_Primitives; -- TODO is there safe fork?

package body SrvCtl is
    package AD renames Ada.Directories;
    package AS renames Ada.Strings;
    package ASMC renames Ada.Strings.Maps.Constants;
    package ASU renames Ada.Strings.Unbounded; -- TODO unneeded?
    package ATIO renames Ada.Text_Io;
    package IV renames Iictl.Vectors;
    package PIO renames Posix.Io;
    package PPI renames Posix.Process_Identification;
    package PPP renames Posix.Process_Primitives;
    package PUPP renames Posix.Unsafe_Process_Primitives;
    -- TODO remove unused packages

    use type ASU.Unbounded_String; -- TODO this is ugly
    package Vector_Pkg is new Ada.Containers.Vectors
        (Natural, ASU.Unbounded_String);

    -- TODO explicit in?
    procedure Reconnect_Servers (Irc_Dir : String; Nick : String) is
        Server_List : IV.Vector; -- TODO rename Directory_List?
        Process_List : IV.Vector;
        -- TODO garbage collector?
    begin
        Reap_Defunct_Procs;
        Server_List := Scan_Server_Directory (Irc_Dir);
        Process_List := Scan_Ii_Procs;
        Respawn_Clients (Server_List, Process_List);
    end Reconnect_Servers;

    -- TODO better formatting
    procedure Maintain_Connection
        (Dir_Ent : in AD.Directory_Entry_Type;
         Nick : in String)
    is

        Srv_Path : String := AD.Full_Name (Dir_Ent); -- TODO simple_name
    begin
        if not Iictl.Is_Fifo_Up (Srv_Path) then
            Spawn_Client (AD.Simple_Name (Dir_Ent), Nick);
        else
            ATIO.Put_Line (Srv_Path & " is running"); -- TODO remove
            -- TODO someone COULD be cat'ing the in file
        end if;
    end Maintain_Connection;

    procedure Spawn_Client (Srv_Name : String; Nick : String) is
        use type PPI.Process_Id;

        Cmd : Posix.Filename := "ii";
        Argv : Posix.Posix_String_List;
    begin
        -- TODO don't assume cwd?

        -- TODO check if Nick is given

        if PUPP.Fork = PPI.Null_Process_Id then -- New process
            Iictl.Verbose_Print ("Iictl: Spawn_Client: " & Srv_Name);

            Posix.Append (Argv, Cmd);
            Posix.Append (Argv, "-s");
            Posix.Append (Argv, Posix.To_Posix_String(Srv_Name));
            if Nick'Length /= 0 then
                Posix.Append (Argv, "-n");
                Posix.Append (Argv, Posix.To_Posix_String(Nick));
            end if;
            -- TODO exec with ii -i prefix
            -- TODO refactor
            PUPP.Exec_Search (Cmd, Argv);
        else -- Old process
            null; -- TODO wait for new process to launch ii
        end if;

        -- TODO check return or exception

        -- TODO keep track of PID?
    end Spawn_Client;

    procedure Reap_Defunct_Procs is
        use type Posix.Error_Code;

        Status : PPP.Termination_Status;
    begin
        loop -- TODO upper limit
            PPP.Wait_For_Child_Process (Status => Status, Block => False);
            -- TODO use more named parameters

            --if Status = didnotreap then
            if not PPP.Status_Available (Status) then
                exit;
            end if;

            Iictl.Verbose_Print ("Iictl: Reap_Defunct_Procs: Reaped one child");
        end loop;
    exception
        when Error : Posix.Posix_Error =>
            if Posix.Get_Error_Code = Posix.No_Child_Process then
                ATIO.Put_Line ("No child yet!"); -- TODO clean this
            else
                raise Posix.Posix_Error with Exception_Message (Error);
            end if;
    end;

    procedure Respawn_Clients (Server_List : IV.Vector;
                               Process_List : IV.Vector)
    is
    begin
        -- TODO use iterator in other functions as well
        Server_Loop:
        for S of Server_List loop
            if Process_List.Find_Index (S) = IV.No_Index then
                Iictl.Verbose_Print ("Iictl: Respawn_Clients: No proc "
                                     & ASU.To_String (S));
                Spawn_Client (ASU.To_String (S), "nick");
                -- TODO Send name as Unbounded_String
                -- TODO get nick and all other flags
            else
                Iictl.Verbose_Print ("Iictl: Respawn_Clients: Found proc: "
                                     & ASU.To_String (S));
                -- TODO remove
            end if;
        end loop Server_Loop;
    end;

    function Is_Srv_Dir (Dir_Ent : AD.Directory_Entry_Type) return Boolean is
        use type AD.File_Kind;

        Name : String := AD.Simple_Name (Dir_Ent);
    begin
        if AD.Kind (Dir_Ent) /= AD.Directory then
            return False;
        elsif Name (Name'First) = '.' then
            return False;
        -- TODO else if no */in */out
        else
            return True;
        end if;
    end Is_Srv_Dir;

    function Scan_Server_Directory (Irc_Dir : in String)
        return IV.Vector
    is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
        Server_Name : ASU.Unbounded_String;
        Server_List : IV.Vector;
    begin
        AD.Start_Search (Search, Irc_Dir, ""); -- TODO get dir from proc or cwd
        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);

            if Is_Srv_Dir (Dir_Ent) then
                Server_Name := ASU.To_Unbounded_String
                                   (AD.Simple_Name (Dir_Ent));
                Server_List.Append (Server_Name);
                Iictl.Verbose_Print ("Iictl: Scan_Server_Directory: found "
                                     & ASU.To_String (Server_Name));
            end if;
        end loop;
        AD.End_Search (Search);

        return Server_List;
    end;

    function Scan_Ii_Procs return IV.Vector is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
        Process_List : IV.Vector;
        Server_Name : ASU.Unbounded_String;
    begin
        AD.Start_Search (Search, "/proc", "");
        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);
            if Is_Ii_Proc (Dir_Ent) then
                Server_Name := Get_Server_Name (Dir_Ent);
                Iictl.Verbose_Print ("Iictl: Scan_Ii_Procs: Found "
                                     & ASU.To_String (Server_Name));
                Process_List.Append (Server_Name);
            end if;
        end loop;
        AD.End_Search (Search);

        return Process_List;
    end;

    function Is_Ii_Proc (Dir_Ent : AD.Directory_Entry_Type) return Boolean is
        Dir_Name : String := AD.Simple_Name (Dir_Ent);
        File : ATIO.File_Type;
        Cmdline : ASU.Unbounded_String;
        Ret : Boolean := False;
    begin
        if not Iictl.Is_Integral (Dir_Name) then
            return False;
        end if;

        ATIO.Open (File, ATIO.In_File, "/proc/" & Dir_Name & "/cmdline");
        Cmdline := ASU.To_Unbounded_String (ATIO.Get_Line (File));

        -- TODO check only pids for current user

        --for I in Integer range 1 .. Cmdline.Length loop
        -- TODO I = 0 .. length
        for I in Integer range 1 .. ASU.Length (Cmdline) loop
            --if Cmdline.Element (I) = Character'Val (0) then
            if ASU.Element (Cmdline, I) = Character'Val (0) then
                if ASU.Element (Cmdline, I - 1) /= 'i' then
                    ret := False;
                elsif ASU.Element (Cmdline, I - 2) /= 'i' then
                    ret := False;
                else
                    Iictl.Verbose_Print ("Iictl: Is_Ii_Proc: found "
                                          & ASU.To_String (Cmdline));
                    ret := True;
                end if;

                -- TODO other programs ending in ii?
                -- TODO check "*/ii" or "^ii"

                goto Exit_Is_Ii_Proc;
            end if;
            -- TODO non null-terminated cmdline
        end loop;
        -- TODO refactor

        Ret := False; -- Cmdline was not null-terminated

    <<Exit_Is_Ii_Proc>>
        ATIO.Close (File);
        return Ret;
    exception
        when ATIO.End_Error =>
            -- TODO goto Exit_Is_Ii_Proc
            ATIO.Close (File);
            return False;
    end;

    -- TODO rename Get_Server_Flags to get host, nick, port etc
    function Get_Server_Name (Dir_Ent : AD.Directory_Entry_Type)
        return ASU.Unbounded_String
    is
        -- TODO define type for proc pid string
        File : ATIO.File_Type;
        Cmdline : ASU.Unbounded_String;
        Flag_First : Natural := 0; -- TODO rename Flag_Start?
        Ctrl_First : Positive;
        Ctrl_Last : Natural;
        Ret : ASU.Unbounded_String;
        Null_Char : ASU.Unbounded_String;
    begin
        ATIO.Open (File,
                   ATIO.In_File,
                   "/proc/" & AD.Simple_Name (Dir_Ent) & "/cmdline");
        Cmdline := ASU.To_Unbounded_String (ATIO.Get_Line (File));

        Flag_First := ASU.Index (Cmdline, "-s");
        if Flag_First = 0 then
            Ret := ASU.To_Unbounded_String ("irc.freenode.net");
            -- TODO consider default host
        else
            ASU.Find_Token (Cmdline, ASMC.Control_Set, Flag_First + 3,
                            AS.Inside, Ctrl_First, Ctrl_Last);
            if Ctrl_Last = 0 then
                Ctrl_Last := ASU.Length (Cmdline);
            end if;

            Ret := ASU.Unbounded_Slice (CmdLine, Flag_First + 3, Ctrl_Last - 1);
        end if;

        ATIO.Close (File);
        Iictl.Verbose_Print ("Iictl: Get_Server_Name: found name "
                             & ASU.To_String (Ret));
        return Ret;
    end;
end SrvCtl;
