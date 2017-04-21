function visualize(obj, SpecimenID, analysisStart, analysisDur)
    sweep = obj.GetExperimentSweep();
    expStimData = sweep.GetStimulusData();
    expAcqData = sweep.GetAcquisitionData();
    expTimeBase = sweep.GetTimeBase(false);
    samplingRate = sweep.GetSamplingRate();
    [~, amp_pa, ~, ~, stimName] = sweep.GetAIBSStimulusInfo();
    spikeTimes = sweep.GetAnalysisSpikeTimes();
    numSpikes = length(spikeTimes);
    % Get the experiment time window and use it to restrict the plot
    [startIndex, endIndex] = obj.GetTimeBaseWindow();
    figure
    
    % Plot the stimulus
    % Note: not all the nwb files have conversion and units set up correctly
    % so we override them here.
    subplot(2,1,1)
    [data, conversion, ~, units] = sweep.GetStimulusData();
    conversion = 10^-12;
    units = 'pA';
    
    plot(expTimeBase(startIndex:endIndex), ...
         expStimData(startIndex:endIndex)/conversion, ...
         '-g', 'LineWidth', 1)
    ylabel(['Current (' units ')'])
    ylim('auto')
    xlim([0 4.0])
    ax = gca;
    ax.XTickMode = 'manual';
    ax.XTick = 0:0.5:4.0;
    ax.XMinorTick = 'on';
    grid on
    ax.XMinorGrid='on';
    title({['Specimen ID: ' SpecimenID]; ...
           ['Stimulus Data for ' sweep.GetSweepStr() ...
            '   Stimulus: ' stimName ...
            ' / ' num2str(amp_pa) ' pA']}, ...
           'Interpreter', 'none');

    % Plot the Response
    subplot(2,1,2)
    % again with the override
    [data, conversion, ~, units] = sweep.GetAcquisitionData(); %#ok<*ASGLU>
    conversion = 10^-3;
    units = 'mV';
    plot(expTimeBase(startIndex:endIndex), ...
         expAcqData(startIndex:endIndex)/conversion, '-k')
    ylabel(['Voltage (' units ')']);
    xlabel('Time (seconds)')
    xlim([0 4.0])
    ax = gca;
    ax.XTickMode = 'manual';
    ax.XTick = 0:0.5:4.0;
    ax.XMinorTick = 'on';
    grid on
    ax.XMinorGrid='on';
    % Formulate a title from the metadata
    title({['Specimen ID: ' SpecimenID]; ...
           ['Acquisition Data for ' sweep.GetSweepStr() ...
            '   Number of spikes = ' num2str(numSpikes)]}, ...
            'Interpreter', 'none');
    
    hold on
    % Plot the analysis window
    if (analysisStart >= 0 && analysisDur >= 0)
        analysisMarker = zeros(1,length(expTimeBase));
        startIndex = analysisStart*samplingRate+1;
        stopIndex = startIndex + analysisDur*samplingRate;
        plot(expTimeBase(startIndex:stopIndex), ...
             analysisMarker(startIndex:stopIndex), ...
             'LineWidth', 2, 'Color', 'red')
    end
    
    sweep.delete();
end
