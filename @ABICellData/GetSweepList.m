% GetSweepList
% Pulls in the numbers of all sweeps found in the given section and
% returns them as strings in a cell array.
function sweepstrs = GetSweepList(obj, sweepparentlocation)
    sweeps = h5info(obj.nwbFile, sweepparentlocation);
    % Sweeps are parented by two different types of HDF5 objects
    numsweeps = max([size(sweeps.Groups,1) size(sweeps.Datasets,1)]);
	sweepstrs = {};
    
    % Run through possible sweep names until reach numsweeps of them
    fid = H5F.open(obj.nwbFile, 'H5F_ACC_RDONLY','H5P_DEFAULT');
    for i = 0:obj.MAX_SWEEPS
        sweepid = ['Sweep_' num2str(i)];
        
        % The sweeps may be groups or may be datasets
        try  
            gid = H5G.open(fid, [sweepparentlocation '/' sweepid]);
            H5G.close(gid);
            sweepstrs = [sweepstrs {num2str(i)}]; %#ok<AGROW>
        catch
            try
                gid = H5G.open(fid, [sweepparentlocation]);
                did = H5D.open(gid, sweepid);
                H5D.close(did);
                H5G.close(gid);
                sweepstrs = [sweepstrs {num2str(i)}]; %#ok<AGROW>
            catch
%                 disp([sweepparentlocation '/' sweepid ' rejected'] );
            end
        end
        if length(sweepstrs) >= numsweeps
            break;
        end
    end
    H5F.close(fid);
 	disp(numsweeps);
end
