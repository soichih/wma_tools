function classificationOut = wma_resortClassificationStruc(classificationIn)
%  This function resorts an input classification structure such that left
%  and right variants of a tract are next to eachother.  Future versions
%  may attempt to sort singleton tracts to the front and subcategories
%  (i.e. interhemispheric or ufibers) in an additional fashion.
%
%  Inputs:
%  classificationIn:  A standardly structured classification structure.
%
%  Outputs:
%  classificationOut: The same classification structure, but now with the
%  names sorted into pairings, and the index numbering adjusted accordingly
%
%  Dan Bullock 2019

outNames=[];
outIndex=zeros(1,length(classificationIn.index));
classificationOut=classificationIn;

%get the pairing information
classificationGrouping = wma_classificationStrucGrouping(classificationIn);

%establish exclusion bool for left/right tracts which do not have a
%partner, for whatever reason
excludeSingletonBool=zeros(1,length(classificationGrouping.names));
%same for groupCounts
groupCounts=excludeSingletonBool;

%estbalish a integer vector with numerals corresponding to the groups
indexVector=1:length(classificationGrouping.names);

%here we find all tracts which are singletons
for itracts=1:length(classificationGrouping.names)
    %find all indexes which correspond to this group
    candidateIndexes=classificationIn.index(classificationGrouping.index==itracts);
    if isempty(candidateIndexes)
        warning('\n %s has no associated streamlines', classificationGrouping.names{itracts})
    end
    
    %find which indexes in the input classification correspond to this group
    uniqueIndexes=unique(candidateIndexes);
    %get the count
    groupCounts(itracts)=length(uniqueIndexes);
    %checks to see if current tract name is in the origional
    %classificationIn.index.  This would only be false of tracts that are
    %categorically, rather than incidentally, singletons.
    excludeSingletonBool(itracts)=isempty(find(strcmp(classificationGrouping.names{itracts},classificationIn.names), 1));
end

%DO WE WANT TO ENGAGE IN FURTHER SORTING OF THE SINGLETON TRACTS?  IF SO DO
%IT HERE

%find the index labels for the singletons
singletonIndexes=find(groupCounts==1&~excludeSingletonBool);

%find the tracts which are not singletons
pairIndexes=setdiff(indexVector,singletonIndexes);

groupOrdering=horzcat(singletonIndexes,pairIndexes);


% loop through the group names
for itracts=groupOrdering
    %find all indexes which correspond to this group
    candidateIndexes=classificationIn.index(classificationGrouping.index==itracts);
if isempty(candidateIndexes)
        warning('\n %s has no associated streamlines', classificationGrouping.names{itracts})
    end
    %find which indexes in the input classification correspond to this group
    uniqueIndexes=unique(candidateIndexes);
    %find the cooresponding names    
    upcomingNames={classificationIn.names{[uniqueIndexes]'}};
    %sort the alphabetically, so that left right is consistent
    [~,sortOrder]=sort(upcomingNames);
    %loop throught the tracts of the group
    for iTractPairs=1:length(uniqueIndexes)
        %get the current name of the current sorted pair
        curName=classificationIn.names{uniqueIndexes(sortOrder(iTractPairs))};
        %add it to the output name vector
        outNames=horzcat(outNames,{curName});
        %find the index label in the origional that corresponds to this
        %name
        origIndexFind=find(strcmp(curName,classificationIn.names));
        %set the index entries in the output classification to the new index
        %label.
        outIndex(classificationIn.index==origIndexFind)=length(outNames);
    end
end

%Set the fields appropriately
classificationOut.names=outNames;
classificationOut.index=outIndex;
end
        
