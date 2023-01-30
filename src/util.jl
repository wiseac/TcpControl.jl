raw(a::Current)   = Float64(ustrip(uconvert(A, a)))
raw(a::Voltage)   = Float64(ustrip(uconvert(V, a)))
raw(a::Frequency) = Float64(ustrip(uconvert(Hz, a)))
raw(a::Time)      = Float64(ustrip(uconvert(u"s", a)))
raw(non_unitful_input) = non_unitful_input

function elapsed_time(start_time)
    seconds = floor(time() - start_time)
    return Time(0) + Second(seconds)
end

function elapsed_time(func, start_time)
    seconds = floor(time() - start_time)
    return Time(0) + Second(func(seconds))
end

"""
    save(data)
    save(data; format=:matlab)
    save(data; filename="custom_file_name.ext")

Save data to a file

By default saves to julia format (.jld2) but can also export
data to matlab by using the format=:matlab keyword argument

# Arguments
- `data`: data to be saved to file

# Keywords
- `filename = ""`: default file name
- `format = :julia`: default julia format
"""
function save(data; filename = "", format = :julia)
    if isempty(filename)
        t = Dates.format(Dates.now(), "yy-mm-dd_HH:MM:SS")
        filename = "InstrumentData_" * t
    end
    if format == :julia
        @save (filename * ".jld2") data
    elseif format == :matlab
        matfile = matopen(filename * ".mat", "w"; compress=true)
        save_to_matfile(matfile, data)
        close(matfile)
    end
end

function save_to_matfile(matfile, data::ScopeData)
    info = data.info
    volt = ustrip.(data.volt)
    time = ustrip.(data.time)
    volt_unit = string(unit(data.volt[1]))
    time_unit = string(unit(data.time[1]))
    write(matfile, "info", info)
    write(matfile, "volt", volt)
    write(matfile, "time", time)
    write(matfile, "volt_unit", volt_unit)
    write(matfile, "time_unit", time_unit)
end

function save_to_matfile(matfile, data_array::Array{ScopeData})
    array_length = length(data_array)
    for idx = 1:array_length
        data_dict = Dict()
        scope_data = data_array[idx]
        data_dict["info"] = scope_data.info
        data_dict["volt"] = ustrip.(scope_data.volt)
        data_dict["time"] = ustrip.(scope_data.time)
        data_dict["volt_unit"] = string(unit(scope_data.volt[1]))
        data_dict["time_unit"] = string(unit(scope_data.time[1]))
        write(matfile, "channel_$(scope_data.info.channel)", data_dict)
    end
end

function save_to_matfile(matfile, data::ImpedanceAnalyzerData)
    info = Dict()
    for fieldname in fieldnames(typeof(data.info))
        val = raw(getfield(data.info, fieldname))
        info[string(fieldname)] = val
    end
    frequency = ustrip.(data.frequency)
    impedance = ustrip.(data.impedance)
    frequency_unit = string(unit(data.frequency[1]))
    impedance_unit = string(unit(data.impedance[1]))
    write(matfile, "info", info)
    write(matfile, "frequency", frequency)
    write(matfile, "impedance", impedance)
    write(matfile, "frequency_unit", frequency_unit)
    write(matfile, "impedance_unit", impedance_unit)
end

function save_to_matfile(matfile, data)
    data_unit = string(unit(data[1]))
    if isempty(data_unit)
        data_unit = "no units"
    end
    write(matfile, "data", raw.(data))
    write(matfile, "data_unit", data_unit)
end

function save_to_matfile(matfile, data::String)
    write(matfile, "data", data)
end


"""
    data = load("function load(filename)
    ")

Loads saved data from a file

# Arguments
- `filename`: name of file

# Returns
- `Dict`: data from file
"""
function load(filename)
    ext = split(filename, '.')[end]
    if ext == "jld2"
        data = jldopen(filename)["data"]
    elseif ext == "mat"
        data = matread(filename)
    else
        error("unsupported file type: $ext")
    end

    return data
end


"""
    scan_network(; network_id="10.1.30.0", host_range=1:255)

By default, report all found devices between addresses `10.1.30.1` to `10.1.30.255`.

Searches for devices connected on port:
- 5025 (scpi)
- 1234 (prologix)

# Keywords
- `network="10.1.30."`: IP address
- `host_range=1:255`: range for IP address

# Returns
- `Array`: IP Addresses
"""
function scan_network(; network="10.1.30.", host_range=1:255)
    network = ensure_ending_dot(network)
    @info "Scanning $network$(host_range[1])-$(host_range[end])"

    # Scan for SCPI devices
    println("Scanning for SCPI devices")
    ips_scpi = asyncmap(x-> _get_info_from_ip(x), [network*"$ip" for ip in host_range])
    println("")

    # Scan for Prologix device
    println("Scanning for Prologix devices")
    ips_prlx = asyncmap(x-> _get_info_from_ip(x; port=1234), [network*"$ip" for ip in host_range])

    ips_all = vcat(ips_scpi, ips_prlx)
    print("\n")
    return [ip for ip in ips_all if !isempty(ip)]
end
ensure_ending_dot(network) = network[end] != '.' ? network*'.' : network

function _get_info_from_ip(ip_str; port = 5025)
    temp_ip = ip_str * ":$port"
    proc = @spawn temp_ip => _get_instr_info_and_close(temp_ip)
    sleep(2)
    if proc.state == :runnable
        print("t") # for time out
        kill_task(proc)
        return ""
    elseif proc.state == :done
        printstyled("s"; color = :green) # for success
        return fetch(proc)
    elseif proc.state == :failed
        print("f") # for failed
        return ""
    else
        error("Uncaught state: $(proc.state)")
    end
end

kill_task(proc) = schedule(proc, ErrorException("Timed out"), error=true)

function _get_instr_info_and_close(ip)

    obj = initialize(AbstractInstrument, ip)
    info_str = info(obj)
    terminate(obj)
    return info_str
end

"""
    scan_prologix(ip::AbstractString)

Scans all GPIB addresses on a prologix device having the ip-address `ip`.

# Arguments
- `ip::AbstractString`: IP address

# Returns
- `Dict`: devices
"""
function scan_prologix(ip::AbstractString)
    devices = Dict()
    prologix_port = ":1234"
    full_ip = ip * prologix_port
    obj = initialize(AbstractInstrument, ip)

    for i in 0:15
        write(obj, "++addr $i")
        try
            devices[i] = query(obj, "*IDN?"; timeout=0.5)
        catch

        end
    end
    return devices
end


udef(func) =  error("$(func) not implemented")

macro codeLocation()
    return quote
        st = stacktrace(backtrace())
        myf = ""
        for frm in st
            funcname = frm.func
            if frm.func != :backtrace && frm.func != Symbol("macro expansion")
                myf = frm.func
                break
            end
        end
        println(
            "Running function ",
            $("$(__module__)"),
            ".$(myf) at ",
            $("$(__source__.file)"),
            ":",
            $("$(__source__.line)"),
        )

        myf
    end
end

function alias_print(msg)
    printstyled("[ Aliasing: ", color = :blue, bold = true)
    println(msg)
end

"""
	split_str_into_host_and_port(str)
Splits a string like "192.168.1.1:5056" into ("192.168.1.1", 5056)
"""
function split_str_into_host_and_port(str::AbstractString)
	spl_str = split(str, ":")
    isempty(spl_str) && error("IP address string is empty!")
    host = spl_str[1]
    if length(spl_str) == 1
        port = 0
    else
        port = parse(Int, spl_str[2])
    end
    return (host, port)
end

function autoscale_seconds(seconds)
    max_val = maximum(abs.(seconds))
    _, unit = convert_to_best_prefix(max_val; base_unit = "s")
    power_of_1000, _, factor = get_power_of_1000(max_val; max_power = 0)
    factor = 1000.0^power_of_1000
    seconds_scaled = seconds .* factor
    return seconds_scaled, unit
end

function new_autoscale_unit(value_in::Vector{<:Unitful.AbstractQuantity})
    max_val = maximum(abs.(value_in))
    scaled_value = convert_to_best_prefix(max_val)
    best_unit = unit(scaled_value)
    scaled_values  = uconvert.(best_unit, value_in)
    return scaled_values
end

"""
    convert_to_best_prefix(input_value; base_unit::String = "", max_power = 3)

# Inputs
- base_unit: Usually "v", "s", or "m"
- max_power: is the maximum power of 1000 to convert to. Valid values: -4:3

# Examples
- convert_to_best_prefix(1.7e5; base_unit = "V")
- convert_to_best_prefix(1.7e5; base_unit = "s", max_power=0)
"""
function convert_to_best_prefix(input_value; base_unit::String, max_power_of_1000 = 3)
    if input_value == 0 || input_value == 1000
        factor = 1
        value = input_value
        unit = base_unit
    else
        power_of_1000, unit_prefix, factor = get_power_of_1000(input_value; max_power=max_power_of_1000)
        value = input_value * factor
        unit = unit_prefix * base_unit
    end
    return value, unit
end

"""
    convert_to_best_prefix(input_value::Unitful.AbstractQuantity; max_power = 3)

# Inputs
- max_power: is the maximum power of 1000 to convert to. Valid values: -4:3

# Examples
- convert_to_best_prefix(1.7e5u"V")
- convert_to_best_prefix(1.7e5u"s", max_power=0)
"""
function convert_to_best_prefix(input_value::Unitful.AbstractQuantity)
    if ustrip(input_value) == 0 || ustrip(input_value) == 1000
        scaled_value = input_value
    else
        isa(input_value, Unitful.Time) ? max_power = 0 : max_power = 3
        _, unit_prefix = get_power_of_1000(ustrip(input_value); max_power=max_power)
        prefixed_unit = uparse(unit_prefix * string(unit(input_value)))
        scaled_value  = uconvert(prefixed_unit, input_value)
    end
    return scaled_value
end

function get_power_of_1000(input_value; max_power = 3)
    if input_value == 0 || input_value == 1000
        power_of_1000 = 0;
        unit_prefix = "";
        error("Invalid Input")
    else
        array_indices = -4:3
        min_power = minimum(array_indices)
        prefixes = OffsetArrays.OffsetArray(["p", "n", "µ", "m", "", "k", "M", "G"], array_indices)
        power_of_1000 = Int(floor(log(1000, abs(input_value))))
        power_of_1000 = clamp(power_of_1000, min_power, max_power)
        unit_prefix = prefixes[power_of_1000]
        factor = 1000.0^(-power_of_1000)
    end
    return power_of_1000, unit_prefix, factor
end

function fake_signal(n)
    fs = 2.0e9;
    f0 = 10.0e6;
    dt = 1/fs
    num_cycles = 10
    t = (0:(num_cycles*fs/f0-1)) .* dt
    s = sin.(2*pi*f0.*t)

    if n >= length(s)
        n_zeros = n-length(s)
        n_pre  = Int(floor(n_zeros/2))
        n_post = Int(ceil(n_zeros/2))
        out = [zeros(n_pre); s; zeros(n_post)]
    else
        out = s[1:n]
    end
    return out
end


function timeout1(f, timeout_sec)
    retval = nothing
    t = @async begin
        task = current_task()
        function timeout_cb(timer)
            Base.throwto(task, InterruptException())
        end
        timeout = Timer(timeout_cb, timeout_sec)
        try
            retval = f()
        catch e
            if typeof(e) == InterruptException
                error("Timed out after $(timeout_sec) s")
            end
        end
        close(timeout)
    end
    try
        wait(t)
    catch ex
        throw(ex.task.exception)
    end
    return retval
end



function timeout2(f, timeout_sec)
    data = nothing
    ch = Channel(1)
    task = @async begin
        reader_task = current_task()
        function timeout_cb(timer)
            Base.throwto(reader_task, InterruptException())
        end
        timeout = Timer(timeout_cb, timeout_sec)
        try
            data = f()
        catch e
            if typeof(e) == InterruptException
                data = :timeout
            end
        end
        timeout_sec > 0 && close(timeout) # Cancel the timeout
        put!(ch, data)
    end
    wait(task)
    bind(ch, task)
    retval = take!(ch)
    if retval === :timeout
        error("Timed out after $(timeout_sec) s.")
        return nothing
    end
    return retval
end

call_w_timeout = timeout1
