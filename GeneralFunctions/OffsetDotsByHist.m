function dotshift = OffsetDotsByHist(DataIn,ShiftMax,NumBins)
%dotshift = OffsetDotsByHist(DataIn,shiftmax,NumBins)
%take data and shift the values according to the histogram of their frequency
%used for plotting individual dots on top of a bar graph, offseting their
%x-axis values by the frequency of occurrence
%input Data (single row), ShiftMax (max ±shift on x-axis), and NumBins (number of bins to collate histogram over)
%
%J Greenwood October 2021
%
% e.g. DataIn = [.8233 .6016 .7184 .9225 .7313 1.0070 1.5152 2.0218 0.5694 .8166 .6000 .4101 .8084 .7740 1.0261 1.0094 .4000 2.5407 .6235 .4084]; dotshift = OffsetDotsByHist(DataIn,0.075,10); plot(dotshift,DataIn,'ko');

[DataHist,BinEdges] = histcounts(DataIn,NumBins); %compute the histogram
DataHist            = DataHist./max(DataHist(:)); %convert to 0-1

for dd=1:numel(DataHist) %loop through each bin
    DataInd = find(DataIn>BinEdges(dd) & DataIn<BinEdges(dd+1)); %find data within this bin
    %dotshift(grp,DataInd) = randn(1,numel(DataInd)).*DataHist(dd); %use a gaussian rand distribution
    if numel(DataInd)>1
        dotshift(DataInd) = linspace(-DataHist(dd),DataHist(dd),numel(DataInd)); %shift values evenly within the range
    else %don't shift values in bins of 0 or 1
        dotshift(DataInd) = 0;
    end
end

dotshift = (dotshift./max(abs(dotshift))).*ShiftMax; %make sure values go from ±yshiftmax

