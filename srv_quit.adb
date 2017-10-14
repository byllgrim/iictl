package body Srv_Quit is
    procedure Detect_Quits (Irc_Dir : String) is
    begin
        null; -- TODO detect and handle parting commands
        -- TODO for each server
            -- TODO continue reading out
                -- TODO purge if '/part'
    end Detect_Quits;
end Srv_Quit;
