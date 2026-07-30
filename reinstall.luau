local cloneref = cloneref or function(ref: any)
    return ref
end

if isfolder('kingvape') then
    delfolder('kingvape')
end

cloneref(game:GetService('StarterGui')):SetCore('SendNotification', {
    Title = 'King Vape',
    Text = 'Successfully reset King Vape settings. Please rejoin the game for changes to take effect.',
    Duration = 10
})