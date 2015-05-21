classdef Image < handle
% Class for all images
   properties
      Img
      Path
      ScaleFromFullResolution
      Size
   end
   methods
      function obj = Image(path, scale)
         obj.Path = path;
         % obj.Img = imread(obj.Path);
         obj.ScaleFromFullResolution = scale;
         obj.Size = size(obj.Img);
      end
      function clearimage(obj)
         obj.Img = [];
      end
   end
end