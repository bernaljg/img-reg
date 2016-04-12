%Created by: Bernal Jimenez
%4/11/2016

function [] = analyze_dfields(dfield, directory)

quiver(dfield(:,:,1),dfield(:,:,2),2);
saveplot(directory,'Vector Field')

[directions, magnitudes] = get_polar(dfield);
colormap default

image(directions,'CDataMapping','scaled');
colorbar
saveplot(directory,'Angle Distributions')

image(magnitudes,'CDataMapping','scaled');
colorbar
saveplot(directory,'Magnitude Distribution')

histogram(directions,359);
saveplot(directory,'Angle Histogram');

histogram(magnitudes);
saveplot(directory,'Magnitude Histogram');

end

function [angles,radii] = get_polar(dfield) %Get list of angles in radians from displacement field vectors
 
[angles,radii] = cart2pol(dfield(:,:,1),dfield(:,:,2));

end

function [] = saveplot(dir,name)

title(name)
savefig([dir '/' name '.fig'])
end
