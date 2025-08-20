function freqRange = validateFc(fc)
%   validateFc validates the carrier frequency FC and returns the frequency
%   range as either 'FR1' or 'FR2'.

    if fc >= 410e6 && fc <= 7.125e9
        freqRange = 'FR1';
    elseif fc >= 24.25e9 && fc <= 52.6e9
        freqRange = 'FR2';
    else
        error('nr5g:invalidFreq',['Selected carrier frequency is outside '...
            'FR1 (410 MHz to 7.125 GHz) and FR2 (24.25 GHz to 52.6 GHz).']);
    end
end