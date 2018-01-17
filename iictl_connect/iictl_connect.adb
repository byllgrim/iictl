with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Posix.Process_Environment;

procedure Iictl_Connect is
   use Ada.Command_Line;
   use Ada.Strings.Unbounded;
   use Posix.Process_Environment;
   Dir : Unbounded_String := To_Unbounded_String (".");
begin
   if Argument_Count = 1 then -- TODO allow multiple directories
      Dir := To_Unbounded_String (Argument(1));
      -- TODO use normal String
   end if;

   Change_Working_Directory ("."); -- TODO wait until later
   -- TODO connect to all servers in Dir
end Iictl_Connect;
