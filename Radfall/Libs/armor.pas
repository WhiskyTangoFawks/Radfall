unit Radfall_armor;

const 
    ObjectTypeArmor = '000F4AE9';
var
    ObjectTypeClothing, ArmorTypePrewar, ArmorTypeImprovised: String;
    armo_improvised_name_contains, armoPrewarCache: TStringList;

//============================================================================
procedure initArmor();
begin
    ObjectTypeClothing := IntToHex(GetLoadOrderFormID(MainRecordByEditorID(GroupBySignature(fileByName('Radfall.esp'), 'KYWD'), 'ObjectTypeClothing')), 8);
    if not assigned(ObjectTypeClothing) then raise Exception.Create('**ERROR** Failed to find keyword ObjectTypeClothing');
    ArmorTypePrewar := getId(getRecord('Radfall.esp', 'KYWD', 'ArmorTypePreWar'));
    if not assigned(ArmorTypePrewar) then raise Exception.Create('**ERROR** Failed to find keyword ArmorTypePreWar');
    ArmorTypeImprovised := getId(getRecord('Radfall.esp', 'KYWD', 'ArmorTypeImprovised'));
    if not assigned(ArmorTypeImprovised) then raise Exception.Create('**ERROR** Failed to find keyword ArmorTypeImprovised');

    armoPrewarCache := newSortedTStringList();
    armo_improvised_name_contains := newSortedTStringList();
    armo_improvised_name_contains.delimitedText := config.readString('Crafting', 'armo_improvised_name_contains', '');
end;

//============================================================================
procedure runArmor();
begin
    addMessage('Running Armor Module');
    
    loadRecordQueue('ARMO');
    while recordQueueHasNext() do processArmo(getQueueNextRecord());
end;


//============================================================================
procedure processArmo(armo: IInterface);
var
  keywordList: TStringList;
begin
    try
        keywordList := getKeywordList(armo);
        if not assigned(keywordList) then keywordList := TStringList.create;
        if not shouldProcessArmo(armo, keywordList) then exit;
        
        AddMessage('----Processing ARMO ' + EditorID(armo) + '------------------------------------------------------');
        armo := copyOverrideToPatch(armo);
        
        if IsArmoPreWarByName(armo) then addKeywordByFormId(armo, ArmorTypePreWar)
        else addKeywordByFormId(armo, ArmorTypeImprovised);

        replaceStandardOmodsWithModcols(armo, keywordList);
        if (keywordList.indexOf('ArmorTypePower') > -1) then begin
            processPowerArmor(armo, keywordList);
            exit;
        end;

        if isClothing(armo) then begin
            replaceKeyword(armo, 'ObjectTypeArmor', ObjectTypeClothing);
            exit;
        end;

        if (keywordList.indexOf('ObjectTypeArmor') = -1) then addKeywordByFormId(armo, ObjectTypeArmor);
    finally
        if assigned(keywordList) then keywordList.free;
    end;

end;
//============================================================================
function shouldProcessArmo(armo: IInterface; keywordList: TStringList): boolean;
begin 
    result := false;
    if (getElementEditValues(armo, 'Record Header\record flags\Non-Playable') = '1') then exit;
    if not containsText(getElementEditValues(armo, 'RNAM'), '00013746') then exit;
    if winningRefByCount(armo) = 0 then exit;
    if StrToInt(GetElementEditValues(armo, 'DATA\value')) = 0 then exit;
    result := true;
end;
//============================================================================
procedure processPowerArmor(armo: IInterface; keywordList: TStringList);
var
    kwda : IInterface;
    i: integer;
begin
    AddMessage('----Processing Power ARMO ' + EditorID(armo) + '------------------------------------------------------');
    copyOverrideToPatch(armo);
    //Remove Unscrappable keyword from ARMO
    kwda := ElementByPath(armo, 'Keywords\KWDA');
    for i := ElementCount(kwda)-1 downto 0 do begin
        if ContainsText(EditorId(LinksTo(ElementByIndex(kwda, i))), 'UnscrappableObject') then begin
            remove(ElementByIndex(kwda, i));
        end;
    end;

end;

//============================================================================  
function isClothing (armo: IInterface): boolean;
var
  Keywords, Entry: IInterface;
  ar, weight: integer;
  usesArmorSlots : boolean;

begin
  
    ar := getElementEditValues(armo, 'FNAM\Armor Rating');
    weight := GetElementEditValues(armo, 'DATA\weight');

    result := false;
    //if (ar > 20) then exit;
    //if isBipedSlotHead(armo) AND (ar > 10) then exit;
    if containsText(editorId(armo), 'helmet') then exit;
    if armoHasArmorBipedSlot(armo) then exit;
    if (not hasKeyword(armo, 'ma_Railroad_ClothingArmor')) and (weight > 20) then exit;
    result := true;
  
end;

//============================================================================  
function armoHasArmorBipedSlot(armo: IInterface): boolean;
var
  Keywords, Entry: IInterface;
begin
   result := isTorsoArmor(armo) OR isArmArmor(armo) OR isLegArmor(armo);
end;


//============================================================================  
function isTorsoArmor(armo: IInterface): boolean;
begin
    result := (GetElementEditValues(armo, 'BOD2\First Person Flags\41 - [A] Torso') = '1');
end;

//============================================================================  
function isArmArmor(armo: IInterface): boolean;
begin
    result := (GetElementEditValues(armo, 'BOD2\First Person Flags\42 - [A] L Arm') = '1')
        OR (GetElementEditValues(armo, 'BOD2\First Person Flags\43 - [A] R Arm') = '1');
end;

//============================================================================  
function isLegArmor(armo: IInterface): boolean;
begin
    result := (GetElementEditValues(armo, 'BOD2\First Person Flags\44 - [A] L Leg') = '1')
        OR (GetElementEditValues(armo, 'BOD2\First Person Flags\45 - [A] R Leg') = '1');
end;

//============================================================================  
function isHelmet(armo: IInterface): boolean;
begin
   result := (GetElementEditValues(armo, 'BOD2\First Person Flags\46 - Headband') = '1')
        or (GetElementEditValues(armo, 'BOD2\First Person Flags\47 - Eyes') = '1')
        or (GetElementEditValues(armo, 'BOD2\First Person Flags\48 - Beard') = '1')
        or (GetElementEditValues(armo, 'BOD2\First Person Flags\49 - Mouth') = '1');
end;
//============================================================================
function IsArmoPreWar(armo: IInterface): boolean;
begin
    result := armoPrewarCache.indexOf(editorId(armo)) > -1;
end;
//============================================================================
function IsArmoPreWarByName(armo: IInterface): boolean;
var
    full: string;
    i : integer;
begin
    full := getElementEditValues(armo, 'FULL');
    
    if hasKeyword(armo, 'ObjectTypeClothing') then begin
        result := false;
        exit;
    end;

    result := false;
    for i := 0 to armo_improvised_name_contains.count -1 do begin
        if containsText(full, armo_improvised_name_contains[i]) then exit;
    end;

    result := true;
    armoPrewarCache.add(editorId(armo));
end;

//###
end.