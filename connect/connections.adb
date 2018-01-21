with Ada.Directories;

package body Connections is
   procedure Connect_Servers (Ii_Dir : String) is
      use Util.String_Vectors;
      Procs : Vector;
   begin
      Procs := Find_Ii_Procs;
      -- TODO Srv_Dirs := Find_Srv_Dirs (Ii_Dir);
      -- TODO Spawn_Ii_Procs (Procs, Srv_Dirs);
   end Connect_Servers;

   function Find_Ii_Procs return Util.String_Vectors.Vector is
      use Ada.Directories;
      use Util.String_Vectors;
      Procs : Vector;
   begin
      Set_Directory ("/proc");
      -- TODO search every /proc for ii processes
      return Procs;
   end Find_Ii_Procs;
end Connections;
