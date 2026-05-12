unit Radfall_Weapons;

var
    WeaponTypeNinja, WeaponTypePrewar, WeaponTypeImprovised: String;
    weap_improvised_name_contains, weapPrewarCache: TStringList;

//============================================================================  
procedure initWeapon();
var
    i, j: integer;
    temp : TStringList;
begin
    addMessage('Initializing Weapons');
    
    WeaponTypeNinja := getId(getRecord('Radfall.esp', 'KYWD', 'weaponTypeNinja'));
    if not assigned(WeaponTypeNinja) then raise Exception.Create('**ERROR** Failed to find keyword WeaponTypeNinja');
    WeaponTypePrewar := getId(getRecord('Radfall.esp', 'KYWD', 'WeaponTypePrewar'));
    if not assigned(WeaponTypePrewar) then raise Exception.Create('**ERROR** Failed to find keyword WeaponTypePreWar');
    WeaponTypeImprovised := getId(getRecord('Radfall.esp', 'KYWD', 'WeaponTypeImprovised'));
    if not assigned(WeaponTypeImprovised) then raise Exception.Create('**ERROR** Failed to find keyword WeaponTypeImprovised');

    weapPrewarCache := newSortedTStringList();
    weap_improvised_name_contains := newSortedTStringList();
    weap_improvised_name_contains.delimitedText := config.readString('Crafting', 'weap_improvised_name_contains', '');
end;

//============================================================================  
procedure runWeapon();
begin
    loadRecordQueue('WEAP');
    while recordQueueHasNext() do processWeap(getQueueNextRecord());
end;

//============================================================================  
procedure processWeap(weap: IInterface);
var
    keywordList: TStringList;
    ammo: IInterface;
    isMelee : boolean;
    ammoEdid: string;
begin

        keywordList := getKeywordList(weap);
        if not assigned(keywordList) then exit;
        if not shouldProcessWeap(weap, keywordList) then exit;
        
        addMessage('Processing: ' + FullPath(weap));
        weap := copyOverrideToPatch(weap);
        
        //distribute MODCOLs for receivers,and melee mods
        replaceStandardOmodsWithModcols(weap, keywordList);
        
        isMelee := isWeapMelee(weap, keywordList);
        if isMelee then begin
            if isBlade(weap) then processBlade(weap);
            exit;
        end;

        if IsWeapPreWarByName(weap) then addKeywordByFormId(weap, WeaponTypePreWar)
        else addKeywordByFormId(weap, WeaponTypeImprovised);

end;

//============================================================================  
function shouldProcessWeap(weap: IInterface; keywordList: TStringList): boolean;
var
    ammo: IInterface;
begin
    result := false;
    if (getElementEditValues(weap, 'Record Header\record flags\Non-Playable') = '1') then exit;
    if containsText(editorId(weap), 'nonplayable') then exit;
    if (winningRefByCount(weap) = 0) then exit;
    if keywordList.indexOf('WeaponTypeGrenade') > -1 then exit;
    if not isWeapMelee(weap, keywordList) then begin
        ammo := winningOverride(linksTo(elementByPath(weap, 'DNAM\Ammo')));
        if not assigned(ammo) then exit;
    end;
    result := true;
        
end;


//============================================================================  
function isWeapMelee(weap: IInterface; keywordList: TStringList): boolean;
begin
    result := false;
    if (keywordList.indexOf('WeaponTypeBallistic') > -1) then exit;
    
    result := true;     
    if (keywordList.indexOf('WeaponTypeMelee1H') > -1) then exit;
    if (keywordList.indexOf('WeaponTypeMelee2H') > -1) then exit;
    if (keywordList.indexOf('WeaponTypeHandToHand') > -1) then exit;
    //if (keywordList.indexOf('WeaponTypeUnarmed') > -1) then exit;
    result := false;
end;

//============================================================================  
procedure processBlade(weap: IInterface);
begin
    addKeywordByFormId(weap, WeaponTypeNinja);
end;

//============================================================================  
function isBlade(weap: IInterface): boolean;
var
    edid: string;
begin
    result := false;
    if HasKeyword(weap, 'WeaponTypeUnarmed') then exit;
    edid := editorId(weap);

    result := true;
    if containsText(edid, 'sword') then exit;
    if containsText(edid, 'knife') then exit;
    if containsText(edid, 'shiv') then exit;
    if containsText(edid, 'Machete') then exit;
    if containsText(edid, 'shish') then exit;
    if containsText(edid, 'cleave') then exit;
    if containsText(edid, 'dozier') then exit;
    if containsText(edid, 'boxcutter') then exit;
    if containsText(edid, 'Balis_weap') then exit;
    if containsText(edid, 'kukri') then exit;
    if containsText(edid, 'DeathclawGauntlet') then exit;
    if containsText(edid, 'Dadao') then exit;
    if containsText(edid, 'blade') and not containsText(edid, 'buzz') then exit;

    result := false;
end;
//============================================================================
function IsWeapPreWar(weap: IInterface): boolean;
begin
    result := weapPrewarCache.indexOf(editorId(weap)) > -1;
end;
//============================================================================
function IsWeapPreWarByName(item: IInterface): boolean;
var
    full: string;
    i: integer;
begin
    result := false;
    
    if hasKeyword(item, 'asenal_improvised') then exit;
    if hasKeyword(item, 'asenal_prewar') then begin
        result := true;
        weapPrewarCache.add(editorId(item));
        exit;
    end;
    
    full := getElementEditValues(item, 'FULL');
    for i := 0 to weap_improvised_name_contains.count -1 do begin
        if containsText(full, weap_improvised_name_contains[i]) then exit;
    end;

    result := true;
    weapPrewarCache.add(editorId(item));
end;

//============================================================================ 
function isCraftable(omod: IInterface): boolean;
var
    ref: IInterface;
    i: integer;
begin
    
    result := false;
    for i := 0 to ReferencedByCount(omod)-1 do begin
        ref := ReferencedByIndex(omod, i);
        if not isWinningOverride(ref) then begin
            //TODO - this will return false if the script is rerun with a partial patching done, due to disabling of the pre-war grips/stock recipes
            continue;
        end;
        if (Signature(ref) <> 'COBJ') then continue;
        result := true;
        //trace('is craftable');
        exit;
    end;
    //trace('is NOT craftable');
end;
//============================================================================ 



end.