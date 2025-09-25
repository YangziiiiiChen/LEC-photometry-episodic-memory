function fullPath = find_tsv(folderPath, animalID)
    fullPath = '';
    allFiles = dir(fullfile(folderPath, '**', '*.tsv'));
    [~, sortedIndex] = sort({allFiles.name});
    allFiles = allFiles(sortedIndex);

    for i = 1:length(allFiles)
        fileName = allFiles(i).name;
        if startsWith(fileName, animalID)
            fullPath = fullfile(allFiles(i).folder, fileName);
            break;
        end
    end

    if isempty(fullPath)
        disp(strcat("No such file", strcat(folderPath, animalID)));
        fullPath = false;
    end
end
