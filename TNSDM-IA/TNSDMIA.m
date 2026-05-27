classdef TNSDMIA < ALGORITHM
    % <2014> <multi> <real/integer/label/binary/permutation> <constrained/none>
    % Two-stage non-dominated sorting and directed mating with Infeasible Archive (TNSDM-IA)
    % MatingType --- 2 --- Type of directed mating (1. Greedy Selection 2. Tournament Selection)
    % ArchiveSize --- 5 --- Number of useful solutions marked from M

    %------------------------------- Reference --------------------------------
    % M. Miyakawa, K. Takadama, and H. Sato. Archive of useful solutions for
    % directed mating in evolutionary constrained multiobjective optimization.
    % Journal of Advanced Computational Intelligence and Intelligent
    % Informatics, 2014, 18(2): 221-231.
    % https://doi.org/10.20965/jaciii.2014.p0221
    %------------------------------- Copyright --------------------------------
    % Copyright (c) 2026 BIMK Group. You are free to use the PlatEMO for
    % research purposes. All publications which use this platform or any code
    % in the platform should acknowledge the use of "PlatEMO" and reference "Ye
    % Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
    % for evolutionary multi-objective optimization [educational forum], IEEE
    % Computational Intelligence Magazine, 2017, 12(4): 73-87".
    %--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            % Pop_P  : Parents population P
            % Pop_Q  : Offspring population Q
            % Pop_S  : Archive population S for directed mating
            % Pop_PQS : Combined population P \cup Q \cup S
            % FrontNo_P,  CrowdDis_P  : Front numbers and crowding distances of P
            % FrontNo_PQS, CrowdDis_PQS : Front numbers and crowding distances of P \cup Q \cup S
            %
            % MatingType  = 1 : Directed mating with greedy selection (GS)
            % MatingType  = 2 : Directed mating with tournament selection (TS)
            % ArchiveSize = alpha : Number of useful solutions marked from M

            %% Parameter setting
            [MatingType,ArchiveSize] = Algorithm.ParameterSet(2,5);

            %% Generate random population
            Pop_P = Problem.Initialization();
            [Pop_P,FrontNo_P,CrowdDis_P,Pop_PQS,FrontNo_PQS,CrowdDis_PQS,IsParent] = TwoStageEnvironmentalSelection(Pop_P,Problem.N);

            %% Optimization
            while Algorithm.NotTerminated(Pop_P)
                [MatingPool,Marked] = DirectedMatingSelection(Problem,Pop_P,FrontNo_P,CrowdDis_P,Pop_PQS,FrontNo_PQS,CrowdDis_PQS,MatingType,ArchiveSize);
                Pop_Q = OperatorGAhalf(Problem,MatingPool);
                Pop_S = UpdateArchive(Pop_PQS,Marked,IsParent);
                [Pop_P,FrontNo_P,CrowdDis_P,Pop_PQS,FrontNo_PQS,CrowdDis_PQS,IsParent] = TwoStageEnvironmentalSelection([Pop_P,Pop_Q,Pop_S],Problem.N);
            end
        end
    end
end
