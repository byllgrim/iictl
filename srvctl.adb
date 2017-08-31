-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;
with Ada.Sequential_IO;
with Ada.Strings.Unbounded;

package body SrvCtl is
    package AD renames Ada.Directories;
    Package ATIO renames Ada.Text_IO;
    package ASU renames Ada.Strings.Unbounded;
    -- TODO is this renaming a good idea?

    procedure Reconnect_Servers is
        Search : AD.Search_Type;
        Dir_Ent : AD.Directory_Entry_Type;
    begin
        AD.Start_Search (Search, ".", "");
        -- TODO don't assume "." is correct dir?

        while AD.More_Entries (Search) loop
            AD.Get_Next_Entry (Search, Dir_Ent);

            if Is_Srv_Dir (Dir_Ent) then
                Maintain_Connection (AD.Simple_Name(Dir_Ent));
            end if;
        end loop;

        AD.End_Search (Search);
    end Reconnect_Servers;

    procedure Maintain_Connection (Name : in String) is
        -- TODO get Dir_Ent as input?
    begin
        --TODO check name
        if Name(Name'First) = '.' then
            return;
        end if;

        --Kind := AD.Kind (Dir_Ent);
        --if AD.File_Kind'Pos (Kind)
        --   = AD.File_Kind'Pos (AD.Special_File) then
        --    --TODO define = operator
        --    --TODO move to Maintain_Connection
        --    Maintain_Connection (AD.Simple_Name(Dir_Ent));
        --end if;

        if not Is_Up (Name) then
            ATIO.Put_Line ("Fifo not up");
            -- TODO Spawn_Client (Name);
        end if;
        ATIO.Put_Line ("Mainting " & Name); -- TODO remove
    end Maintain_Connection;

    function Is_Up (Name : in String) return Boolean is
        package Irc_IO is new Ada.Sequential_IO (String);
        File : Irc_IO.File_Type;
        Relative_Path : ASU.Unbounded_String; -- TODO In_File
    begin
        -- TODO Is_Open?
        Relative_Path := ASU.To_Unbounded_String (Name);
        ASU.Append (Relative_Path, "/in");

        ATIO.Put_Line ("Chk " & ASU.To_String (Relative_Path));

        return True; -- TODO open file, check fifo?, check ENXIO
    end Is_Up;

    function Is_Srv_Dir (Dir_Ent : AD.Directory_Entry_Type) return Boolean is
        Kind : AD.File_Kind;
    begin
        Kind := AD.Kind (Dir_Ent); --TODO use without variable
        if AD.File_Kind'Pos (Kind) /= AD.File_Kind'Pos (AD.Directory) then
            --TODO define = operator
            --TODO move to Maintain_Connection?
            return False;
        --TODO else if ".." etc
        --TODO else if no */in */out
        else
            return True;
        end if;
    end Is_Srv_Dir;
end SrvCtl;
