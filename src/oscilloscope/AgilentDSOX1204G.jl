function set_impedance_50ohm(instr::Instrument{AgilentDSOX1204G}; chan=1)
    error("AgilentDSOX1204G impedance is fixed to 1 MΩ")
    return nothing
end
