function block_accuracy = compute_block_accuracy(poke_correct, window_size)

n = length(poke_correct);

if n < window_size
    block_accuracy = sum(poke_correct) / n;
else
    starts = 1:10:(n - window_size + 1);
    if starts(end) ~= n - window_size + 1
        starts = [starts, n - window_size + 1];
    end
    block_accuracy = arrayfun(@(i) sum(poke_correct(i:i+window_size-1)) / window_size, starts);
end

end
