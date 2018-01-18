with Ada.Containers.Vectors;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Util is
   package String_Vectors is new Ada.Containers.Vectors
     (Element_Type => Unbounded_String,
      Index_Type => Natural);
end Util;
