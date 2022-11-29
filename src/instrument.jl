import InstrumentConfig: initialize, terminate

"""
An instrument is a generic device with which you can take and read measurements

# Supported Instrument Groups
- `Oscilloscope`
- `Multimeter`
- `PowerSupply`
- `WaveformGenerator`
- `ImpedanceAnalyzer`
- `SourceMeasureUnit`

All instruments can be initialized and terminated. For more
information on how to connect to a supported instrument:
```
help?> initialize
```
Use the help feature for documentation of each of the instrument groups for more detail.

"""
abstract type AbstractInstrument end


mutable struct Instrument{ T <: AbstractInstrument } <: AbstractInstrument
    model::Union{Type, T}
    address::String
    sock::TCPSocket
    connected::Bool
end

function CreateTcpInstr(model, address)
    Instrument{model}(model, address, TCPSocket(), false)
end

function Base.show(io::IO, ::MIME"text/plain", i::TcpInstruments.Instrument)
    model = i.model isa DataType ? i.model : typeof(i.model)
    println("TcpInstruments.Instr{$(i.model)}")
    println("    Group: $(supertype(model))")
    println("    Model: $(model)")
    println("    Address: $(i.address)")
    println("    Connected: $(i.connected)")
end


"""
    initialize(model::Type{Instrument})
    initialize(model::Type{Instrument}, address::String; GPIB_ID::Int=-1)

Initializes a connection to the instrument at the given (input) IP address.

# Arguments
- `model::Type{<:Instrument}`: The device type you are connecting to. Use `help> Instrument` to see available options
- `address` (optional): The ip address of the device. Ex. "10.3.30.23". If not provided, TcpInstruments will look for the address in the config file

# Keywords
- `GPIB_ID`: The GPIB interface ID of your device. This is optional and doesn't need to be set unless you are using a prologix controller to control it remotely

# Returns
- `Instr`: An instrument of the specified model connected to the given IP address.

# Throws
- 'Instrument was not found in your .tcp_instruments.yml file' if the specified model is not listed
"""
function initialize(model::Type{<:AbstractInstrument}, address; GPIB_ID=-1)
    instr_h = CreateTcpInstr(model, address)
    connect!(instr_h)
    remote_mode(instr_h)
    if GPIB_ID >= 0
        set_prologix_chan(instr_h, GPIB_ID)
    end
    return instr_h
end

function initialize(model::Type{<:AbstractInstrument})
    data = nothing
    try
        data = get_config()[string(model)]
    catch e
        error("""
        $(string(model)) was not found in your .tcp_instruments.yml file.
        To update to the latest version:
        `create_config()`

        Otherwise please add it to your config file or
        specify an ip address:
        `initialize($(string(model)), "10.1.30.XX")`

        """)
    end

    # TODO: refactor the following using traits
    if data isa String
        instr_h = initialize(model, data)
    else
        address = get(data, "address", "")
        gpib = get(data, "gpib", "")
        if isempty(gpib)
            instr_h = initialize(model, address)
        else
            instr_h = initialize(model, address, GPIB_ID=gpib)
        end
    end

    return instr_h
end


"""
    terminate(instr::Instrument)

Closes the TCP connection.

# Arguments
- `instr::Instrument`: The device to close the TCP connection
"""
function terminate(instr::AbstractInstrument)
    close!(instr)
    local_mode(instr)
end

"""
    reset(obj)

Resets instrument

# Arguments
- `obj`: The device to reset
"""
reset(obj) = write(obj, "*RST")

remote_mode(obj)   = nothing
local_mode(obj) = nothing

"""
    set_prologix_chan(obj, chan)

Set the prologix channel to given one

# Arguments
- `obj`: The device
- `channel`: The channel number
"""
set_prologix_chan(obj, chan) = write(obj, "++addr $chan")

"""
    get_prologix_chan(obj)

Get the prologix channel

# Arguments
- `obj`: The device

# Returns
- Prologix channel
"""
get_prologix_chan(obj) = query(obj, "++addr")


"""
    info(instr::Instrument)

Asks an instrument to print model number and other device info.

# Arguments
- `obj`: Specified instrument to get device info
"""
info(obj) = query(obj, "*IDN?")


import Base.write, Base.read

"""
    connect!(instr::Instrument)

Connects to the specified instrument via instrument IP addres

# Arguments
- `instr::Instrument`: Specified instrument to be connected

# Throws
- `Cannot connect. Instrument is already connected!`: if instruemnt is already connected
"""
function connect!(instr::AbstractInstrument)
    instr.connected && error("Cannot connect. Instrument is already connected!")
	SCPI_port = 5025
	host,port = split_str_into_host_and_port(instr.address)
	port == 0 && (port = SCPI_port)
	instr.sock = connect(host,port)
	instr.connected = true
end

"""
    close!(instr::Instrument)

Disconnects to the specified instrument and updates instrument connect status

# Arguments
- `instr::Instrument`: Specified instrument to be connected

# Throws
- `Cannot disconnect. Instrument is not connected!`: if instrument is already connected
"""
function close!(instr::AbstractInstrument)::Bool
    !instr.connected && error("Cannot disconnect. Instrument is not connected!")
	close(instr.sock)
	instr.connected = false
end

"""
    write(instr::Instrument, message::AbstractString)

Disconnects to the specified instrument and updates instrument connect status

# Arguments
- `instr::Instrument`: Specified instrument to be written to
- `message::AbstractString`: Message to send to instrument

# Throws
- `Instrument is not connected, cannot write to it!`: if instrument is not connected
"""
function write(instr::AbstractInstrument, message::AbstractString)
    !instr.connected && error("Instrument is not connected, cannot write to it!")
	println(instr.sock, message)
end

function read(instr::AbstractInstrument)
    !instr.connected && error("Instrument is not connected, cannot read from it!")
	return rstrip(readline(instr.sock), ['\r', '\n'])
end

"""
    query(instr::Instrument, message::AbstractString; timeout=2.8)

Writes a message to a device then listens for and returns any output from
the device.

This is a blocking procedure and will block until a response is received from the device or
till it has been blocking for longer than the designated `timeout` time after which an
error will be thrown.

# Arguments
- `instr::Instrument`: Any instrument that supports being written to and read from
- `message::AbstractString`: The message to be sent to the device before listening for a response

# Keywords
- `timeout`: How long to try and listen for a response before giving up and throwing an error. The default time is 2.8 seconds.
    _Note_: if timeout is set to 0 then this will turn off the timeout functionality and `query` may listen/block indefinitely for a response

# Returns
- `Data`: Output from device after message is sent

# Throws
- `Query timed out`: No output from device is receieved within timeout
"""
function query(instr::AbstractInstrument, message::AbstractString; timeout=2.8)
    write(instr, message)
    return timeout == 0 ? read(instr) : read_with_timeout(instr, timeout)
end

"""
    f_query(instr::Instrument, message; timeout=0.5)

Writes a message to a device then listens for and returns any output from
the device.

This is a blocking procedure and will block until a response is received from the device or
till it has been blocking for longer than the designated `timeout` time after which an
error will be thrown.

# Arguments
- `instr::Instrument`: Any instrument that supports being written to and read from
- `message`: The message to be sent to the device before listening for a response

# Keywords
- `timeout`: How long to try and listen for a response before giving up and throwing an error. The default time is 0.5 seconds.
    _Note_: if timeout is set to 0 then this will turn off the timeout functionality and `query` may listen/block indefinitely for a response

# Returns
- `Float64`: Output from device after message is sent
"""
f_query(instr::AbstractInstrument, message; timeout=0.5) = parse(Float64, query(instr, message; timeout=timeout))

"""
    i_query(instr::Instrument, message; timeout=0.5)

Writes a message to a device then listens for and returns any output from
the device.

This is a blocking procedure and will block until a response is received from the device or
till it has been blocking for longer than the designated `timeout` time after which an
error will be thrown.

# Arguments
- `instr::Instrument`: Any instrument that supports being written to and read from
- `message`: The message to be sent to the device before listening for a response

# Keywords
- `timeout=0.5`: How long to try and listen for a response before giving up and throwing an error.
    _Note_: if timeout is set to 0 then this will turn off the timeout functionality and `query` may listen/block indefinitely for a response

# Returns
- `Int64`: Output from device after message is sent
"""
i_query(instr::AbstractInstrument, message; timeout=0.5) = parse(Int64, query(instr, message; timeout=timeout))


"""
    clear_buffer(instr::Instrument)

Remove any unread data from the instrument buffer

# Arguments
- `instr::Instrument`: Instrument to have unread data cleared from buffer
"""
function clear_buffer(instr::AbstractInstrument)
    while !isnothing(read_with_timeout(instr, 0.5))
    end
    return nothing
end

function read_with_timeout(instr::AbstractInstrument, timeout_sec=2.8)
    ch = Channel(1)
    task = @async begin
        reader_task = current_task()
        function timeout_cb(timer)
            put!(ch, :timeout)
            Base.throwto(reader_task, InterruptException())
        end
        timeout = Timer(timeout_cb, timeout_sec)
        data = read(instr)
        timeout_sec > 0 && close(timeout) # Cancel the timeout
        put!(ch, data)
    end
    wait(task)
    bind(ch, task)
    retval = take!(ch)
    if retval === :timeout
        return error("Query timed out")
    end
    return retval
end
