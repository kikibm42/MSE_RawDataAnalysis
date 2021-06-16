function data = behv_ExtractNumericalData(filename, variablename)

x = fileread(filename);
m = [variablename ':[\r\n0-9 :.-]+'];
[start,endd] = regexp(x,m);

if length(start) > 1
    error('More than one variable match.');

end

data = x(start:endd);
data = regexprep(data,'[A-z]:','');
data = regexprep(data, '[0-9]+:', '');
data = regexprep(data, '[\r\n]+', ' ');
data = regexprep(data, '^[ ]+', '');
data = regexprep(data, '[ ]+$', '');
data = regexprep(data, ' [ ]+', ' ');

data = regexp(data, ' ', 'split');
if ~isequal(data, {''})
    data = cellfun(@str2num, data);
else
    data = {};
end