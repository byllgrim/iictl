-- See LICENSE file for cc0 license details
with Ada.Text_IO;
With SrvCtl;

procedure Iictl is
begin
    -- TODO output procedure information when -v?

    loop
        SrvCtl.Reconnect_Servers;
        -- TODO ChCtl.Rejoin_Channels;
        -- TODO SrvCtl.Detect_Quits;
        -- TODO ChCtl.Detect_Parts;
    end loop;
end Iictl;
