"""
    enable_output(obj::Instr{<:AgilentSourceMeasurementUnit})

Parameters:

Supported Instruments:

Returns:
    Nothing
"""
enable_output(obj::Instr{<:AgilentSourceMeasurementUnit}) = write(obj, ":OUTP ON")
disable_output(obj::Instr{<:AgilentSourceMeasurementUnit}) = write(obj, ":OUTP OFF")
set_voltage_mode(obj::Instr{<:AgilentSourceMeasurementUnit}) = write(obj, ":SOUR:FUNC")


"""
    set_measurement_mode(obj::Instr{<:AgilentSourceMeasurementUnit};
        current=false, voltage=false, resistance=false
        )
"""
function set_measurement_mode(obj::Instr{<:AgilentSourceMeasurementUnit};
    current=false, voltage=false, resistance=false
    )
    mode = ""
    current && add_mode!(mode, "CURR")
    voltage && add_mode!(mode, "VOLT")
    resistance && add_mode!(mode, "RES")
    isempty(mode) && error("The mode was empty. You must set one or more of the input arguments: current, voltage, and resistance to true.")
    write(obj, ":SOUR:FUNC $(mode)")
    return nothing
end

function add_mode!(buffer, mode)
    isempty(buffer) ? pre = "\"" : pre = ",\""
    post = "\""
    push!(buffer, pre*mode*post)
    return nothing
end

#=
TODO - Functions to implement:
- [`set_source_mode`](@ref)
- [`set_current_or_voltage`](@ref)
- [`set_limit`](@ref)
- [`get_measurement`](@ref)
- [`enable_autorange`](@ref)
- [`disable_autorange`](@ref)
- [`set_measurement_time`](@ref)
- [`set_measurement_time`](@ref)
=#
