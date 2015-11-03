% ABISweep.m
% A class representing a sweep in an Allen Brain Institute NWB file.
% Generic sweep approach: if a sweep doesn't have the attribute in either
% the acquisition or stimulus sections, it returns either a NaN or an empty
% string.  Apparent truth: if, for a specific sweep number an attribute
% appears in both acquisition and stimulus/presentation sections, its
% value is the same in both; so here we report the value from the first
% place in which we find the attribute.
%% Sweep children discovered so far
% ----------------------------------|
% aibs_stimulus_amplitude_mv           
% aibs_stimulus_amplitude_pa
% aibs_stimulus_description
% aibs_stimulus_interval
% aibs_stimulus_name
% bias_current
% bridge_balance
% capacitance_compensation
% capacitance_fast
% capacitance_slow
% data
% electrode
% gain
% initial_access_resistance
% num_samples
% resistance_comp_bandwidth
% resistance_comp_correction
% resistance_comp_prediction
% seal
% starting_time
% whole_cell_capacitance_comp
% whole_cell_series_resistance_comp
% ----------------------------------|

%%
classdef ABISweep < handle
    properties
        filepath;
        acqlocation;
        analocation;
        stimlocation;
        sweepnum
        sweepstr;
        acqsweeploc;
        anasweeploc;
        stimsweeploc;
        
        % The pdf says sampling rate is 200 KHz
        SAMPLING_RATE = 200000.0;
        SAMPLING_PERIOD = 1/200000.0;
    end
    
    methods
        %% Basic
        function obj = ABISweep(filepath, sweepnum)
            obj.filepath = filepath;
            obj.acqlocation = '/acquisition/timeseries';
            obj.analocation = '/analysis/aibs_spike_times';
            obj.stimlocation = '/stimulus/presentation';
            obj.sweepnum = sweepnum;
            obj.sweepstr = ['Sweep_' num2str(sweepnum)];
            obj.acqsweeploc = [obj.acqlocation '/' obj.sweepstr];
            obj.anasweeploc = [obj.analocation '/' obj.sweepstr];
            obj.stimsweeploc = [obj.stimlocation '/' obj.sweepstr];
        end
        
        function num = GetSweepnum(obj)
            num = obj.sweepnum;
        end
        
        function str = GetSweepStr(obj)
            str = obj.sweepstr;
        end
        
        function rate = GetSamplingRate(obj)
            rate = obj.SAMPLING_RATE;
        end
        
        function period = GetSamplingPeriod(obj)
            period = obj.SAMPLING_PERIOD;
        end

        %% Features
        % GetAIBSStimulusInfo
        function [amp_mv, amp_pa, des, int, name] = GetAIBSStimulusInfo(obj)
            %
            try
                amp_mv = h5read(obj.filepath, ...
                                [obj.acqsweeploc '/aibs_stimulus_amplitude_mv']);
            catch
                try
                    amp_mv = h5read(obj.filepath, ...
                      [obj.stimsweeploc '/aibs_stimulus_amplitude_mv']); %#ok<*NASGU>
                catch
                    amp_mv = NaN;
                end
            end
            %
            try
                amp_pa = h5read(obj.filepath, ...
                         [obj.acqsweeploc '/aibs_stimulus_amplitude_pa']);
            catch
                try
                    amp_pa = h5read(obj.filepath, ...
                             [obj.stimsweeploc '/aibs_stimulus_amplitude_pa']);
                catch
                    amp_pa = NaN;
                end
            end
            %
            try
                descell = h5read(obj.filepath, ...
                         [obj.acqsweeploc '/aibs_stimulus_description']);
                des = descell{1};
            catch
                try
                    descell = h5read(obj.filepath, ...
                             [obj.stimsweeploc '/aibs_stimulus_description']);
                    des = descell{1};
                catch
                    des = '';
                end
            end
            %
            try
                int = h5read(obj.filepath, ...
                         [obj.acqsweeploc '/aibs_stimulus_interval']);
            catch
                try
                    int = h5read(obj.filepath, ...
                             [obj.stimsweeploc '/aibs_stimulus_interval']);
                catch
                    int = NaN;
                end
            end
            %
            try
                namecell = h5read(obj.filepath, ...
                         [obj.acqsweeploc '/aibs_stimulus_name']);
                name = namecell{1};
            catch
                try
                    namecell = h5read(obj.filepath, ...
                             [obj.stimsweeploc '/aibs_stimulus_name']);
                    name = namecell{1};
                catch
                    name = '';
                end
            end
        end
        
        % GetCapacitances
        function [capfast, capslow, whcellcapcomp] = GetCapacitances(obj)
            try
                capfast = h5read(obj.filepath, ...
                                 [obj.acqsweeploc '/capacitance_fast']);
            catch
                try
                    capfast = h5read(obj.filepath, ...
                                 [obj.stimsweeploc '/capacitance_fast']);
                catch
                    capfast = NaN;
                end
            end
            %
            try
                capslow = h5read(obj.filepath, ...
                                 [obj.acqsweeploc '/capacitance_fast']);
            catch
                try
                    capslow = h5read(obj.filepath, ...
                                 [obj.stimsweeploc '/capacitance_fast']);
                catch
                    capslow = NaN;
                end
            end
            %
            try
                whcellcapcomp = h5read(obj.filepath, ...
                                 [obj.acqsweeploc '/whole_cell_capacitance_comp']);
            catch
                try
                    whcellcapcomp = h5read(obj.filepath, ...
                                 [obj.stimsweeploc '/whole_cell_capacitance_comp']);
                catch
                    whcellcapcomp = NaN;
                end
            end
        end
        
        % GetResistances
        function [initAccess, compBW, compCorr, compPred, ...
                  whCellSeriesComp] = GetResistances(obj)
            try
                initAccess = h5read(obj.filepath, ...
                                    [obj.acqsweeploc '/initial_access_resistance']);
            catch
                try
                    initAccess = h5read(obj.filepath, ...
                                    [obj.stimsweeploc '/initial_access_resistance']);
                catch
                    initAccess = NaN;
                end
            end
            %
            try
                compBW = h5read(obj.filepath, ...
                                [obj.acqsweeploc '/resistance_comp_bandwidth']);
            catch
                try
                    compBW = h5read(obj.filepath, ...
                                [obj.stimsweeploc '/resistance_comp_bandwidth']);
                catch
                    compBW = NaN;
                end
            end
            %
            try
                compCorr = h5read(obj.filepath, ...
                                [obj.acqsweeploc '/resistance_comp_correction']);
            catch
                try
                    compCorr = h5read(obj.filepath, ...
                                [obj.stimsweeploc '/resistance_comp_correction']);
                catch
                    compCorr = NaN;
                end
            end
            %
            try
                compPred = h5read(obj.filepath, ...
                                [obj.acqsweeploc '/resistance_comp_prediction']);
            catch
                try
                    compPred = h5read(obj.filepath, ...
                                [obj.stimsweeploc '/resistance_comp_prediction']);
                catch
                    compPred = NaN;
                end
            end
            %
            try
                whCellSeriesComp = h5read(obj.filepath, ...
                    [obj.acqsweeploc '/whole_cell_series_resistance_comp']);
            catch
                try
                    whCellSeriesComp = h5read(obj.filepath, ...
                        [obj.stimsweeploc '/whole_cell_series_resistance_comp']);
                catch
                    whCellSeriesComp = NaN;
                end
            end
        end
        
        % GetBasicInfo
        function [electrode, gain, num_samples, seal, starting_time] = ...
                GetBasicInfo(obj)
            try
                electrode = h5read(obj.filepath, ...
                                       [obj.acqsweeploc '/electrode']);
            catch
                try
                    electrode = h5read(obj.filepath, ...
                                       [obj.stimsweeploc '/electrode']);
                catch
                    electrode = '';
                end
            end
            %
            try
                gain = h5read(obj.filepath, [obj.acqsweeploc '/gain']);
            catch
                try
                    gain = h5read(obj.filepath, [obj.stimsweeploc '/gain']);
                catch
                    gain = NaN;
                end
            end
            %
            try
                num_samples = h5read(obj.filepath, ...
                                     [obj.acqsweeploc '/num_samples']);
            catch
                try
                    num_samples = h5read(obj.filepath, ...
                                         [obj.stimsweeploc '/num_samples']);
                catch
                    num_samples = NaN;
                end
            end
            %
            try
                seal = h5read(obj.filepath, [obj.acqsweeploc '/seal']);
            catch
                try
                    seal = h5read(obj.filepath, [obj.stimsweeploc '/seal']);
                catch
                    seal = NaN;
                end
            end
            %
            try
                starting_time = h5read(obj.filepath, ...
                                [obj.acqsweeploc '/starting_time']);
            catch
                try
                    starting_time = h5read(obj.filepath, ...
                                    [obj.stimsweeploc '/starting_time']);
                catch
                    starting_time = '';
                end
            end
        end 
            
        
        %% Data
        % GetTimeBase
        function timeBase = GetTimeBase(obj)
            [~,~,numSamples,~,startTime] = obj.GetBasicInfo();
            samplingPeriod = obj.GetSamplingPeriod();
            timeBase = double(startTime):samplingPeriod:(double(startTime)+(double(numSamples)-1)*samplingPeriod);
            if length(timeBase) ~= numSamples
                error('TimeBase error');
            end
        end
        
        % GetAcquisitionData
        function [data, conversion, resolution, units] = GetAcquisitionData(obj)
            data = h5read(obj.filepath, [obj.acqsweeploc '/data']);
            try
                conversion = ...
                    num2str(h5readatt(obj.filepath, ...
                                [obj.acqsweeploc '/data'], 'conversion'));
            catch
                conversion = '';
            end
            
            try
                resolution = ...
                    num2str(h5readatt(obj.filepath, ...
                                [obj.acqsweeploc '/data'], 'resolution'));
            catch
                resolution = '';
            end
            
            try
                unitscell = ...
                    h5readatt(obj.filepath, [obj.acqsweeploc '/data'], 'units');
                units = unitscell{1};
            catch
                units = '';
            end
            
        end
        
        % GetStimulusData
        function [data, conversion, resolution, units] = GetStimulusData(obj)
            data = h5read(obj.filepath, [obj.stimsweeploc '/data']);
            try
                conversion = ...
                    num2str(h5readatt(obj.filepath, ...
                                [obj.stimsweeploc '/data'], 'conversion'));
            catch
                conversion = '';
            end
            
            try
                resolution = ...
                    num2str(h5readatt(obj.filepath, ...
                                [obj.stimsweeploc '/data'], 'resolution'));
            catch
                resolution = '';
            end
            
            try
                unitscell = ...
                    h5readatt(obj.filepath, [obj.stimsweeploc '/data'], 'units');
                units = unitscell{1};
            catch
                units = '';
            end
        end
        
        % GetAnalysisSpikeTimes
        function times = GetAnalysisSpikeTimes(obj)
            try
                times = h5read(obj.filepath, [obj.analocation '/' obj.sweepstr]);        
            catch
                times = [];
            end
        end
    end
end
