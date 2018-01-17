with Posix;
with Posix.Process_Environment;

package body Connections is
   procedure Connect_Servers (Ii_Dir : String) is
      use Posix;
      use Posix.Process_Environment;
   begin
      Change_Working_Directory (To_Posix_String (Ii_Dir));
         -- TODO wait until later
      -- TODO Procs := Find_Ii_Procs;
      -- TODO Srv_Dirs := Find_Srv_Dirs (Ii_Dir);
      -- TODO Spawn_Ii_Procs (Procs, Srv_Dirs);
   end Connect_Servers;
end Connections;
