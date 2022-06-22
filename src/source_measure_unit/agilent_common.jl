"""
    enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will enable an output channel of a device.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":OUTP$channel ON")

"""
    disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will disable an output channel of a device.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":OUTP$channel OFF")

"""
    set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will set th selected channel as a voltage source.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":SOUR$channel:FUNC:MODE VOLT")

"""
set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will set the selected channel's as a current source.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":SOUR$channel:FUNC:MODE CURR")

"""
    set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::Unitful.Current; channel = 1)

    This will set the selected channel's output current.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - current
        - as described in Unitful Package
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::Unitful.Current; channel = 1) = write(obj, ":SOUR$channel:CURR $(raw(current))")

"""
    set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::String; channel = 1)

    This will set the selected channel's output current.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - current
        - "MIN" | "MAX" | "DEF" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
function set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::String = "DEF" ;channel = 1)
    verify_value_specifier(current)
    write(obj, ":SOUR$channel:CURR $current")
end

"""
    set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Unitful.Voltage; channel = 1)

    This will set the selected channel's output voltage.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - voltage
        - as described in Unitful Package
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Unitful.Voltage; channel = 1) = write(obj, ":SOUR$channel:VOLT $(raw(voltage))")

"""
set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::String; channel = 1)

    This will set the selected channel's output voltage.

    Parameters:
    - obj
         - must be a Source Measure Unit Instrument
    - voltage
        - "MIN" | "MAX" | "DEF" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
"""
function set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::String = "DEF" ; channel = 1)
    verify_value_specifier(voltage)
    write(obj, ":SOUR$channel:VOLT $voltage")
end

"""
    set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::Unitful.Current; channel = 1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative current.

    Parameters:
    - obj
         - must be a Source Measure Unit Instrument
    - current
        - as described in Unitful Package
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
"""
set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::Unitful.Current; channel = 1) = write(obj, ":SENS$channel:CURR:PROT $(raw(current))")

"""
    set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::String; channel = 1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative current.

    Parameters:
    - obj
         - must be a Source Measure Unit Instrument
    - current
        - "MIN" | "MAX" | "DEF" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
"""
function set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::String = "DEF" ; channel = 1)
    verify_value_specifier(current)
    write(obj, ":SENS$channel:CURR:PROT $current")
end

"""
    set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Unitful.Voltage; channel = 1)

    This will set the selected channel's output voltage limit. The limit is applied to both positive and negative voltage.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - voltage
        - as described in Unitful Package
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
"""
set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Unitful.Voltage; channel = 1) = write(obj, ":SENS$channel:VOLT:PROT $(raw(voltage))")

"""
    set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::String = "DEF" ; channel = 1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative voltage.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - voltage
        - "MIN" | "MAX" | "DEF" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
"""
function set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::String = "DEF" ; channel = 1)
    verify_value_specifier(voltage)
    write(obj, ":SENS$channel:VOLT:PROT $voltage")
end


"""
    set_measurement_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    chan= 1, current=false, voltage=false, resistance=false
    )

    This will enable the selected channel's specified measurement functions.
    Enabling resistance will enable voltage and current measurement modes as well.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - voltage
        - true | false (Default)
    - current
        - true | false (Default)
    - resistance
        - true | false (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
"""
function set_measurement_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    voltage=false, current=false, resistance=false, channel=1
    )

    mode = String[]
    voltage && add_mode!(mode, "VOLT")
    current && add_mode!(mode, "CURR")
    resistance && add_mode!(mode, "RES")
    mode = join(mode)

    isempty(mode) && error("The mode was empty. You must set one or more of the input arguments: current, voltage, and resistance to true.")
    write(obj, ":SENS$channel:FUNC:OFF:ALL")
    write(obj, ":SENS$channel:FUNC $mode")
    return nothing
end

function add_mode!(buffer, mode)
    isempty(buffer) ? pre = "\"" : pre = ",\""
    post = "\""
    push!(buffer, pre*mode*post)
    return nothing
end

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}, type="VOLT"; channel=1)

    Executes a spot (one-shot) measurement and returns the measurement result data.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - type
        - "CURR" | "RES" | "VOLT" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}, type="VOLT"; channel=1)
    verify_measurement_type(type)
    val  = f_query(obj, "MEAS:$type? (@$channel)"; timeout = 0)
    return attach_unit!(val, type)
end

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    Executes a spot (one-shot) measurement and returns valid voltage, current, and resistance if type is not specified.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
    
"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    write(obj, ":FORM:ELEM:SENS VOLT,CURR,RES")
    val = query(obj, ":MEAS? (@$channel)"; timeout = 0)

    val = split(val, ",")
    val = parse.(Float64, val)
    val = val[1] * V, val[2] * A, val[3] * R
    val = filter( x -> x/oneunit(x) != 9.91e37, val)

    return val
end

verify_measurement_type(type) =  !(type in ["VOLT", "CURR", "RES"]) && error("Measurement type \"$type\" is not valid!\nIt's value must be \"VOLT\", \"CURR\", or \"RES\".")

function attach_unit!(value, unit)
    if unit == "VOLT"
        value = value * V
    elseif unit == "CURR"
        value = value * A
    elseif unit == "RES"
        value = value * R 
    end

    return value
end

verify_source_type(type) = !(type in ["VOLT", "CURR"]) && error("Source type \"$type\" is not valid!\nIt's value must be \"VOLT\" or \"CURR\".")
verify_source_mode(mode) = !(mode in ["FIX", "LIST", "SWE"]) && error("Source mode \"$mode\" is not valid!\nIt's value must be \"FIX\", \"LIST\", or \"SWE\".")
verify_value_specifier(value) = !(value in ["MIN", "MAX", "DEF"]) && error("Value specifier \"$value\" is not valid!\nIt's value must be \"MIN\", \"MAX\", or \"DEF\".")

"""
    enable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; mode ="VOLT", channel = 1)

    This will enable an output channel's automatic ranging. 
 
    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - type
        - "CURR" | "VOLT" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
function enable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; mode ="VOLT", channel = 1)
    verify_source_type(mode)
    write(obj, "SOUR$channel:$mode:RANG:AUTO ON")
end

"""
    disable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; mode ="VOLT", channel = 1)

    This will disable an output channel's automatic ranging. If automatic ranging disabled, the source output 
    is performed using the range set [SOURce]:<CURRent|VOLTage>:RANGe command.
 
    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - type
        - "CURR" | "VOLT" (Default)
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.

"""
function disable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; mode ="VOLT", channel = 1)
    verify_source_type(mode)
    write(obj, "SOUR$channel:$mode:RANG:AUTO OFF")
end

#=
TODO - Functions to implement:

- [`set_to_sweep_mode`](@ref)
- [`set_sweep_start`](@ref)
- [`set_sweep_stop`](@ref)
- [`set_sweep_step`](@ref)
- [`set_measurement_range`](@ref)
- [`set_measurement_time`](@ref)
- [`get_measurement`](@ref)
- [`start_measurement`](@ref)
=#
