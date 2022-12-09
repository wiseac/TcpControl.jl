@recipe function plot(data::SourceMeasureUnitData;)
    # setting default Plots attributes with -->
    plot_title --> "SMU IV Curve"
    legend --> false
    label --> "Channel 1"
    seriestype --> :path
    guidefont --> 8
    titlefontsize --> 11
    time_unit, scaled_time = autoscale_seconds(data.time)
    xguide := "Time / " * time_unit
    @series begin
        xguide := "Voltage / V"
        yguide := "Current / A"
        return ustrip(data.voltage), ustrip(data.current)
    end
end
