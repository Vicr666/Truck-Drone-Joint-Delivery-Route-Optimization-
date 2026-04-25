function varargout = log_time(logfile, funcHandle, varargin)
% MATLAB conversion of Log decorator
s = tic;
[varargout{1:nargout}] = funcHandle(varargin{:});
elapsed = toc(s);
if nargin >= 1 && ~isempty(logfile)
    fid = fopen(logfile, 'a');
    if fid >= 0
        fprintf(fid, '%s,%.6f
', func2str(funcHandle), elapsed);
        fclose(fid);
    end
end
end
