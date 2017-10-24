with Ada.Exceptions; use Ada.Exceptions; -- TODO clean
with Ada.Text_Io;
with Posix;
with Posix.Io;

package body Util is
    package ATIO renames Ada.Text_Io;
    package PIO renames Posix.Io;

    procedure Verbose_Print (Msg : String) is -- TODO rename Debug_Print?
    begin
        -- TODO define type for severity? Info, Debug, Warning, Error?

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
end Util;
