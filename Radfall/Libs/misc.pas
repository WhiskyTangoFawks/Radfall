unit Radfall_barter_misc;

var 
    c_tools, c_radio, c_motor, c_battery, c_pan: String;

procedure initMisc();
begin
    c_tools := getId(getRecord('Radfall.esp', 'CMPO', 'c_Tools'));
    c_radio := getId(getRecord('Radfall.esp', 'CMPO', 'c_Radio'));
    c_motor := getId(getRecord('Radfall.esp', 'CMPO', 'c_Electric_Motor'));
    c_battery := getId(getRecord('Radfall.esp', 'CMPO', 'c_Battery'));
    c_pan := getId(getRecord('Radfall.esp', 'CMPO', 'c_CookingPan'));
end;

//============================================================================
procedure processMisc(misc: IInterface);
var
    keywords, entry: IInterface;
    full: string;
begin
    if HasKeyword(misc, 'ObjectTypeLooseMod') then exit;
    if ContainsText(EditorID(misc), 'Caps001') then exit;
    if ContainsText(EditorID(misc), 'BobbyPin') then exit;
    
    misc := copyOverrideToPatch(misc);
    
    AddMessage('----Processing MISC ' + EditorID(misc) + '------------------------------------------------------');
    addNoSaleKeyword(misc);
    full := getElementEditValues(misc, 'FULL');
    if (containsText(full, 'cigarettes')) then removeElement(misc, 'CVPA');
    
    if (containsText(full, 'radio')) then replaceScrap(misc, c_Radio)
    
    else if (containsText(full, 'hammer')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'plier')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'stapler')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'drill')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'wrench')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'saw')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'paintbrush')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'scissor')) then replaceScrap(misc, c_tools)
    else if (containsText(full, 'drill')) then replaceScrap(misc, c_tools)
    
    else if (containsText(full, 'cooking')) then replaceScrap(misc, c_pan)

    else if (containsText(full, 'battery')) then replaceScrap(misc, c_battery)
    
    else if (containsText(full, 'fan')) then replaceScrap(misc, c_motor);


    
end;

//============================================================================
procedure addNoSaleKeyword(misc: IInterface);
var
    keywords, entry: IInterface;
begin
    if StrToInt(getElementEditValues(misc, 'DATA\Value')) > MiscValueThreshold then exit;
    if StrToInt(getElementEditValues(misc, 'DATA\Value')) < 1 then exit;
    addKeywordByFormId(misc, NO_SALE_KYWD);
end;

//============================================================================
procedure replaceScrap(misc: IInterface; scrapId: string);
var
    cvpa, entry: IInterface;
begin
    removeElement(misc, 'CVPA');
    cvpa := add(misc, 'CVPA', true);
    entry := ElementAssign(cvpa, HighInteger, nil, true);
    setElementEditValues(entry, 'count', 1);
    setElementEditValues(entry, 'component', scrapId);
end;

//###
end.