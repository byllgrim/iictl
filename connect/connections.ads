with Util;

package Connections is
   procedure Connect_Servers (Ii_Dir : String);
   function Find_Ii_Procs return Util.String_Vectors.Vector;
      -- TODO more elegant handling of names
end Connections;
