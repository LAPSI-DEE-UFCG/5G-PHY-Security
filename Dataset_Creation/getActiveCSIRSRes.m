function csirsTransmitted = getActiveCSIRSRes(carrier,csirs)
%   getActiveCSIRSRes returns a binary vector indicating the presence of
%   all CSI-RS resources in a specified slot, given the carrier
%   configuration object CARRIER and CSI-RS configuration object CSIRS.

    % Extract the following properties of carrier
    NSlotA        = carrier.NSlot;          % Absolute slot number
    NFrameA       = carrier.NFrame;         % Absolute frame number
    SlotsPerFrame = carrier.SlotsPerFrame;  % Number of slots per frame
    
    % Calculate the appropriate frame number (0...1023) based on the
    % absolute slot number
    NFrameR = mod(NFrameA + fix(NSlotA/SlotsPerFrame),1024);
    % Relative slot number (0...slotsPerFrame-1)
    NSlotR = mod(NSlotA,SlotsPerFrame);
    
    % Loop over the number of CSI-RS resources
    numCSIRSRes = numel(csirs.CSIRSType);
    csirsTransmitted = zeros(1,numCSIRSRes);
    csirs_struct = validateConfig(csirs);
    for resIdx = 1:numCSIRSRes
        % Extract the CSI-RS slot periodicity and offset
        if isnumeric(csirs_struct.CSIRSPeriod{resIdx})
            Tcsi_rs = csirs_struct.CSIRSPeriod{resIdx}(1);
            Toffset = csirs_struct.CSIRSPeriod{resIdx}(2);
        else
            if strcmpi(csirs_struct.CSIRSPeriod{resIdx},'on')
                Tcsi_rs = 1;
            else
                Tcsi_rs = 0;
            end
            Toffset = 0;
        end
        
        % Check for the presence of CSI-RS, based on slot periodicity and offset
        if (Tcsi_rs ~= 0) && (mod(SlotsPerFrame*NFrameR + NSlotR - Toffset, Tcsi_rs) == 0)
            csirsTransmitted(resIdx) = 1;
        end
    end
end
