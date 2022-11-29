"""
Supported Instruments:

  - [`AgilentDSOX4024A`](@ref)
  - [`AgilentDSOX4034A`](@ref)
"""
abstract type Oscilloscope <: AbstractInstrument end


"""
Supported models
- `AgilentDSOX4024A`
- `AgilentDSOX4034A`

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`run`](@ref)
- [`stop`](@ref)
- [`get_data`](@ref)
- [`get_waveform_info`](@ref)


- [`get_impedance`](@ref)
- [`set_impedance_1Mohm`](@ref)
- [`set_impedance_50ohm`](@ref)
- [`get_lpf_state`](@ref)
- [`lpf_on`](@ref)
- [`lpf_off`](@ref)
- [`get_coupling`](@ref)
"""
abstract type AgilentScope <: Oscilloscope end
"""
Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`run`](@ref)
- [`stop`](@ref)
- [`get_data`](@ref)
- [`get_waveform_info`](@ref)


- [`get_impedance`](@ref)
- [`set_impedance_1Mohm`](@ref)
- [`set_impedance_50ohm`](@ref)
- [`get_lpf_state`](@ref)
- [`lpf_on`](@ref)
- [`lpf_off`](@ref)
- [`get_coupling`](@ref)
"""
struct AgilentDSOX4024A <: AgilentScope end
"""
Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`run`](@ref)
- [`stop`](@ref)
- [`get_data`](@ref)
- [`get_waveform_info`](@ref)


- [`get_impedance`](@ref)
- [`set_impedance_1Mohm`](@ref)
- [`set_impedance_50ohm`](@ref)
- [`get_lpf_state`](@ref)
- [`lpf_on`](@ref)
- [`lpf_off`](@ref)
- [`get_coupling`](@ref)
"""
struct AgilentDSOX4034A <: AgilentScope end
struct AgilentDSOX1204G <: AgilentScope end

struct ScopeInfo
    format::String
    type::String
    num_points::Int64
    x_increment::Float64
    x_origin::Float64
    x_reference::Float64
    y_increment::Float64
    y_origin::Float64
    y_reference::Float64
    impedance::String
    coupling::String
    low_pass_filter::String
    channel::Int64
end

function Base.show(io::IO, info::ScopeInfo)
    println(io, " ScopeInfo: ")
    if get(io, :compact, false)
        show_core_fields(io, info)
    else
        show_core_fields(io, info)
        show_additional_fields(io, info)
    end
end

function show_core_fields(io::IO, info::ScopeInfo)
    println(io, "        channel: ", info.channel)
    println(io, "         format: ", info.format)
    println(io, "       acq_type: ", info.type)
    println(io, "     num_points: ", info.num_points)
    println(io, "      impedance: ", info.impedance)
    println(io, "       coupling: ", info.coupling)
    println(io, "low_pass_filter: ", info.low_pass_filter)
end

function show_additional_fields(io::IO, info::ScopeInfo)
    println(io, "    x_reference: ", info.x_reference)
    println(io, "       x_origin: ", info.x_origin)
    println(io, "    x_increment: ", info.x_increment)
    println(io, "    y_reference: ", info.y_reference)
    println(io, "       y_origin: ", info.y_origin)
    println(io, "    y_increment: ", info.y_increment)
end


struct ScopeData
    info::Union{ScopeInfo, Nothing}
    volt::Vector{typeof(1.0u"V")}
    time::Vector{typeof(1.0u"s")}
end

function Base.show(io::IO, ::MIME"text/plain", data_array::AbstractArray{ScopeData})
    for idx in eachindex(data_array)
        data = data_array[idx]
        println(io, "Channel #", data.info.channel)
        show(IOContext(io, :compact=>true), data)
        println(io, "-------------------------")
    end
end

function Base.show(io::IO, data::ScopeData)
    println(io, "ScopeData:")
    show_volt_and_time(io, data)
    show(IOContext(io, :compact=>true), data.info)
    return nothing
end

function show_volt_and_time(io::IO, data::ScopeData)
    println(io, "          volt: ", size(data.volt), " ", unit(data.volt[1]))
    println(io, "          time: ", size(data.time), " ", unit(data.time[1]))
    return nothing
end
