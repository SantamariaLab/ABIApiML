% ABIExperiment.m
% A class representing an experiment represented in an Allen Brain
% Institute Cell Types Database nwb file.
classdef ABIExperiment < handle
    properties
        filePath;
        expNum;
        expStr;
        expLocation;
        sweep;
    end
        
    methods
        %% Basic
        function obj = ABIExperiment(filepath, expnum)
            obj.filePath = filepath;
            obj.expNum = expnum;
            obj.expStr = ['Experiment_' num2str(expnum)];
            obj.expLocation = ['/epochs' '/' obj.expStr];
        end
        
        function num = GetExpNum(obj)
            num = obj.expNum;
        end
        
        function str = GetExpStr(obj)
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
        
        function sweep = GetExperimentSweep(obj)
            sweep = ABISweep(obj.filePath, obj.expNum);
        end
       
        function desc = GetStimulusDescription(obj)
            sweep = obj.GetExperimentSweep(); %#ok<*PROP>
            [~,~,~,~,desc] = sweep.GetAIBSStimulusInfo();
            sweep.delete();
        end
    end
end