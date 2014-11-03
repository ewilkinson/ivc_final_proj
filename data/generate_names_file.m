fileID = fopen('./misc/names.txt','wt');
for i=1:size(names)
   fprintf(fileID,'%d : %s\n',i, names{i});
end