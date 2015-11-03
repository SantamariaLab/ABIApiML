% ExampleScriptABICellData.m
clc
clf
% This is the path where you are keeping the nwb files.
myNwbPath = 'C:\Users\David\Dropbox\Documents\SantamariaLab\Projects\ABAtlas\ABIApiML';
% This is the "ephys-result-id" of the session data file; it's also
% the name of the file downloaded from the ephys summary page for the cell
% (minus the ".nwb").
ephysResultID = '324466856';
% ephysResultID = '386970631';
% ephysResultID = '466245542';
% ephysResultID = '325480370';

% Construct an object that represents the session
acd = ABICellData(myNwbPath, ephysResultID);

% Pull out some of the features of the session
[aibs_cre_line, aibs_dendrite_state, aibs_dendrite_type, ...
                  aibs_specimen_id, aibs_specimen_name] ...
                = acd.GetSpecimenInfo();
[slices, session_id, protocol, pharmacology] = acd.GetCollectionInfo();
[subject, species, genotype, age, sex] = acd.GetSubjectData();

% Open the webpage where the specimen's ephys data is shown
% acd.OpenSpecimenWebPage();

% Get the version of nwb to which this file conforms 
disp(acd.GetNWBVersion());

% Get lists of the sweeps in the acquisition, analysis, and stimulus
% groups without going through an experiment.
sweepstrs1 = acd.GetAcquisitionSweepList();
sweepstrs2 = acd.GetAnalysisSweepList();
sweepstrs3 = acd.GetStimulusSweepList();

% You can grab individual sweeps directly without going through an
% experiment.
% sweepnum = 13
% sweep = acd.GetAcquisitionSweep(sweepnum);
% sweep = acd.GetStimulusSweep(sweepnum);
% sweep = acd.GetAnalysisSweep(sweepnum);

% Get a list of all the experiments in the cell
expstrs = acd.GetExperimentList();

% Get a struct that shows the stimulus waveform for each experiment
expReport = acd.GetExpReport();

%% 
% Pick an experiment, then get the stimulus and response data for it and
% plot them in a figure that is similar to that seen on the specimen
% website
experiment = 48;
myExp = acd.GetExperiment(experiment);
expdescription = myExp.GetExperimentDescription();
[starttime, stoptime] = myExp.GetExperimentTimes()

% The experiment's sweep object represents the stimulus,
% acquisition/response, and analysis sweeps associated with that experiment
sweep = myExp.GetExperimentSweep();

% This tells you the times when the ABI analysis software detected spikes
% in the experiment's response
times = sweep.GetAnalysisSpikeTimes();
numspikes = length(times);

% You can grab data about the experiment's sweep like this
[amp_mv, amp_pa, description, interval, name] ...
                                            = sweep.GetAIBSStimulusInfo();
[capfast, capslow, whcellcapcomp]           = sweep.GetCapacitances();
[initAccess, compBW, compCorr, compPred, whCellSeriesComp] ...
                                            = sweep.GetResistances();
[electrode, gain, num_samples, seal, starting_time] ...
                                            = sweep.GetBasicInfo();

% Plot the stimulus and response for our chosen experiment using the sweep
% object grabbed above. Can compare this with that seen on the webpage for
% this sweep; however the webpages x and y limits are not the same as presented
% in the nwb file (but the figure's limits can be adjusted through the axis
% property editor).
h = figure(1);

% The timebase is common for both stimulus and response in this experiment
t = sweep.GetTimeBase();
subplot(2,1,1)
[data, conversion, ~, units] = sweep.GetStimulusData();
plot(t, data/str2double(conversion))
[~,~,~,~,stimName] = sweep.GetAIBSStimulusInfo(); 
title(['Specimen ID: ' aibs_specimen_id ...
       '   Stimulus Data for ' sweep.GetSweepStr() ...
       '   Stimulus Name: ' stimName], ...
       'Interpreter', 'none');
ylabel({[conversion '  ' units]});

subplot(2,1,2)
[data, conversion, ~, units] = sweep.GetAcquisitionData();
plot(t, data/str2double(conversion))
title({['Specimen ID: ' aibs_specimen_id ...
        '   Acquisition Data for ' sweep.GetSweepStr() ...
        '   Number of spikes = ' num2str(numspikes)]}, ...
        'Interpreter', 'none');
ylabel({[conversion '  ' units]});

xlabel('Time (seconds)');

% Make a little more room at the bottom of the figure
% (This kinda works but not the best, but no need to do any better)
position = h.Position;
position(2) = position(2)-position(4)*0.2;
position(3) = position(3)*1.5;
position(4) = position(4)*0.8;
h.Position = position;
hold on
oposition = h.OuterPosition;
oposition(4) = oposition(4) * 1.6;
h.OuterPosition = oposition;
