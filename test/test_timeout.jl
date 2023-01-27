using TcpInstruments
using Test
using TestSetExtensions

@testset "timeout1 timeout2 unit tests" begin
    function sleep_function(sleep_time::Float64)
        sleep(sleep_time)
        return 0
    end
    sleep_time = 0.5
    timeout = 0.3
    f() = sleep_function(sleep_time)
    for i in 1:100
        @test_throws ErrorException TcpInstruments.timeout1(f, timeout)
        @test_throws ErrorException TcpInstruments.timeout2(f, timeout)
    end

    sleep_time = 0.03
    timeout = 0.02
    f() = sleep_function(sleep_time)
    for i in 1:100
        @test_throws ErrorException TcpInstruments.timeout1(f, timeout)
        @test_throws ErrorException TcpInstruments.timeout2(f, timeout)
    end

    sleep_time = 0.2
    timeout = 0.01
    f() = sleep_function(sleep_time)
    for i in 1:100
        @test_throws ErrorException TcpInstruments.timeout1(f, timeout)
        @test_throws ErrorException TcpInstruments.timeout2(f, timeout)
    end

    sleep_time = 0.05
    timeout = 0.08
    f() = sleep_function(sleep_time)
    for i in 1:100
        @test 0 == TcpInstruments.timeout1(f, timeout)
        @test 0 == TcpInstruments.timeout2(f, timeout)
    end  

    sleep_time = 0.02
    timeout = 0.03
    f() = sleep_function(sleep_time)
    for i in 1:100
        @test 0 == (TcpInstruments.timeout1(f, timeout))
        @test 0 == (TcpInstruments.timeout2(f, timeout)) 
    end

    sleep_time = 0.02
    timeout = 0.01
    f() = sleep_function(sleep_time)
    for i in 1:100
        @test_throws ErrorException TcpInstruments.timeout1(f, timeout)
        @test_throws ErrorException TcpInstruments.timeout2(f, timeout)
    end
end 
