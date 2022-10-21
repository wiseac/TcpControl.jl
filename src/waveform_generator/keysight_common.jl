"""
    get_output_status(wave_gen; chan=1)

Get the status of the front panel output connector

Returns "ON" or "OFF"
"""
function get_output_status(obj::Instr{<:KeysightWaveGen}; chan=1) 
    return query(obj, "OUTPUT$chan?") == "1" ? "ON" : "OFF"
end


"""
    set_output_on(wave_gen; chan=1)

Activate the front panel output connector

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen
"""
set_output_on(obj::Instr{<:KeysightWaveGen}; chan=1) = write(obj, "OUTPUT$chan ON")


"""
    set_output_off(wave_gen; chan=1)

Deactivate the front panel output connector

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen

# Keywords
- `chan=1`: specific channel
"""
set_output_off(obj::Instr{<:KeysightWaveGen}; chan=1) = write(obj, "OUTPUT$chan OFF")


"""
    get_frequency(wave_gen; chan=1)

Returns the signal frequency for the channel [Hz]

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen

# Returns
- `Float64`: signal frequency for the channel [Hz]
"""
get_frequency(obj::Instr{<:KeysightWaveGen}; chan=1) =
    f_query(obj, "SOURCE$chan:FREQUENCY?") * Hz


"""
    set_frequency(wave_gen; chan=1)

Set the signal frequency for the channel [Hz]

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator  
- `num::Frequency`: signal frequency for the channel  

# Keywords
- `chan=1`: specific channel
"""
set_frequency(obj::Instr{<:KeysightWaveGen}, num::Frequency; chan=1) =
    write(obj, "SOURCE$chan:FREQUENCY $(raw(num))")


"""
    get_amplitude(wave_gen; chan=1)

Returns the peak to peak voltage for the channel [Vpp]

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator  

# Keywords
- `chan=1`: specific channel
"""
get_amplitude(obj::Instr{<:KeysightWaveGen}; chan=1) =
    f_query(obj, "SOURCE$chan:VOLTAGE?") * V


"""
    set_amplitude(wave_gen; chan=1)

Set the peak to peak voltage for the channel [Vpp]

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator
- `num::Voltage`: peak voltage for the channel

# Keywords
- `chan=1`: specific channel
"""
set_amplitude(obj::Instr{<:KeysightWaveGen}, num::Voltage; chan=1) =
    write(obj, "SOURCE$chan:VOLTAGE $(raw(num))")


"""
    get_voltage_offset(wave_gen; chan=1)

Returns the voltage offset for the channel [V]

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator

# Keywords
- `chan=1`: specific channel
"""
get_voltage_offset(obj::Instr{<:KeysightWaveGen}; chan=1) =
    f_query(obj, "SOURCE$chan:VOLTAGE:OFFSET?") * V


"""
    set_voltage_offset(wave_gen; chan=1)

Set the voltage offset for the channel [V]

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator
- `num::Voltage`: voltage offset

# Keywords
- `chan`: Specify channel: Default is 1
"""
set_voltage_offset(obj::Instr{<:KeysightWaveGen}, num::Voltage; chan=1) =
    write(obj, "SOURCE$chan:VOLTAGE:OFFSET $(raw(num))")


"""
    get_function(instr)
    get_function(instr; chan=2)

# Keywords
- `chan`: Specify channel: Default is 1
# Returns
- `String`: Will return one of these shortened forms:
{SINusoid|SQUare|TRIangle|RAMP|PULSe|PRBS|NOISe|ARB|DC}
"""
get_function(obj::Instr{<:KeysightWaveGen}; chan=1) = query(obj, "SOURCE$chan:FUNCTION?")


"""
    set_function(instr, func; chan=1)

# Arguments
- `func::String`: Acceptable inputs:
{SINusoid|SQUare|TRIangle|RAMP|PULSe|PRBS|NOISe|ARB|DC}

# Keywords
- `chan`: Specify channel: Default is 1
"""
set_function(obj::Instr{<:KeysightWaveGen}, func; chan=1) = write(obj, "SOURCE$chan:FUNCTION $func")


"""
    get_mode(instr)
    get_mode(instr; chan=1)

Gets mode of KeysightWaveGen instrument

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator

# Keywords
- `chan=1`: specific chanel

# Returns
- `CW`: if device is in continous wavefrom mode
- `BURST`: if device is in BURST mode
"""
get_mode(obj::Instr{<:KeysightWaveGen}; chan=1) = query(obj, "SOURCE$chan:BURST:STATE?") == "1" ? "BURST" : "CW"


"""
    set_mode_cw(instr)
    set_mode_cw(instr; chan=1)

Puts the device in continuous waveform/turns off burst mode

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen

# Keywords
- `chan=1`: Specify channel
"""
set_mode_cw(obj::Instr{<:KeysightWaveGen}; chan=1) = write(obj, "SOURCE$chan:BURST:STATE OFF")


"""
```
    set_mode_burst(obj::Instr{<:KeysightWaveGen})
```
Changes Waveform Generator mode from continous waveform to burst

By default it sets the type of burst mode to triggered mode. Gated
mode can also be set by using the optional flag:

```
    set_mode_burst(instr; mode=:gated)
```

The optional trig_src flag sets the trigger source for burst
triggered mode. Right now the default is Timer. To implement
more trigger sources see page 130 of the manual for 33612A

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: WaveformGenerator

"""
function set_mode_burst(obj::Instr{<:KeysightWaveGen};
                         chan=1,
                         mode=:trigger,
                         trig_src=:timer)
    if mode == :trigger
        set_burst_mode_trigger(obj)
    elseif mode == :gated
        set_burst_mode_gated(obj)
    else
        error("""mode flag cannot be set to: $mode\n
              available modes are [:trigger, :gated]""")
    end
    if trig_src == :timer
        set_trigger_source_timer(obj; chan=chan)
    else
        error("""trig_src flag cannot be set to: $trig_src\n
              available modes are [:timer]""")
    end
    write(obj, "SOURCE$chan:BURST:STATE ON")
end


"""
    get_burst_mode(instr)
    get_burst_mode(instr; chan=1)

Returns the burst mode of a device:
    "TRIG" ~ If the device is in Triggered Mode
    "GAT" ~ If the device is in Gated Mode
"""
get_burst_mode(obj::Instr{<:KeysightWaveGen}; chan=1) = query(obj, "SOURCE$chan:BURST:MODE?")


"""
    set_burst_mode_trigger(wave_gen; chan=1)

Set the burst mode of a device to Triggered Mode
"""
set_burst_mode_trigger(obj::Instr{<:KeysightWaveGen}; chan=1) = write(obj, "SOURCE$chan:BURST:MODE TRIG")


"""
    set_burst_mode_gated(wave_gen; chan=1)

Set the burst mode of a device to Gated Mode
"""
set_burst_mode_gated(obj::Instr{<:KeysightWaveGen}; chan=1) = write(obj, "SOURCE$chan:BURST:MODE GATED")


"""
    get_burst_num_cycles(instr)
    get_burst_num_cycles(instr; chan=2)

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen

# Keywords
- `chan=1`: specific channel 

# Returns
- `Float64`: number of cycles burst mode is set to
"""
get_burst_num_cycles(obj::Instr{<:KeysightWaveGen}; chan=1) = f_query(obj, "SOURCE$chan:BURST:NCYCLES?")


"""
    set_burst_num_cycles(instr, cycles)
    set_burst_num_cycles(instr, cycles; chan=2)

Sets the number of cycles for burst mode

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen
- `num`: number of cycles for burst mode

# Keywords
- `chan=1`: specific channel
"""
set_burst_num_cycles(obj::Instr{<:KeysightWaveGen}, num; chan=1) = write(obj, "SOURCE$chan:BURST:NCYCLES $(Float64(num))")


"""
    get_burst_period(instr; chan=1)

Get burst period

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen

# Keywords
- `chan::Integer=1`: specific channel

# Returns
- `Float64`: time between bursts [s]
"""
get_burst_period(obj::Instr{<:KeysightWaveGen}; chan::Integer=1) = f_query(obj, "SOURCE$chan:BURST:INTERNAL:PERIOD?") * s


"""
    set_burst_period(obj, duration; chan=1)

Sets burst period for KeysightWaveGen instrument

# Arguments
- `obj::Instr{<:KeysightWaveGen}`: KeysightWaveGen
- `duration`: The number of seconds (This value can also be "MIN" or "MAX")

# Keywords
- `chan::Integer=1`: specific channel
"""
set_burst_period(obj::Instr{<:KeysightWaveGen}, duration; chan::Integer=1) = write(obj, "SOURCE$chan:BURST:INTERNAL:PERIOD $(Float64(duration))")


set_trigger_source_timer(obj::Instr{<:KeysightWaveGen}; chan::Integer=1) = write(obj, "TRIGGER$chan:SOURCE TIMER")


status(obj::Instr{<:KeysightWaveGen}) = query(obj, "APPLY?")
