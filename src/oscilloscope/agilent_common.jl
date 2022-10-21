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
function get_data(instr::Instr{<:AgilentScope})
    ch_vec = get_valid_channels(instr)
    @info "Loading channels: $ch_vec"
    return get_data(instr, ch_vec; check_channels=false)
end

get_valid_channels(instr::Instr{AgilentDSOX4024A}) = [1,2,3,4]
get_valid_channels(instr::Instr{AgilentDSOX4034A}) = [1,2,3,4]

function get_valid_channels(instr::Instr{<:AgilentScope})
    statuses = asyncmap(x->(x, channel_is_displayed(instr, x)), 1:4)
    filter!(x -> x[2], statuses)
    valid_channels = map(x -> x[begin], statuses)
    return valid_channels
end
channel_is_displayed(instr::Instr{<:AgilentScope}, chan) = query(instr, "STAT? CHAN$chan") == "1" ? true : false


function get_data(instr::Instr{<:AgilentScope}, ch_vec::Vector{Int}; check_channels=true)
    if check_channels
        unique!(ch_vec)
        valid_channels = get_valid_channels(instr)
        for ch in ch_vec
            if !(ch in valid_channels)
                error("Channel $ch is offline, data cannot be read")
            end
        end
    end
    stop(instr) # Makes sure the data from each channel is from the same trigger event
    wfm_data = [get_data(instr, ch) for ch in ch_vec]
    run(instr)
    return wfm_data
end

function get_data(instr::Instr{<:AgilentScope}, ch::Integer)
    set_waveform_source(instr, ch)
    raw_data = read_raw_waveform(instr);
    info = get_waveform_info(instr, ch)
    return parse_raw_waveform(raw_data, info)
end


set_waveform_source(instr::Instr{<:AgilentScope}, ch::Int) = write(instr, "WAVEFORM:SOURCE CHAN$ch")


function read_raw_waveform(scope::Instr{<:AgilentScope})
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


function read_uint8(scope::Instr{<:AgilentScope})
    request_waveform_data(scope)
    num_data_bytes = get_num_data_bytes(scope)

    data = read_num_bytes(scope, num_data_bytes)
    read_end_of_line_character(scope)

    num_data_points = get_num_data_points(scope)
    if length(data) != num_data_points
        error("Transferred data did not have the expected number of data points\nTransferred: $(length(data))\nExpected: $num_values ($num_data_points * $num_values_per_point)\n")
    end

    return data
end


function read_uint16(scope::Instr{<:AgilentScope})
    set_data_transfer_byte_order(scope, :least_significant_first)
    request_waveform_data(scope)
    num_data_bytes = get_num_data_bytes(scope)

    data = reinterpret(UInt16, read_num_bytes(scope, num_data_bytes))
    read_end_of_line_character(scope)

    num_data_points = get_num_data_points(scope)
    if length(data) != num_data_points
        error("Transferred data did not have the expected number of data points\nTransferred: $(length(data))\nExpected: $num_values ($num_data_points * $num_values_per_point)\n")
    end

    return data
end


function set_data_transfer_byte_order(scope::Instr{<:AgilentScope}, byte_order::Symbol)
    if byte_order == :least_significant_first
        write(scope, "WAVEFORM:BYTEORDER LSBFIRST")
    elseif byte_order == :most_significant_first
        write(scope, "WAVEFORM:BYTEORDER MSBFIRST")
    else
        error("Data transfer byte order ($byte_order) not recognized")
    end
    return nothing
end

function get_data_transfer_byte_order(scope::Instr{<:AgilentScope})
    return query(scope, "WAVEFORM:BYTEORDER?")
end


function request_waveform_data(scope::Instr{<:AgilentScope})
    write(scope, "WAV:DATA?")
    return nothing
end


function get_num_data_bytes(scope::Instr{<:AgilentScope})
    header = get_data_header(scope)
    num_header_description_bytes = 2
    num_data_points = parse(Int, header[num_header_description_bytes+1:end])
    return num_data_points
end


function get_data_header(scope::Instr{<:AgilentScope})
    # data header is an ASCII character string "#8DDDDDDDD", where the Ds indicate how many
    # bytes follow (p.1433 of Keysight InfiniiVision 4000 X-Series Oscilloscopes
    # Programmer's Guide)
    num_header_description_bytes = 2
    header_description_uint8 = read(scope.sock, num_header_description_bytes)
    if header_description_uint8[1] != UInt8('#')
        error("The waveform data format is not formatted as expected")
    end
    header_block_length = parse(Int, convert(Char, header_description_uint8[2]))
    header_block_uint8 = read(scope.sock, header_block_length)
    header = vcat(header_description_uint8, header_block_uint8)
    header = String(convert.(Char, header))
    return header
end


function read_num_bytes(scope::Instr{<:AgilentScope}, num_bytes)
    output = read(scope.sock, num_bytes)
    return output
end


function read_end_of_line_character(scope::Instr{<:AgilentScope})
    read(scope)
    return nothing
end


function get_num_data_points(scope::Instr{<:AgilentScope})
    return i_query(scope, "WAVEFORM:POINTS?")
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
function get_waveform_info(instr::Instr{<:AgilentScope}, ch::Integer)
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
get_coupling(instr::Instr{<:AgilentScope}; chan=1) = query(instr, "CHANNEL$chan:COUPLING?")


"""
    lpf_on(instr::Instr{<:AgilentScope}; chan=1)

Turn on an internal low-pass filter. When the filter is on, the bandwidth of
the specified channel is limited to approximately 25 MHz.

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
lpf_on(instr::Instr{<:AgilentScope}; chan=1) = write(instr, "CHANNEL$chan:BWLIMIT ON")


"""
    lpf_off(instr::Instr{<:AgilentScope}; chan=1)

Turn off an internal low-pass filter.

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
lpf_off(instr::Instr{<:AgilentScope}; chan=1) = write(instr, "CHANNEL$chan:BWLIMIT OFF")


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
get_lpf_state(instr::Instr{<:AgilentScope}; chan=1) = query(instr, "CHANNEL$chan:BWLIMIT?")


"""
    set_impedance_1Mohm(instr::Instr{<:AgilentScope}; chan=1)

Set impedance to 1MΩ

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
set_impedance_1Mohm(instr::Instr{<:AgilentScope}; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE ONEMEG")


"""
    set_impedance_50ohm(instr::Instr{<:AgilentScope}; chan=1)

Set impedance to 50Ω

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Keywords
- `chan=1`: specific channel
"""
set_impedance_50ohm(instr::Instr{<:AgilentScope}; chan=1) = write(instr, ":CHANNEL$chan:IMPEDANCE FIFTY")


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
get_impedance(instr::Instr{<:AgilentScope}; chan::Integer=1) = query(instr, ":CHANNEL$chan:IMPEDANCE?")


"""
    run(scope)

Run Oscilloscope
"""
run(instr::Instr{<:AgilentScope}) = write(instr, "RUN")


"""
    stop(scope)

Stop Oscilloscope
"""
stop(instr::Instr{<:AgilentScope}) = write(instr, "STOP")


get_waveform_preamble(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:PREAMBLE?")
get_waveform_source(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:SOURCE?")

"""
    get_data_transfer_format(instr::Instr{<:AgilentScope})

Gets data transfer format

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Returns
- `String`: data transfer format
"""
get_data_transfer_format(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:FORMAT?")

"""
    set_data_transfer_format_8bit(instr::Instr{<:AgilentScope})

Set data transfer format to 8bit

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_data_transfer_format_8bit(instr::Instr{<:AgilentScope}) = write(instr, "WAVEFORM:FORMAT BYTE")

"""
set_data_transfer_format_16bit(instr::Instr{<:AgilentScope})

Set data transfer format to 16bit

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_data_transfer_format_16bit(instr::Instr{<:AgilentScope}) = write(instr, "WAVEFORM:FORMAT WORD")

get_waveform_num_points(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:POINTS?")
set_waveform_num_points(instr::Instr{<:AgilentScope}, num_points::Integer) = write(instr, "WAVEFORM:POINTS $num_points")
set_waveform_num_points(instr::Instr{<:AgilentScope}, mode::String) = write(instr, "WAVEFORM:POINTS $mode")

get_waveform_points_mode(instr::Instr{<:AgilentScope}) = query(instr, "WAVEFORM:POINTS:MODE?")

"""
    set_waveform_points_mode(scope, mode)

Set which data to transfer when using `get_data`(@ref)

Inputs:
`scope`: handle to the connected oscilloscope
`mode`:
- `:NORMAL`: transfer the measurement data
- `:RAW`: transfer the raw acquisition data
"""
function set_waveform_points_mode(instr::Instr{<:AgilentScope}, mode::Symbol)
    if mode ∈ [:NORMAL, :RAW]
        write(instr, "WAVEFORM:POINTS:MODE $(mode)")
    else
        error("Mode $mode not recognized. Specify :NORMAL or :RAW instead")
    end
    return nothing
end


function set_speed_mode(instr::Instr{<:AgilentScope}, speed::Integer)
    if speed == 1
        set_data_transfer_format_16bit(instr)
        set_waveform_points_mode(instr, :NORMAL)
    elseif speed == 3
        set_data_transfer_format_16bit(instr)
        set_waveform_points_mode(instr, :RAW)
    elseif speed == 5
        set_data_transfer_format_8bit(instr)
        set_waveform_points_mode(instr, :NORMAL)
    elseif speed == 6
        set_data_transfer_format_8bit(instr)
        set_waveform_points_mode(instr, :RAW)
    end
end

"""
    get_acquisition_type(scope::Instr{<:AgilentScope})

Gets acquisition type

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope

# Returns
- `String`: acquisition type
"""
function get_acquisition_type(scope::Instr{<:AgilentScope})
    return query(scope, "ACQUIRE:TYPE?")
end

"""
    set_acquisition_type_normal(scope::Instr{<:AgilentScope})

Set acquisition type to normal

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_acquisition_type_normal(scope::Instr{<:AgilentScope}) = write(scope, "ACQUIRE:TYPE NORM")

"""
    set_acquisition_type_average(scope::Instr{<:AgilentScope})

Set acquisition type to average

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_acquisition_type_average(scope::Instr{<:AgilentScope}) = write(scope, "ACQUIRE:TYPE AVER")

"""
    set_acquisition_type_high_res(scope::Instr{<:AgilentScope})

Set acquisition type to high res

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_acquisition_type_high_res(scope::Instr{<:AgilentScope}) = write(scope, "ACQUIRE:TYPE HRES")

"""
    set_acquisition_type_peak(scope::Instr{<:AgilentScope})

Set acquisition type to type peak

# Arguments
- `instr::Instr{<:AgilentScope}`: AgilentScope
"""
set_acquisition_type_peak(scope::Instr{<:AgilentScope}) = write(scope, "ACQUIRE:TYPE PEAK")
