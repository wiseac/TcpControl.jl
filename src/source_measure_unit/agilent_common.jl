"""
    enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will enable an output channel of a device.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

"""
enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":OUTP$channel ON")

"""
    disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will disable an output channel of a device.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

"""
disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":OUTP$channel OFF")

"""
    set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will set th selected channel as a voltage source.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

"""
set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1) = write(obj, ":SOUR$channel:FUNC:MODE VOLT")

"""
set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel = 1)

    This will set the selected channel's as a current source.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels
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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels
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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels
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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels
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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels
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
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels
"""
function set_measurement_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    voltage=false, current=false, resistance=false, channel=1
    )

    mode = ""

    if voltage
        mode = "\"VOLT\""
        current && (mode = mode * ",\"CURR\"")
        resistance && (mode = mode * ",\"RES\"")
    elseif current
        mode = "\"CURR\""
        resistance && (mode = mode * ",\"RES\"")
    elseif resistance
        mode = "\"RES\""
    end

    isempty(mode) && error("The mode was empty. You must set one or more of the input arguments: current, voltage, and resistance to true.")

    write(obj, ":SENS$channel:FUNC:OFF:ALL")
    write(obj, ":SENS$channel:FUNC $mode")

    return nothing
end

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit};
        type="VOLT", channel=1
    )

    Executes a spot (one-shot) measurement and returns the measurement result data.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - type
        - "CURR" | "RES" | "VOLT" (Default)
    - channel
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit};
    type="VOLT", channel=1
    )

    verify_measurement_type(type)
    val  = f_query(obj, "MEAS:$type? (@$channel)"; timeout = 0)
    return attach_unit!(val, type)
end

verify_measurement_type(type) =  !(type in ["VOLT", "CURR", "RES"]) && error("Measurement type \"$type\" is not valid!\nIt's value must be \"VOLT\", \"CURR\", or \"RES\".")

"""
    set_source_mode(obj::Instr{<:AgilentSourceMeasureUnit};
        type = "VOLT",
        mode = "FIX",
        channel = 1
    )

    Selects the source mode, fixed list sweep, or sweep, of the specified source channel.

    Parameters:
    - obj
        - must be a Source Measure Unit Instrument
    - type
        - "CURR" | "VOLT" (Default)
    - mode
        - "FIX" (Default) | "LIST" | "SWE"
        - FIX sets the constant current or voltage source.
        - LIST sets the user-specified current or voltage list sweep source. Specified by set_sweep_steps()
        - SWEep sets the current or voltage sweep source. Specified by set_list_sweep()
    - channel
        - This is an optional parameter
        - If not provided it will use the default channel 1
        - Otherwise this can be an int: 1, 2, 3 .. to n
        where n is the total number of channels

"""
function set_source_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    type="VOLT", mode="FIX", channel=1
    )

    verify_source_type(type)
    verify_source_mode(mode)

    write(obj, ":SOUR$channel :$type:MODE $mode")
    return nothing
end

verify_source_type(type) = !(type in ["VOLT", "CURR"]) && error("Source type \"$type\" is not valid!\nIt's value must be \"VOLT\" or \"CURR\".")
verify_source_mode(mode) = !(mode in ["FIX", "LIST", "SWE"]) && error("Source mode \"$mode\" is not valid!\nIt's value must be \"FIX\", \"LIST\", or \"SWE\".")



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

function add_mode!(buffer, mode)
    isempty(buffer) ? pre = "\"" : pre = ",\""
    post = "\""
    buffer = buffer*pre*mode*post
end

verify_value_specifier(value) = !(value in ["MIN", "MAX", "DEF"]) && error("Value specifier \"$value\" is not valid!\nIt's value must be \"MIN\", \"MAX\", or \"DEF\".")
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
