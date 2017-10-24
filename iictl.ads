with Ada.Strings.Unbounded;

package Iictl is
    procedure Iictl;
    procedure Parse_Options;

    function Default_Irc_Dir return Ada.Strings.Unbounded.Unbounded_String;
end Iictl;
