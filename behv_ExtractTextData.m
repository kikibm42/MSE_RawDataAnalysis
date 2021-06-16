function data = behv_ExtractTextData(filename, variablename)

x = fileread(filename);

if strcmp(variablename, 'Subject')
   m = ['(?<=' variablename ': )[ A-z#0-9:./_\-]+']; 
else 
   m = ['(?<=' variablename ': )[ A-z0-9:./_\-]+'];
end

[start,endd] = regexp(x,m);

if length(start) > 1
    error('More than one variable match.');

end

data = x(start:endd);