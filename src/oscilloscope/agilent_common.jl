"""
    get_data(instr::Instr{<:AgilentScope}, ch_vec::Vector{Int}; check_channels=true)
    get_data(instr::Instr{<:AgilentScope}, ch::Integer)
    get_data(instr::Instr{<:AgilentScope})

Grab data from the specified channel(s). If no channels are specified, data will be grabbed
from all available channels

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `ch::Integer`: channel number
- `ch_vec::Vector{Int}`: vector of channels

# Keywords
- `check_channels=true`: checks channels

# Returns
- `[]`: data from scope

# Throws
- `"Channel is offline, data cannot be read"`: if channel is offline
"""
function get_data(instr::Instrument{<:AgilentScope})
    ch_vec = get_valid_channels(instr)
    @info "Loading channels: $ch_vec"
    return get_data(instr, ch_vec; check_channels=false)
end

get_valid_channels(instr::Instrument{AgilentDSOX4024A}) = [1,2,3,4]
get_valid_channels(instr::Instrument{AgilentDSOX4034A}) = [1,2,3,4]

function get_valid_channels(instr::Instrument{<:AgilentScope})
    statuses = asyncmap(x->(x, channel_is_displayed(instr, x)), 1:4)
    filter!(x -> x[2], statuses)
    valid_channels = map(x -> x[begin], statuses)
    return valid_channels
end
channel_is_displayed(instr::Instrument{<:AgilentScope}, chan) = query(instr, "STAT? CHAN$chan") == "1" ? true : false


function get_data(instr::Instrument{<:AgilentScope}, ch_vec::Vector{Int}; check_channels=true)
    if check_channels
        unique!(ch_vec)
        valid_channels = get_valid_channels(instr)
        for ch in ch_vec
            if !(ch in valid_channels)
                error("Channel $ch is offline, data cannot be read")
            end
        end
    end
    digitize_blocking_wait(instr)
    wfm_data = [get_data(instr, ch) for ch in ch_vec]
    run(instr)
    return wfm_data
end

function get_data(instr::Instrument{<:AgilentScope}, ch::Integer)
    set_waveform_source(instr, ch)
    raw_data = read_raw_waveform(instr);
    info = get_waveform_info(instr, ch)
    return parse_raw_waveform(raw_data, info)
end


digitize_blocking_wait(scope::Instrument{<:AgilentScope}) = write(scope, "DIGITIZE")

set_waveform_source(instr::Instrument{<:AgilentScope}, ch::Int) = write(instr, "WAVEFORM:SOURCE CHAN$ch")


function read_raw_waveform(scope::Instrument{<:AgilentScope})
    data_transfer_format = get_data_transfer_format(scope)
    if data_transfer_format == "BYTE"
        raw_data = read_uint8(scope)
    elseif data_transfer_format == "WORD"
        raw_data = read_uint16(scope)
    else
        error("Data transfer format $data_transfer_format not yet supported")
    end
    return raw_data
end


function read_uint8(scope::Instrument{<:AgilentScope})
    request_waveform_data(scope)
    num_bytes = get_num_data_bytes(scope)

    data = read_with_timeout(scope; num_bytes)
    read_end_of_line_character(scope)

    num_data_points = get_num_data_points(scope)
    if length(data) != num_data_points
        error("Transferred data did not have the expected number of data points\nTransferred: $(length(data))\nExpected: $num_data_points")
    end

    return data
end


function read_uint16(scope::Instrument{<:AgilentScope})
    set_data_transfer_byte_order(scope, :least_significant_first)
    request_waveform_data(scope)
    num_bytes = get_num_data_bytes(scope)

    data = reinterpret(UInt16, read_with_timeout(scope; num_bytes))
    read_end_of_line_character(scope)

    num_data_points = get_num_data_points(scope)
    if length(data) != num_data_points
        error("Transferred data did not have the expected number of data points\nTransferred: $(length(data))\nExpected: $num_data_points")
    end

    return data
end


function set_data_transfer_byte_order(scope::Instrument{<:AgilentScope}, byte_order::Symbol)
    if byte_order == :least_significant_first
        write(scope, "WAVEFORM:BYTEORDER LSBFIRST")
    elseif byte_order == :most_significant_first
        write(scope, "WAVEFORM:BYTEORDER MSBFIRST")
    else
        error("Data transfer byte order ($byte_order) not recognized")
    end
    return nothing
end

function get_data_transfer_byte_order(scope::Instrument{<:AgilentScope})
    return query(scope, "WAVEFORM:BYTEORDER?")
end


function request_waveform_data(scope::Instrument{<:AgilentScope})
    write(scope, "WAV:DATA?")
    return nothing
end


function get_num_data_bytes(scope::Instrument{<:AgilentScope})
    header = get_data_header(scope)
    num_header_description_bytes = 2
    num_data_points = parse(Int, header[num_header_description_bytes+1:end])
    return num_data_points
end


function get_data_header(scope::Instrument{<:AgilentScope})
    # data header is an ASCII character string "#8DDDDDDDD", where the Ds indicate how many
    # bytes follow (p.1433 of Keysight InfiniiVision 4000 X-Series Oscilloscopes
    # Programmer's Guide)
    num_header_description_bytes = 2
    header_description_uint8 = read_with_timeout(scope; num_bytes=num_header_description_bytes)
    if header_description_uint8[1] != UInt8('#')
        error("The waveform data format is not formatted as expected")
    end
    header_block_length = parse(Int, convert(Char, header_description_uint8[2]))
    header_block_uint8 = read_with_timeout(scope; num_bytes=header_block_length)
    header = vcat(header_description_uint8, header_block_uint8)
    header = String(convert.(Char, header))
    return header
end


function read_end_of_line_character(scope::Instrument{<:AgilentScope})
    read_with_timeout(scope)
    return nothing
end


function get_num_data_points(scope::Instrument{<:AgilentScope})
    return i_query(scope, "WAVEFORM:POINTS?", timeout=7)
end


"""
    get_waveform_info(instr::Instr{<:AgilentScope}, ch::Integer)

Grab channel information and return it in a `ScopeInfo`(@ref) struct

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `ch::Integer`: channel

# Returns
- `ScopeInfo`: Struct of scope information
"""
function get_waveform_info(instr::Instrument{<:AgilentScope}, ch::Integer)
    str = get_waveform_preamble(instr)
    str_array = split(str, ",")
    format      = RESOLUTION_MODE[str_array[1]]
    type        = TYPE[str_array[2]]
    num_points  = parse(Int64,   str_array[3])
    count       = parse(Int64,   str_array[4]) # is always one
    x_increment = parse(Float64, str_array[5])
    x_origin    = parse(Float64, str_array[6])
    x_reference = parse(Float64, str_array[7])
    y_increment = parse(Float64, str_array[8])
    y_origin    = parse(Float64, str_array[9])
    y_reference = parse(Float64, str_array[10])
    impedance = get_impedance(instr; chan=ch)
    coupling =  get_coupling(instr; chan=ch)
    low_pass_filter =  get_lpf_state(instr; chan=ch)
    return ScopeInfo(format, type, num_points, x_increment, x_origin, x_reference, y_increment, y_origin, y_reference, impedance, coupling, low_pass_filter, ch)
end

const RESOLUTION_MODE = Dict("+0" => "8bit", "+1" => "16bit", "+2" => "ASCII")
const TYPE = Dict("+0" => "Normal", "+1" => "Peak", "+2" => "Average",  "+3" => "High Resolution")


function parse_raw_waveform(data, scope_info::ScopeInfo)
    voltage_trace = create_voltage_trace(data, scope_info)
    time_trace = create_time_trace(data, scope_info)
    return ScopeData(scope_info, voltage_trace, time_trace)
end


function create_voltage_trace(data, scope_info::ScopeInfo)
    voltage_trace = ((convert.(Float64, data) .- scope_info.y_reference) .* scope_info.y_increment) .+ scope_info.y_origin
    return voltage_trace .* u"V"
end


function create_time_trace(data, scope_info::ScopeInfo)
    time_trace = ((collect(0:scope_info.num_points-1) .- scope_info.x_reference) .* scope_info.x_increment) .+ scope_info.x_origin
    return time_trace * u"s"
end


"""
    get_coupling(instr::Instr{<:AgilentScope}; chan=1)

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel

# Returns
- `String`: "AC" or "DC"
"""
get_coupling(instr::Instrument{<:AgilentScope}; chan=1) = query(instr, "CHANNEL$chan:COUPLING?")


"""
    lpf_on(instr::Instr{<:AgilentScope}; chan=1)

Turn on an internal low-pass filter. When the filter is on, the bandwidth of
the specified channel is limited to approximately 25 MHz.

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
lpf_on(instr::Instrument{<:AgilentScope}; chan=1) = write(instr, "CHANNEL$chan:BWLIMIT ON")


"""
    lpf_off(instr::Instr{<:AgilentScope}; chan=1)

Turn off an internal low-pass filter.

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
lpf_off(instr::Instrument{<:AgilentScope}; chan=1) = write(instr, "CHANNEL$chan:BWLIMIT OFF")


"""
    get_lpf_state(instr::Instr{<:AgilentScope}; chan=1)

See state the internal low-pass filter:

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel

# Returns
- `String`: "0" or "1"
"""
get_lpf_state(instr::Instrument{<:AgilentScope}; chan=1) = query(instr, "CHANNEL$chan:BWLIMIT?")


"""
    set_impedance_1Mohm(instr::Instr{<:AgilentScope}; chan=1)

Set impedance to 1MΩ

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
set_impedance_1Mohm(instr::Instrument{<:AgilentScope}; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE ONEMEG")


"""
    set_impedance_50ohm(instr::Instr{<:AgilentScope}; chan=1)

Set impedance to 50Ω

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
set_impedance_50ohm(instr::Instrument{<:AgilentScope}; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE FIFTY")


"""
    get_impedance(instr::Instr{<:AgilentScope}; chan::Integer=1)

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan::Integer=1`: specific channel

# Returns
- `"FIFT"`: 50Ω
- `"ONEM"`: 1MΩ
"""
get_impedance(instr::Instrument{<:AgilentScope}; chan::Integer=1) = query(instr, ":CHANNEL$chan:IMPEDANCE?")


"""
    run(scope)

Run Oscilloscope
"""
run(instr::Instrument{<:AgilentScope}) = write(instr, "RUN")


"""
    stop(scope)

Stop Oscilloscope
"""
stop(instr::Instrument{<:AgilentScope}) = write(instr, "STOP")


get_waveform_preamble(instr::Instrument{<:AgilentScope}) = query(instr, "WAVEFORM:PREAMBLE?")
get_waveform_source(instr::Instrument{<:AgilentScope}) = query(instr, "WAVEFORM:SOURCE?")

"""
    get_data_transfer_format(instr::Instr{<:AgilentScope})

Gets data transfer format

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Returns
- `String`: data transfer format
"""
get_data_transfer_format(instr::Instrument{<:AgilentScope}) = query(instr, "WAVEFORM:FORMAT?")

"""
    set_data_transfer_format_8bit(instr::Instr{<:AgilentScope})

Set data transfer format to 8bit

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_data_transfer_format_8bit(instr::Instrument{<:AgilentScope}) = write(instr, "WAVEFORM:FORMAT BYTE")

"""
set_data_transfer_format_16bit(instr::Instr{<:AgilentScope})

Set data transfer format to 16bit

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_data_transfer_format_16bit(instr::Instrument{<:AgilentScope}) = write(instr, "WAVEFORM:FORMAT WORD")

get_waveform_num_points(instr::Instrument{<:AgilentScope}) = query(instr, "WAVEFORM:POINTS?")


"""
    set_waveform_num_points(instr::Instr{<:AgilentScope}, num_points::Integer)
Sets the number of sample points in the voltage trace returned by the scope when using
`get_data`(@ref).

# Arguments
- `num_points::Integer`: number of sample points.
"""
set_waveform_num_points(instr::Instrument{<:AgilentScope}, num_points::Integer) = write(instr, "WAVEFORM:POINTS $num_points")
set_waveform_num_points(instr::Instrument{<:AgilentScope}, mode::String) = write(instr, "WAVEFORM:POINTS $mode") #<- I suspect this function is here by an error. TODO: test if this function works

get_waveform_points_mode(instr::Instrument{<:AgilentScope}) = query(instr, "WAVEFORM:POINTS:MODE?")

"""
    set_waveform_points_mode(scope, mode)

Set which data to transfer when using `get_data`(@ref)

Inputs:
`scope`: handle to the connected oscilloscope
`mode`:
- `:NORMAL`: transfer the measurement data
- `:RAW`: transfer the raw acquisition data
"""
function set_waveform_points_mode(instr::Instrument{<:AgilentScope}, mode::Symbol)
    if mode ∈ [:NORMAL, :RAW]
        write(instr, "WAVEFORM:POINTS:MODE $(mode)")
    else
        error("Mode $mode not recognized. Specify :NORMAL or :RAW instead")
    end
    return nothing
end

"""
set_speed_mode(instr::Instr{<:AgilentScope}, speed::Integer)

Adjust the tradeoff between speed and resolution.
This is a wrapper function around the three functions:
- `set_data_transfer_format_16bit`(@ref)
- `set_data_transfer_format_8bit`(@ref)
- `set_waveform_points_mode`(@ref)


Inputs:
`instr`: handle to the connected Agilenst oscilloscope
`speed`: integer of value 1,3,5, or 6, where 1 is slowest and 6 is fastest.
- 1: 16bit, RAW mode
- 3: 16bit, NORMAL mode
- 5: 8bit, RAW mode
- 6: 8bit, NORMAL mode

Speed 6 corresponds to the Agilent scope normal setting when booting.
"""
function set_speed_mode(instr::Instrument{<:AgilentScope}, speed::Integer)
    if speed == 1
        set_data_transfer_format_16bit(instr)
        set_waveform_points_mode(instr, :RAW)
    elseif speed == 3
        set_data_transfer_format_16bit(instr)
        set_waveform_points_mode(instr, :NORMAL)
    elseif speed == 5
        set_data_transfer_format_8bit(instr)
        set_waveform_points_mode(instr, :RAW)
    elseif speed == 6
        set_data_transfer_format_8bit(instr)
        set_waveform_points_mode(instr, :NORMAL)
    end
    return nothing
end

"""
    get_acquisition_type(scope::Instr{<:AgilentScope})

Gets acquisition type

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Returns
- `String`: acquisition type
"""
function get_acquisition_type(scope::Instrument{<:AgilentScope})
    return query(scope, "ACQUIRE:TYPE?")
end


"""
    set_acquisition_type(scope::Instr{<:AgilentScope, type::Symbol})

Sets acquisition type to either normal, average, high_res, or peak.

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `type::Symbol`: The acquisition type. Must be either `:normal`, `:average`, `:high_res`,
                  or `peak`.
"""
set_acquisition_type(scope::Instrument{<:AgilentScope}, type::Symbol) = set_acquisition_type(scope, Val(type))
set_acquisition_type(scope::Instrument{<:AgilentScope}, ::Val{:normal}) = write(scope, "ACQUIRE:TYPE NORM")
set_acquisition_type(scope::Instrument{<:AgilentScope}, ::Val{:average}) = write(scope, "ACQUIRE:TYPE AVER")
set_acquisition_type(scope::Instrument{<:AgilentScope}, ::Val{:high_res}) = write(scope, "ACQUIRE:TYPE HRES")
set_acquisition_type(scope::Instrument{<:AgilentScope}, ::Val{:peak}) = write(scope, "ACQUIRE:TYPE PEAK")

"""
    set_acquisition_type_normal(scope::Instr{<:AgilentScope})

Set acquisition type to normal

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
function set_acquisition_type_normal(scope::Instrument{<:AgilentScope})
    @warn "set_acquisition_type_normal() will be removed in release v0.13.0. Use set_acquisition_type(scope, :normal) instead"
    set_acquisition_type(scope, :normal)
    return nothing
end

"""
    set_acquisition_type_average(scope::Instr{<:AgilentScope})

Set acquisition type to average

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
function set_acquisition_type_average(scope::Instrument{<:AgilentScope})
    @warn "set_acquisition_type_average() will be removed in release v0.13.0. Use set_acquisition_type(scope, :average) instead"
    set_acquisition_type(scope, :average)
    return nothing
end

"""
    set_acquisition_type_high_res(scope::Instr{<:AgilentScope})

Set acquisition type to high res

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
function set_acquisition_type_high_res(scope::Instrument{<:AgilentScope})
    @warn "set_acquisition_type_high_res() will be removed in release v0.13.0. Use set_acquisition_type(scope, :high_res) instead"
    set_acquisition_type(scope, :high_res)
    return nothing
end

"""
    set_acquisition_type_peak(scope::Instr{<:AgilentScope})

Set acquisition type to type peak

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
function set_acquisition_type_peak(scope::Instrument{<:AgilentScope})
    @warn "set_acquisition_type_peak() will be removed in release v0.13.0. Use set_acquisition_type(scope, :peak) instead"
    set_acquisition_type(scope, :peak)
    return nothing
end

"""
    get_voltage_axis(scope::Instr{<:AgilentScope}, ch_vec::Vector{Int})
    get_voltage_axis(scope::Instr{<:AgilentScope}, ch::Int)
    get_voltage_axis(scope::Instr{<:AgilentScope})

Gets the vertical scale setting from the specified channel(s). If no channels are specified,
vertical scale setting for all channels will be returned

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `channels::Vector{Int}`: vector of channel numbers
- `channel::Int`: channel number

# Returns
- `NamedTuple`: per channel with the fields 
    channel
    scale (Voltage per division)
    offset (Voltage offset)

# Throws
- `"Channel is offline, voltage scale cannot be read"`: if channel is offline
"""
function get_voltage_axis(scope::Instrument{<:AgilentScope}, channels::Vector{Int})
    return [get_voltage_axis(scope, channel) for channel in channels]
end

function get_voltage_axis(scope::Instrument{<:AgilentScope}, channel::Int)
    verify_channels(get_valid_channels(scope), [channel])
    return (channel=channel, scale=_get_voltage_scale(scope, channel), offset=_get_voltage_offset(scope, channel))
end

function get_voltage_axis(scope::Instrument{<:AgilentScope})
    return [get_voltage_axis(scope, channel) for channel in get_valid_channels(scope)]
end

function verify_channels(valid_channels, channels)
    for channel in channels
        if !(channel in valid_channels)
            error("Channel $channel is offline, voltage axis cannot be read")
        end
    end
end
"""
    set_time_axis(scope::Instr{<:AgilentScope}; time_per_div::Unitful.Time, time_offset::Unitful.Time)

Set the horizontal scale or units per division for the main window by setting the time per div and/or time offset

# Arguments
- `scope::Instr{<:AgilentScope}`: AgilentScope
- `time_per_div::Unitful.Time`: Time per division [optional]
- `time_offset::Unitful.Time`: Offset time [optional]
"""
function set_time_axis(scope::Instrument{<:AgilentScope}; time_per_div::Unitful.Time, time_offset::Unitful.Time)
    !isnothing(time_per_div) && set_time_per_div(scope, time_per_div)
    !isnothing(time_offset) && set_time_offset(scope, time_offset)
    return nothing
end

function set_time_per_div(scope::Instrument{<:AgilentScope}, time_per_div::Unitful.Time)
    verify_time(time_per_div, "time_per_div", 2ns, 50s)
    time_per_div = unitful_to_string(time_per_div)
    _set_time_per_div(scope, time_per_div)
    return nothing
end

function set_time_offset(scope::Instrument{<:AgilentScope}, time_offset::Unitful.Time)
    verify_time(time_offset, "time_offset", -500s, 500s)
    time_offset = unitful_to_string(time_offset)
    _set_time_offset(scope, time_offset)
    return nothing
end

function verify_time(time_input, name, lowlim, uplim)
    if time_input < lowlim || time_input > uplim
        error("$name must be in the range $lowlim to $uplim (was: $time_input)")
    end
    return nothing
end

function unitful_to_string(value)
    unit(value) == µs && return μs_to_scientific_e_notation(value)
    return string(value)
end

μs_to_scientific_e_notation(microseconds) = string(ustrip(microseconds)) * "E-06"

_set_time_per_div(scope::Instrument{<:AgilentScope}, time_per_div) = write(scope, "TIMEBASE:SCALE $time_per_div")

_set_time_offset(scope::Instrument{<:AgilentScope}, time_offset) = write(scope, "TIMEBASE:POSITION $time_offset") # alias for TIMEBASE:DELAY, which is obsolete

"""
    get_time_axis(scope::Instr{<:AgilentScope})

Gets the horizontal scale or units per divison for the main window
    
# Arguments
- `scope::Instr{<:AgilentScope}`: AgilentScope
# Returns
- `NamedTuple`: With the fields
    time_per_div
    time_offset
"""
function get_time_axis(scope::Instrument{<:AgilentScope})
    parsed_unit_per_div = _get_time_per_division(scope)
    best_prefix_unit_per_div = convert_to_best_prefix(parsed_unit_per_div)
    parsed_offset = _get_offset(scope)
    best_prefix_offset = convert_to_best_prefix(parsed_offset)
    return (time_per_div=best_prefix_unit_per_div, time_offset=best_prefix_offset)
end

_get_time_per_division(scope::Instrument{<:AgilentScope}) = parse(Float64, query(scope, "TIMEBASE:SCALE?")) * u"s"

_get_offset(scope::Instrument{<:AgilentScope}) = parse(Float64, query(scope, "TIMEBASE:POSITION?")) * u"s"
_get_voltage_scale(scope::Instrument{<:AgilentScope}, channel) = uparse(query(scope, "CHANNEL$channel:SCALE?") * "V")
_get_voltage_offset(scope::Instrument{<:AgilentScope}, channel) = uparse(query(scope, "CHANNEL$channel:OFFSET?") * "V")

"""
    set_trigger(scope::Instrument{<:AgilentScope}; level::Voltage, mode::Symbol, edge::Symbol=:pos)

Set trigger parameters

# Arguments
- `scope::Instr{<:AgilentScope}`: AgilentScope
- `mode::String`: scope mode "NORM" or "AUTO"
- `level::Voltage`: voltage to set trigger to 

# Keywords
- `edge::String`: Default value of "POS" 
"""
function set_trigger(scope::Instrument{<:AgilentScope}; mode::String, level::Voltage, edge::String="POS")
    set_mode(scope, mode)
    set_trigger_level(scope, level)
    set_edge_type(scope, edge)
    return nothing
end


"""
    get_trigger(scope::Instrument{<:AgilentScope})

Gets trigger parameters

# Arguments
- `scope::Instr{<:AgilentScope}`: AgilentScope

# Returns
- `TriggerInfo': Struct of scope mode , trigger level, edge type
"""
function get_trigger(scope::Instrument{<:AgilentScope})
    return TriggerInfo(get_mode(scope), get_trigger_level(scope), get_edge_type(scope))
end

"""
    get_trigger_level(scope::Instr{<:AgilentScope})

Gets trigger level

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
# Returns
- `Voltage`: trigger level 
"""
function get_trigger_level(scope::Instrument{<:AgilentScope})
    return parse(Float64,query(scope, "TRIGGER:LEVEL?")) * V
end

"""
    set_trigger_level(scope::Instrument{<:AgilentScope}, level::Voltage)

Sets trigger level

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- 'level::Voltage' : voltage to set trigger level to 
"""
function set_trigger_level(scope::Instrument{<:AgilentScope}, level::Voltage)
    level =  Float64(uconvert(V, level))
    write(scope, "TRIGGER:LEVEL $level")
end

"""
    get_mode(scope::Instr{<:AgilentScope})

Get scope mode

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Returns
- `String`: "NORM" or "AUTO"
"""
function get_mode(scope::Instrument{<:AgilentScope})
    return query(scope, "TRIGGER:SWEEP?")
end

"""
    set_mode(scope::Instrument{<:AgilentScope}, mode::String)

Set scope mode

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `mode::String`: "AUTO" or "NORM"
"""
function set_mode(scope::Instrument{<:AgilentScope}, mode::String)
    if mode ∈ ["AUTO", "NORM"]
        write(scope, "TRIGGER:SWEEP $mode")
    else 
        error("Mode $mode not recognized. Specify AUTO or NORM instead")
    end
end

"""
get_edge_type(scope::Instrument{<:AgilentScope})

    Gets edge type

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
# Returns
- `String`: POSITIVE, NEGATIVE, EITHER, ALTERNATE
"""
function get_edge_type(scope::Instrument{<:AgilentScope})
    return parse_edge_type(query(scope, "TRIGGER:EDGE:SLOPE?"))
end

function parse_edge_type(edge_type)
    edge_type_dic = Dict("POS" => "POSITIVE", "NEG" => "NEGATIVE", "EITH" => "EITHER", "ALT" => "ALTERNATE")
    return edge_type_dic[edge_type]
end

"""
    set_edge_type(scope::Instr{<:AgilentScope, edge_type::Symbol})

Sets edge type (slop) to either POSITIVE, NEGATIVE, EITH (either), Alt(alternate)

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `edge_type::String`: The edge type. Must be either "POSITIVE", "NEGATIVE", "EITHER", "ALTERNATE",
""" 
function set_edge_type(scope::Instrument{<:AgilentScope}, edge_type::String)
    if edge_type ∈ ["POSITIVE", "NEGATIVE", "EITHER", "ALTERNATE"]
        set_edge_type(scope, Val(Symbol(lowercase(edge_type))))
    else
        error("Edge type $edge_type not recognized. Specify POSITIVE, NEGATIVE, EITHER, or ALTERNATE instead")
    end
end
set_edge_type(scope::Instrument{<:AgilentScope}, ::Val{:positive}) = write(scope, "TRIGGER:EDGE:SLOPE POS")
set_edge_type(scope::Instrument{<:AgilentScope}, ::Val{:negative}) = write(scope, "TRIGGER:EDGE:SLOPE NEG")
set_edge_type(scope::Instrument{<:AgilentScope}, ::Val{:either}) = write(scope, "TRIGGER:EDGE:SLOPE EITH")
set_edge_type(scope::Instrument{<:AgilentScope}, ::Val{:alternate}) = write(scope, "TRIGGER:EDGE:SLOPE ALT")

"""
    get_trigger_mode(scope::Instr{<:AgilentScope})

Gets trigger mode

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
# Returns
- `String`: "EDGE", "GLITCH", "PATTERN", "TV", "DELAY", "EBURST"
"""
function get_trigger_mode(scope::Instrument{<:AgilentScope})
    return query(scope, "TRIGGER:MODE?")
end

"""
    set_trigger_mode(scope::Instr{<:AgilentScope, mode::Symbol})

Sets trigger mode to either EDGE, GLITCH, PATTERN, TV, DELAY, EBURST

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
- `mode::String`: The trigger mode. Must be either "EDGE", "GLITCH", "PATTERN", "TV",
                 "EBURST".
                  PROGRAMMING GUIDE p. 1308
""" 
function set_trigger_mode(scope::Instrument{<:AgilentScope}, mode::String)
    if mode ∈ ["EDGE", "GLITCH", "PATTERN", "TV", "DELAY", "EBURST"]
        set_trigger_mode(scope, Val(Symbol(lowercase(mode))))
    else
        error("Trigger mode $mode not recognized. Specify EDGE, GLITCH, PATTERN, TV or EBURST instead")
    end
end
set_trigger_mode(scope::Instrument{<:AgilentScope}, ::Val{:edge}) = write(scope, "TRIGGER:MODE EDGE")
set_trigger_mode(scope::Instrument{<:AgilentScope}, ::Val{:glitch}) = write(scope, "TRIGGER:MODE GLIT")
set_trigger_mode(scope::Instrument{<:AgilentScope}, ::Val{:pattern}) = write(scope, "TRIGGER:MODE PATT")
set_trigger_mode(scope::Instrument{<:AgilentScope}, ::Val{:tv}) = write(scope, "TRIGGER:MODE TV")
set_trigger_mode(scope::Instrument{<:AgilentScope}, ::Val{:eburst}) = write(scope, "TRIGGER:MODE EBUR")
