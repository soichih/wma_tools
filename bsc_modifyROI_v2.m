function [roiOUT]=bsc_modifyROI_v2(atlas,roiIN, refCoord, location)
% [roiOUT]=bsc_modifyROI_v2(atlas,roiIN, refCoord, location)
% DESCRIPTION:
% This function modifies an roi by removing all roi coordinates NOT
% specified by the input.  For example, relative to a particular
% coordinate, an input instruction (in the "location" variable) of
% "superior" will remove all coordinates inferior to the specified refCoord
%
% INPUTS:
% -atlas: path to atlas or atlas nifti
%
% -roiIN: the roi that is to be modified.
%
% -refCoord= reference coordinate from which modification will be made.  If
% a plane is input, it will infer that the plane is suppose to serve as a
% devision point.  This could lead to an empty output (i.e. asking for
% everything anterior of a plane that is already anterior of the roi).
%
% -location: a string input indicating the extreme-most part of the roi
% that is to serve as the basis for forming the roi.  i.e. "top",
% "superior", "bottom", "inferior", "anterior", "posterior", "medial",
% "lateral"
%
% OUTPUTS:
% -roiOUT: the roi structure of the modified ROI
%
%  (C) Daniel Bullock 2017 Bloomington
%%  Begin Code

% redefine refCoord if plane
if isstruct(refCoord)
    refCoord=[mean(refCoord.coords(:,1)),mean(refCoord.coords(:,2)),mean(refCoord.coords(:,3))];
else
    %no need to redfine refCoord
end

%if roiIN is fsNum get roi, else do nothing.
if isnumeric(roiIN)
    roiIN=bsc_roiFromAtlasNums(atlas,[roiIN ],0);
elseif isstruct(roiIN)
    %no action
else
    error('\n Unrecognized input for "roiIN" in bsc_planeFromROI')
end

%determine if this roi is on the left or the right.  Will cause
%problems for cross hemispheric ROIS  

%HUGE CHANGE FOR V2 :  USING THE refCoord AS THE DETERMINANT FOR LEFT RIGHT
%LRflag=mean(roiIN.coords(:,1))<0;
LRflag=refCoord<0;

%create dummy structure
roiOUT=roiIN;

%SHOULD THIS BE DONE FROM THE PERSPECTIVE OF THE ROI OR THE CRITERIA?
%execute switch statement and find coords that meet criteria
switch lower(location)
    case 'top'
        refCoordSingle=refCoord(3);
        roiOUT.coords=roiIN.coords(roiIN.coords(:,3)>refCoordSingle,:);
    case 'superior'
        refCoordSingle=refCoord(3);
        roiOUT.coords=roiIN.coords(roiIN.coords(:,3)>refCoordSingle,:);
    case 'bottom'
        refCoordSingle=refCoord(3);
        roiOUT.coords=roiIN.coords(roiIN.coords(:,3)<refCoordSingle,:);
    case 'inferior'
        refCoordSingle=refCoord(3);
        roiOUT.coords=roiIN.coords(roiIN.coords(:,3)<refCoordSingle,:);
    case 'anterior'
        refCoordSingle=refCoord(2);
        roiOUT.coords=roiIN.coords(roiIN.coords(:,2)>refCoordSingle,:);
    case 'posterior'
        refCoordSingle=refCoord(2);
        roiOUT.coords=roiIN.coords(roiIN.coords(:,2)<refCoordSingle,:);
    case 'medial'
        if LRflag
            refCoordSingle=refCoord(1);
            roiOUT.coords=roiIN.coords(roiIN.coords(:,1)>refCoordSingle,:);
        else
            refCoordSingle=refCoord(1);
            roiOUT.coords=roiIN.coords(roiIN.coords(:,1)<refCoordSingle,:);
        end
    case 'lateral'
        if LRflag
            refCoordSingle=refCoord(1);
            roiOUT.coords=roiIN.coords(roiIN.coords(:,1)<refCoordSingle,:);
        else
            refCoordSingle=refCoord(1);
            roiOUT.coords=roiIN.coords(roiIN.coords(:,1)>refCoordSingle,:);
        end
end

%rename ROI
roiOUT.name=strcat(roiIN.name,'_',num2str(refCoord),'_',location);

%throw warning for empty ROI
if isempty(roiOUT.coords)
    fprintf('bsc_modifyROI_v2: Empty roi.. %s\n', roiIN.name)
end

end
