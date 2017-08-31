-- See LICENSE file for cc0 license details
with Ada.Directories;
with Ada.Text_IO;
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

        --Kind := AD.Kind (Dir_Ent);
        --if AD.File_Kind'Pos (Kind)
        --   = AD.File_Kind'Pos (AD.Special_File) then
        --    --TODO define = operator
        --    --TODO move to Maintain_Connection
        --    Maintain_Connection (AD.Simple_Name(Dir_Ent));
        --end if;

        if not Is_Up (Name) then
            ATIO.Put_Line ("Spawning client for " & Name);
            -- TODO Spawn_Client (Name);
        else
            ATIO.Put_Line (Name & " is running"); --TODO remove
        end if;
    end Maintain_Connection;

    function Is_Up (Name : in String) return Boolean is
        In_File : ATIO.File_Type;
        Path : ASU.Unbounded_String; -- TODO In_File
    begin
        -- TODO Is_Open?
        Path := ASU.To_Unbounded_String (Name);
        ASU.Append (Path, "/in");

        ATIO.Put_Line ("Opening " & ASU.To_String (Path));
        ATIO.Open (In_File, ATIO.Out_File, ASU.To_String (Path), "");
        --TODO nonblocking
        --TODO catch exception. Is_Open()?
        --TODO close file

        return False; -- TODO open file, check fifo?, check ENXIO
    end Is_Up;

    function Is_Srv_Dir (Dir_Ent : AD.Directory_Entry_Type) return Boolean is
        Kind : AD.File_Kind := AD.Kind (Dir_Ent); --TODO use without variable
        Name : String := AD.Simple_Name (Dir_Ent);
    begin

        if AD.File_Kind'Pos (Kind) /= AD.File_Kind'Pos (AD.Directory) then
            --TODO define = operator
            --TODO move to Maintain_Connection?
            return False;
        elsif Name(Name'First) = '.' then
            return False;
        --TODO else if no */in */out
        else
            return True;
        end if;
    end Is_Srv_Dir;
end SrvCtl;
