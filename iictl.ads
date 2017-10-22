with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Iictl is
    use type Ada.Strings.Unbounded.Unbounded_String;
    package Unbounded_String_Vectors is new Ada.Containers.Vectors
        (Element_Type => Ada.Strings.Unbounded.Unbounded_String,
         Index_Type => Natural);
    type Unbounded_String_Vector is new Unbounded_String_Vectors.Vector with
    record
      null;
    end record;
    -- TODO use a null record

    procedure Iictl;
    procedure Verbose_Print (Msg : String);
    procedure Parse_Options;
    function Is_Fifo_Up
        (Srv_Path : in String) return Boolean;
    function Is_Integral (Text : String) return Boolean; -- TODO package util?
    function Default_Irc_Dir return Ada.Strings.Unbounded.Unbounded_String;
end Iictl;
