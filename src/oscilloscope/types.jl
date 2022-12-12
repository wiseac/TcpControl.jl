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

function show(io::IO, x::ScopeInfo)
    println(io, "(ScopeInfo:")
    println(io, "          .format:  \"$(x.format)\"")
    println(io, "            .type:  \"$(x.type)\"")
    println(io, "      .num_points:  $(x.num_points)")
    println(io, "     .x_increment:  $(x.x_increment)")
    println(io, "        .x_origin:  $(x.x_origin)")
    println(io, "     .x_reference:  $(x.x_reference)")
    println(io, "     .y_increment:  $(x.y_increment)")
    println(io, "        .y_origin:  $(x.y_origin)")
    println(io, "     .y_reference:  $(x.y_reference)")
    println(io, "       .impedance:  \"$(x.impedance)\"")
    println(io, "        .coupling:  \"$(x.coupling)\"")
    println(io, " .low_pass_filter:  \"$(x.low_pass_filter)\"")
    println(io, "         .channel:  $(x.channel)")
    println(io, ")")
end


struct ScopeData
    info::Union{ScopeInfo, Nothing}
    volt::Vector{typeof(1.0u"V")}
    time::Vector{typeof(1.0u"s")}
end

function show(io::IO, x::ScopeData)
    println(io, "ScopeData has three fields: .info, .volt, and .time.")
    if isnothing(x.info)
        println(io, "ScopeData.info: nothing")
    else
        println(io, "ScopeData.info contains:")
        Base.show(io, x.info)
    end

    seconds = new_autoscale_unit(x.time)
    volt    = new_autoscale_unit(x.volt)

    time_unit = unit(seconds[1])
    volt_unit = unit(volt[1])
    seconds = raw.(seconds)
    volt    = raw.(volt)

    println(io, "\nPlot of ScopeData.volt vs ScopeData.time:")
    plt = UnicodePlots.lineplot(seconds, volt;
        title = "Voltage Trace",
        name="Channel $(x.info.channel)",
        width = 70,
        height= 25,
        margin= 1,
        xlabel="Time / $(time_unit)",
        ylabel="Volt / $(volt_unit)")
    show(io, plt)
    println("")
end
