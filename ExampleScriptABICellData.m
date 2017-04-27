%% ExampleScriptABICellData.m
% Note: not all cells or sweeps have all information available.
% Visual inspection of the nwb file using HDFView or other app can
% be necessary.
clc
%close all

% A simple config file for paths
config = ini2struct('dbsconfig.ini'); % Use your own; config.ini supplied

% The full path of the cURL bin directory 
cURLBinDir = config.cURL.cURLBinDir;

% The path where you are keeping the nwb files (but see notes just below);
% the below is set up for this pattern:
% myNwbDir/cell_types/specimen_321707905/ephys.nwb  
myNwbDir = config.ABI.cacheDir;

%% Basic access
% Note that the "ephys-result-id" of the session data file, which is also
% the name of the file downloaded from the ephys summary page for the cell
% (minus the ".nwb"), is NOT the same as the aibs_specimen_id, which
% is used in the webpage URL. 
% The argument to the ABICellData constructor is the actual full path of
% the nwb file you wish to access.

SpecimenID = '321707905';
ephysFilename = ['ephys.nwb'];

% Construct an object that represents the session/file
acd = ABICellData(fullfile(myNwbDir, 'cell_types', ...
                           ['specimen_' SpecimenID], ephysFilename), ...
                           cURLBinDir);

% Unlike the remainder of the statements in this script, which access the
% local NWB file as stated, this statement accesses the ABI website
% directly using RMA access via cURL; returning cell features that were
% computed by ABI from all sweeps available (see the ABI documentation for
% details) 
[cellData, success, answer] = acd.getComputedParameters();
disp(['RMA access of ABI -- Cell average ISI: ', cellData.avg_isi])
            

% The statements below access the local NWB file.
% Pull out some of the features (metadata) of the session
[aibs_cre_line, aibs_dendrite_state, aibs_dendrite_type, ...
 aibs_specimen_id, aibs_specimen_name] = acd.GetSpecimenInfo();
disp(['Specimen: ' acd.getSpecimenID()])
[slices, session_id, protocol, pharmacology] = acd.GetCollectionInfo();
[subject, species, genotype, age, sex] = acd.GetSubjectData();

% Open the webpage where the specimen's ephys data is shown.
% You should be able to see the same waveform as plotted below by selecting
% the proper stimulus type, then hovering over the proper sweep's colored
% blob.
disp(['Opening ABI web page for Specimen ' num2str(SpecimenID)])
acd.OpenSpecimenWebPage();

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
sweepnum = 13; % We choose any sweep
% Since we are accessing the sweep directly, not through the experiment,
% the sweep property fromExperiment will be set to false (the hdf locations
% are different, although the data may not be)
sweep = acd.GetAcquisitionSweep(sweepnum); %#ok<NASGU>
sweep = acd.GetStimulusSweep(sweepnum); %#ok<NASGU>
sweep = acd.GetAnalysisSweep(sweepnum); %#ok<NASGU>

% Get a list of all the experiments in the cell
expstrs = acd.GetExperimentList();
availExps = join(expstrs, ', ');
msg = sprintf('Available Experiments: %s', availExps{1});
disp(msg);  %#ok<*DSPS>

% Get a struct array that shows the stimulus type for each experiment
expReport = acd.GetExperimentReport();

%% Experiment access
% Pick an experiment, then get its metadata, its sweep and sweep metadata
experiment = 45;
disp(['Experiment ' num2str(experiment) ' chosen.'])

myExp = acd.GetExperiment(experiment);
expdescription = myExp.GetExperimentDescription();
disp(expdescription{1})
% Following is not the time within the sweep...
[starttime, stoptime] = myExp.GetExperimentTimes();  % in msec

% The experiment's sweep object represents the stimulus,
% acquisition/response, and analysis sweeps associated with that experiment
% The sweep's fromExperiment property will be set to true.
sweep = myExp.GetExperimentSweep();
str = sweep.GetSweepStr();  % The name of the sweep in the file

% This method tells you the times when the ABI analysis software detected 
% spikes in the experiment's response
spikeTimes = sweep.GetAnalysisSpikeTimes();
numSpikes = length(spikeTimes);
spikeTimesCellStr = cellfun(@num2str, num2cell(spikeTimes), ...
                            'UniformOutput', false);
spikeTimesStr = join(spikeTimesCellStr, ', ');
msg = ['Detected ' num2str(numSpikes) ' spikes at times: ' spikeTimesStr{1}];
disp(msg)


% You can grab metadata about the experiment's sweep like this, if it's
% available in the file; the files are not consistent
[amp_mv, amp_pa, description, interval, stimName] ...
                                            = sweep.GetAIBSStimulusInfo(); %#ok<*ASGLU>
[capfast, capslow, whcellcapcomp]           = sweep.GetCapacitances();
[initAccess, compBW, compCorr, compPred, whCellSeriesComp] ...
                                            = sweep.GetResistances();
[bias_current, bridge_balance, capacitance_compensation] ...
                                            = sweep.GetElectronic();
[electrode, gain, num_samples, seal, starting_time] ...
                                            = sweep.GetBasicInfo();

%% Data Access and Plotting
% The experiment class offers a basic visualization function that uses the
% sweep object grabbed above, then plots the data in a way that allows
% comparison with that seen on the ABI webpage for this sweep.  Note,
% however, that 1)the webpages x and y limits are not the same as presented
% in the nwb file (but the figure's limits can be adjusted through the axis
% property editor), and 2) the occurrence times of the spikes as seen on
% the plots do not agree (by a constant bias). However, the ABIMpiML plot 
% is correct because it agrees with the spike times stored in the NWB file;
% the webpage plot is "incorrect" as far as spike occurrence time goes.
disp(['Visualizing experiment ' num2str(experiment)])
analysisStart = 1.02;
analysisDur = 2.0;
myExp.visualize(SpecimenID, analysisStart, analysisDur)

                       
