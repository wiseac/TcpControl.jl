using TcpInstruments
using Test
using Unitful

smu = initialize(AgilentB2910BL)
TcpInstruments.instrument_reset(smu)
@info "Successfully connected $(smu.model) at $(smu.address)"


"""
Spec:

    enable_output()
    disable_output()

    set_voltage_mode()
    set_voltage_output()
    set_voltage_limit()
    set_current_mode()

    set_current_output()
    set_current_limit()

    set_measurement_mode()
    spot_measurement()

    enable_autorange()
    disable_autorange()

    set_to_sweep_mode()
    set_voltage_sweep_start()
    set_voltage_sweep_stop()
    set_current_sweep_start()
    set_current_sweep_stop()
    set_current_sweep_step()

    set_measurement_range()
    set_measurement_time()

    get_measurement()
    start_measurement()
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

    set_voltage_output(smu, 3.3*u"V")
    @test f_query(smu, "SOUR:VOLT:LEV:IMM:AMPL?") == 3.3
    
    set_voltage_output(smu, "MAX")
    @test f_query(smu, "SOUR:VOLT:LEV:IMM:AMPL?") != 3.3

    @test_throws ErrorException set_voltage_output(smu, "Throw")
    @test_throws ErrorException set_voltage_output(smu, 10)
    @test_throws ErrorException set_voltage_output(smu, 10*u"A")

    set_voltage_limit(smu, 5.0*u"V")
    @test f_query(smu, "SENS:VOLT:PROT?") == 5.0

    set_voltage_limit(smu, "MAX")
    @test f_query(smu, "SENS:VOLT:PROT?") != 5.0

    @test_throws ErrorException set_voltage_limit(smu, "Throw")
    @test_throws ErrorException set_voltage_output(smu, 10)
    @test_throws ErrorException set_voltage_output(smu, 10*u"A")
end

@testset "Current" begin
    set_current_mode(smu)
    @test query(smu, ":SOUR:FUNC:MODE?") == "CURR"

    set_current_output(smu, 0.33*u"A")
    @test f_query(smu, "SOUR:CURR:LEV:IMM:AMPL?") == 0.33
    
    set_current_output(smu, "MAX")
    @test f_query(smu, "SOUR:CURR:LEV:IMM:AMPL?") != 0.33

    @test_throws ErrorException set_current_output(smu, "Throw")
    @test_throws ErrorException set_current_output(smu, 10)
    @test_throws ErrorException set_current_output(smu, 10*u"V")

    set_current_limit(smu, 1.0*u"A")
    @test f_query(smu, "SENS:CURR:PROT?") == 1.0

    set_current_limit(smu, "MAX")
    @test f_query(smu, "SENS:CURR:PROT?") != 1.0

    @test_throws ErrorException set_current_limit(smu, "Throw")
    @test_throws ErrorException set_current_output(smu, 10)
    @test_throws ErrorException set_current_output(smu, 10*u"V")
end

@testset "Measurement Mode" begin

    set_measurement_mode(smu; voltage = true, current = true, resistance = true)
    @test query(smu, ":SENS:FUNC?") == "\"VOLT\",\"CURR\",\"RES\""

    set_measurement_mode(smu; voltage = true)
    @test query(smu, ":SENS:FUNC?") == "\"VOLT\""

    set_measurement_mode(smu; current = true)
    @test query(smu, ":SENS:FUNC?") == "\"CURR\""

    set_measurement_mode(smu; resistance = true)
    @test query(smu, ":SENS:FUNC?") == "\"VOLT\",\"CURR\",\"RES\""

    set_measurement_mode(smu; voltage = true, current = true)
    @test query(smu, ":SENS:FUNC?") == "\"VOLT\",\"CURR\""

    @test_throws ErrorException  set_measurement_mode(smu)
end

@testset "Spot Measurement" begin

    @test spot_measurement(smu, "VOLT") isa Unitful.Voltage
    @test spot_measurement(smu, "CURR") isa Unitful.Current
    @test spot_measurement(smu, "RES") isa Number
    @test_throws ErrorException  spot_measurement(smu, "Throw")
   
    @test spot_measurement(smu) isa Tuple
end

@testset "Set measurement mode and get data " begin
    TcpInstruments.instrument_reset(smu)

    set_measurement_mode(smu; voltage = true)
    data = spot_measurement(smu)
    @test data[1] isa Unitful.Voltage
    @test_throws BoundsError data[2] isa Unitful.Current
    @info data

    set_measurement_mode(smu; current = true)
    data = spot_measurement(smu)
    @test data[1] isa Unitful.Current
    @test_throws BoundsError data[2] isa Unitful.Voltage
    @info data

    set_measurement_mode(smu; voltage = true, current = true, resistance = true)
    data = spot_measurement(smu)
    @test data[1] isa Unitful.Voltage
    @test data[2] isa Unitful.Current
    @test data[3] isa Number
    @test_throws BoundsError data[4] isa Number
    @info data
end

@testset "Autorange" begin

    enable_autorange(smu; source = "VOLT")
    @test query(smu, "SOUR:VOLT:RANG:AUTO?") == "1"
    disable_autorange(smu, source = "VOLT")
    @test query(smu, "SOUR:VOLT:RANG:AUTO?") == "0"
    
    enable_autorange(smu, source = "CURR")
    @test query(smu, "SOUR:CURR:RANG:AUTO?") == "1"
    disable_autorange(smu, source = "CURR")
    @test query(smu, "SOUR:CURR:RANG:AUTO?") == "0"

    @test_throws ErrorException enable_autorange(smu; source = "RES")
end

@testset "Sweep Mode" begin

    set_to_sweep_mode(smu; source = "VOLT")
    @test query(smu, "SOUR:VOLT:MODE?") == "SWE"

    set_to_sweep_mode(smu; source = "CURR")
    @test query(smu, "SOUR:CURR:MODE?") == "SWE"

    set_voltage_sweep_start(smu; start = -1*u"V")
    @test f_query(smu, "SOUR:VOLT:START?") == -1.0

    set_voltage_sweep_start(smu; start = "MIN")
    @test f_query(smu, "SOUR:VOLT:START?") != -1.0

    set_voltage_sweep_stop(smu; stop = 1*u"V")
    @test f_query(smu, "SOUR:VOLT:STOP?") == 1.0

    set_voltage_sweep_stop(smu; stop = "MAX")
    @test f_query(smu, "SOUR:VOLT:STOP?") != 1.0

    set_voltage_sweep_step(smu; step = 0.5*u"V")
    @test f_query(smu, "SOUR:VOLT:STEP?") == 0.5

    set_voltage_sweep_step(smu; step = "MAX")
    @test f_query(smu, "SOUR:VOLT:STEP?") != 0.5
end

@testset "Measurement Range" begin

    set_measurement_range(smu; measurement = "VOLT", range = 1 )
    set_measurement_range(smu; measurement = "VOLT", range = "MAX")
    @test f_query(smu, "SENS:VOLT:RANGE?") != 1

    set_measurement_range(smu; measurement = "CURR", range = 1 )
    set_measurement_range(smu; measurement = "CURR", range = "MAX")
    @test f_query(smu, "SENS:CURR:RANGE?") != 1

    set_measurement_range(smu; measurement = "RES", range = 1 )
    set_measurement_range(smu; measurement = "RES", range = "MAX")
    @test f_query(smu, "SENS:RES:RANGE?") != 1

    @test_throws ErrorException set_measurement_range(smu, measurement = "Throw")
end

@testset "Measurement Time" begin

    set_measurement_time(smu; aperture = 0.5u"s")
    @test f_query(smu, "SENS:VOLT:APER?") == 0.5

    set_measurement_time(smu; aperture = "MAX")
    @test f_query(smu, "SENS:VOLT:APER?") != 0.5

    @test_throws ErrorException set_measurement_time(smu; aperture = 0.5)
end

@testset "Get Measurement" begin
    TcpInstruments.instrument_reset(smu)
    
    start_measurement(smu)
    data = get_measurement(smu)
    @test data isa Tuple
    @info data
end

@testset "Helper Functions" begin

    @test TcpInstruments.verify_source("VOLT") == false
    @test TcpInstruments.verify_source("CURR") == false
    @test_throws ErrorException TcpInstruments.verify_source("RES")

    @test TcpInstruments.verify_measurement("VOLT") == false
    @test TcpInstruments.verify_measurement("CURR") == false
    @test TcpInstruments.verify_measurement("RES") == false
    @test_throws ErrorException TcpInstruments.verify_measurement("Throw")

    @test TcpInstruments.verify_value_specifier("MAX") == false
    @test TcpInstruments.verify_value_specifier("MIN") == false
    @test TcpInstruments.verify_value_specifier("DEF") == false
    @test_throws ErrorException TcpInstruments.verify_value_specifier("Throw") == true

    @test TcpInstruments.verify_voltage("DEF") == false
    @test TcpInstruments.verify_voltage(5u"V") == false
    @test_throws ErrorException  TcpInstruments.verify_voltage(5u"A")

    @test TcpInstruments.verify_current("DEF") == false
    @test TcpInstruments.verify_current(5u"A") == false
    @test_throws ErrorException  TcpInstruments.verify_current(5u"V")

    @test TcpInstruments.verify_range(100) == nothing
    @test TcpInstruments.verify_range("MIN") == false
    @test TcpInstruments.verify_range("MAX") == false
    @test TcpInstruments.verify_range("DEF") == false
    @test TcpInstruments.verify_range("UP") == false
    @test TcpInstruments.verify_range("DOWN") == false
    @test_throws ErrorException  TcpInstruments.verify_range("Throw")

    @test TcpInstruments.verify_aperture(1u"s") == false
    @test TcpInstruments.verify_aperture("MIN") == false
    @test TcpInstruments.verify_aperture("MAX") == false
    @test TcpInstruments.verify_aperture("DEF") == false

    @test TcpInstruments.attach_unit!(1, "VOLT") isa Unitful.Voltage
    @test TcpInstruments.attach_unit!(1, "CURR") isa Unitful.Current
    @test TcpInstruments.attach_unit!(1, "RES") isa Number
    @test_throws MethodError TcpInstruments.attach_unit!("Throw") == true

    mode = String[]
    TcpInstruments.add_mode!(mode, "VOLT")
    @test join(mode) == "\"VOLT\""
    
    TcpInstruments.add_mode!(mode, "CURR")
    @test join(mode) == "\"VOLT\",\"CURR\""

    TcpInstruments.add_mode!(mode, "RES")
    @test join(mode) == "\"VOLT\",\"CURR\",\"RES\""
    @test_throws MethodError TcpInstruments.add_mode!("Throw") == true

end
