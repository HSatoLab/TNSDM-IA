function Pop_S = UpdateArchive(Pop_PQS,Marked,IsParent)
% Select marked solutions that are not members of the parents population P

Pop_S = Pop_PQS([]);
if isempty(Marked)
    return;
end

MarkedFlag = false(1,length(Pop_PQS));
MarkedFlag(unique(Marked)) = true;
MarkedFlag(IsParent) = false;
Pop_S = Pop_PQS(MarkedFlag);
end
