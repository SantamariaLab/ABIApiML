% GetExperimentList
% Pulls in the numbers of all experiments found in the given section and
% returns them as strings in a cell array.
function expStrs = GetExperimentList(obj)
    expLocation = '/epochs';
    epochChildren = h5info(obj.nwbFile, expLocation);
    maxExps = size(epochChildren.Groups,1);
	expStrs = {};
    
    % Run through possible exp names until reach maxExps of them
    fid = H5F.open(obj.nwbFile, 'H5F_ACC_RDONLY','H5P_DEFAULT');
    for i = 0:obj.MAX_EXPS
        expID = ['Experiment_' num2str(i)];
        
        try  
            gid = H5G.open(fid, [expLocation '/' expID]);
            H5G.close(gid);
            expStrs = [expStrs {num2str(i)}]; %#ok<AGROW>
        catch
        end
        if length(expStrs) >= maxExps
            break;
        end
    end
    H5F.close(fid);
 	disp(length(expStrs));
end
