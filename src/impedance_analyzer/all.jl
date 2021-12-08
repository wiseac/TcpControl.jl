include("./Agilent4294A.jl")
include("./Agilent4395A.jl")


struct ImpedanceAnalyzerInfo
    dc_voltage::Unitful.Voltage
    ac_voltage::Unitful.Voltage
    num_averages::Int64
    bandwidth_level::Int64
    point_delay_time::Unitful.Time
    sweep_delay_time::Unitful.Time
    sweep_direction::String
end

struct ImpedanceAnalyzerData
    info::Union{ImpedanceAnalyzerInfo, Nothing}
    frequency::Vector{typeof(1.0u"Hz")}
    impedance::Vector{typeof(1.0u"Ω")}
end


function get_impedance_analyzer_info(ia::Instr{<:ImpedanceAnalyzer})
    dc_voltage = get_volt_dc(ia)
    ac_voltage = get_volt_ac(ia)
    num_averages = get_num_averages(ia)
    bandwidth_level = get_bandwidth(ia)
    point_delay_time = get_point_delay_time(ia)
    sweep_delay_time = get_sweep_delay_time(ia)
    sweep_direction = get_sweep_direction(ia)
    return ImpedanceAnalyzerInfo(dc_voltage, ac_voltage, num_averages, bandwidth_level, point_delay_time, sweep_delay_time, sweep_direction)
end


function get_num_averages(ia::Instr{<:ImpedanceAnalyzer})
    return -1
end


function get_point_delay_time(ia::Instr{<:ImpedanceAnalyzer})
    return -1
end


function get_sweep_delay_time(ia::Instr{<:ImpedanceAnalyzer})
    return -1
end


function get_sweep_direction(ia::Instr{<:ImpedanceAnalyzer})
    return "PLACEHOLDER"
end


"""
    get_frequency_limits(instr)

# Returns
`Tuple{Frequency, Frequency}`: (lower_limit, upper_limit)
"""
function get_frequency_limits(ia::Instr{T}) where T <: ImpedanceAnalyzer
    lower_bound = get_frequency_lower_bound(ia)
    upper_bound = get_frequency_upper_bound(ia)
    return lower_bound, upper_bound
end

function get_frequency_lower_bound(ia::Instr{T}) where T <: ImpedanceAnalyzer
    write(ia, "STAR?")
    lower_bound = parse(Float64, read(ia)) * u"Hz"
    return uconvert(u"MHz", lower_bound)
end

function get_frequency_upper_bound(ia::Instr{T}) where T <: ImpedanceAnalyzer
    write(ia, "STOP?")
    upper_bound = parse(Float64, read(ia)) * u"Hz"
    return uconvert(u"MHz", upper_bound)
end


"""
    set_frequency_limits(instr, lower_limit, upper_limit)

"""
function set_frequency_limits(ia::Instr{T}, lower_bound::Frequency, upper_bound::Frequency) where T <: ImpedanceAnalyzer
    if lower_bound > upper_bound
        error("Lower bound ($lower_bound) is larger than upper bound ($upper_bound)")
    end
    set_frequency_lower_bound(ia, lower_bound)
    set_frequency_upper_bound(ia, upper_bound)
    return nothing
end

function set_frequency_lower_bound(ia::Instr{T}, lower_bound::Frequency) where T <: ImpedanceAnalyzer
    write(ia, "STAR $(raw(lower_bound))")
    return nothing
end

function set_frequency_upper_bound(ia::Instr{T}, upper_bound::Frequency) where T <: ImpedanceAnalyzer
    write(ia, "STOP $(raw(upper_bound))")
    return nothing
end


"""
    set_num_data_points(instr, num_points)

"""
function set_num_data_points(ia::Instr{T}, num_data_points) where T <: ImpedanceAnalyzer
    write(ia, "POIN $num_data_points")
    return nothing
end


"""
    get_num_data_points(instr)

"""
function get_num_data_points(ia::Instr{T}) where T <: ImpedanceAnalyzer
    write(ia, "POIN?")
    num_data_points = parse(Int64, read(ia))
    return num_data_points
end


"""
    get_volt_dc(instr)

"""
get_volt_dc(obj::Instr{T}) where (T <: ImpedanceAnalyzer) =
    f_query(obj, "DCV?") * V

"""
    set_volt_dc(instr, volts)

"""
set_volt_dc(obj::Instr{T}, num::Voltage) where (T <: ImpedanceAnalyzer) =
    write(obj, "DCV $(raw(num))")
