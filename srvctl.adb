-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Interfaces.C;

package body SrvCtl is
    package AD renames Ada.Directories;
    Package ATIO renames Ada.Text_IO;
    package ASU renames Ada.Strings.Unbounded;
    package IC renames Interfaces.C;
    -- TODO is this renaming a good idea?

    --TODO pragma Import (C, Is_Up, "is_up");

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
        Srv_Path : String := AD.Full_Name (Dir_Ent); -- TODO just Short_Name?
    begin

        --Kind := AD.Kind (Dir_Ent);
        --if AD.File_Kind'Pos (Kind)
        --  = AD.File_Kind'Pos (AD.Special_File) then
        --    -- TODO define = operator
        --    -- TODO move to Maintain_Connection
        --    Maintain_Connection (AD.Simple_Name (Dir_Ent));
        --end if;

        if Is_Up (IC.To_C (Srv_Path)) /= 1 then
            ATIO.Put_Line ("Spawning client for " & Srv_Path);
            -- TODO Spawn_Client (Name);
        else
            ATIO.Put_Line (Srv_Path & " is running"); -- TODO remove
        end if;
    end Maintain_Connection;

    function Is_Srv_Dir (Dir_Ent : AD.Directory_Entry_Type) return Boolean is
        use type AD.File_Kind;

        Name : String := AD.Simple_Name (Dir_Ent);
    begin

        if AD.Kind (Dir_Ent) /= AD.Directory then
            -- TODO move to Maintain_Connection?
            return False;
        elsif Name (Name'First) = '.' then
            -- TODO index by number?
            return False;
        -- TODO else if no */in */out
        else
            return True;
        end if;
    end Is_Srv_Dir;
end SrvCtl;
