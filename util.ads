with Ada.Containers.Vectors;
With Ada.Strings.Unbounded;

package Util is
    -- TODO separate further into specialized packages?
    -- TODO make child package of Iictl?

    Verbose : Boolean := False;
        -- TODO make private or something. Util.Set_Verbose?

    use type Ada.Strings.Unbounded.Unbounded_String;
    package Unbounded_String_Vectors is new Ada.Containers.Vectors
        (Element_Type => Ada.Strings.Unbounded.Unbounded_String,
         Index_Type => Natural);
    type Unbounded_String_Vector is new Unbounded_String_Vectors.Vector
        with null record;

    procedure Verbose_Print (Msg : String);

    function Is_Fifo_Up (Srv_Path : in String) return Boolean;
        -- TODO rename Is_Fifo_Down? Avoid double negatives
    function Is_Integral (Text : String) return Boolean; -- TODO package util?
end Util;
