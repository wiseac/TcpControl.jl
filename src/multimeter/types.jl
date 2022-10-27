"""
Supported Instruments:

  - [`KeysightDMM34465A`](@ref)
"""
abstract type Multimeter <: Instrument end

"""
Supported models
- `KeysightDMM34465A`

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`get_channel`](@ref)
- [`get_voltage`](@ref)
- [`get_current`](@ref)
- [`get_resistance`](@ref)
- [`get_tc_temperature`](@ref)
- [`set_tc_type`](@ref)
- [`get_temp_unit`](@ref)
- [`set_temp_unit_celsius`](@ref)
- [`set_temp_unit_farenheit`](@ref)
- [`set_temp_unit_kelvin`](@ref)
"""
abstract type KeysightMultimeter <: Multimeter end

"""
Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)


- [`get_channel`](@ref)
- [`get_voltage`](@ref)
- [`get_current`](@ref)
- [`get_resistance`](@ref)
- [`get_tc_temperature`](@ref)
- [`set_tc_type`](@ref)
- [`get_temp_unit`](@ref)
- [`set_temp_unit_celsius`](@ref)
- [`set_temp_unit_farenheit`](@ref)
- [`set_temp_unit_kelvin`](@ref)
"""
struct KeysightDMM34465A <: KeysightMultimeter end
