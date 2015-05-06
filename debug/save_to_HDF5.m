input = '/mnt/data0/tommy/elastic_renders_1x/S2-W001/';
output = [input 'HDF5/'];
files = dir([input 'full/*.tif']);
for file = files(1)
    img = imread([input 'full/' file.name]);
    fn = [output file.name(1:end-4) '.h5']
    h5create(fn, '/main', size(img));
    h5write(fn, '/main', img); 
end