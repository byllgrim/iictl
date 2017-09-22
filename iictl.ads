with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;

package Iictl is
    use type Ada.Strings.Unbounded.Unbounded_String;
    package Vectors is new Ada.Containers.Vectors
        (Natural, Ada.Strings.Unbounded.Unbounded_String);
        -- TODO rename String_Vectors?

    procedure Iictl;
    procedure Verbose_Print (Msg : String);
end Iictl;
