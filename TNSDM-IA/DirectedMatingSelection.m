function [MatingPool,Marked] = DirectedMatingSelection(Problem,Pop_P,FrontNo_P,CrowdDis_P,Pop_PQS,FrontNo_PQS,CrowdDis_PQS,MatingType,ArchiveSize)
% Directed mating with greedy selection or tournament selection

Pa_array = repmat(Pop_P(1),1,Problem.N);
Pb_array = repmat(Pop_P(1),1,Problem.N);
Marked   = zeros(1,0);

% Ensure that ranking information is handled as column vectors.
Front_PQS = FrontNo_PQS(:);
Crowd_PQS = CrowdDis_PQS(:);

for i = 1 : Problem.N
    %% Select the primary parent pa from P by crowded tournament selection
    idx_pa = TournamentSelection(2,1,FrontNo_P,-CrowdDis_P);
    pa = Pop_P(idx_pa);

    %% Pick solutions in P \cup Q \cup S that dominate pa in the objective space
    M_idx = find(all(Pop_PQS.objs <= pa.objs,2) & any(Pop_PQS.objs < pa.objs,2));
    M_idx = M_idx(:);

    %% Mark useful solutions for the archive
    if ArchiveSize > 0 && ~isempty(M_idx)
        % Rank candidates by the two-stage front number and crowding distance.
        % Smaller front numbers are better, and larger crowding distances are better.
        [~,Rank] = sortrows([Front_PQS(M_idx), -Crowd_PQS(M_idx)]);

        nSelect  = min(ArchiveSize,numel(M_idx));
        Selected = M_idx(Rank(1:nSelect));

        Marked = [Marked, Selected(:)'];
    end

    %% Directed mating
    if all(pa.cons <= 0) && numel(M_idx) >= 2
        switch MatingType
            case 1
                %% Greedy selection (GS)
                % Select the best solution in M according to the front number and crowding distance
                BestFront = min(Front_PQS(M_idx));
                Candidate = M_idx(Front_PQS(M_idx) == BestFront);

                [~,best] = max(Crowd_PQS(Candidate));
                pb = Pop_PQS(Candidate(best));

            case 2
                %% Tournament selection (TS)
                % Select the secondary parent pb from M by crowded tournament selection
                winner = TournamentSelection(2,1,Front_PQS(M_idx),-Crowd_PQS(M_idx));
                pb = Pop_PQS(M_idx(winner));

            otherwise
                error('MatingType must be 1 (greedy selection) or 2 (tournament selection).');
        end
    else
        % Select the secondary parent pb from P if directed mating is not applied
        idx_pb = TournamentSelection(2,1,FrontNo_P,-CrowdDis_P);
        pb = Pop_P(idx_pb);
    end

    Pa_array(i) = pa;
    Pb_array(i) = pb;
end

%% Construct the mating pool for OperatorGAhalf
% The first half contains primary parents, and the second half contains secondary parents.
MatingPool = [Pa_array, Pb_array];
end