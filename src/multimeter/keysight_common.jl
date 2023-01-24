"""
    get_tc_temperature(obj::Instr{<:KeysightMultimeter})

Perform take a measurement with the probe mode set to thermocouple

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter

# Returns
- `Float64`: tc temperature
"""
function get_tc_temperature(obj::Instrument{<:KeysightMultimeter})
    units = get_temp_unit(obj)
    return f_query(obj, "MEASURE:TEMPERATURE? TC"; timeout=0) * units
end

"""
    set_tc_type(multimeter; type="K")

Sets TC Type

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter

# Keywords
- `type`: Can be E, J, K, N, R, T (Defaults to K)
"""
function set_tc_type(obj::Instrument{<:KeysightMultimeter}; type="K")
    if !(string(type) in ["E", "J", "K", "N", "R", "T"])
        error("$type must be one of [E, J, K, N, R, T]")
    end
    write(obj, "CONFIGURE:TEMPERATURE TC,$type")
end

"""
Returns voltage

# Keywords
- `type`: "DC" | "AC" (Default DC)

"""
function get_voltage(obj::Instrument{<:KeysightMultimeter}; type="DC")
    !(type in ["AC","DC"]) && error("$type not valid!\nMust be AC or DC")
    f_query(obj, "MEASURE:VOLTAGE:$type?"; timeout=0) * V
end


"""
    get_current(obj::Instr{<:KeysightMultimeter}; type="DC")

Returns current

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter

# Keywords
- `type`: "DC" | "AC" (Default DC)
"""
function get_current(obj::Instrument{<:KeysightMultimeter}; type="DC")
    !(type in ["AC","DC"]) && error("$type not valid!\nMust be AC or DC")
    f_query(obj, "MEASURE:CURRENT:$type?"; timeout=0) * A
end

"""
    get_resistance(multimeter; wire=2)
    get_resistance(multimeter; wire=4)

Returns resistance

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter

# Keywords
- `wire`: 2 | 4 (Required)
"""
function get_resistance(obj::Instrument{<:KeysightMultimeter}; wire)
    if wire == 2
        f_query(obj, "MEASURE:RESISTANCE?"; timeout=0) * Ω
    elseif wire == 4
        f_query(obj, "MEASURE:FRESISTANCE?"; timeout=0) * Ω
    else
        error("wire flag must be 2 or 4 not $wire")
    end
end

"""
    set_temp_unit_celsius(multimeter)

Sets the temperature unit to celcius

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter
"""
set_temp_unit_celsius(obj::Instrument{<:KeysightMultimeter}) =
    write(obj, "UNIT:TEMPERATURE C")

"""
    set_temp_unit_farenheit(multimeter)

Sets the temperature unit to farenheit

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter
"""
set_temp_unit_farenheit(obj::Instrument{<:KeysightMultimeter}) =
    write(obj, "UNIT:TEMPERATURE F")

"""
    set_temp_unit_kelvin(multimeter)

Sets the temperature unit to kelvin

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter
"""
set_temp_unit_kelvin(obj::Instrument{<:KeysightMultimeter}) =
    write(obj, "UNIT:TEMPERATURE K")

"""
    get_temp_unit(multimeter)

Returns set temperature unit

# Arguments
- `obj::Instr{<:KeysightMultimeter}}`: Multimeter

# Returns
- `u`: C, F or K
"""
function get_temp_unit(obj::Instrument{<:KeysightMultimeter})
   units = query(obj, "UNIT:TEMPERATURE?")
   return if units == "C"
       u"C"
   elseif units == "F"
       u"F"
   elseif units == "K"
       u"K"
   else
       error("Expected [C, F, K]. Got: $units")
   end
end


"""
    get_channel(obj::Instr{<:KeysightMultimeter})
Indicates which input terminals are selected on the front panel
Front/Rear switch. This switch is not programmable; this query reports
the position of the switch, but cannot change it.

Do not toggle the Front/Rear switch with active signals on the
terminals. This switch is not intended to be used in this way and may be damaged by high voltages or currents, possibly compromising the
instrument's safety features.

# Returns
- "FRON" or "REAR"
"""
get_channel(obj::Instrument{<:KeysightMultimeter}) =
    query(obj, "ROUTE:TERMINALS?")
