using Sockets
using Base.Threads: @spawn

function scan_network(; ip_network="10.1.30.", ip_range=1:255)
    @info "Scanning $ip_network$(ip_range[1])-$(ip_range[end])"
    ips = asyncmap(
        x->connect_to_scpy(x),
        [ip_network*"$ip" for ip in ip_range]
    )
    return [s for s in ips if !isempty(s)]
end

function connect_to_scpy(ip_str)
    scpy_port = 5025
    temp_ip = ip_str * ":$scpy_port"
    proc = @spawn temp_ip => info(initialize(Instrument, temp_ip))
    sleep(2)
    if proc.state == :runnable
        schedule(proc, ErrorException("Timed out"), error=true)
        return ""
    elseif proc.state == :done
        return fetch(proc)
    elseif proc.state == :failed
        return ip_str * ":????"
    else
        error("Undefined $(proc.state)")
    end
end

udef(func) =  error("$(func) not implemented")

macro codeLocation()
           return quote
               st = stacktrace(backtrace())
               myf = ""
               for frm in st
                   funcname = frm.func
                   if frm.func != :backtrace && frm.func!= Symbol("macro expansion")
                       myf = frm.func
                       break
                   end
               end
               println("Running function ", $("$(__module__)"),".$(myf) at ",$("$(__source__.file)"),":",$("$(__source__.line)"))
               
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
function split_str_into_host_and_port(str::AbstractString)::Tuple{String, Int}
	spl_str = split(str, ":")
	@assert !isempty(spl_str) "IP address string is empty!"
	host = spl_str[1]
	if length(spl_str) == 1
		port = 0
	else
		port = parse(Int, spl_str[2])
	end
	return (host, port)
end
