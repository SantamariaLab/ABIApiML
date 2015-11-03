% ABIExperiment.m
% A class representing an experiment represented in an Allen Brain
% Institute Cell Types Database nwb file.
classdef ABIExperiment < handle
    properties
        filePath;
        expNum;
        expStr;
        expLocation;
    end
        
    methods
        %% Basic
        function obj = ABIExperiment(filepath, expnum)
            obj.filePath = filepath;
            obj.expNum = expnum;
            obj.expStr = ['Experiment_' num2str(expnum)];
            obj.expLocation = ['/epochs' '/' obj.expStr];
        end
        
        function num = GetExperimentNum(obj)
            num = obj.expNum;
        end
        
        function str = GetExperimentStr(obj)
            str = obj.expStr;
        end
        
        %% Features
        function desc = GetExperimentDescription(obj)
            desc = h5read(obj.filePath, [obj.expLocation '/description']);
        end
        
        function [starttime, stoptime] = GetExperimentTimes(obj)
            starttime = h5read(obj.filePath, [obj.expLocation '/start_time']);
            stoptime  = h5read(obj.filePath, [obj.expLocation '/stop_time']);
        end
        
        % GetTimeBaseWindow
        % stimulus and response appear to have same timebase so we just use
        % stimulus 
        function [startIndex, endIndex] = GetTimeBaseWindow(obj)
            startIndex = h5read(obj.filePath, ...
                                [obj.expLocation '/stimulus/idx_start']);
            count      = h5read(obj.filePath, ...
                                [obj.expLocation '/stimulus/count']);
            endIndex = startIndex + count - 1;
        end
        
        % GetExperimentSweep 
        % Grabs this experiment's sweep using the experiment hdf5 path
        % just in case it matters sometime
        function sweep = GetExperimentSweep(obj)
            sweep = ABISweep(obj.filePath, obj.expNum, true, obj.expNum);
        end
       
        function desc = GetStimulusDescription(obj)
            sweep = obj.GetExperimentSweep(); %#ok<*PROP>
            [~,~,~,~,desc] = sweep.GetAIBSStimulusInfo();
            sweep.delete();
        end
    end
end