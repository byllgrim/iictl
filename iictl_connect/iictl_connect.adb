with Ada.Command_Line;
with Ada.Strings.Unbounded;

procedure Iictl_Connect is
   use Ada.Command_Line;
   use Ada.Strings.Unbounded;
   Dir : Unbounded_String := To_Unbounded_String (".");
begin
   if Argument_Count = 1 then
      -- TODO allow multiple directories?
      Dir := To_Unbounded_String (Argument(1));
      -- TODO use normal String
   end if;

   -- TODO connect to all servers in Dir
end Iictl_Connect;
