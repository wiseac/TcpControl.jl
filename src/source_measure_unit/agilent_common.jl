"""

    Keywords:

    - obj
        - must be a Source Measure Unit Instrument
    - channel
        - Valid values are positive integers 1 to N, where N is the number of channels on the device.
    - source
        - "voltage" (Default) | "current"
    - measurement
        - "voltage" (Default) | "current" | "resistance"
    - mode
        - "fixed" (Default) | "list" | "sweep" 
    - value specifiers
        - "minimum" | "maximum" | "default" (Default) | "up" (Range-only) | "down" (Range-only)

"""


"""
    enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)

    This will enable an output channel of a device.
"""
function enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)
    verify_channel(obj, channel)
    write(obj, ":OUTP$channel ON")
end

verify_channel(obj::Instr{AgilentB2910BL}, channel) = !(channel in get_valid_channels(obj)) && error("Invalid channel! Refer to device manual.")
get_valid_channels(obj::Instr{AgilentB2910BL}) = [1]

"""
    disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)

    This will disable an output channel of a device.
"""
function disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1) 
    verify_channel(obj, channel)
    write(obj, ":OUTP$channel OFF")
end
"""
    set_source(obj::Instr{<:AgilentSourceMeasureUnit}; source="voltage", channel::Integer=1)

    This will set the selected channel's source output mode.
"""
function set_source(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", channel::Integer=1)
    verify_channel(obj, channel) 
    write(obj, ":SOUR$channel:FUNC:MODE $source")
end

"""
    get_source_mode(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)

    This will get the selected channel's source output mode.
"""
function get_source(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)
    verify_channel(obj, channel) 
    query(obj, ":SOUR$channel:FUNC:MODE?")
end
"""
    set_voltage_output(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="default"; channel::Integer=1)

    This will set the selected channel's output voltage.
"""
function set_voltage_output(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="default"; channel::Integer=1)
    verify_voltage(voltage)
    verify_channel(obj, channel)
    _set_voltage_output(obj, voltage, channel)
    return nothing
end

_set_voltage_output(obj, voltage, channel) = write(obj, ":SOUR$channel:VOLT $(raw(voltage))")

"""
    set_current_output(obj::Instr{<:AgilentSourceMeasureUnit}, current="default"; channel::Integer=1)

    This will set the selected channel's output current.
"""
function set_current_output(obj::Instr{<:AgilentSourceMeasureUnit}, current="default"; channel::Integer=1)
    verify_current(current)
    verify_channel(obj, channel)
    _set_current_output(obj, current, channel)
    return nothing
end

_set_current_output(obj, current, channel) = write(obj, ":SOUR$channel:CURR $(raw(current))")

"""
    set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="default"; channel::Integer=1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative voltage.
"""
function set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage="default"; channel::Integer=1)
    verify_voltage(voltage)
    verify_channel(obj, channel)
    _set_voltage_limit(obj, voltage, channel)
    return nothing
end

_set_voltage_limit(obj, voltage, channel) = write(obj, ":SENS$channel:VOLT:PROT $(raw(voltage))")

"""
    set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current="default"; channel::Integer=1)

    This will set the selected channel's output current limit. The limit is applied to both positive and negative current.
"""
function set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current="default"; channel::Integer=1)
    verify_current(current)
    verify_channel(obj, channel)
    _set_current_limit(obj, current, channel)
    return nothing
end

_set_current_limit(obj, current, channel) = write(obj, ":SENS$channel:CURR:PROT $(raw(current))")

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
    voltage=false, current=false, resistance=false, channel::Integer=1
    )

    verify_channel(obj, channel)
    mode = String[]
    voltage && add_mode!(mode, "voltage")
    current && add_mode!(mode, "current")
    resistance && add_mode!(mode, "resistance")
    mode = join(mode)

    isempty(mode) && error("The mode was empty. You must set one or more of the input arguments: current, voltage, and resistance to true.")
    _clear_measurement_mode(obj, channel)
    _set_measurement_mode(obj, channel, mode)
    return nothing
end

_clear_measurement_mode(obj, channel) = write(obj, ":SENS$channel:FUNC:OFF:ALL")
_set_measurement_mode(obj, channel, mode) = write(obj, ":SENS$channel:FUNC $mode")

function add_mode!(buffer, mode)
    isempty(buffer) ? pre = "\"" : pre = ",\""
    post = "\""
    push!(buffer, pre*mode*post)
    return nothing
end

"""
    enable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source="voltage", channel::Integer=1)

    This will enable an output channel's automatic ranging. 
"""
function enable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", channel::Integer=1)
    verify_source(source)
    verify_channel(obj, channel)
    _enable_autorange(obj, source, channel)
    return nothing
end

_enable_autorange(obj, source, channel) = write(obj, "SOUR$channel:$source:RANG:AUTO ON")

"""
    disable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source="voltage", channel::Integer=1)

    This will disable an output channel's automatic ranging. If automatic ranging disabled, the source output 
    is performed using the range set [SOURce]:<CURRent|VOLTage>:RANGe command.
"""
function disable_autorange(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", channel::Integer=1)
    verify_source(source)
    verify_channel(obj, channel)
    _disable_autorange(obj, source, channel)
    return nothing
end

_disable_autorange(obj, source, channel) = write(obj, "SOUR$channel:$source:RANG:AUTO OFF")

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}, measurement::String="voltage"; channel::Integer=1)

    Executes a spot (one-shot) measurement and returns the measurement result data.
"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}, measurement::String; channel::Integer=1)
    verify_measurement(measurement)
    verify_channel(obj, channel)
    val  = _spot_single_measurement(obj, measurement, channel)
    return attach_unit!(val, measurement)
end

_spot_single_measurement(obj, measurement, channel) = f_query(obj, "MEAS:$measurement? (@$channel)")

function attach_unit!(value, unit)
    if unit == "voltage"
        value = value * V
    elseif unit == "current"
        value = value * A
    elseif unit == "resistance"
        value = value * R 
    end

    return value
end

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)

    Executes a spot (one-shot) measurement and returns valid voltage, current, and resistance if type is not specified.
"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)
    verify_channel(obj, channel)
    specify_element_format_vcr(obj)
    arr = _spot_measurement(obj, channel)
    arr = parse_measurement_vcr!(arr)
    return arr
end

specify_element_format_vcr(obj) = write(obj, ":FORM:ELEM:SENS voltage,current,resistance")
_spot_measurement(obj, channel) = query(obj, ":MEAS? (@$channel)")

function parse_measurement_vcr!(arr)
    arr = split(arr, ",")
    arr = parse.(Float64, arr)
    arr = arr[1] * V, arr[2] * A, arr[3] * R
    arr = remove_NaN!(arr)
    return arr
end

remove_NaN!(x) = filter( x -> ustrip(x) != SMU_NAN, x)

"""
    set_source_mode(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", mode="fixed", channel::Integer=1)

    This will set a source channel mode.
"""
function set_source_mode(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", mode::String="fixed", channel::Integer=1)
    verify_source(source)
    verify_source_mode(mode)
    verify_channel(obj, channel)
    _set_source_mode(obj, source, mode, channel)
    return nothing
end

_set_source_mode(obj, source, mode, channel) = write(obj, "SOUR$channel:$source:MODE $mode")

"""
    get_source_mode(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", channel::Integer=1)

    This will get a source channel mode.
"""
function get_source_mode(obj::Instr{<:AgilentSourceMeasureUnit}; source::String="voltage", channel::Integer=1)
    verify_source(source)
    verify_channel(obj, channel)
    return _get_source_mode(obj, source, channel)
end

_get_source_mode(obj, source, channel) = query(obj, "SOUR$channel:$source:MODE?")

"""
    set_voltage_sweep_parameters(obj::Instr{<:AgilentSourceMeasureUnit}; 
    start="default", 
    stop="default", 
    step="default", 
    channel::Integer=1)

    This will set a channel's voltage source start, stop, step, and trigger point value for sweep output. 
    points = span/step + 1 (where step is not 0)
    span = stop - start
"""
function set_voltage_sweep_parameters(obj::Instr{<:AgilentSourceMeasureUnit}; 
    start="default", 
    stop="default", 
    step="default", 
    channel::Integer=1)

    verify_channel(obj, channel)
    set_voltage_sweep_start(obj; start, channel)
    set_voltage_sweep_stop(obj; stop, channel)
    set_voltage_sweep_step(obj; step, channel)
    set_voltage_trigger_points(obj; channel)
end

function set_voltage_sweep_start(obj::Instr{<:AgilentSourceMeasureUnit}; start="default", channel::Integer=1) 
    verify_start(start)
    _set_voltage_sweep_start(obj, start, channel)
    return nothing
end

_set_voltage_sweep_start(obj, start, channel) = write(obj, "SOUR$channel:VOLT:START $(raw(start))")

function set_voltage_sweep_stop(obj::Instr{<:AgilentSourceMeasureUnit}; stop="default", channel::Integer=1) 
    verify_stop(stop)
    _set_voltage_sweep_stop(obj, stop, channel)
    return nothing
end

_set_voltage_sweep_stop(obj, stop, channel) = write(obj, "SOUR$channel:VOLT:STOP $(raw(stop))")

function set_voltage_sweep_step(obj::Instr{<:AgilentSourceMeasureUnit}; step="default", channel::Integer=1) 
    verify_step(step)
    _set_voltage_sweep_step(obj, step, channel) 
    return nothing
end

_set_voltage_sweep_step(obj, step, channel) = write(obj, "SOUR$channel:VOLT:STEP $(raw(step))")

function set_voltage_trigger_points(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)
    verify_channel(obj, channel)
    span = _get_voltage_span(obj, channel)
    step = _get_voltage_step(obj, channel)
    points =  _get_trigger_points(span, step)
    _set_voltage_trigger_points(obj, points, channel)
end

_get_voltage_span(obj, channel) = f_query(obj, ":SOUR$channel:VOLT:SPAN?")
_get_voltage_step(obj, channel) = f_query(obj, ":SOUR$channel:VOLT:STEP?") 

function _get_trigger_points(span, step)
    if step == 0
        return 1
    else
        return trunc(Int, span/step + 1)
    end
end

_set_voltage_trigger_points(obj, points, channel) = write(obj, ":TRIG$channel:ALL:COUN $points")

"""
    set_current_sweep_parameters(obj::Instr{<:AgilentSourceMeasureUnit}; 
    start="default", 
    stop="default", 
    step="default", 
    channel::Integer=1)

    This will set a channel's current source start, stop, step, and trigger point value for sweep output. 
    points = span/step + 1 (where step is not 0)
    span = stop - start
"""
function set_current_sweep_parameters(obj::Instr{<:AgilentSourceMeasureUnit}; 
    start="default", 
    stop="default", 
    step="default", 
    channel::Integer=1)

    verify_channel(obj, channel)
    set_current_sweep_start(obj; start, channel)
    set_current_sweep_stop(obj; stop, channel)
    set_current_sweep_step(obj; step, channel)
    set_current_trigger_points(obj; channel)
end

function set_current_sweep_start(obj::Instr{<:AgilentSourceMeasureUnit}; start="default", channel::Integer=1) 
    verify_start(start)
    _set_current_sweep_start(obj, start, channel)
    return nothing
end

_set_current_sweep_start(obj, start, channel) = write(obj, "SOUR$channel:CURR:START $(raw(start))")

function set_current_sweep_stop(obj::Instr{<:AgilentSourceMeasureUnit}; stop="default", channel::Integer=1) 
    verify_stop(stop)
    _set_current_sweep_stop(obj, stop, channel)
    return nothing
end

_set_current_sweep_stop(obj, stop, channel) = write(obj, "SOUR$channel:CURR:STOP $(raw(stop))")

function set_current_sweep_step(obj::Instr{<:AgilentSourceMeasureUnit}; step="default", channel::Integer=1) 
    verify_step(step)
    _set_current_sweep_step(obj, step, channel)
    return nothing
end

_set_current_sweep_step(obj, step, channel) = write(obj, "SOUR$channel:CURR:STEP $(raw(step))")

function set_current_trigger_points(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)
    span = _get_current_span(obj, channel)
    step = _get_current_step(obj, channel)
    points =  _get_trigger_points(span, step)
    _set_current_trigger_points(obj, points, channel)
end

_get_current_span(obj, channel) = f_query(obj, ":SOUR$channel:CURR:SPAN?")
_get_current_step(obj, channel) = f_query(obj, ":SOUR$channel:CURR:STEP?") 
_set_current_trigger_points(obj, points, channel) = write(obj, ":TRIG$channel:ALL:COUN $points")

"""
    set_measurement_range(obj::Instr{<:AgilentSourceMeasureUnit}, range; channel::Integer=1)

    This will set an output channel's measurement range.
"""
function set_measurement_range(obj::Instr{<:AgilentSourceMeasureUnit}, range; channel::Integer=1)
    verify_channel(obj, channel)
    _set_measurement_range(obj, range, channel)
    return nothing
end

_set_measurement_range(obj, range::Unitful.Voltage, channel) = write(obj, "SENS$channel:VOLT:RANGE $(raw(range))")
_set_measurement_range(obj, range::Unitful.Current, channel) = write(obj, "SENS$channel:CURR:RANGE $(raw(range))")
_set_measurement_range(obj, range::Resistance, channel) = write(obj, "SENS$channel:RES:RANGE $(raw(range))")
_set_measurement_range(obj, range, channel) = error("Type of 'range' must be a Unitful.Voltage, Unitful.Current, Resistance, or String")

"""
    set_measurement_range(obj::Instr{<:AgilentSourceMeasureUnit}; measurement::String="voltage", range="default", channel::Integer=1)

    This will set an output channel's measurement range.
"""
function set_measurement_range(obj::Instr{<:AgilentSourceMeasureUnit}; measurement::String="voltage", range::String="default", channel::Integer=1)
    verify_measurement(measurement)
    verify_range(range)
    verify_channel(obj, channel)
    _set_measurement_range(obj, measurement, range, channel) 
    return nothing
end

_set_measurement_range(obj, measurement, range, channel) = write(obj, "SENS$channel:$measurement:range $(raw(range))")

verify_range(range::String) = !(range in ["minimum", "maximum", "default", "UP", "DOWN"]) && error("Range specifier \"$range\" is not valid!\nIt's value must be \"MIN\", \"MAX\", \"DEF\", \"UP\", or \"DOWN\".")

"""
    set_measurement_duration(obj::Instr{<:AgilentSourceMeasureUnit}; aperture="default", channel::Integer=1)

    This will set an output channel's integration time for one point measurement. 
    Measurement type is not important since time value is common for voltage, current, and resistance.
    If value set is less than MIN or greater than MAX, time is automatically set to MIN or MAX.
"""
function set_measurement_duration(obj::Instr{<:AgilentSourceMeasureUnit}; aperture="default", channel::Integer=1)
    verify_aperture(aperture)
    verify_channel(obj, channel)
    _set_measurement_duration(obj, aperture, channel)
    return nothing
end

_set_measurement_duration(obj, aperture, channel) = write(obj, "SENS$channel:VOLT:APER $(raw(aperture))")

"""
    start_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)

    Initiates the specified device action for the specified channel. Trigger status is changed from idle to initiated.
    Adjust voltage and current limit if necessary.
"""
function start_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1) 
    verify_channel(obj, channel)
    write(obj, ":INIT (@$channel)")
end

"""
    get_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)

    Get measurement stored by start_measurement(). 
    Returns voltage, current, resistance, and time.
"""
function get_measurement(obj::Instr{<:AgilentSourceMeasureUnit}; channel::Integer=1)
    verify_channel(obj, channel)
    voltage = _get_voltage(obj, channel)
    current = _get_current(obj, channel)
    resistance = _get_resistance(obj, channel)
    time = _get_time(obj, channel)
    return SourceMeasureUnitData(voltage, current, resistance, time)
end

function _get_voltage(obj, channel)
    _format_voltage(obj)
    arr = fetch_array(obj, channel)
    arr = split(arr,",")
    arr = parse.(Float64, arr)
    arr = arr * V
    return arr
end

_format_voltage(obj) = write(obj, "FORM:ELEM:SENS VOLT")

function _get_current(obj, channel)
    _format_current(obj)
    arr = fetch_array(obj, channel)
    arr = split(arr,",")
    arr = parse.(Float64, arr)
    arr = arr * A
    return arr
end

_format_current(obj) = write(obj, "FORM:ELEM:SENS current")

function _get_resistance(obj, channel)
    _format_resistance(obj)
    arr = fetch_array(obj, channel)
    arr = split(arr,",")
    arr = parse.(Float64, arr)
    arr = arr * R
    return arr
end

_format_resistance(obj) = write(obj, "FORM:ELEM:SENS resistance")

function _get_time(obj, channel)
    _format_time(obj)
    arr = fetch_array(obj, channel)
    arr = split(arr,",")
    arr = parse.(Float64, arr)
    arr = arr * u"s"
    return arr
end

_format_time(obj) = write(obj, "FORM:ELEM:SENS TIME")

fetch_array(obj, channel) = query(obj, ":FETCH:ARR? (@$channel)"; timeout = 5)

verify_source(source) = !(source in ["voltage", "current"]) && error("Source \"$source\" is not valid!\nIt's value must be \"voltage\" or \"current\".")
verify_source_mode(mode) = !(mode in ["fixed", "list", "sweep"]) && error("Source mode \"$mode\" is not valid!\nIt's value must be \"fixed\", \"list\", or \"sweep\".")
verify_measurement(type) =  !(type in ["voltage", "current", "resistance"]) && error("Measurement type \"$type\" is not valid!\nIt's value must be \"voltage\", \"current\", or \"resistance\".")
verify_value_specifier(value) = !(value in ["minimum", "maximum", "default"]) && error("Value specifier \"$value\" is not valid!\nIt's value must be \"minimum\", \"maximum\", or \"default\".")

verify_start(start::Unitful.Voltage) = verify_voltage(start)
verify_start(start::Unitful.Current) = verify_current(start)
verify_start(start::String) = verify_value_specifier(start)

verify_stop(stop::Unitful.Voltage) = verify_voltage(stop)
verify_stop(stop::Unitful.Current) = verify_current(stop)
verify_stop(stop::String) = verify_value_specifier(stop)

verify_step(step::Unitful.Voltage) = verify_voltage(step)
verify_step(step::Unitful.Current) = verify_current(step)
verify_step(step::String) = verify_value_specifier(step)

verify_voltage(voltage::String) = verify_value_specifier(voltage)
verify_voltage(voltage::Unitful.Voltage) = nothing
verify_voltage(voltage) = error("Type of 'voltage' must be a Unitful.Voltage or String")

verify_current(current::String) = verify_value_specifier(current)
verify_current(current::Unitful.Current) = nothing
verify_current(current) = error("Type of 'current' must be a Unitful.Current or String")

verify_aperture(aperture::String) = verify_value_specifier(aperture)
verify_aperture(aperture::Unitful.Time) = nothing
verify_aperture(aperture) = error("Type of 'aperture' must be a Unitful.Time or String")
