-- See LICENSE file for cc0 license details
with Ada.Containers.Vectors;
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions; -- TODO remove
with Ada.Strings.Unbounded; -- TODO needed?
with Ada.Text_Io;
with Iictl;
with Posix.Io;
with Posix.Process_Identification;
with Posix.Unsafe_Process_Primitives;

package body SrvCtl is
    package AD renames Ada.Directories;
    package ASU renames Ada.Strings.Unbounded; -- TODO unneeded?
    package ATIO renames Ada.Text_Io;
    package PIO renames Posix.Io;
    package PPI renames Posix.Process_Identification;
    package PUPP renames Posix.Unsafe_Process_Primitives;
    -- TODO IC Iictl.Vectors

    use type ASU.Unbounded_String; -- TODO this is ugly
    package Vector_Pkg is new Ada.Containers.Vectors
        (Natural, ASU.Unbounded_String);

    -- TODO explicit in?
    procedure Reconnect_Servers (Irc_Dir : String; Nick : String) is
        Server_List : Iictl.Vectors.Vector; -- TODO rename Directory_List?
        Process_List : Iictl.Vectors.Vector;
        -- TODO garbage collector?
    begin
        Server_List := Scan_Server_Directory (Irc_Dir);
        Process_List := Scan_Ii_Procs;
        -- TODO Respawn_Servers (Server_List, Process_List);
    end Reconnect_Servers;

    -- TODO better formatting
    procedure Maintain_Connection
        (Dir_Ent : in AD.Directory_Entry_Type;
         Nick : in String)
    is

        Srv_Path : String := AD.Full_Name (Dir_Ent); -- TODO simple_name
    begin
        if not Is_Up (Srv_Path) then
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
            Iictl.Verbose_Print ("Iictl: Spawning ii for " & Srv_Name);

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

        -- TODO reap/kill dead defuncts/zombies
    end Spawn_Client;

    function Is_Up (Srv_Path : String) Return Boolean is
        -- TODO take Posix_String?
        use type Posix.Error_Code;

        In_Path : Posix.Posix_String
                := Posix.To_Posix_String (Srv_Path & "/in");
        Fd : PIO.File_Descriptor;
    begin
        -- It's up if it's possible to open wronly without error

        -- TODO rename Is_Fifo_Up or something

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
    end Is_Up;

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
        return Iictl.Vectors.Vector
    is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
        Server_Name : ASU.Unbounded_String;
        Server_List : Iictl.Vectors.Vector;
    begin
        AD.Start_Search (Search, Irc_Dir, ""); -- TODO get dir from proc or cwd
        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);

            if Is_Srv_Dir (Dir_Ent) then
                Server_Name := ASU.To_Unbounded_String
                                   (AD.Simple_Name (Dir_Ent));
                Server_List.Append (Server_Name);
            end if;
        end loop;
        AD.End_Search (Search);

        return Server_List;
    end;

    function Scan_Ii_Procs return Iictl.Vectors.Vector is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
        Process_List : Iictl.Vectors.Vector;
    begin
        AD.Start_Search (Search, "/proc", "");
        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);
            if Is_Ii_Proc (Dir_Ent) then
                Process_List.Append (Get_Server_Name (Dir_Ent));
            end if;
        end loop;
        AD.End_Search (Search);

        -- TODO remove this loop
        for I in Integer range 0 .. Integer (Process_List.Length) - 1 loop
        ATIO.Put_Line (ASU.To_String (Process_List.Element (I)));
        end loop;

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
                    Iictl.Verbose_Print ("Iictl: Found ii: "
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

    function Get_Server_Name (Dir_Ent : AD.Directory_Entry_Type)
        return ASU.Unbounded_String
    is
        -- TODO define type for proc pid string
        File : ATIO.File_Type;
        Cmdline : ASU.Unbounded_String;
        Index : Natural := 0;
        Ret : ASU.Unbounded_String;
    begin
        ATIO.Open (File,
                   ATIO.In_File,
                   "/proc/" & AD.Simple_Name (Dir_Ent) & "/cmdline");
        Cmdline := ASU.To_Unbounded_String (ATIO.Get_Line (File));
        Index := ASU.Index (Cmdline, "-s");

        if Index = 0 then
            Ret := ASU.To_Unbounded_String ("irc.freenode.net");
            -- TODO consider default host
        else
            Ret := ASU.Unbounded_Slice (CmdLine, Index + 3, ASU.Length (Cmdline));
            -- TODO limit length of name
        end if;

        ATIO.Close (File);
        return Ret;
    end;
end SrvCtl;
