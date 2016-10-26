%% ExampleScriptABICellData.m
clc
close all

%% Basic access
% This is the path where you are keeping the nwb files.
myNwbPath = 'C:\Users\David\Dropbox\Documents\SantamariaLab\Projects\ABAtlas\ABIApiML';
% This is the "ephys-result-id" of the session data file; it's also
% the name of the file downloaded from the ephys summary page for the cell
% (minus the ".nwb").
ephysResultID = '324256801';
% ephysResultID = '324466856';
% ephysResultID = '386970631';
% ephysResultID = '466245542';
% ephysResultID = '325480370';

% Construct an object that represents the session/file
acd = ABICellData(myNwbPath, ephysResultID);

% Pull out some of the features (metadata) of the session
[aibs_cre_line, aibs_dendrite_state, aibs_dendrite_type, ...
 aibs_specimen_id, aibs_specimen_name] = acd.GetSpecimenInfo();
[slices, session_id, protocol, pharmacology] = acd.GetCollectionInfo();
[subject, species, genotype, age, sex] = acd.GetSubjectData();

% Open the webpage where the specimen's ephys data is shown
% acd.OpenSpecimenWebPage();

% Get the version of nwb to which this file conforms 
nwbVersion = acd.GetNWBVersion();

% Get lists of the sweeps in the acquisition, analysis, and stimulus
% groups without going through an experiment.
sweepstrs1 = acd.GetAcquisitionSweepList();
sweepstrs2 = acd.GetAnalysisSweepList();
sweepstrs3 = acd.GetStimulusSweepList();

% Grab individual sweeps directly without going through an experiment.
% These give same sweep object but the sweepnum existence check checks the
% specified group, so may differ in error condition
sweepnum = 13;
sweep = acd.GetAcquisitionSweep(sweepnum); %#ok<NASGU>
sweep = acd.GetStimulusSweep(sweepnum); %#ok<NASGU>
sweep = acd.GetAnalysisSweep(sweepnum); %#ok<NASGU>

% Get a list of all the experiments in the cell
expstrs = acd.GetExperimentList();

% Get a struct that shows the stimulus waveform for each experiment
expReport = acd.GetExperimentReport();

%% Experiment access
% Pick an experiment, then get its metadata, its sweep and sweep metadata
experiment = 41;
myExp = acd.GetExperiment(experiment);
expdescription = myExp.GetExperimentDescription();
[starttime, stoptime] = myExp.GetExperimentTimes();

% The experiment's sweep object represents the stimulus,
% acquisition/response, and analysis sweeps associated with that experiment
sweep = myExp.GetExperimentSweep();
str = sweep.GetSweepStr();

% This tells you the times when the ABI analysis software detected spikes
% in the experiment's response
spiketimes = sweep.GetAnalysisSpikeTimes()
numspikes = length(spiketimes);

% You can grab metadata about the experiment's sweep like this
[amp_mv, amp_pa, description, interval, name] ...
                                            = sweep.GetAIBSStimulusInfo();
[capfast, capslow, whcellcapcomp]           = sweep.GetCapacitances();
[initAccess, compBW, compCorr, compPred, whCellSeriesComp] ...
                                            = sweep.GetResistances();
[bias_current, bridge_balance, capacitance_compensation] ...
                                            = sweep.GetElectronic();
[electrode, gain, num_samples, seal, starting_time] ...
                                            = sweep.GetBasicInfo();

%% Data Access and Plotting
% Access the stimulus and response data for our chosen experiment using the
% sweep object grabbed above, then plot them in a way that allows
% comparison with that seen on the ABI webpage for this sweep.  Note,
% however, that 1)the webpages x and y limits are not the same as presented
% in the nwb file (but the figure's limits can be adjusted through the axis
% property editor), and 2) the occurrence times of the spikes as seen on
% the plots do not agree. However, the ABIMpiML plot is correct because it
% agrees with the spike times stored in the NWB file; the webpage plot is
% incorrect as far as spike occurrence time goes.
h = figure(1);
hold off
% Get the time base
% The timebase is common for both stimulus and response in this experiment
t = sweep.GetTimeBase(false);
% Get the experiment time window and use it to restrict the plot
[startIndex, endIndex] = myExp.GetTimeBaseWindow();

% Plot the stimulus
subplot(2,1,1)
[data, conversion, ~, units] = sweep.GetStimulusData();
plot(t(startIndex:endIndex), data(startIndex:endIndex)/str2double(conversion));
% Formulate a title from the metadata
[~,~,~,~,stimName] = sweep.GetAIBSStimulusInfo(); 
title(['Specimen ID: ' aibs_specimen_id ...
       '   Stimulus Data for ' sweep.GetSweepStr() ...
       '   Stimulus Name: ' stimName], ...
       'Interpreter', 'none');
ylabel({[conversion '  ' units]});

% Plot the Response
subplot(2,1,2)
[data, conversion, ~, units] = sweep.GetAcquisitionData();
plot(t(startIndex:endIndex), data(startIndex:endIndex)/str2double(conversion))
% Formulate a title from the metadata
title({['Specimen ID: ' aibs_specimen_id ...
        '   Acquisition Data for ' sweep.GetSweepStr() ...
        '   Number of spikes = ' num2str(numspikes)]}, ...
        'Interpreter', 'none');
ylabel({[conversion '  ' units]});
xlabel('Time (seconds)');

% Make a little more room at the bottom of the figure
% (This kinda works but not the best, but no need to do any better)
% This notation only applies to later versions of MATLAB (2014b and later).
if ~verLessThan('matlab','8.4')
    position = h.Position;
    position(2) = position(2)-position(4)*0.2;
    position(3) = position(3)*1.5;
    position(4) = position(4)*0.8;
    h.Position = position;
    hold on
    oposition = h.OuterPosition;
    oposition(4) = oposition(4) * 1.6;
    h.OuterPosition = oposition;
end
