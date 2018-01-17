with Ada.Command_Line;
with Ada.Strings.Unbounded;
with Connections;

procedure Iictl_Connect is
   use Ada.Command_Line;
   use Ada.Strings.Unbounded;
   use Connections;
   Ii_Dir : Unbounded_String := To_Unbounded_String (".");
begin
   if Argument_Count > 0 then -- TODO allow multiple directories
      Ii_Dir := To_Unbounded_String (Argument (1));
      -- TODO use normal String
   end if;

   Connect_Servers (To_String (Ii_Dir)); -- TODO while loop
end Iictl_Connect;
