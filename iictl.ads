with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Iictl is
    use type Ada.Strings.Unbounded.Unbounded_String;
    package String_Vectors is new Ada.Containers.Vectors
        (Element_Type => Ada.Strings.Unbounded.Unbounded_String,
         Index_Type => Natural);
    -- TODO rename spesific to the strings being used?

    procedure Iictl;
    procedure Verbose_Print (Msg : String);
    procedure Parse_Options;
    function Is_Fifo_Up
        (Srv_Path : in String) return Boolean;
    function Is_Integral (Text : String) return Boolean; -- TODO package util?
    function Default_Irc_Dir return Ada.Strings.Unbounded.Unbounded_String;
end Iictl;
