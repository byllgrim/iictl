-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with POSIX.IO;

package body SrvCtl is
    package AD renames Ada.Directories;
    Package ATIO renames Ada.Text_IO;
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
            ATIO.Put_Line ("Spawning client for " & Srv_Path);
            -- TODO Spawn_Client (Name);
        else
            ATIO.Put_Line (Srv_Path & " is running"); -- TODO remove
            -- TODO someone COULD be cat'ing the in file
        end if;
    end Maintain_Connection;

    function Is_Up (Srv_Path : String) Return Boolean is
    begin
        -- TODO rename Is_Fifo_Up or something
        -- TODO PIO.Open (
        return False;
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
