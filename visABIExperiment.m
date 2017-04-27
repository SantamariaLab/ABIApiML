% Visualize sweep of the experimental data
function visABIExperiment(specID, expID, analysisStart, analysisDur, ...
                          ABIApiMLPath, expDataDir)
	% ABIApiMLPath - The location where the ABIApiML classes are kept
    % expDataDir - The location where the nwb file is kept (including the
    % cell_types directory)
    addpath(ABIApiMLPath); 
	abiSamplingRate = 200000;
    nwbFilePath = ...
        fullfile(expDataDir, ['specimen_' num2str(specID)], 'ephys.nwb');
    acd = ABICellData(nwbFilePath);
    exp = acd.GetExperiment(expID);
    sweep = exp.GetExperimentSweep();
    expStimData = sweep.GetStimulusData();
    expAcqData = sweep.GetAcquisitionData();
    expTimeBase = sweep.GetTimeBase(false);
    
    % Plot the experimental part
    figure
    subplot(2,1,1)
    plot(expTimeBase, expStimData*10^11, '-g', 'LineWidth', 1)
    ylabel('Current (pA)')
    xlim([0 4.0])
    ax = gca;
    ax.XTickMode = 'manual';
    ax.XTick = 0:0.5:4.0;
    ax.XMinorTick = 'on';
    grid on
    ax.XMinorGrid='on';
    title(['Specimen ' num2str(specID) '  Experiment ' num2str(expID)]);

    subplot(2,1,2)
    plot(expTimeBase, expAcqData*1000, '-k')
    ylabel('Voltage (mV)')
    xlabel('Time (sec)')
    xlim([0 4.0])
    ax = gca;
    ax.XTickMode = 'manual';
    ax.XTick = 0:0.5:4.0;
    ax.XMinorTick = 'on';
    grid on
    ax.XMinorGrid='on';
    hold on
    if (analysisStart >= 0 && analysisDur >= 0)
        analysisMarker = zeros(1,length(expTimeBase));
        startIndex = analysisStart*abiSamplingRate+1;
        stopIndex = startIndex + analysisDur*abiSamplingRate;
        plot(expTimeBase(startIndex:stopIndex), ...
             analysisMarker(startIndex:stopIndex), ...
             'LineWidth', 2, 'Color', 'red')
    end
end
