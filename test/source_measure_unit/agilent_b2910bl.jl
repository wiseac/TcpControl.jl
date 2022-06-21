using TcpInstruments
using Test
using Unitful

smu = initialize(AgilentB2910BL)
@info "Successfully connected $(smu.model) at $(smu.address)"


"""
Spec:
enable_output()
disable_output()

set_voltage_mode()
set_output_voltage()
set_voltage_limit()

set_voltage_mode()
set_output_voltage()
set_voltage_limit()

set_measurement_mode()
spot_measurement()

"""

@testset "Output" begin

    enable_output(smu)
    @test query(smu, ":OUTP?") ==  "1"

    disable_output(smu)
    @test query(smu, ":OUTP?") ==  "0"

end

@testset "Voltage" begin

    set_voltage_mode(smu)
    @test query(smu, ":SOUR:FUNC:MODE?") == "VOLT"

    set_output_voltage(smu, 3.3*u"V")
    @test f_query(smu, "SOUR:VOLT:LEV:IMM:AMPL?") == 3.3

    set_voltage_limit(smu, 5.0*u"V")
    @test f_query(smu, "SENS:VOLT:PROT?") == 5.0

end

@testset "Current" begin

    set_current_mode(smu)
    @test query(smu, ":SOUR:FUNC:MODE?") == "CURR"

    set_output_current(smu, 1.0*u"A")
    @test f_query(smu, "SOUR:CURR:LEV:IMM:AMPL?") == 1.0

    set_current_limit(smu, 1.5*u"A")
    @test f_query(smu, "SENS:CURR:PROT?") == 1.5

end

@testset "Measurement Mode" begin

    set_measurement_mode(smu; voltage = true)
    @test query(smu, ":SENS:FUNC?") == "\"VOLT\""

    set_measurement_mode(smu; current = true)
    @test query(smu, ":SENS:FUNC?") == "\"CURR\""

    set_measurement_mode(smu; resistance = true)
    @test query(smu, ":SENS:FUNC?") == "\"VOLT\",\"CURR\",\"RES\""

end

@testset "Spot Measurement" begin

     @test spot_measurement(smu; type = "VOLT") isa Unitful.Voltage
     @test spot_measurement(smu; type = "CURR") isa Unitful.Current
end

@testset "Helper Functions" begin

     @test TcpInstruments.verify_measurement_type("VOLT") == false
     @test TcpInstruments.verify_measurement_type("CURR") == false
     @test TcpInstruments.verify_measurement_type("RES") == false

     @test TcpInstruments.verify_source_type("VOLT") == false
     @test TcpInstruments.verify_source_type("CURR") == false

     @test TcpInstruments.verify_value_specifier("MAX") == false
     @test TcpInstruments.verify_value_specifier("MIN") == false
     @test TcpInstruments.verify_value_specifier("DEF") == false

     @test TcpInstruments.attach_unit!(1, "VOLT") isa Unitful.Voltage
     @test TcpInstruments.attach_unit!(1, "CURR") isa Unitful.Current

     @testset "add_mode!" begin
        mode = String[]
        TcpInstruments.add_mode!(mode, "VOLT")
        @test join(mode) == "\"VOLT\""
        
        TcpInstruments.add_mode!(mode, "CURR")
        @test join(mode) == "\"VOLT\",\"CURR\""

        TcpInstruments.add_mode!(mode, "RES")
        @test join(mode) == "\"VOLT\",\"CURR\",\"RES\""
     end
end
