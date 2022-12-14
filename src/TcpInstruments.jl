"""
TcpInstruments is an ongoing effort to provide a simple unified
interface to common lab equipment.

To connect to an instrument use:
```
handle = initialize({Instrument-Type}, "IP-ADDRESS:PORT")
```

To prevent hardcoding in scripts and/or to make it simplier for
your lab or organization to keep track of all the equipment and
ip addresses a configuration file can also be specified.

To use Orchard Ultrasound's latest lab config use:
```
create_config()
```
This will create a yaml file in your home directory: ~/.tcp_instruments.yml

This yaml file will be loaded everytime you use this package.

You can also create a project-specific config by creating
the config in your project root directory instead of your home
directory. You can do this with:
```
create_config(pwd())
```

Once you have created a config file you can change it with
```
edit_config()
```

If the instrument has its address in the config file you can now connect with:
```
handle = initialize({Instrument-Type})
```

To see the different types of devices you can interface with
use `help?> Instrument`.
"""
module TcpInstruments

import Base.show
import UnicodePlots
using Sockets
using Base.Threads: @spawn
using Dates
using OffsetArrays
using MAT
using JLD2
using RecipesBase
import InstrumentConfig: initialize, terminate
using Reexport

@reexport using Unitful
@reexport using Unitful: s, ms, μs, ns, ps
@reexport using Unitful: MΩ, kΩ, Ω, mΩ, µΩ, nΩ, pΩ
@reexport using Unitful: V, mV, µV, nV, pV
@reexport using Unitful: A, mA, µA, nA, pA
@reexport using Unitful: GHz, MHz, kHz, Hz
using Unitful: dimension, Current, Voltage, Frequency, Time
Unitful.@derived_dimension Resistance dimension(u"Ω")

const SMU_NAN = 9.91e37

export AbstractInstrument
export Oscilloscope, Multimeter, PowerSupply
export WaveformGenerator, ImpedanceAnalyzer, SourceMeasureUnit
export AgilentScope, KeysightMultimeter, AgilentImpedAnalyzer, SRSPowerSupply
export AgilentPowerSupply, VersatilePowerSupply, AgilentSourceMeasureUnit, KeysightWaveGen

export save, load

export initialize, terminate, reset
export remote_mode, local_mode
export query, f_query, i_query, write, info, connect!, close!
export clear_buffer

# Power Supply
export enable_output, disable_output, get_output_status
export set_current_limit, get_current_limit
export set_voltage, get_voltage
export set_voltage_limit, get_voltage_limit
export set_channel, get_channel

# Oscilloscope
export get_data, get_waveform_info
export get_data_transfer_format, set_data_transfer_format_8bit, set_data_transfer_format_16bit
export get_acquisition_type, set_acquisition_type
export set_acquisition_type_normal, set_acquisition_type_average, set_acquisition_type_high_res, set_acquisition_type_peak
export lpf_on, lpf_off, get_lpf_state
export set_impedance_1Mohm, set_impedance_50ohm, get_impedance
export get_coupling

export get_function, set_function
export get_frequency, set_frequency
export get_amplitude, set_amplitude
export get_voltage_offset, set_voltage_offset
export set_burst_mode_gated, set_burst_mode_triggered, get_burst_mode
export get_mode, set_mode_burst, set_mode_cw
export set_speed_mode
export set_waveform_num_points, get_waveform_num_points

# Prologix
export set_prologix_chan, get_prologix_chan, scan_prologix


# DMM
export get_tc_temperature, set_tc_type
export get_current
export get_resistance
export set_temp_unit_celsius, set_temp_unit_farenheit, set_temp_unit_kelvin
export get_temp_unit

# Impedance
export get_impedance
export get_impedance_analyzer_info
export get_volt_dc, set_volt_dc
export get_volt_ac, set_volt_ac
export get_num_averages, is_average_mode_on
export get_bandwidth, set_bandwidth
export get_point_delay_time, get_sweep_delay_time
export get_sweep_direction
export get_frequency
export get_frequency_limits, set_frequency_limits
export get_num_data_points, set_num_data_points
export get_volt_limit_dc, set_volt_limit_dc

# Waveform Generator
export set_output_on, set_output_off, get_output_status
export get_frequency, set_frequency
export get_amplitude, set_amplitude
export get_burst_num_cycles, set_burst_num_cycles
export get_time_offset, set_time_offset
export get_voltage_offset, set_voltage_offset
export get_burst_period, set_burst_period
export get_mode, set_mode_burst, set_mode_cw

# Source Measure Unit
export enable_output, disable_output
export set_source, get_source
export set_source_mode, get_source_mode
export set_measurement_mode, spot_measurement
export enable_autorange, disable_autorange
export set_measurement_range, set_measurement_duration
export set_voltage_output, set_voltage_limit, set_voltage_sweep_parameters
export set_current_output, set_current_limit, set_current_sweep_parameters
export get_measurement, start_measurement

# Devices
## Impedance Analyzer
export Agilent4294A, Agilent4395A
## Multimeter
export KeysightDMM34465A
## Scope
export AgilentDSOX4024A, AgilentDSOX4034A, AgilentDSOX1204G
## Power Supply
export AgilentE36312A, SRSPS310, VersatilePower
## Waveform Generator
export Keysight33612A
## Source Measure Unit
export AgilentB2910BL

export scan_network


include("config.jl")
include("instrument.jl")
include("common_commands.jl")

include("types.jl")
include("util.jl")

# instruments
include("oscilloscope/all.jl")
include("oscilloscope/recipes.jl")
include("power_supply/all.jl")
include("waveform_generator/all.jl")
include("impedance_analyzer/all.jl")
include("multimeter/all.jl")
include("source_measure_unit/all.jl")
include("source_measure_unit/recipes.jl")

include("emulator/emulator.jl")
end #endmodule
