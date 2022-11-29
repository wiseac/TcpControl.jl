"""
    enable_output(obj::Instr{<:VersatilePowerSupply})

This will enable an output on a device.

# Arguments
- `obj::Instr{<:VersatilePowerSupply}`: VersatilePowerSupply
"""
enable_output(obj::Instrument{<:VersatilePowerSupply}) = write(obj, "OUTPUT ON")

"""
    disable_output(obj::Instr{<:VersatilePowerSupply})

This will disable an output on a device.

# Arguments
- `obj::Instr{<:VersatilePowerSupply}`: Power Supply Instrument
"""
disable_output(obj::Instrument{<:VersatilePowerSupply}) = write(obj, "OUTPUT OFF")


"""
    get_output_status(obj::Instr{<:VersatilePowerSupply})

This will return the state of an output on a device.

# Arguments
- `obj::Instr{<:VersatilePowerSupply}`: Power supply instrument

# Returns
- `String`: {"OFF"|"ON"}
"""
get_output_status(obj::Instrument{<:VersatilePowerSupply}) = query(obj, "OUTPUT?")

"""
    set_voltage(obj::Instr{<:VersatilePowerSupply}, num::Voltage)

This will change the voltage output of a device.


Supported Instruments:
   - Power supply

# Returns
  Nothing
"""
set_voltage(obj::Instrument{<:VersatilePowerSupply}, num::Voltage) = write(obj, "VOLTAGE $(raw(num))")

"""
    get_voltage(obj::Instr{<:VersatilePowerSupply})

This will return the voltage of a device

Supported Instruments:
   - Power supply

# Returns
  Voltage
"""
get_voltage(obj::Instrument{<:VersatilePowerSupply}) = f_query(obj, "VOLTAGE?") * V

"""
    set_current_limit(obj::Instr{<:VersatilePowerSupply}, num::Current)

This will change the current limit of a device

# Arguments
- `obj::Instr{<:VersatilePowerSupply}: Power supply
- `num::Current`: current limit
"""
set_current_limit(obj::Instrument{<:VersatilePowerSupply}, num::Current) = write(obj, "CURRENT $(raw(num))")

"""
    get_current_limit(obj::Instr{<:VersatilePowerSupply})

This will return the current limit of a device.


Supported Instruments:
   - Power supply

# Returns
  Current Limit
"""
get_current_limit(obj::Instrument{<:VersatilePowerSupply}) = query(obj, "CURRENT?")


"""
    remote_mode(obj::Instr{<:VersatilePowerSupply})

Set device to remote mode
"""
remote_mode(obj::Instrument{<:VersatilePowerSupply}) = write(obj, "SYSTEM:MODE REMOTE")

"""
    local_mode(obj::Instr{<:VersatilePowerSupply})

Set device to remote mode
"""
local_mode(obj::Instrument{<:VersatilePowerSupply}) =   write(obj, "SYSTEM:MODE LOCAL")
