local ui = {}
local imgui = require('imgui')

local theme = T{
    window_bg = { 0.101, 0.098, 0.098, 0.9 },
    child_bg = { 0.0, 0.0, 0.0, 0.50 },
    header_text_col = { 0.462, 0.647, 0.756, 1.0 },
    desc_text_col = { 0.450, 0.498, 0.529, 1.0 },
    button_create_filt = { 0.094, 0.447, 0.094, 0.9 },
    button_test_colors = { 0.894, 0.525, 0.525, 0.9 },
    button_tab_act_col = { 0.152, 0.298, 0.427, 0.9 },
    button_tab_dis_col = { 0.2, 0.2, 0.2, 0.9 },
    button_hov_col = { 0.2, 0.2, 0.3, 0.9 },
    button_act_col = { 0.3, 0.2, 0.3, 0.9 },
}

local filter_info = {
    filter_order = {
        'Melee',
        'Ranged',
        'Damage',
        'Healing',
        'Misses',
        'Items',
        'Uses',
        'Readies',
        'Casting',
        'Other',
    },

    filter_categories = {
        'Me',
        'Party',
        'Alliance',
        'Others',
        'My Pet',
        'My Fellow',
        'Other Pets',
        'Enemies',
        'Monsters',
    },
};

local function HasNestedFilters(filters)
    for _, value in pairs(filters) do
        if type(value) == 'table' then
            return true
        end
    end
    return false
end

local target_labels = {
    me = 'You',
    party = 'Party',
    alliance = 'Alliance',
    others = 'Outside Players',
    my_pet = 'Your Pet',
    my_fellow = 'Your Fellow',
    other_pets = 'Outside Pets',
    enemies = 'Claimed Enemies',
    monsters = 'Unclaimed Monsters',
}

local function CopyFlatFilters(filters)
    local copy = {}
    for key, value in pairs(filters) do
        if type(value) ~= 'table' then
            copy[key] = value
        end
    end
    return copy
end

local function EnableTargetSpecificFilters(actor_key)
    local flat = gProfileFilter[actor_key]
    local nested = {}
    for _, target_label in ipairs(filter_info.filter_categories) do
        local target_key = target_label:lower():gsub(' ', '_')
        nested[target_key] = CopyFlatFilters(flat)
    end
    gProfileFilter[actor_key] = nested
end

local function RenderNestedFilters(actor_key)
    for _, target_label in ipairs(filter_info.filter_categories) do
        local target_key = target_label:lower():gsub(' ', '_')
        local row = gProfileFilter[actor_key][target_key]
        if type(row) == 'table' then
            if imgui.Checkbox(('##%s_%s_all'):fmt(actor_key, target_key), {row.all == true}) then
                row.all = not row.all
            end
            imgui.SameLine()
            imgui.TextColored(theme.header_text_col,
                ('Targeting %s'):fmt(target_labels[target_key]))

            if not row.all then
                for _, filter_label in ipairs(filter_info.filter_order) do
                    local filter_key = filter_label:lower()
                    imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                    imgui.SameLine()
                    if imgui.Checkbox(('##%s_%s_%s'):fmt(actor_key, target_key, filter_key),
                        {row[filter_key] == true}) then
                        row[filter_key] = not row[filter_key]
                    end
                    imgui.SameLine()
                    imgui.TextColored(theme.header_text_col, filter_label)
                end
            end
        end
    end
end

local function RenderFlatFilters(actor_key, label, description)
    local row = gProfileFilter[actor_key]
    if imgui.Checkbox(('##%s_all'):fmt(actor_key), {row.all == true}) then
        row.all = not row.all
    end
    imgui.SameLine()
    imgui.TextColored(theme.header_text_col, label .. ': All Messages')
    if description then
        imgui.TextColored(theme.desc_text_col, description)
    end

    if not row.all then
        for _, filter_label in ipairs(filter_info.filter_order) do
            local filter_key = filter_label:lower()
            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
            imgui.SameLine()
            if imgui.Checkbox(('##%s_%s'):fmt(actor_key, filter_key), {row[filter_key] == true}) then
                row[filter_key] = not row[filter_key]
            end
            imgui.SameLine()
            imgui.TextColored(theme.header_text_col, filter_label)
        end
    end
end

local function RenderSplitFilters(actor_key, label, description)
    imgui.TextColored(theme.header_text_col, label .. ':')
    if description then
        imgui.TextColored(theme.desc_text_col, description)
    end
    RenderNestedFilters(actor_key)
end

local function RenderGroupFilters(actor_key, label, description)
    if HasNestedFilters(gProfileFilter[actor_key]) then
        RenderSplitFilters(actor_key, label, description)
        return
    end

    RenderFlatFilters(actor_key, label, description)
    if imgui.Button(('Split by Target##%s_split'):fmt(actor_key)) then
        EnableTargetSpecificFilters(actor_key)
    end
    imgui.TextColored(theme.desc_text_col, 'Copies these choices to each target so you can change them separately.')
end

local color_info = {
    color_order = {
        'mob',
        'other',
        'p0',
        'p1',
        'p2',
        'p3',
        'p4',
        'p5',
        'al0',
        'al1',
        'al2',
        'al3',
        'al4',
        'al5',
        'a20',
        'a21',
        'a22',
        'a23',
        'a24',
        'a25',
        'mobdmg',
        'mydmg',
        'partydmg',
        'allydmg',
        'otherdmg',
        'spellcol',
        'mobspellcol',
        'abilcol',
        'wscol',
        'mobwscol',
        'statuscol',
        'enfeebcol',
        'itemcol',
    },
    color_name = {
        'Monster',
        'Other',
        'You (Party Member 1)',
        'Party Member 2',
        'Party Member 3',
        'Party Member 4',
        'Party Member 5',
        'Party Member 6',
        'Alliance 1 Member 1',
        'Alliance 1 Member 2',
        'Alliance 1 Member 3',
        'Alliance 1 Member 4',
        'Alliance 1 Member 5',
        'Alliance 1 Member 6',
        'Alliance 2 Member 1',
        'Alliance 2 Member 2',
        'Alliance 2 Member 3',
        'Alliance 2 Member 4',
        'Alliance 2 Member 5',
        'Alliance 2 Member 6',
        'Monster Damage',
        'Player Damage',
        'Party Damage',
        'Ally Damage',
        'Other Damage',
        'Spell Color',
        'Monster Spell Color',
        'Ability Color',
        'Weapon Skill Color',
        'Monster Weapon Skill Color',
        'Status Color',
        'Enfeeblement Color',
        'Item Color',
    },
    color_inputs = {
    },
    job_inputs = {
    },
    pet_names = {
        bst = 'BST Pet',
        drg = 'DRG Wyvern',
        smn = 'SMN Avatar',
        pup = 'PUP Automaton',
    },
};

local function RenderJobColorInput(key, default, label)
    if not color_info.job_inputs[key] then
        local value = gProfileColor[key]
        color_info.job_inputs[key] = T{ type(value) == 'number' and value or default }
    end
    imgui.PushItemWidth(30)
    if imgui.InputInt(('##%s'):fmt(key), color_info.job_inputs[key], 0) then
        local value = math.max(-1, tonumber(color_info.job_inputs[key][1]) or -1)
        color_info.job_inputs[key][1] = value
        gProfileColor[key] = value
    end
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.TextColored(theme.header_text_col, label)
end

ui.state = T{
    button_pressed = false,
    toggle_menu = false,
    open = T{false},
    tab = 0,
};

--local module = {}

ui.toggle_menu = function (trig)
    if trig == 0 then
        ui.state.toggle_menu = false
    end
    if trig == 1 then
        ui.state.toggle_menu = true
    end
end

ui.render_config = function(toggle)
    if toggle then
        local state = (not ui.state.open[1] and "Opening") or "Closing"
        print(chat.header('SimpleLog')..chat.message(state .. ' menu...'))
        ui.state.open[1] = not ui.state.open[1]
        --print('settings open: '..tostring(ui.state.open))
    end

    if not ui.state.open[1] then
        --print('settings close: '..tostring(ui.state.open))
        return
    end
    if not gProfileSettings or not gProfileFilter or not gProfileColor then
        return
    end

    imgui.SetNextWindowContentSize({ 330, 430 })
    imgui.SetNextWindowSizeConstraints({ 330, 470 }, { 430, 650 })

    imgui.PushStyleColor(ImGuiCol_WindowBg , theme.window_bg)
    imgui.PushStyleColor(ImGuiCol_TitleBg, theme.child_bg)
    if imgui.Begin(('SimpleLog - v%s'):fmt(addon.version), ui.state.open) then
        imgui.PushTextWrapPos(0)
        imgui.BeginGroup()
            if ui.state.tab == 0 then
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_act_col)
            else
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_dis_col)
            end
            imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
            imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
            if imgui.Button('\xEF\x82\xAD Settings') then
                ui.state.tab = 0
            end
            imgui.PopStyleColor(3)
            if imgui.IsItemHovered() then
                imgui.SetTooltip('General addon settings')
            end
            if ui.state.tab == 1 then
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_act_col)
            else
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_dis_col)
            end
            imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
            imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
            imgui.SameLine()
            if imgui.Button('\xef\x8a\x8d Filters') then
                ui.state.tab = 1
            end
            imgui.PopStyleColor(3)
            if imgui.IsItemHovered() then
                imgui.SetTooltip('Chat log filter settings')
            end
            if ui.state.tab == 2 then
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_act_col)
            else
                imgui.PushStyleColor(ImGuiCol_Button, theme.button_tab_dis_col)
            end
            imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
            imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
            imgui.SameLine()
            if imgui.Button('\xef\x87\xbc Colors') then
                ui.state.tab = 2
                ui.updatecolors()
            end
            imgui.PopStyleColor(3)
            if imgui.IsItemHovered() then
                imgui.SetTooltip('Chat log color settings')
            end
            imgui.PushStyleColor(ImGuiCol_ChildBg, theme.child_bg)
            local childValue = (ashita.interface_version >= 4.30) and ImGuiChildFlags_Borders or true;
            if imgui.BeginChild('conf_box##simplelog_config_box', { imgui.GetWindowWidth()-16, imgui.GetWindowHeight()-120 }, childValue) then
                imgui.PushTextWrapPos(0)
                if ui.state.tab == 0 then
                    local lang_choices = {'English', 'Japanese'}

                    -- Language support yet not fully implemented
                    imgui.TextColored(theme.desc_text_col, 'Language:\nChoose English or Japanese messages.')
                    -- Temp Warning
                    imgui.TextColored({1.0, 0.0, 0.0, 1.0}, 'EXPERIMENTAL')
                    if imgui.BeginCombo('##language_select', lang_choices[gProfileSettings.lang.object]) then
                        if imgui.Selectable('English', gProfileSettings.lang.msg_text == 'en') then
                            gProfileSettings.lang.object = 1
                            gProfileSettings.lang.internal = 2
                            gProfileSettings.lang.msg_text = 'en'
                        end
                        if imgui.Selectable('Japanese', gProfileSettings.lang.msg_text == 'jp') then
                            gProfileSettings.lang.object = 2
                            gProfileSettings.lang.internal = 1
                            gProfileSettings.lang.msg_text = 'jp'
                        end
                        imgui.EndCombo()
                    end

                    imgui.TextColored(theme.desc_text_col, 'General Options:\nChange how messages are shown.')
                    if imgui.TreeNodeEx('Condense Options', bit.bor(ImGuiTreeNodeFlags_Framed, ImGuiTreeNodeFlags_DefaultOpen)) then
                        imgui.PushTextWrapPos(0)
                        local simplify_change = imgui.Checkbox('##simplify', {gProfileSettings.mode.simplify})
                        if simplify_change then
                            gProfileSettings.mode.simplify = not gProfileSettings.mode.simplify
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Simplify')
                        imgui.TextColored(theme.desc_text_col, 'Use shorter custom battle messages.')
                        local debug_messages_change = imgui.Checkbox('##debug_messages', {gProfileSettings.mode.show_debug_messages or false});
                        if debug_messages_change then
                            gProfileSettings.mode.show_debug_messages = not gProfileSettings.mode.show_debug_messages;
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Debug Messages')
                        imgui.TextColored(theme.desc_text_col, 'Show a note when SimpleLog cannot identify an actor or target.')

                        imgui.NewLine()
                        local condensetargets_change = imgui.Checkbox('##condensetargets', {gProfileSettings.mode.condensetargets})
                        if condensetargets_change then
                            gProfileSettings.mode.condensetargets = not gProfileSettings.mode.condensetargets
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Condense Targets')
                        imgui.TextColored(theme.desc_text_col, 'Combine targets with the same result into one line.')


                        if gProfileSettings.mode.condensetargets then
                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local targetnumber_change = imgui.Checkbox('##targetnumber', {gProfileSettings.mode.targetnumber})
                            if targetnumber_change then
                                gProfileSettings.mode.targetnumber = not gProfileSettings.mode.targetnumber
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Target Number')
                            imgui.TextColored(theme.desc_text_col, 'Show how many targets were combined.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local condensetargetname_change = imgui.Checkbox('##condensetargetname', {gProfileSettings.mode.condensetargetname})
                            if condensetargetname_change then
                                gProfileSettings.mode.condensetargetname = not gProfileSettings.mode.condensetargetname
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Condense Target Name')
                            imgui.TextColored(theme.desc_text_col, 'Show targets with the same name once, with a count.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local oxford_change = imgui.Checkbox('##oxford', {gProfileSettings.mode.oxford})
                            if oxford_change then
                                gProfileSettings.mode.oxford = not gProfileSettings.mode.oxford
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Oxford Comma')
                            imgui.TextColored(theme.desc_text_col, 'Add a comma before "and" in lists of three or more.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local commamode_change = imgui.Checkbox('##commamode', {gProfileSettings.mode.commamode})
                            if commamode_change then
                                gProfileSettings.mode.commamode = not gProfileSettings.mode.commamode
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Comma Mode')
                            imgui.TextColored(theme.desc_text_col, 'Use only commas in lists, without "and".')
                        end

                        imgui.NewLine()
                        local condensedamage_change = imgui.Checkbox('##condesedamage', {gProfileSettings.mode.condensedamage})
                        if condensedamage_change then
                            gProfileSettings.mode.condensedamage = not gProfileSettings.mode.condensedamage
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Condense Damage')
                        imgui.TextColored(theme.desc_text_col, 'Combine repeated hits on one target into one line.')

                        if gProfileSettings.mode.condensedamage then
                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local swingnumber_change = imgui.Checkbox('##swingnumber', {gProfileSettings.mode.swingnumber})
                            if swingnumber_change then
                                gProfileSettings.mode.swingnumber = not gProfileSettings.mode.swingnumber
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Swing Number')
                            imgui.TextColored(theme.desc_text_col, 'Show how many hits were combined.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local sumdamage_change = imgui.Checkbox('##sumdamage', {gProfileSettings.mode.sumdamage})
                            if sumdamage_change then
                                gProfileSettings.mode.sumdamage = not gProfileSettings.mode.sumdamage
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Sum Damage')
                            imgui.TextColored(theme.desc_text_col, 'Show combined hits as one total. When off, list each hit.')

                            imgui.TextColored(theme.header_text_col, '\xef\x8c\x8b')
                            imgui.SameLine()
                            local condensecrits_change = imgui.Checkbox('##condensecrits', {gProfileSettings.mode.condensecrits})
                            if condensecrits_change then
                                gProfileSettings.mode.condensecrits = not gProfileSettings.mode.condensecrits
                            end
                            imgui.SameLine()
                            imgui.TextColored(theme.header_text_col, 'Condense Crits')
                            imgui.TextColored(theme.desc_text_col, 'Include critical hits when combining hits.')
                        end
                        imgui.PopTextWrapPos();
                        imgui.TreePop();
                    end

                    if imgui.TreeNodeEx('Visibility Options', ImGuiTreeNodeFlags_Framed) then
                        imgui.PushTextWrapPos(0)
                        local cancelmultimsg_change = imgui.Checkbox('##cancelmultimsg', {gProfileSettings.mode.cancelmultimsg})
                        if cancelmultimsg_change then
                            gProfileSettings.mode.cancelmultimsg = not gProfileSettings.mode.cancelmultimsg
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Cancel Multiple Messages')
                        imgui.TextColored(theme.desc_text_col, 'Hide repeated equipment change and error messages.')

                        imgui.NewLine()
                        local showpetownernames_change = imgui.Checkbox('##showpetownernames', {gProfileSettings.mode.showpetownernames})
                        if showpetownernames_change then
                            gProfileSettings.mode.showpetownernames = not gProfileSettings.mode.showpetownernames
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Pet Owner Names')
                        imgui.TextColored(theme.desc_text_col, 'Show the owner\'s name next to pets.')

                        imgui.NewLine()
                        local crafting_change = imgui.Checkbox('##crafting', {gProfileSettings.mode.crafting})
                        if crafting_change then
                            gProfileSettings.mode.crafting = not gProfileSettings.mode.crafting
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Crafting')
                        imgui.TextColored(theme.desc_text_col, 'Show crafting results as soon as they are known.')

                        imgui.NewLine()
                        local showblocks_change = imgui.Checkbox('##showblocks', {gProfileSettings.mode.showblocks})
                        if showblocks_change then
                            gProfileSettings.mode.showblocks = not gProfileSettings.mode.showblocks
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Blocks')
                        imgui.TextColored(theme.desc_text_col, 'Add "Blocked!" when an attack is blocked.')

                        imgui.NewLine()
                        local showguards_change = imgui.Checkbox('##showguards', {gProfileSettings.mode.showguards})
                        if showguards_change then
                            gProfileSettings.mode.showguards = not gProfileSettings.mode.showguards
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Guards')
                        imgui.TextColored(theme.desc_text_col, 'Add "Guarded!" when an attack is guarded.')

                        imgui.NewLine()
                        local showcritws_change = imgui.Checkbox('##showcritws', {gProfileSettings.mode.showcritws})
                        if showcritws_change then
                            gProfileSettings.mode.showcritws = not gProfileSettings.mode.showcritws
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Critical Weapon Skill')
                        imgui.TextColored(theme.desc_text_col, 'Add "Critical Hit!" to critical weapon skills.')

                        imgui.NewLine()
                        local showrollinfo_change = imgui.Checkbox('##showrollinfo', {gProfileSettings.mode.showrollinfo})
                        if showrollinfo_change then
                            gProfileSettings.mode.showrollinfo = not gProfileSettings.mode.showrollinfo
                        end
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, 'Show Roll Info')
                        imgui.TextColored(theme.desc_text_col, 'Show what each Corsair roll number does.')
                        imgui.PopTextWrapPos();
                        imgui.TreePop()
                    end
                elseif ui.state.tab == 1 then
                    imgui.TextColored(theme.desc_text_col, 'Profile: ')
                    imgui.SameLine()
                    imgui.TextColored(theme.button_create_filt, gStatus.CurrentFilters)
                    if gStatus.FilterWarning then
                        imgui.TextColored(theme.button_test_colors,
                            ('Could not load %s. You are editing %s instead.')
                                :fmt(gStatus.FilterWarning.Profile, gStatus.CurrentFilters))
                        imgui.TextColored(theme.desc_text_col,
                            'Reason: ' .. gStatus.FilterWarning.Reason)
                        imgui.TextColored(theme.desc_text_col,
                            'The profile that could not be loaded will not be changed.')
                    end
                    imgui.PushStyleColor(ImGuiCol_Button, theme.button_create_filt)
                    imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
                    imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
                    if imgui.Button('\xef\x85\x9b Create Job Profile') then
                        local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));
                        local shortFileName = jobFiltersFile:match("[^\\]*.$");

                        if (not ashita.fs.exists(jobFiltersFile)) then
			                local sourceFile = ('%saddons\\simplelog\\filters.lua'):fmt(AshitaCore:GetInstallPath());
                            gFileTools.OverwriteProfile(jobFiltersFile, sourceFile);
                            print(chat.header('SimpleLog') .. chat.message('Created filters profile: ') .. chat.color1(2, shortFileName));
                            gStatus.LoadProfile(jobFiltersFile, 'filters');
                        elseif (ashita.fs.exists(jobFiltersFile)) then
                            imgui.OpenPopup('###file_man')
                        end
                    end
                    
                    imgui.PopStyleColor(3)
                    if imgui.IsItemHovered() then
                        imgui.SetTooltip('Create a filter profile for your current job.')
                    end

                    local size = imgui.GetIO().DisplaySize
                    local center = { size.x * 0.5, size.y * 0.5 }

                    imgui.SetNextWindowPos(center, ImGuiCond_Appearing, {0.5, 0.5})
                    imgui.SetNextWindowSize({ -1, -1 },  ImGuiCond_Always)

                    if imgui.BeginPopupModal('Overwrite?###file_man', nil, ImGuiWindowFlags_AlwaysAutoResize) then
                        imgui.NewLine()
                        imgui.Text('A filter profile for this job already exists.\nReplace it with the default filters?')
                        imgui.NewLine()
                        imgui.Separator()

                        imgui.SetCursorPosX(imgui.GetCursorPosX() + 45)
                        if imgui.Button('Confirm') then
                            local defaultFiltersFile = ('%saddons\\simplelog\\filters.lua'):fmt(AshitaCore:GetInstallPath());

                            local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));
                            local shortFileName = jobFiltersFile:match("[^\\]*.$");

                            if gFileTools.OverwriteProfile(jobFiltersFile, defaultFiltersFile) then
                                print(chat.header('SimpleLog') .. chat.message('Recreated filters profile: ') .. chat.color1(2, shortFileName));
                            end
                            gStatus.LoadProfile(jobFiltersFile, 'filters');
                            imgui.CloseCurrentPopup()
                        end
                        imgui.SameLine()
                        if imgui.Button('Cancel') then
                            imgui.CloseCurrentPopup()
                        end
                        imgui.EndPopup()
                    end

                    imgui.TextColored(theme.desc_text_col,
                        'Checked messages are hidden. When a party or alliance pet is the target, it counts as Party or Alliance.')
                    if imgui.BeginTabBar('#filters_bar') then
                        if imgui.BeginTabItem('Player') then
                            RenderFlatFilters('me', 'You')
                            imgui.NewLine()

                            RenderGroupFilters('party', 'Party')
                            imgui.NewLine()
                            RenderGroupFilters('alliance', 'Alliance')
                            imgui.NewLine()
                            RenderFlatFilters('my_pet', 'Your Pet')
                            imgui.NewLine()
                            RenderFlatFilters('my_fellow', 'Your Fellow')
                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem('Others') then
                            RenderGroupFilters('others', 'Outside Players', 'Players outside your party and alliance.')
                            imgui.NewLine()
                            RenderGroupFilters('other_pets', 'Pets Except Yours', 'Includes party and alliance pets.')
                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem('Enemies') then
                            RenderSplitFilters('enemies', 'Claimed Enemies', 'Monsters your group has claimed.')
                            imgui.EndTabItem()
                        end
                        if imgui.BeginTabItem('Monsters') then
                            RenderSplitFilters('monsters', 'Unclaimed Monsters',
                                'Monsters not claimed by your group. Unknown NPCs fighting your group also use these settings for readying and casting.')
                            imgui.EndTabItem()
                        end
                        imgui.EndTabBar()
                    end
                elseif ui.state.tab == 2 then
                    imgui.TextColored(theme.desc_text_col, 'Colors:')
                    imgui.TextColored(theme.desc_text_col, 'Name colors follow party and alliance position, or job when Color Names by Job is on. Click Color Test to see every color code.')
                    imgui.TextColored(theme.desc_text_col, 'Set a color to 0 to keep the game\'s normal color.')
                    imgui.PushStyleColor(ImGuiCol_Button, theme.button_test_colors)
                    imgui.PushStyleColor(ImGuiCol_ButtonHovered, theme.button_hov_col)
                    imgui.PushStyleColor(ImGuiCol_ButtonActive, theme.button_act_col)
                    if imgui.Button('\xef\x94\xbf Color Test') then
                        local counter = 0
                        local line = ''
                        local loc_col
                        for n = 1, 262 do
                            if not color_redundant:contains(n) and not black_colors:contains(n) then
                                if n <= 255 then
                                    loc_col = string.char(0x1F, n)
                                else
                                    loc_col = string.char(0x1E, n - 254)
                                end
                                line = line..loc_col..string.format('%03d ', n)
                                counter = counter + 1
                            end
                            if counter == 16 or n == 262 then
                                AshitaCore:GetChatManager():AddChatMessage(6, false, line)
                                counter = 0
                                line = ''
                            end

                        end
                        AshitaCore:GetChatManager():AddChatMessage(122, false, 'Colors Tested!')
                    end
                    imgui.PopStyleColor(3)
                    if imgui.IsItemHovered() then
                        imgui.SetTooltip('Print every color code in chat.')
                    end

                    local colors_inputbox = {}
                    for i, v in ipairs(color_info.color_order) do
                        imgui.PushItemWidth(30)
                        colors_inputbox[i] = imgui.InputInt(('##%s'):fmt(v), color_info.color_inputs[v], 0)
                        if colors_inputbox[i] then
                            gProfileColor[v] = tonumber(color_info.color_inputs[v][1])
                        end
                        imgui.PopItemWidth()
                        imgui.SameLine()
                        imgui.TextColored(theme.header_text_col, color_info.color_name[i])
                    end

                    imgui.NewLine()
                    if imgui.Checkbox('##job_colors', {gProfileSettings.mode.job_colors == true}) then
                        gProfileSettings.mode.job_colors = not gProfileSettings.mode.job_colors
                    end
                    imgui.SameLine()
                    imgui.TextColored(theme.header_text_col, 'Color Names by Job')
                    imgui.SameLine()
                    imgui.TextColored({1.0, 0.0, 0.0, 1.0}, 'EXPERIMENTAL')
                    imgui.TextColored(theme.desc_text_col,
                        'Color you, your party, your alliance, and their pets by main job. Players outside your group are not affected.')

                    if gProfileSettings.mode.job_colors then
                        imgui.TextColored(theme.desc_text_col,
                            'Set a job to -1 to use its party position color. Set a pet to -1 to use its owner\'s job color.')
                        for _, abbr in ipairs(job_color_keys) do
                            RenderJobColorInput('job_' .. abbr, default_job_colors[abbr], abbr:upper())
                        end
                        for _, abbr in ipairs(job_color_keys) do
                            if default_pet_colors[abbr] then
                                RenderJobColorInput('pet_' .. abbr, default_pet_colors[abbr], color_info.pet_names[abbr])
                            end
                        end
                    end
                end
                imgui.PopTextWrapPos();
            end
            imgui.EndChild()
            imgui.PopStyleColor()
            if imgui.Button('\xef\x95\xaf Save Changes', {imgui.GetWindowWidth()-16, 20}) then
                if not static_config and not gStatus.FilterSavingDisabled then
                    ui.save_changes()
                else
                    gFuncs.Error('Saving is Disabled.')
                end
            end
            imgui.TextDisabled(('\xef\x83\x81 %s'):fmt(addon.link))
            imgui.TextDisabled(('\xef\x87\xb9 2022 by %s'):fmt(addon.author))
        imgui.EndGroup()
        imgui.PopTextWrapPos()
    end
    imgui.End()
    imgui.PopStyleColor(2)
end

ui.updatecolors = function ()
    color_info.job_inputs = {}
    for i, v in pairs(gProfileColor) do
        if type(v) == 'table' then
            color_info.color_inputs[i] = v
        else
            color_info.color_inputs[i] = T{ v }
        end
    end
end

ui.save_changes = function ()
    local defaultSettingsFile = gStatus.SettingsFolder .. 'config.lua';
	local defaultFiltersFile = gStatus.SettingsFolder .. 'default_filters.lua';
	local defaultColorsFile = gStatus.SettingsFolder .. 'chat_colors.lua';
	local jobFiltersFile = (gStatus.SettingsFolder .. '%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob));

    if not gFileTools.SaveChanges(defaultSettingsFile, gProfileSettings, 'settings') then
        gFuncs.Error('Failed to save config.lua')
        return
    end
    if gStatus.CurrentFilters == ('%s.lua'):fmt(AshitaCore:GetResourceManager():GetString("jobs.names_abbr", gStatus.PlayerJob)) then
        if not gFileTools.SaveChanges(jobFiltersFile, gProfileFilter, 'filters') then
            gFuncs.Error('Failed to save filter profile')
            return
        end
    else
        if not gFileTools.SaveChanges(defaultFiltersFile, gProfileFilter, 'filters') then
            gFuncs.Error('Failed to save default_filters.lua')
            return
        end
    end
    
    if not gFileTools.SaveChanges(defaultColorsFile, gProfileColor, 'colors') then
        gFuncs.Error('Failed to save chat_colors.lua')
        return
    end
    print(chat.header('SimpleLog')..chat.success('All changes Saved'))
end

return ui
