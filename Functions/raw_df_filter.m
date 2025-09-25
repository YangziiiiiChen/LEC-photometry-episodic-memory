function result = raw_df_filter(df)


filtered_df = df(ismember(df.content, {'A_poke', 'B_poke', 'C_poke', 'D_poke'}), :);
timeDiff = diff(filtered_df.time);
groupStartIdx = [true; timeDiff >= 0.0001];
filtered_rows = filtered_df(~groupStartIdx, :);
deleteIdx = ismember(df.time, filtered_rows.time) & ismember(df.content, filtered_rows.content);
df = df(~deleteIdx, :);

filtered_df = df(ismember(df.content, {'A_poke', 'B_poke', 'C_poke', 'D_poke'}), :);
non_repeating_idx = [true; ~strcmp(filtered_df.content(1:end-1), filtered_df.content(2:end))];
result = filtered_df(non_repeating_idx, :);

end