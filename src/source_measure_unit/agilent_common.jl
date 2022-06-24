"""
    Keywords:

    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
    - source
        - Valid output source types are voltage and current.
        - "VOLT" (Default) | "CURR"
    - measurement
        - Valid measurement types are voltage, current, and resistance.
        - "VOLT" (Default) | "CURR" | "RES"
    - mode
        Valid source modes are fixed, list sweep, and sweep.
        - "FIX" (Default) | "LIST" | "SWE" 
    - value specifiers
        - "MIN" | "MAX" | "DEF" (Default) | "UP" (range-only) | "DOWN" (range-only)

"""


"""
    enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    This will enable an output channel of a device.
"""
enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1) = write(obj, ":OUTP$channel ON")

"""
    disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    This will disable an output channel of a device.
"""
disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1) = write(obj, ":OUTP$channel OFF")

"""
    set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    This will set th selected channel as a voltage source.
"""
set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1) = write(obj, ":SOUR$channel:FUNC:MODE VOLT")

"""
set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    This will set the selected channel's as a current source.
"""
set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1) = write(obj, ":SOUR$channel:FUNC:MODE CURR")

"""
    set_voltage_output(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="DEF" ; channel=1)

    This will set the selected channel's output voltage.
"""
function set_voltage_output(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="DEF" ; channel=1)
    verify_voltage(voltage)
    write(obj, ":SOUR$channel:VOLT $(raw(voltage))")
end

"""
    set_current_output(obj::Instr{<:AgilentSourceMeasureUnit}, current="DEF"; channel = 1)

    This will set the selected channel's output current.
"""
function set_current_output(obj::Instr{<:AgilentSourceMeasureUnit}, current="DEF"; channel = 1)
    verify_current(current)
    write(obj, ":SOUR$channel:CURR $(raw(current))")
end

"""
    set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current="DEF" ; channel=1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative current.
"""
function set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current="DEF" ; channel=1)
    verify_current(current)
    write(obj, ":SENS$channel:CURR:PROT $(raw(current))")
end

"""
    set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="DEF" ; channel=1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative voltage.
"""
function set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="DEF" ; channel=1)
    verify_voltage(voltage)
    write(obj, ":SENS$channel:VOLT:PROT $(raw(voltage))")
end


"""
    set_measurement_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    chan= 1, current=false, voltage=false, resistance=false
    )

    This will enable the selected channel's specified measurement functions.
    Enabling resistance will enable voltage and current measurement modes as well.

    Parameters:
    - voltage
        - true | false (Default)
    - current
        - true | false (Default)
    - resistance
        - true | false (Default)
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
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}, measurement="VOLT"; channel=1)

    Executes a spot (one-shot) measurement and returns the measurement result data.

"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}, measurement="VOLT"; channel=1)
    verify_measurement(measurement)
    val  = f_query(obj, "MEAS:$measurement? (@$channel)"; timeout = 0)
    return attach_unit!(val, measurement)
end

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    Executes a spot (one-shot) measurement and returns valid voltage, current, and resistance if type is not specified.
    
"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    write(obj, ":FORM:ELEM:SENS VOLT,CURR,RES")
    val = query(obj, ":MEAS? (@$channel)"; timeout = 0)

    val = split(val, ",")
    val = parse.(Float64, val)
    val = val[1] * V, val[2] * A, val[3] * R
    val = filter( x -> x/oneunit(x) != NaN, val)

    return val
end

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

"""
    enable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source="VOLT", channel = 1)

    This will enable an output channel's automatic ranging. 

"""
function enable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source="VOLT", channel = 1)
    verify_source(source)
    write(obj, "SOUR$channel:$source:RANG:AUTO ON")
end

"""
    disable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source="VOLT", channel = 1)

    This will disable an output channel's automatic ranging. If automatic ranging disabled, the source output 
    is performed using the range set [SOURce]:<CURRent|VOLTage>:RANGe command.

"""
function disable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source="VOLT", channel = 1)
    verify_source(source)
    write(obj, "SOUR$channel:$source:RANG:AUTO OFF")
end

"""
    set_to_sweep_mode(obj::Instr{<:AgilentSourceMeasureUnit}; source="VOLT", channel = 1)

    This will set a source channel to sweep mode.

"""
function set_to_sweep_mode(obj::Instr{<:AgilentSourceMeasureUnit}; source="VOLT",channel=1)
    verify_source(source)
    write(obj, "SOUR$channel:$source:MODE SWE")
end

"""
    set_voltage_sweep_start(obj::Instr{<:AgilentSourceMeasureUnit}; start="DEF", channel=1) 

    This will set a channel's voltage source start value for sweep output.

"""
function set_voltage_sweep_start(obj::Instr{<:AgilentSourceMeasureUnit}; start="DEF", channel=1) 
    verify_voltage(start)
    write(obj, "SOUR$channel:VOLT:START $(raw(start))")
end

"""
    set_current_sweep_start(obj::Instr{<:AgilentSourceMeasureUnit}; start="DEF", channel=1) 

    This will set a channel's current source start value for sweep output.

"""
function set_current_sweep_start(obj::Instr{<:AgilentSourceMeasureUnit}; start="DEF", channel=1) 
    verify_current(start)
    write(obj, "SOUR$channel:CURR:START $(raw(start))")
end

"""
    set_voltage_sweep_stop(obj::Instr{<:AgilentSourceMeasureUnit}; stop="DEF", channel=1) 

    This will set a channel's voltage source stop value for sweep output.

"""
function set_voltage_sweep_stop(obj::Instr{<:AgilentSourceMeasureUnit}; stop="DEF", channel=1) 
    verify_voltage(stop)
    write(obj, "SOUR$channel:VOLT:STOP $(raw(stop))")
end

"""
    set_current_sweep_stop(obj::Instr{<:AgilentSourceMeasureUnit}; stop="DEF", channel=1) 

    This will set a channel's current source stop value for sweep output.

"""
function set_current_sweep_stop(obj::Instr{<:AgilentSourceMeasureUnit}; stop="DEF", channel=1) 
    verify_current(stop)
    write(obj, "SOUR$channel:CURR:STOP $(raw(stop))")
end

"""
    set_voltage_sweep_step(obj::Instr{<:AgilentSourceMeasureUnit}; step::String="DEF", channel=1)

    This will set a channel's voltage source step value for sweep output. 
    Changing step value will automatically change point value.
    points = span/step + 1 (where step is not 0)

"""
function set_voltage_sweep_step(obj::Instr{<:AgilentSourceMeasureUnit}; step="DEF", channel=1) 
    verify_voltage(step)
    write(obj, "SOUR$channel:VOLT:STEP $(raw(step))")
end

"""
    set_current_sweep_step(obj::Instr{<:AgilentSourceMeasureUnit}; step::String="DEF", channel=1)

    This will set a channel's voltage source step value for sweep output. 
    Changing step value will automatically change point value.
    points = span/step + 1 (where step is not 0)

"""
function set_current_sweep_step(obj::Instr{<:AgilentSourceMeasureUnit}; step="DEF", channel=1) 
    verify_current(step)
    write(obj, "SOUR$channel:CURR:STEP $(raw(step))")
end

"""
    set_measurement_range(obj::Instr{<:AgilentSourceMeasureUnit}; measurement="VOLT", range="DEF", channel=1)

    This will set an output channel's measurement range.
"""
function set_measurement_range(obj::Instr{<:AgilentSourceMeasureUnit}; measurement="VOLT", range="DEF", channel=1)
    verify_measurement(measurement)
    verify_range(range)
    write(obj, "SENS$channel:$measurement:range $(raw(range))")
end

"""
    set_measurement_time(obj::Instr{<:AgilentSourceMeasureUnit}; aperture="DEF", channel=1)

    This will set an output channel's integration time for one point measurement. 
    Measurement type is not important since time value is common for voltage, current, and resistance.
    If value set is less than MIN or greater than MAX, time is automatically set to MIN or MAX.
    
"""
function set_measurement_time(obj::Instr{<:AgilentSourceMeasureUnit}; aperture="DEF", channel=1)
    verify_aperture(aperture)
    write(obj, "SENS$channel:VOLT:APER $(raw(aperture))")
end

"""
    get_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    Get measurement and returns voltage, current, and resistance if enabled and valid.
    
"""
function get_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    write(obj, ":FORM:ELEM:SENS VOLT,CURR,RES")
    val = query(obj, ":FETCH:ARR? (@$channel)"; timeout = 0)

    val = split(val, ",")
    val = parse.(Float64, val)
    val = val[1] * V, val[2] * A, val[3] * R
    val = filter( x -> x/oneunit(x) != NaN, val)

    return val
end

"""
    get_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1)

    Get measurement and returns valid voltage, current, and resistance if type is not specified.
    
"""
start_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel=1) = write(obj, ":INIT:ACQ (@$channel)")

verify_source(source) = !(source in ["VOLT", "CURR"]) && error("Source \"$source\" is not valid!\nIt's value must be \"VOLT\" or \"CURR\".")
verify_source_mode(mode) = !(mode in ["FIX", "LIST", "SWE"]) && error("Source mode \"$mode\" is not valid!\nIt's value must be \"FIX\", \"LIST\", or \"SWE\".")
verify_measurement(type) =  !(type in ["VOLT", "CURR", "RES"]) && error("Measurement type \"$type\" is not valid!\nIt's value must be \"VOLT\", \"CURR\", or \"RES\".")
verify_value_specifier(value) = !(value in ["MIN", "MAX", "DEF"]) && error("Value specifier \"$value\" is not valid!\nIt's value must be \"MIN\", \"MAX\", or \"DEF\".")
verify_voltage(voltage) = !(voltage isa Unitful.Voltage) && error("Voltage must be of Unitful.Voltage")
verify_voltage(voltage::String) = verify_value_specifier(voltage)
verify_current(current) = !(current isa Unitful.Current) && error("Current type be of Unitful.Current")
verify_current(current::String) = verify_value_specifier(current)
verify_range(range) = nothing
verify_range(range::String) = !(range in ["MIN", "MAX", "DEF", "UP", "DOWN"]) && error("Range specifier \"$range\" is not valid!\nIt's value must be \"MIN\", \"MAX\", \"DEF\", \"UP\", or \"DOWN\".")
verify_aperture(aperture) = !(aperture isa Unitful.Time) && error("Aperture must be of Unitful.Time.")
verify_aperture(aperture::String) = !(aperture in ["MIN", "MAX", "DEF"]) && error("Aperture \"$aperture\" is not valid!\nIt's value must be \"MIN\", \"MAX\", or \"DEF\".")
