function correct_ports = find_correct_port(filename)

mapping = containers.Map({'A', 'B', 'C', 'D'}, {1, 2, 3, 4});
df = readtable(filename, "FileType","text",'Delimiter', '\t');
content_str = df.content{2};
if strcmp(content_str, 'Foraging_3PortActive') || strcmp(content_str, 'Foraging_4PortActive') || strcmp(content_str, '4Ports_Shaping_Foraging') 
    correct_ports = NaN;
else
    active_ports = content_str(end-1:end);
    correct_ports = [mapping(active_ports(1)), mapping(active_ports(2))];
end

end