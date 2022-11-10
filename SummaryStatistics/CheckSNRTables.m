count = 0;
for i = 1:size(mappingReport, 1)
    cname = mappingReport{i, 4}.open_source_c;
    row = -1;
    for j = 1:size(subjectTable, 1)
        if(strcmp(subjectTable.SubjectId(j), cname))
           row = j;
           break;
        end
    end
    if(row == -1)
       fprintf("Could not find matching file for %s...\n", cname);
       count = count + 1;
    end
end