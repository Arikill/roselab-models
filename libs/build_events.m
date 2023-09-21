function eventArray = build_events(times, eventRate, numEvents)
    % Calculate the interval (in terms of the times array) between events
    interval = round(1 / eventRate * numel(times));

    % Calculate indices where '1's should be placed
    indices = 1:interval:numEvents*interval;

    % Clip indices that go beyond the length of times
    indices(indices > numel(times)) = [];

    % Initialize the eventArray with all zeros
    eventArray = zeros(size(times));

    % Place '1's at the appropriate indices
    eventArray(indices) = 1;

    if length(indices) < numEvents
        warning('Reached end of times array before placing all events.');
    end
end

