using TcpInstruments
using Test

"""
Spec: 

1. Connect a compensated oscilloscope probe from channel 1 and channel 3 to the Probe Comp signal terminal on the front panel,
using 10x gain settings (setting is on the probe). This will allow the oscilloscope to accurately measure the signal.

2. Connect the probe's ground lead to the ground terminal that is next to the Probe Comp terminal. This will ensure that 
the signal is properly grounded.

3. Press AutoScale to automatically adjust the vertical scale and position of the signal on the oscilloscope.

4. Set level between 50mV and 250mV

5. Check that the oscilloscope displays a square wave signal on channel 1 and 3. If the signal is not square or does not appear
on both channels, check your connections and settings.

The test validates the average amplitude/voltage value in the high and low states of the square wave signal.
"""

execute_test_loop = false
no_test_signal_average_voltage = 0.06 * V 
test_signal_high_state_average_volt = 0.15 * V 
test_signal_low_state_average_volt = 0.06 * V 

scope = initialize(AgilentDSOX4034A, "10.0.0.42")
@testset "initalize" begin
    if scope.connected
        @info "Successfully connected $(scope.model) at $(scope.address)"
    end
    @test typeof(scope) == TcpInstruments.Instrument{AgilentDSOX4034A}
end

@testset "get_data() test signal test" begin
    function average(v::Vector) # internal function to avoid loading the Statistics lib for built in mean()
        vector_length = length(v)
        if vector_length == 0
            return NaN
        end
        total = 0.0 * V
        for i in 1:vector_length
            total += v[i]
        end
        return total / vector_length
    end
    set_time_axis(scope, time_per_div=200µs, time_offset=168µs)
    set_waveform_num_points(scope, 1000)

    function get_data_test(num_iterations::Int)
        scope_data = get_data(scope)
    
        channel_1_data = scope_data[1]
        @test length(channel_1_data.volt) == length(channel_1_data.time)
        channel_1_voltages = channel_1_data.volt 
        # divide 1000 points of squarewave vector into 5 subvectors of 200 voltage values of either high or low state
        channel_1_voltage_states = [channel_1_voltages[(i-1)*200+1:i*200] for i in 1:5]  
        # validate squarewave for high and low state voltages
        @test average(channel_1_voltage_states[1]) > test_signal_high_state_average_volt 
        @test average(channel_1_voltage_states[2]) < test_signal_low_state_average_volt 
        @test average(channel_1_voltage_states[3]) > test_signal_high_state_average_volt 
        @test average(channel_1_voltage_states[4]) < test_signal_low_state_average_volt 
        @test average(channel_1_voltage_states[5]) > test_signal_high_state_average_volt

        # no test signal
        channel_2_data = scope_data[2]
        @test length(channel_2_data.volt) == length(channel_2_data.time)
        channel_2_voltages = channel_2_data.volt 
        @test average(channel_2_voltages) < no_test_signal_average_voltage

        channel_3_data = scope_data[3]
        @test length(channel_3_data.volt) == length(channel_3_data.time)
        channel_3_voltages = channel_1_data.volt 
        # divide 1000 points of squarewave vector into 5 subvectors of 200 voltage values of either high or low state
        channel_3_voltage_states = [channel_3_voltages[(i-1)*200+1:i*200] for i in 1:5]  
        # validate squarewave for high and low state voltages
        @test average(channel_3_voltage_states[1]) > test_signal_high_state_average_volt 
        @test average(channel_3_voltage_states[2]) < test_signal_low_state_average_volt 
        @test average(channel_3_voltage_states[3]) > test_signal_high_state_average_volt 
        @test average(channel_3_voltage_states[4]) < test_signal_low_state_average_volt 
        @test average(channel_3_voltage_states[5]) > test_signal_high_state_average_volt

        # no test signal
        channel_4_data = scope_data[4]
        @test length(channel_4_data.volt) == length(channel_4_data.time)
        channel_4_voltages = channel_4_data.volt 
        @test average(channel_4_voltages) < no_test_signal_average_voltage
    end
    get_data_test(execute_test_loop ? 50 : 1)
end

terminate(scope)
if !scope.connected
    @info "Successfully disconnected"
    @info "Goodbye"
end
