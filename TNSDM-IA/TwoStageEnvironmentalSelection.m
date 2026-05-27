function [Pop_P, FrontNo_P, CrowdDis_P, Pop_PQS, FrontNo_PQS, CrowdDis_PQS, IsParent] = TwoStageEnvironmentalSelection(Pop_PQS, N)
% Environmental selection based on two-stage non-dominated sorting

%% First-stage non-dominated sorting based on constraint violation values
if isempty(Pop_PQS.cons)
    V = zeros(length(Pop_PQS),1);
else
    V = max(0,Pop_PQS.cons);
end
[FrontNo_v, MaxFNo_v] = NDSort(V, inf);

%% Second-stage non-dominated sorting based on objective function values
FrontNo_PQS     = zeros(1, length(Pop_PQS));
current_offset = 0;

for i = 1 : MaxFNo_v
    group = find(FrontNo_v == i);
    if ~isempty(group)
        [FrontNo_f, MaxFNo_f] = NDSort(Pop_PQS(group).objs, inf);
        for j = 1 : MaxFNo_f
            FrontNo_PQS(group(FrontNo_f == j)) = current_offset + j;
        end
        current_offset = current_offset + MaxFNo_f;
    end
end

%% Calculate the crowding distance
CrowdDis_PQS = CrowdingDistance(Pop_PQS.objs, FrontNo_PQS);

%% Select N solutions
sorted_fronts = sort(FrontNo_PQS);
MaxFNo        = sorted_fronts(N);

IsParent = FrontNo_PQS < MaxFNo;

Last = find(FrontNo_PQS == MaxFNo);
[~,Rank] = sort(CrowdDis_PQS(Last),'descend');

IsParent(Last(Rank(1:N-sum(IsParent)))) = true;

%% Return the selected parents and their corresponding selection information
Pop_P      = Pop_PQS(IsParent);
FrontNo_P  = FrontNo_PQS(IsParent);
CrowdDis_P = CrowdDis_PQS(IsParent);
end
