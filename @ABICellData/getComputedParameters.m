% getComputedParameters
% Given a cell (specimen) ID, returns the computed parameters for that cell
% in a struct.
function [cellData, success, answer] = getComputedParameters(obj)
    baseAddr = 'http://api.brain-map.org/api/v2/data/';
    addressExt = ...
        ['query.json?'...
         'criteria=model::EphysFeature,rma::criteria,%5Bspecimen_id$eq' ...
         obj.specimenID '%5D'];
    cmd = [fullfile(obj.curlDir, 'curl -sS ') '-X GET '];
    address = [baseAddr addressExt];
    cmd = [cmd address];

    % Issue command and parse the answer into response body and
    % response code
    [result, rawAnswer] = system(cmd);

    % Check for system command failure
    if result
        cellData = 0;
        success = false;
        answer = '';
        return;
    end

    parseRegExp = '^(.*})(\d*)$';
	answer = regexprep(rawAnswer, parseRegExp, '$1');
    data = loadjson(answer);
    
    % Check for API query failure
    if data.success == 1
        success = true;
    else
        success = false;
        cellData = 0;
        return;
    end
    
    % Pull out the data
    cellData = data.msg{1,1};
end
