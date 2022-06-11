"""
- [`AgilentSourceMeasureUnit`](@ref)
"""
abstract type SourceMeasureUnit <: Instrument end


"""
Supported model
- `AgilentB2910BL`

Supported functions
- [`initialize`](@ref)
- [`terminate`](@ref)

- [`enable_output`](@ref)
- [`disable_output`](@ref)
- [`set_source_mode`](@ref)
- [`set_current_or_voltage`](@ref)
- [`set_limit`](@ref)
- [`set_measurement_mode`](@ref)
- [`get_measurement`](@ref)
- [`enable_autorange`](@ref)
- [`disable_autorange`](@ref)
- [`set_measurement_time`](@ref)
- [`set_measurement_time`](@ref)


"""
abstract type AgilentSourceMeasureUnit <: SourceMeasureUnit end
struct AgilentB2910BL <: AgilentSourceMeasureUnit end
