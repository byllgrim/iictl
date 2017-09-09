-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Exceptions; use Ada.Exceptions; -- TODO remove
with Ada.Text_IO;
with Ada.Strings.Unbounded; -- TODO needed?
with Posix.IO;

package body SrvCtl is
    package AD renames Ada.Directories;
    package ATIO renames Ada.Text_IO;
    package ASU renames Ada.Strings.Unbounded;
    package PIO renames POSIX.IO;

    procedure Reconnect_Servers (Irc_Dir : String) is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
    begin
        AD.Start_Search (Search, Irc_Dir, "");

        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);

            if Is_Srv_Dir (Dir_Ent) then
                Maintain_Connection (Dir_Ent);
            end if;
        end loop;

        AD.End_Search (Search);
    end Reconnect_Servers;

    procedure Maintain_Connection (Dir_Ent : in AD.Directory_Entry_Type) is
        Srv_Path : String := AD.Full_Name (Dir_Ent); -- TODO simple_name
    begin
        if not Is_Up (Srv_Path) then
            Spawn_Client (AD.Simple_Name (Dir_Ent));
        else
            ATIO.Put_Line (Srv_Path & " is running"); -- TODO remove
            -- TODO someone COULD be cat'ing the in file
        end if;
    end Maintain_Connection;

    procedure Spawn_Client (Srv_Name : String) is
    begin
        -- TODO don't assume cwd?

        ATIO.Put_Line ("exec: ii -s " & Srv_Name & " -n ?");
    end Spawn_Client;

    function Is_Up (Srv_Path : String) Return Boolean is
        -- TODO take POSIX_String?
        use type Posix.Error_Code;

        In_Path : Posix.POSIX_String
                := Posix.To_POSIX_String (Srv_Path & "/in");
        Fd : PIO.File_Descriptor;
    begin
        -- It's up if it's possible to open wronly without error

        -- TODO rename Is_Fifo_Up or something

        -- TODO Is_Pathname ()?

        -- TODO check ps environ

        Fd := PIO.Open (In_Path, PIO.Write_Only, PIO.Non_Blocking);

        -- TODO Close
        return True;
    exception
        when Error : Posix.POSIX_ERROR =>
            if Posix.Get_Error_Code = Posix.ENXIO then
                return False; -- Fifo is down
            else
                raise Posix.POSIX_ERROR with Exception_Message (Error);
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
