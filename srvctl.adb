-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions; -- TODO remove
with Ada.Text_Io;
with Ada.Strings.Unbounded; -- TODO needed?
with Posix.Io;
with Posix.Process_Identification;
with Posix.Unsafe_Process_Primitives;

package body SrvCtl is
    package AD renames Ada.Directories;
    package ATIO renames Ada.Text_Io;
    package ASU renames Ada.Strings.Unbounded; -- TODO unneeded?
    package PIO renames Posix.Io;
    package PPI renames Posix.Process_Identification;
    package PUPP renames Posix.Unsafe_Process_Primitives;

    -- TODO explicit in?
    procedure Reconnect_Servers (Irc_Dir : String; Nick : String) is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
    begin
        AD.Start_Search (Search, Irc_Dir, "");

        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);

            if Is_Srv_Dir (Dir_Ent) then
                Maintain_Connection (Dir_Ent, Nick);
            end if;
        end loop;

        AD.End_Search (Search);
    end Reconnect_Servers;

    -- TODO better formatting
    procedure Maintain_Connection
        (Dir_Ent : in AD.Directory_Entry_Type;
         Nick : in String) is

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
            ATIO.Put_Line ("exec: ii -s " & Srv_Name & " -n " & Nick);
                -- TODO remove
            Posix.Append (Argv, Cmd);
            Posix.Append (Argv, "-s");
            Posix.Append (Argv, Posix.To_Posix_String(Srv_Name));
            if Nick'Length /= 0 then
                Posix.Append (Argv, "-n");
                Posix.Append (Argv, Posix.To_Posix_String(Nick));
            end if;
            -- TODO refactor
            PUPP.Exec_Search (Cmd, Argv);
        else -- Old process
            null; -- TODO wait for new process to launch ii
        end if;

        loop
            null; -- TODO remove
        end loop;

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
        when Error : Posix.Posix_ERROR =>
            if Posix.Get_Error_Code = Posix.ENXIo then
                return False; -- Fifo is down
            else
                raise Posix.Posix_ERROR with Exception_Message (Error);
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
end SrvCtl;
