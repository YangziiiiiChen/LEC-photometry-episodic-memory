function [AveZscore, Std_GCAMP] = Calculate_dFoF_V2(fname_TDT, ifplot)

% function m-file to calculate deltaF/F from raw GFP and GCAMP signals
%
% INPUT ---- fname_TDT: the name of matlab file storing the raw signal values.
%            fname_dFoF: the name of file to store the dF/F and timestamps
%
% written by K.T. on June 2nd 2025


%%
load(fname_TDT); 

% Reward locked activity
RewardTS = PyControlData.time_correct;
[dF.Reward, zScore.Reward, Std_GCAMP] = Event_Locked_Activity(RewardTS, PhotometryData, 'Reward', 1, fname_TDT, ifplot);


% Extract movement-related timestamps
for type = 1:2
    if type == 1
        dlcData = DLCData_rewarded; 
    else
        dlcData = DLCData_unrewarded;
    end

    for l = 1:length(dlcData)
        data = dlcData{l};
        Entry(l) = data.entry_time;
        Exit(l) = data.exit_time;
        PortFrontBin = find(data.spatial_bin == 12);
        if isempty(PortFrontBin)==1
            PortFront(l) = nan;
        else
            PortFront(l) = data.timestamps(PortFrontBin(1));
        end
    end

    if type == 1
        TS.Rewarded.Entry = Entry;
        TS.Rewarded.Exit = Exit;
        TS.Rewarded.PortFront = PortFront;
    else
        TS.UnRewarded.Entry = Entry;
        TS.UnRewarded.Exit = Exit;
        TS.UnRewarded.PortFront = PortFront;
    end
end
        
% Entry locked activity

EntryTS = TS.Rewarded.Entry;
EntryTS(isnan(EntryTS)==1) = [];
[dF.Entry.Rewarded, zScore.Entry.Rewarded, ~] = Event_Locked_Activity(EntryTS, PhotometryData, 'Entry-Rewarded', 0, fname_TDT, ifplot);

EntryTS = TS.UnRewarded.Entry;
EntryTS(isnan(EntryTS)==1) = [];
[dF.Entry.UnRewarded, zScore.Entry.UnRewarded, ~] = Event_Locked_Activity(EntryTS, PhotometryData, 'Entry-UnRewarded', 0, fname_TDT, ifplot);


% Exit locked activity

ExitTS = TS.Rewarded.Exit;
ExitTS(isnan(ExitTS)==1) = [];
[dF.Exit.Rewarded, zScore.Exit.Rewarded, ~] = Event_Locked_Activity(ExitTS, PhotometryData, 'Exit-Rewarded', 0, fname_TDT, ifplot);

ExitTS = TS.UnRewarded.Exit;
ExitTS(isnan(ExitTS)==1) = [];
[dF.Exit.UnRewarded, zScore.Exit.UnRewarded, ~] = Event_Locked_Activity(ExitTS, PhotometryData, 'Exit-UnRewarded', 0, fname_TDT, ifplot);

% Port front activity

PortFrontTS = TS.Rewarded.PortFront;
PortFrontTS(isnan(PortFrontTS)==1) = [];
[dF.PortFront.Rewarded, zScore.PortFront.Rewarded, ~] = Event_Locked_Activity(PortFrontTS, PhotometryData, 'PortFront-Rewarded', 0, fname_TDT, ifplot);

PortFrontTS = TS.UnRewarded.PortFront;
PortFrontTS(isnan(PortFrontTS)==1) = [];
[dF.PortFront.UnRewarded, zScore.PortFront.UnRewarded, ~] = Event_Locked_Activity(PortFrontTS, PhotometryData, 'PortFront-UnRewarded', 0, fname_TDT, ifplot);


FalseAlarmTS = []; HitTS = [];
PokeTS = PyControlData.poke_times;
for i = 1:length(PokeTS)
    if ~any(abs(RewardTS-PokeTS(i))<0.1, "all") == 1
        FalseAlarmTS = [FalseAlarmTS; PokeTS(i)];
    else
        HitTS = [HitTS; PokeTS(i)];
    end
end

if length(FalseAlarmTS) > 10 % at least 10 FA trials
    [dF.Hit, zScore.Hit, ~] = Event_Locked_Activity(HitTS, PhotometryData, 'Hit', 0, fname_TDT, ifplot);
    [dF.FA, zScore.FA, ~] = Event_Locked_Activity(FalseAlarmTS, PhotometryData, 'False Alarm', 0, fname_TDT, ifplot);
    Skip = 0;
else
    disp('Not enough FA trials.')
    Skip = 1;
end

clear AveZscore
AveZscore(1, :) = mean(zScore.Reward, 1);
if Skip == 0
    AveZscore(2, :) = mean(zScore.FA, 1);
else
    AveZscore(2, :) = nan(1, size(zScore.Reward,2));
end

AveZscore(3, :) = mean(zScore.Entry.Rewarded, 1);
AveZscore(4, :) = mean(zScore.Entry.UnRewarded, 1);
AveZscore(5, :) = mean(zScore.Exit.Rewarded, 1);
AveZscore(6, :) = mean(zScore.Exit.UnRewarded, 1);
AveZscore(7, :) = mean(zScore.PortFront.Rewarded, 1);
AveZscore(8, :) = mean(zScore.PortFront.UnRewarded, 1);



save(fname_TDT);

