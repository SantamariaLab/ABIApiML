%% ABICellData.m
% A class that provides MATLAB access to the Allen Brain Institute Cell
% Types electrophysiology data inside a NWB formatted file.
classdef ABICellData < handle
    properties
        % Full absolute path/filename of NWB file
        nwbFile; 
        specimenID;
        
        curlDir =...
            ['C:/Users/David/Dropbox/Documents/SantamariaLab/Projects' ... 
             '/ProjNeuroMan/CloudStuff/curl-7.46.0-win64-mingw/bin/'];
        
        % Assumed max sweeps in each phase of an experiment
        MAX_SWEEPS = 1000; 
        MAX_EXPS = 1000;
        
        experimentList;
        acquisitionSweepList;
        analysisSweepList;
        stimulusSweepList;
    end
        
    methods
        %% Constructor
        function obj = ABICellData(fullPathname)
            obj.nwbFile = fullPathname;
            if ~(exist(obj.nwbFile, 'file') == 2)
                error(['File ' obj.nwbFile ' not found'])
            end
            obj.experimentList = obj.GetExperimentList();
            obj.acquisitionSweepList = ...
                            obj.GetSweepList('/acquisition/timeseries');
            obj.analysisSweepList = ...
                            obj.GetSweepList('/analysis/spike_times');
            obj.stimulusSweepList = ...
                            obj.GetSweepList('/stimulus/presentation');
            obj.specimenID = num2str(h5read(obj.nwbFile, ...
                                            '/general/aibs_specimen_id'));
        end
        
        function id = getSpecimenID(obj)
            id = obj.specimenID;
        end
        
        %% Experiments
        function experiment = GetExperiment(obj, expnum)
            if ~obj.IsExperiment(expnum)
                 error(['Experiment ' num2str(expnum) ...
                        ' is NOT available in this session.']);
            end
            experiment = ABIExperiment(obj.nwbFile, expnum);
        end
        
        % True if there is an experiment in the list with the stated number
        function tf = IsExperiment(obj, expnum)
            expstr = num2str(expnum);
            tf = any(strcmpi(expstr, obj.experimentList));
        end

        function expReport = GetExperimentReport(obj)
            for i = 1:length(obj.experimentList)
                expnum = str2num(obj.experimentList{i}); %#ok<ST2NM>
                experiment = obj.GetExperiment(expnum);
                expReport(i).ExpNum = experiment.GetExperimentNum(); %#ok<AGROW>
                sweep = experiment.GetExperimentSweep();
                [~,~,~,~,name] = sweep.GetAIBSStimulusInfo();
                expReport(i).StimulusName = name; %#ok<AGROW>
                sweep.delete();
                experiment.delete();
            end
        end
        
        %% Sweeps
        % These are from the sweep view; for the experiment view, use the
        % ABIExperiment GetExperimentSweep method.
        function sweep = GetAcquisitionSweep(obj, sweepnum)
            if ~obj.IsAcquisitionSweep(sweepnum)
                 error(['Acquisition sweep ' num2str(sweepnum) ...
                        ' is NOT available in this session.']);
            end
            sweep = ABISweep(obj.nwbFile, sweepnum, false, 0);
        end
        
        function sweep = GetStimulusSweep(obj, sweepnum)
            if ~obj.IsStimulusSweep(sweepnum)
                 error(['Stimulus sweep ' num2str(sweepnum) ...
                        ' is NOT available in this session.']);
            end
            sweep = ABISweep(obj.nwbFile, sweepnum, false, 0);
        end
        
        function sweep = GetAnalysisSweep(obj, sweepnum)
            if ~obj.IsAnalysisSweep(sweepnum)
                 error(['Analysis sweep ' num2str(sweepnum) ...
                        ' is NOT available in this session.']);
            end
            sweep = ABISweep(obj.nwbFile, sweepnum, false, 0);
        end
        
        
        
        %% Top Level info
        % Returns top level identifier as a string
        function id = GetIdentifier(obj)
            identifiercell = h5read(obj.nwbFile, '/identifier');
            id = identifiercell{1};
        end
        
        % Returns NWB Version as a string
        function nwb_version = GetNWBVersion(obj)
            nwb_versioncell = h5read(obj.nwbFile, '/nwb_version');
            nwb_version = nwb_versioncell{1};
        end
        
        %% General Info
        % Specimen info
        function [aibs_cre_line, aibs_dendrite_state, ...
                  aibs_dendrite_type, aibs_specimen_id, ...
                  aibs_specimen_name] = GetSpecimenInfo(obj)
            aibs_cre_linecell = h5read(obj.nwbFile, ...
                                                '/general/aibs_cre_line');
            aibs_cre_line = aibs_cre_linecell; %{1}
%             aibs_dendrite_statecell = h5read(obj.nwbFile, ...
%                                         '/general/aibs_dendrite_state');
            aibs_dendrite_state = '';%aibs_dendrite_statecell{1};
            aibs_dendrite_typecell = h5read(obj.nwbFile, ...
                                        '/general/aibs_dendrite_type');
            aibs_dendrite_type = aibs_dendrite_typecell; %{1};
            aibs_specimen_idnum = h5read(obj.nwbFile, ...
                                            '/general/aibs_specimen_id');
            aibs_specimen_id = num2str(aibs_specimen_idnum);
            aibs_specimen_namecell = h5read(obj.nwbFile, ...
                                            '/general/aibs_specimen_name');
            aibs_specimen_name = aibs_specimen_namecell;%{1};
        end
        
        % Open the Specimen WebPage at the Allen Brain Institute Website
        function OpenSpecimenWebPage(obj)
            aibs_specimen_idnum = h5read(obj.nwbFile, ...
                                            '/general/aibs_specimen_id');
            aibs_specimen_id = num2str(aibs_specimen_idnum);
            url = ['http://celltypes.brain-map.org/' ...
                   'mouse/experiment/electrophysiology/' aibs_specimen_id];
            web(url, '-browser');
        end
        
        % Collection info
        function [slices, session_id, session_start_time,...
                        protocol, pharmacology] = GetCollectionInfo(obj)
%             slicescell = h5read(obj.nwbFile, '/general/slices');
            slices = '';%slicescell{1};
            session_start_time = h5read(obj.nwbFile, '/session_start_time');
            session_idnum = h5read(obj.nwbFile, '/general/session_id');
            session_id = num2str(session_idnum);
            protocolcell = h5read(obj.nwbFile, '/general/protocol');
            protocol = protocolcell; %{1};
            pharmacologycell = h5read(obj.nwbFile, '/general/pharmacology');
            pharmacology = pharmacologycell; %{1};
        end
        
        % Subject info
        function [subject, species, genotype, age, sex] = ...
                                                    GetSubjectData(obj)
%             subjectcell = h5read(obj.nwbFile, '/general/subject');
            subject = '';%subjectcell{1};
            speciescell = h5read(obj.nwbFile, '/general/subject/species');
            species = speciescell;%{1};
            genotypecell = h5read(obj.nwbFile, '/general/subject/genotype');
            genotype = genotypecell;%{1};
            agecell = h5read(obj.nwbFile, '/general/subject/age');
            age = agecell;%{1};
            sexcell = h5read(obj.nwbFile, '/general/subject/sex');
            sex = sexcell;%{1};
        end
        
        %% Acquisition Data
        function list = GetAcquisitionSweepList(obj)
            list = obj.acquisitionSweepList;
        end
        
        % True if there is a sweep in the acquisition sweeps with the
        % stated number
        function tf = IsAcquisitionSweep(obj, sweepnum)
            sweepstr = num2str(sweepnum);
            tf = any(strcmpi(sweepstr, obj.acquisitionSweepList));
        end
        
        %% Stimulus Data
        function list = GetStimulusSweepList(obj)
            list = obj.stimulusSweepList;
        end
        
        % True if there is a sweep in the stimulus sweeps with the
        % stated number
        function tf = IsStimulusSweep(obj, sweepnum)
            sweepstr = num2str(sweepnum);
            tf = any(strcmpi(sweepstr, obj.stimulusSweepList));
        end
        
        %% Analysis Data
        function list = GetAnalysisSweepList(obj)
            list = obj.analysisSweepList;
        end
        
        % True if there is a sweep in the analysis sweeps with the
        % stated number
        function tf = IsAnalysisSweep(obj, sweepnum)
            sweepstr = num2str(sweepnum);
            tf = any(strcmpi(sweepstr, obj.analysisSweepList));
        end
        
    end 
    
    %% Computed Parameters
    methods 
        % defn in separate file
        [cellData, success, answer] = getComputedParameters(obj)  
    end
    
	methods(Access=protected)
        list = GetSweepList(obj,location)
    end
end

