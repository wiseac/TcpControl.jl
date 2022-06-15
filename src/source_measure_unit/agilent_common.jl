"""
    enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1)

    Enable channel output.
"""
enable_output(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1) = write(obj, ":OUTP$chan ON")

"""
    disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1)

    Disable channel output.
"""
disable_output(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1) = write(obj, ":OUTP$chan OFF")

"""
    set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1)

    Set channel as voltage source.
"""
set_voltage_mode(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1) = write(obj, ":SOUR$chan:FUNC:MODE VOLT")

"""
    set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1)

    Set channel as current source.
"""
set_current_mode(obj::Instr{<:AgilentSourceMeasureUnit}; chan = 1) = write(obj, ":SOUR$chan:FUNC:MODE CURR")

"""
    set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::Current; chan = 1)

    Set channel output current.
"""
set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::Current; chan = 1) = write(obj, ":SOUR$chan:CURR $(raw(current))")

"""
    set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::String; chan = 1)

    Set channel output current.

    # Keywords
    - `current': "MIN" | "MAX" | "DEF" (Default)
"""
function set_output_current(obj::Instr{<:AgilentSourceMeasureUnit}, current::String = "DEF" ; chan = 1)
    verify_value_specifier(current)
    write(obj, ":SOUR$chan:CURR $current")
end

"""
    set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Voltage; chan = 1)

    Set channel output voltage .
"""
set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Voltage; chan = 1) = write(obj, ":SOUR$chan:VOLT $(raw(voltage))")

"""
set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::String; chan = 1)

    Set channel output voltage.

    # Keywords
    - `voltage': "MIN" | "MAX" | "DEF" (Default)
"""
function set_output_voltage(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::String = "DEF" ; chan = 1)
    verify_value_specifier(voltage)
    write(obj, ":SOUR$chan:VOLT $voltage")
end

"""
    set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::Current; chan = 1)

    Set channel output current limit. The limit is applied to both positive and negative current.
"""
set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::Current; chan = 1) = write(obj, ":SENS$chan:CURR:PROT $(raw(current))")

"""
    set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::Current; chan = 1)

    Set channel output current limit. The limit is applied to both positive and negative current.

    # Keywords
    - `current': "MIN" | "MAX" | "DEF" (Default)
"""
function set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::String = "DEF" ; chan = 1)
    verify_value_specifier(current)
    write(obj, ":SENS:$chan:CURR:PROT $current")
end

"""
    set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Voltage; chan = 1)

    Set channel output voltage limit. The limit is applied to both positive and negative current.
"""
set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, voltage::Voltage; chan = 1) = write(obj, ":SENS$chan:VOLT:PROT $(raw(voltage))")

"""
    set_voltage_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::Voltage; chan = 1)

    Set channel output voltage limit. The limit is applied to both positive and negative voltage.

    # Keywords
    - `current`: "MIN" | "MAX" | "DEF" (Default)
"""
function set_current_limit(obj::Instr{<:AgilentSourceMeasureUnit}, current::String = "DEF" ; chan = 1)
    verify_value_specifier(current)
    write(obj, ":SENS:$chan:CURR:PROT $current")
end


"""
    set_measurement_mode(obj::Instr{<:AgilentSourceMeasureUnit};
        chan= 1, current=false, voltage=false, resistance=false  
        )
"""
function set_measurement_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    chan= 1, current=false, voltage=false, resistance=false  
    )
    mode = ""
    current && add_mode!(mode, "CURR")
    voltage && add_mode!(mode, "VOLT")
    resistance && add_mode!(mode, "RES")
    isempty(mode) && error("The mode was empty. You must set one or more of the input arguments: current, voltage, and resistance to true.")
    
    write(obj, ":SENS$chan:FUNC:OFF:ALL")
    write(obj, ":SENS$chan:FUNC $(mode)")
    return nothing
end

"""
    set_source_mode(obj::Instr{<:AgilentSourceMeasureUnit};
        chan = 1,
        type = "VOLT",
        mode = "FIX"
        )

    # Keywords
    - `type`: "CURR" | "VOLT" (Default)
    - 'mode': "FIX" (Default) | "LIST" | "SWE"

    mode=FIX sets the constant current or voltage source.
    mode=LIST sets the user-specified current or voltage list sweep source. Specified by set_sweep_steps()
    mode=SWEep sets the current or voltage sweep source. Specified by set_list_sweep()
"""
function set_source_mode(obj::Instr{<:AgilentSourceMeasureUnit};
    chan = 1,
    type = "VOLT",
    mode = "FIX"
    )

    verify_source_type(type)
    verify_source_mode(mode)

    write(obj, ":SOUR$chan:$type:MODE $mode")
    return nothing
end

verify_source_type(type) = !(type in ["VOLT", "CURR"]) && error("Source type \"$type\" is not valid!\nIt's value must be \"VOLT\" or \"CURR\".") 
verify_source_mode(mode) = !(mode in ["FIX", "LIST", "SWE"]) && error("Source mode \"$mode\" is not valid!\nIt's value must be \"FIX\", \"LIST\", or \"SWE\".")

"""
    spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit};
    chan = 1,
    type = "VOLT"
    )

    # Keywords
    - `type`: "CURR" | "VOLT" (Default)
    - 'mode': "FIX" (Default) | "LIST" | "SWE"
"""
function spot_measurement(obj::Instr{<:AgilentSourceMeasureUnit};
    chan = 1,
    type = "VOLT"
    )

    verify_measurement_type(type)
    val  = f_query(obj, "MEAS:$type (@$chan)")
    return attach_type!(val, type)
end

verify_measurement_type(type) =  !(type in ["VOLT", "CURR", "RES"]) && error("Measurement type \"$type\" is not valid!\nIt's value must be \"VOLT\", \"CURR\", or \"RES\".")

function attach_type!(value, type)
    if type == "VOLT"
        value = value * V
    end

    if type == "CURR"
        value = value * A
    end

    if type == "RES"
        value = value * R
    end

    return value
end

function add_mode!(buffer, mode)
    isempty(buffer) ? pre = "\"" : pre = ",\""
    post = "\""
    push!(buffer, pre*mode*post)
    return nothing
end

verify_value_specifier(value) = !(value in ["MIN", "MAX", "DEF"]) && error("Value specifier \"$value\" is not valid!\nIt's value must be \"MIN\", \"MAX\", or \"DEF\".")
#=
TODO - Functions to implement:
- [`set_source_mode`](@ref)
- [`set_current_or_voltage`](@ref)
- [`set_limit`](@ref)
- [`get_measurement`](@ref)
- [`enable_autorange`](@ref)
- [`disable_autorange`](@ref)
- [`set_measurement_time`](@ref)
- [`set_measurement_time`](@ref)
=#
