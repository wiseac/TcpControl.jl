function set_impedance_50ohm(instr::Instrument{T}; chan=1) where {T <: AgilentDSOX1204G}
    error(string(T) * " impedance is fixed to 1 MΩ")
    return nothing
end
