using TcpInstruments
using Test

scope = initialize(AgilentDSOX4034A) 
@testset "initalize" begin
    if scope.connected
        @info "Successfully connected $(scope.model) at $(scope.address)"
    end
    @test typeof(scope) == TcpInstruments.Instrument{AgilentDSOX4034A}
end

"""
Spec:

> scope_h = initialize("192.168.1.15")

Grab data from channel 1
> data_struct = get_data(scope_h, 1)

Grab data from channel 2 and 4
> data_struct = get_data(scope_h, [2,4])

Low Pass Filter
Turn on Low Pass Filter 25
> lpf_on(scope)

Check if low pass filter is on
> get_lpf_state(scope) == "1"

Turn on Low Pass Filter 25MHz
> lpf_off(scope)
> get_lpf_state(scope) == "0"

Impedance

> set_impedance_1Mohm(scope_h)

> get_impedance(scope_h) == ONEM

> set_impedance_50ohm(scope_h)

> get_impedance(scope_h) == FIFT

Terminate TCP connection
> terminate(scope_h)


"""

@testset "Set and get impedance" begin
    set_impedance_1Mohm(scope)
    @test get_impedance(scope) == "ONEM"
    set_impedance_50ohm(scope)
    @test get_impedance(scope) == "FIFT"
end

@testset "Waveform Source" begin
    TcpInstruments.set_waveform_source(scope, 1)
    @test TcpInstruments.get_waveform_source(scope) == "CHAN1"
end

@testset "Aquisition type" begin
    set_acquisition_type_normal(scope)
    @test get_acquisition_type(scope) == "NORM"
    set_acquisition_type_average(scope)
    @test get_acquisition_type(scope) == "AVER"
    set_acquisition_type_high_res(scope)
    @test get_acquisition_type(scope) == "HRES"
    set_acquisition_type_peak(scope)
    @test get_acquisition_type(scope) == "PEAK"
end

@testset "Waveform Points Mode" begin
    TcpInstruments.set_waveform_points_mode(scope, :NORMAL)
    @test TcpInstruments.get_waveform_points_mode(scope) == "NORM"

    TcpInstruments.set_waveform_points_mode(scope, :RAW)
    @test TcpInstruments.get_waveform_points_mode(scope) == "RAW"
end

@testset "Data transfer format" begin
    set_data_transfer_format_8bit(scope)
    @test get_data_transfer_format(scope) == "BYTE"

    set_data_transfer_format_16bit(scope)
    @test get_data_transfer_format(scope) == "WORD"
end

@testset "set_speed_mode()" begin
    set_speed_mode(scope, 1)
    @test get_data_transfer_format(scope) == "WORD"
    @test TcpInstruments.get_waveform_points_mode(scope) == "RAW"
    set_speed_mode(scope, 3)
    @test get_data_transfer_format(scope) == "WORD"
    @test TcpInstruments.get_waveform_points_mode(scope) == "NORM"
    set_speed_mode(scope, 5)
    @test get_data_transfer_format(scope) == "BYTE"
    @test TcpInstruments.get_waveform_points_mode(scope) == "RAW"
    set_speed_mode(scope, 6)
    @test get_data_transfer_format(scope) == "BYTE"
    @test TcpInstruments.get_waveform_points_mode(scope) == "NORM"
end 

@testset "Data transfer byte order" begin
    TcpInstruments.set_data_transfer_byte_order(scope, :least_significant_first)
    @test TcpInstruments.get_data_transfer_byte_order(scope) == "LSBF"

    TcpInstruments.set_data_transfer_byte_order(scope, :most_significant_first)
    @test TcpInstruments.get_data_transfer_byte_order(scope) == "MSBF"
end

@testset "LPF state" begin
    lpf_on(scope)
    @test get_lpf_state(scope) == "1"
    lpf_off(scope)
    @test get_lpf_state(scope) == "0"
end


@testset "get data"  begin
    data = get_data(scope, 1)
    @test typeof(data) == TcpInstruments.ScopeData
    @test !isempty(data.volt)
    @test !isempty(data.time)
    data = get_data(scope, 2)

    @test typeof(data) == TcpInstruments.ScopeData
    @test !isempty(data.volt)
    @test !isempty(data.time)
    data = get_data(scope, 3)

    @test typeof(data) == TcpInstruments.ScopeData
    @test !isempty(data.volt)
    @test !isempty(data.time)

    data = get_data(scope, 4)
    @test typeof(data) == TcpInstruments.ScopeData
    @test !isempty(data.volt)
    @test !isempty(data.time)
end

@testset "Set and Get Trigger Mode" begin
    TcpInstruments.set_trigger_mode(scope, "EDGE")
    @test TcpInstruments.get_trigger_mode(scope) == "EDGE"
    TcpInstruments.set_trigger_mode(scope,  "GLITCH")
    @test TcpInstruments.get_trigger_mode(scope) == "GLIT"
    TcpInstruments.set_trigger_mode(scope, "PATTERN")
    @test TcpInstruments.get_trigger_mode(scope) == "PATT"
    TcpInstruments.set_trigger_mode(scope, "TV")
    @test TcpInstruments.get_trigger_mode(scope) == "TV"
    TcpInstruments.set_trigger_mode(scope, "EBURST")
    @test TcpInstruments.get_trigger_mode(scope) == "EBUR"
end

@testset "Set and get edge type" begin
    TcpInstruments.set_edge_type(scope, "POSITIVE")
    @test TcpInstruments.get_edge_type(scope) == "POSITIVE"
    TcpInstruments.set_edge_type(scope, "NEGATIVE")
    @test TcpInstruments.get_edge_type(scope) == "NEGATIVE"
    TcpInstruments.set_edge_type(scope, "EITHER")
    @test TcpInstruments.get_edge_type(scope) == "EITHER"
    TcpInstruments.set_edge_type(scope, "ALTERNATE")
    @test TcpInstruments.get_edge_type(scope) == "ALTERNATE"
end

@testset "set and get trigger level" begin
    TcpInstruments.set_trigger_level(scope, 0.2u"V")
    @test TcpInstruments.get_trigger_level(scope) == 0.2u"V"
end

@testset "Set and Get  Mode" begin
    TcpInstruments.set_mode(scope, "AUTO")
    @test TcpInstruments.get_mode(scope) == "AUTO"
    TcpInstruments.set_mode(scope,  "NORM")
    @test TcpInstruments.get_mode(scope) == "NORM"
end

# plot(data)

terminate(scope)
if !scope.connected
    @info "Successfully disconnected"
    @info "Goodbye"
end
