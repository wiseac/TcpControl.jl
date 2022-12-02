include("./Agilent4294A.jl")
include("./Agilent4395A.jl")


"""
    get_impedance_analyzer_info(ia::Instr{<:AgilentImpedAnalyzer})

Get current acquisition parameters from the impedance analyzer

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `ImpedanceAnalyzerInfo`: dc_voltage [V]
    ac_voltage [V]
    num_averages
    bandwidth_level [1, 2, 3, 4, 5]
    point_delay_time [s]
    sweep_delay_time [s]
    sweep_direction ["UP", "DOWN"]
"""
function get_impedance_analyzer_info(ia::Instrument{<:AgilentImpedAnalyzer})
    dc_voltage = get_volt_dc(ia)
    ac_voltage = get_volt_ac(ia)
    num_averages = get_num_averages(ia)
    bandwidth_level = get_bandwidth(ia)
    point_delay_time = get_point_delay_time(ia)
    sweep_delay_time = get_sweep_delay_time(ia)
    sweep_direction = get_sweep_direction(ia)
    return ImpedanceAnalyzerInfo(dc_voltage, ac_voltage, num_averages, bandwidth_level, point_delay_time, sweep_delay_time, sweep_direction)
end


"""
    get_num_averages(ia::Instr{<:AgilentImpedAnalyzer})

Get the number of sweep averages being used

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `Float64`: number of sweet averages being iused
"""
function get_num_averages(ia::Instrument{<:AgilentImpedAnalyzer})
    if is_average_mode_on(ia)
        write(ia, "AVERFACT?")
        num_averages = parse(Float64, read_with_timeout(ia))
    else
        num_averages = 1
    end
    return num_averages
end


"""
    is_average_mode_on(ia::Instr{<:AgilentImpedAnalyzer})

Get status for whether average mode is on

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `Bool`: [true, false]
"""
function is_average_mode_on(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "AVER?")
    return parse(Bool, read_with_timeout(ia))
end


"""
    get_point_delay_time(ia::Instr{<:AgilentImpedAnalyzer})
Get time delay value used between data point acquisitions
Output is in [s]
"""
function get_point_delay_time(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "PDELT?")
    point_delay_time = parse(Float64, read_with_timeout(ia)) * u"s"
    return point_delay_time
end


"""
    get_sweep_delay_time(ia::Instr{<:AgilentImpedAnalyzer})

Get time delay value used between sweep acquisitions

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `Float64`: Get time delay value used between sweep acquisitions in [s]
"""
function get_sweep_delay_time(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "SDELT?")
    sweep_delay_time = parse(Float64, read_with_timeout(ia)) * u"s"
    return sweep_delay_time
end


"""
    get_sweep_direction(ia::Instr{<:AgilentImpedAnalyzer})

Get acquisition sweep direction
Output is ["UP", "DOWN"]

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `UP` sweeps along increasing values (left to right on screen),
    `DOWN` sweeps along decreasing values (right to left on screen)
"""
function get_sweep_direction(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "SWED?")
    sweep_direction = read_with_timeout(ia)
    return sweep_direction
end


"""
    get_frequency(ia::Instr{<:AgilentImpedAnalyzer})

Get an array of frequency values with the same number of points as the data trace
Output is in [MHz]

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `Array`: frequency values with the same number of points as the data trace
"""
function get_frequency(ia::Instrument{<:AgilentImpedAnalyzer})
    start_frequency = get_frequency_lower_bound(ia)
    end_frequency = get_frequency_upper_bound(ia)
    num_points = get_num_data_points(ia)
    frequency = collect(LinRange(start_frequency, end_frequency, num_points))
    return frequency
end


"""
    get_frequency_limits(ia::Instr{<:AgilentImpedAnalyzer})

Gets frequency limits

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer

# Returns
- `Tuple{Frequency, Frequency}`: (lower_limit, upper_limit)
"""
function get_frequency_limits(ia::Instrument{<:AgilentImpedAnalyzer})
    lower_bound = get_frequency_lower_bound(ia)
    upper_bound = get_frequency_upper_bound(ia)
    return lower_bound, upper_bound
end

function get_frequency_lower_bound(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "STAR?")
    lower_bound = parse(Float64, read_with_timeout(ia)) * u"Hz"
    return uconvert(u"MHz", lower_bound)
end

function get_frequency_upper_bound(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "STOP?")
    upper_bound = parse(Float64, read_with_timeout(ia)) * u"Hz"
    return uconvert(u"MHz", upper_bound)
end


"""
    set_frequency_limits(ia::Instr{<:AgilentImpedAnalyzer}, lower_limit, upper_limit)

Sets lower and upper frequency limits

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer}`: ImpedanceAnalyzer
- `lower_bound::Frequency`: lower bound
- `upper_bound::Frequency`: upper bound
"""
function set_frequency_limits(ia::Instrument{<:AgilentImpedAnalyzer}, lower_bound::Frequency, upper_bound::Frequency)
    if lower_bound > upper_bound
        error("Lower bound ($lower_bound) is larger than upper bound ($upper_bound)")
    end
    set_frequency_lower_bound(ia, lower_bound)
    set_frequency_upper_bound(ia, upper_bound)
    return nothing
end

function set_frequency_lower_bound(ia::Instrument{<:AgilentImpedAnalyzer}, lower_bound::Frequency)
    write(ia, "STAR $(raw(lower_bound))")
    return nothing
end

function set_frequency_upper_bound(ia::Instrument{<:AgilentImpedAnalyzer}, upper_bound::Frequency)
    write(ia, "STOP $(raw(upper_bound))")
    return nothing
end


"""
    set_num_data_points(ia::Instr{<:AgilentImpedAnalyzer}, num_points)

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer`: ImpedanceAnalyzer
- `num_data_points`: number of data points
"""
function set_num_data_points(ia::Instrument{<:AgilentImpedAnalyzer}, num_data_points)
    write(ia, "POIN $num_data_points")
    return nothing
end


"""
    get_num_data_points(ia::Instr{<:AgilentImpedAnalyzer})

Gets the set number of data points

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer`: ImpedanceAnalyzer

# Returns
- `Int`: number of data points
"""
function get_num_data_points(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "POIN?")
    num_data_points = parse(Int64, read_with_timeout(ia))
    return num_data_points
end


"""
    get_volt_dc(ia::Instr{<:AgilentImpedAnalyzer})

Gets DC voltage

# Arguments
- `ia::Instr{<:AgilentImpedAnalyzer`: ImpedanceAnalyzer

# Returns
- `Float64`: Voltage
"""
function get_volt_dc(ia::Instrument{<:AgilentImpedAnalyzer})
    write(ia, "DCV?")
    volt_dc = parse(Float64, read_with_timeout(ia)) * u"V"
    return volt_dc
end


"""
    set_volt_dc(obj::Instr{<:AgilentImpedAnalyzer}, num::Voltage)

Sets DC voltage

# Arguments
- `obj::Instr{<:AgilentImpedAnalyzer`: ImpedanceAnalyzer
- `num::Voltage`: voltage
"""
set_volt_dc(obj::Instrument{<:AgilentImpedAnalyzer}, num::Voltage) = write(obj, "DCV $(raw(num))")
