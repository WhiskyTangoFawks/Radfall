unit radfall_crafting;

uses 'Radfall\Libs\crafting_degredation';
uses 'Radfall\Libs\perks';
uses 'Radfall\Libs\crafting_disable';
uses 'Radfall\Libs\crafting_workshop';

var
    adhesive, screw, oil: integer;
    globalEnableScrapRecipe, globalEnableVanillaWorkshop, disableTransferKeyword : string;
    prewar_transferrable_apprs, improv_transferrable_apprs, prewar_disable_crafting_apprs, improv_disable_crafting_apprs: TStringList;
    blacksmith, itemCache, tranferredMiscCache, workshopWorkbenchFilter: TStringList;


//============================================================================  
procedure runCrafting();
begin
    initDegredation();

    itemCache := newSortedTStringList();

    workshopWorkbenchFilter := newSortedTStringList();
    workshopWorkbenchFilter.add('00246F85'); // WorkshopWorkbenchTypeSettlement
    workshopWorkbenchFilter.add('0005B5E3'); // WorkshopWorkbenchTypeFurniture
    workshopWorkbenchFilter.add('0023D9BA'); // WorkshopWorkbenchTypeInteriorOnly
    workshopWorkbenchFilter.add('0005A0CA'); // WorkshopWorkbenchTypePower
    workshopWorkbenchFilter.add('0008280B'); // WorkshopWorkbenchTypeDecorations
    workshopWorkbenchFilter.add('0005A0C8'); // WorkshopWorkbenchTypeExterior
    workshopWorkbenchFilter.add('0005A0C9'); // WorkshopWorkbenchTypeWire
    workshopWorkbenchFilter.add('00020592'); // WorkshopWorkObject
    workshopWorkbenchFilter.add('0012E2C8'); // WorkshopWorkbenchTypeCrafting
    
    //get the blacksmith formIDs
    blacksmith := listOf('0,0004B253,0004B26A,000264D8');
    blacksmith.add(getId(getRecord('Radfall.esp', 'PERK', 'Blacksmith04')));
    globalEnableScrapRecipe := getId(getRecord('Radfall.esp', 'GLOB', 'bEnableScrapRecipes'));
    globalEnableVanillaWorkshop := getId(getRecord('Radfall.esp', 'GLOB', 'bEnableVanillaWorkshop'));
    adhesive := GetLoadOrderFormID(getRecord('Fallout4.esm', 'CMPO', 'c_Adhesive'));
    screw := GetLoadOrderFormID(getRecord('Fallout4.esm', 'CMPO', 'c_Screws'));
    oil := GetLoadOrderFormID(getRecord('Fallout4.esm', 'CMPO', 'c_Oil'));
    addMessage('disable transfer keyword: ' + fullPath(getRecord('Radfall.esp', 'KYWD', 'ma_DisableTransfer')) );
    disableTransferKeyword := getId(getRecord('Radfall.esp', 'KYWD', 'ma_DisableTransfer'));

    tranferredMiscCache := newSortedTStringList();
    
    prewar_transferrable_apprs := newSortedTStringList();
    prewar_transferrable_apprs.delimitedText := config.readString('Crafting', 'prewar_transferrable_apprs', '');
    
    improv_transferrable_apprs := newSortedTStringList();
    improv_transferrable_apprs.delimitedText := config.readString('Crafting', 'improvised_transferrable_apprs', '');
    
    prewar_disable_crafting_apprs := newSortedTStringList();
    prewar_disable_crafting_apprs.delimitedText := config.readString('Crafting', 'prewar_disable_crafting_apprs', '');
    
    improv_disable_crafting_apprs := newSortedTStringList();
    improv_disable_crafting_apprs.delimitedText := config.readString('Crafting', 'improvised_disable_crafting_apprs', '');

    loadRecordQueue('COBJ');
    while recordQueueHasNext() do evalCobj(getQueueNextRecord());

end;

//============================================================================  
procedure evalCobj(cobj: IInterface);
var
    cnam, item: iinterface;
    sigCnam, bnamId: string;
    keywordList: TStringList;
begin
    addMessage('Evaluating: ' + FullPath(cobj));
    cnam := winningOverride(LinksTo(ElementBySignature(cobj, 'CNAM')));
    bnamId := getId(linksTo(elementByPath(cobj, 'BNAM')));
    trace('Found cnam ' + editorId(cnam));
    if not assigned(cnam) then begin
        debug('no CNAM assigned, skipping');
        exit;
    end;

    if containsText(editorId(cobj), 'workshop_co_scrap') then exit;

    sigCnam := signature(cnam);
    if (sigCnam = 'ARMO') then begin
        trace('Found ARMO recipe');
        if (getElementEditValues(cnam, 'Record Header\record flags\Non-Playable') = '1') then exit;
        if winningRefByCount(cnam) = 0 then exit;
        if hasKeyword(cnam, 'ArmorTypePower') then processPaRepairCobj(cobj, cnam)
        else warn('found non-power armor COBJ');
        exit;
    end
    else if sigCnam = 'OMOD' then begin //Omods
        trace('Found OMOD recipe');
        if not assigned(LinksTo(elementByPath(cnam, 'DATA\Attach Point'))) then exit;
        item := getWeapOrArmoForOMOD(cnam);
        if not assigned(item) then exit;
        trace('got recipe item: ' + editorId(item));
        keywordList := getKeywordList(item);
        if signature(item) = 'WEAP' then if not shouldProcessWeap(item, keywordList) then exit;
        if signature(item) = 'ARMO' then if not shouldProcessArmo(item, keywordList) then exit;

        processOmodCobj(cobj, cnam, item);
    end
    else if (workshopWorkbenchFilter.indexOf(getId(linksTo(elementByPath(cobj, 'BNAM')))) > -1) then begin
        processWorkshopCobj(cobj, cnam);
    end
    else begin
        debug('Found unknown recipe type ' + editorId(cobj));
        exit; //There are a LOT of recipes for other crap- just skip them
    end;
end;
//============================================================================  
procedure processPaRepairCobj(cobj, armo: IInterface);
var
    eFVPA, cmpo : IInterface;
    i: integer;
begin
    //I've decided to remove the PaScrap idea from Radfall
        //The lack of UI integration makes this feature weird
        //Less plentiful armor with PATTP removal also causes issues
    //addMessage('Processing: ' + FullPath(cobj));
    
    //cobj := copyOverrideToPatch(cobj);
    //if IsArmoPreWar(armo) then begin
    //    eFVPA := ElementByPath(cobj, 'FVPA - Components');
    //    for i := ElementCount(eFVPA)-1 downto 0 do begin
    //        cmpo := LinksTo(ElementByIndex(ElementByIndex(eFVPA, i), 0));
    //        if EditorID(cmpo) = 'c_Steel' then setEditValue(ElementByIndex(ElementByIndex(eFVPA, i), 0), paScrap);
    //    end;
    //end;

    //if not assigned(elementByPath(cobj, 'FNAM')) then add(cobj, 'FNAM', true);
    //SetEditValue(ElementAssign(elementByPath(cobj, 'FNAM'), HighInteger, nil, true), '00106D8F');

end;
//============================================================================  
procedure processOmodCobj(cobj, omod, item: IInterface);
var
    transferRecipe, craftingRecipe, misc, disableTransferOmod, appr, mnam: IInterface;
    prewar, standard: boolean;
    
begin
    addMessage('Processing: ' + FullPath(cobj));

    misc := linksTo(elementByPath(omod, 'LNAM'));
    cobj := copyOverrideToPatch(cobj);
    if signature(item) = 'WEAP' then preWar := IsWeapPreWar(item)
    else preWar := isArmoPrewar(item);
    appr : = LinksTo(ElementByPath(omod, 'DATA\Attach Point'));
    standard := isStandard(omod);

    //try adding a degredation, will exit early if not a valid candidate for degredation
    if (signature(item) = 'WEAP') then addDegredationSpell(omod, item);

    swapRadfallPerks(cobj, item);

    if shouldDisableCraftingForAppr(appr, prewar) then begin
        removeElement(cobj, 'CNAM');
        disableReferences(misc);
        info('Disabling crafting');
        exit;
    end;

    if not assigned(misc) then begin
        info('No miscmod found for OMOD ' + editorId(omod) + ', skipping transfer/crafting processing');
        exit;
    end;

    if not standard then misc := replaceMnamIfTransferrable(omod, misc, item, prewar);

    transferRecipe := copyRecordToFile(cobj, patchFile, true);
    setElementEditValues(transferRecipe, 'EDID', editorId(cobj) + '_transfer');
    cleanPerkConditions(transferRecipe);
    cleanRecipe(transferRecipe);
    if not standard then addRecipeComponent(transferRecipe, getId(misc), 1);

    //create a copy of the omod with a dead end FNAM to disable the vanilla transfer mechanism, because I made a specific recipe for it
    disableTransferOmod := copyRecordToFile(omod, patchFile, true);
    setElementEditValues(disableTransferOmod, 'EDID', editorId(omod) + '_noTransfer');;
    removeElement(disableTransferOmod, 'MNAM');
    add(disableTransferOmod, 'MNAM', true);
    mnam := elementAssign(elementByPath(disableTransferOmod, 'MNAM'), highInteger, nil, true);
    setEditValue(mnam, disableTransferKeyword);
    

    //for improvised weapons ONLY, setup crafting-from-scrap-components recipe
    if (not preWar) AND (not standard) then begin
        craftingRecipe := copyRecordToFile(cobj, patchFile, true);
        setElementEditValues(craftingRecipe, 'EDID', editorId(cobj) + '_craft');
    end;

    //replace default "scrap" recipe with miscmod, so scrapping weapon returns loose miscmods
    //Only add miscmod as scrap if it's not a standard recipe
    disableRecipe(cobj, globalEnableScrapRecipe);
    cleanRecipe(cobj); //clear existing components
    if standard then begin
        removeElement(cobj, elementByPath(COBJ, 'FVPA - Components'));
        cleanPerkConditions(craftingRecipe);
    end
    else addRecipeComponent(cobj, getId(misc), 2);
    
end;

//============================================================================ 
procedure disableRecipe(cobj: IInterface; global: String);
var
    conditions, condition, ctda: iinterface;
begin
    conditions := elementByPath(cobj, 'Conditions');
    if not assigned(conditions) then begin
        conditions := Add(cobj, 'Conditions', true);
        condition := elementByIndex(conditions, 0);
    end 
    else condition := ElementAssign(conditions, HighInteger, nil, true);

    ctda := ElementBySignature(condition, 'CTDA');
    SetEditValue(ElementByName(ctda, 'Type'), '10000000');
    SetNativeValue(ElementByName(ctda, 'Comparison Value - Float'), 1.0);
    SetEditValue(ElementByName(ctda, 'Function'), 'GetGlobalValue');
    SetEditValue(ElementByName(ctda, 'Global'), global);
end;
//============================================================================ 
function cleanRecipe(cobj: IInterface): String;
var
  WorkingComp, eFVPA: IInterface;
  i, oldCount, newCount, cmpoId: integer;
  rarity: String;
begin
    eFVPA := ElementByPath(cobj, 'FVPA - Components');
    for i := ElementCount(eFVPA)-1 downto 0 do begin
        WorkingComp := ElementByIndex(eFVPA, i);
        oldCount := StrToInt(GetEditValue(ElementByIndex(WorkingComp, 1)));
        cmpoId := GetLoadOrderFormID(LinksTo(ElementByIndex(WorkingComp, 0)));
        //rarity := getElementEditValues(cmpo, 'GNAM');
        
        if cmpoId = adhesive then newCount := ceil(oldCount * 0.5)
        else if cmpoId = screw then newCount := ceil(oldCount * 0.5)
        else if cmpoId = oil then newCount := ceil(oldCount * 0.5)
        //else if containsText(rarity, 'rare') then setEditValue(ElementByIndex(WorkingComp, 1), ceil(oldCount * RareRatio))
        //else if containsText(rarity, 'uncommon') then setEditValue(ElementByIndex(WorkingComp, 1), ceil(oldCount * uncommonRatio))
        //else if containsText(rarity, 'common') then setEditValue(ElementByIndex(WorkingComp, 1), ceil(oldCount * commonRatio));
        else newCount := 0;
        
        if (newCount > 0) then setEditValue(ElementByIndex(WorkingComp, 1), newCount)
        else remove(WorkingComp);
    end;
end;
//============================================================================
procedure addRecipeComponent(cobj, IInterface; cmpo: String; count: integer);
var
    components, component: IInterface;
begin
    components := add(cobj, 'FVPA', true); //adds if missing, otherwise returns existing;
    component := ElementAssign(components, HighInteger, nil, true);
    setElementEditValues(component, 'count', count);
    setElementEditValues(component, 'component', cmpo);
end;

//============================================================================  
//Gets the record for an OMOD based on the MNAM filter keyword
function getWeapOrArmoForOMOD(omod: IInterface): IInterface;
var
  ref, mnam, mnams: IInterface;
  i, refCount, count, cacheIndex: integer;
begin
    //Grab the mnam with the fewest references
    refCount := -1;
    mnams := ElementBySignature(omod, 'MNAM');
    for i := 0 to elementCount(mnams)-1 do begin
        ref := linksTo(elementByIndex(mnams, i));
        if i = 0 then begin
            mnam := ref;
            refCount := ReferencedByCount(ref);
        end
        else if (refCount > ReferencedByCount(ref)) then begin
            mnam := ref;
            refCount := ReferencedByCount(ref);
        end;
    end;
    refCount := -1;
    //Check if I've already done the item seach for the object
    cacheIndex := itemCache.indexOf('mnam');
    if (cacheIndex > -1) then begin
        addMessage('found cached value, returning');
        result := ObjectToElement(itemCache.objects[cacheIndex]);
        exit;
    end;

    //TODO - consider how to handle universal armor keywords, like RailroadWeave, that are going to be on hundreds of items
    for i := 0 to ReferencedByCount(mnam)-1 do begin
        ref := ReferencedByIndex(mnam, i);
        if not(isWinningOverride(ref)) then continue;
        if ((signature(ref) <> 'ARMO') AND (signature(ref) <> 'WEAP')) then continue;
        if (getElementEditValues(ref, 'CNAM') <> '') then continue; 
        if (getElementEditValues(ref, 'TNAM') <> '') then continue;
        if (getElementEditValues(ref, 'Record Header\record flags\Non-Playable') = '1') then continue;
        
        count := winningRefByCount(ref);
        if count > refCount then begin
        refCount := ReferencedByCount(ref);
        result := ref;
        end;
    end;
    itemCache.addObject(editorId(mnam), result);
end;

//============================================================================ 
procedure swapRadfallPerks(cobj, item: IInterface);
begin
    if (signature(item) = 'ARMO') and hasKeyword(item, 'ArmorTypePower') then begin
        //convert Armorer to Blacksmith
        swapPerkReqs(cobj, 'Armorer01', blacksmith[1]);
        swapPerkReqs(cobj, 'Armorer02', blacksmith[2]);
        swapPerkReqs(cobj, 'Armorer03', blacksmith[3]);
        swapPerkReqs(cobj, 'Armorer04', blacksmith[4]);
    end;
end;

//============================================================================ 
function getTransferKey(omod, misc, item: IInterface; prewar: boolean): string;
var
    ap, ammo : IInterface;
    newFull, ammoFull, omodFull: string;
begin
    //set the default key to result
    result := editorId(LinksTo(ElementByPath(omod, 'DATA\Attach Point'))) + '_' + getElementEditValues(omod, 'FULL');    
    if not prewar then result := 'improv_ ' + result;
    
    //check if we're a gun mod (currently only receiver is set to go here), if not then exit
    if signature(item) <> 'WEAP' then exit;
    ammo := linksTo(elementByPath(item, 'DNAM\Ammo'));
    ap := LinksTo(ElementByPath(omod, 'DATA\Attach Point'));
    if not assigned(ammo) then exit;
    if not assigned(ap) then exit;
    
    //If it's a receiver for a weapon with ammo, then...
    misc := copyOverrideToPatch(winningOverride(misc));

    if (editorId(ap) = 'ap_gun_receiver') then begin
        ammoFull := getElementEditValues(ammo, 'FULL');
        ammoFull := stringReplace(ammoFull, ' Round', '', [rfReplaceAll]);
        ammoFull := stringReplace(ammoFull, ' Shell', '', [rfReplaceAll]);
        ammoFull := stringReplace(ammoFull, ' Caliber', '', [rfReplaceAll]);
        ammoFull := stringReplace(ammoFull, ' Cartridge', '', [rfReplaceAll]);
        ammoFull := stringReplace(ammoFull, ' AP', '', [rfReplaceAll]);
        ammoFull := stringReplace(ammoFull, ' +P', '', [rfReplaceAll]);
    
        omodFull := getElementEditValues(omod, 'FULL');
        //Remove automatic/burst
        omodFull := stringReplace(omodFull, 'RCW ', '', [rfReplaceAll]);
        omodFull := stringReplace(omodFull, 'Automatic ', '', [rfReplaceAll]);
        omodFull := stringReplace(omodFull, 'Burst Fire ', '', [rfReplaceAll]);
        if (omodFull = 'Receiver') then omodFull := 'Standard Receiver';
        if (omodFull = 'Capacitor') then omodFull := 'Standard Capacitor';

        if hasKeyword(item, 'WeaponTypeBallistic') then begin
            if prewar then newFull := ammoFull + ' ' + omodFull
            else newFull := ammoFull +' Pipe ' + omodFull;
        end
        else begin
            if prewar then newFull := ammoFull + ' ' + omodFull
            else newFull := ammoFull +' Salvaged ' + omodFull;
        end;
            
        setElementEditValues(misc, 'FULL', newFull);
    end;
    result := editorId(LinksTo(ElementByPath(omod, 'DATA\Attach Point'))) + '_' + newFull;
end;

//============================================================================ 
function replaceMnamIfTransferrable(omod, misc, item: IInterface; prewar: boolean): IInterface;
var
    key, apEdid: string;
    miscIndex: integer;
    newMisc: IInterface;
begin
    result := misc;
    //If AP is standardizable, then swap Miscmod to standard version (first one found)
    apEdid := editorId(LinksTo(ElementByPath(omod, 'DATA\Attach Point')));
    if prewar AND (prewar_transferrable_apprs.indexOf(apEdid) = -1) then exit
    else if improv_transferrable_apprs.indexOf(apEdid) = -1 then exit;
    
    key := getTransferKey(omod, misc, item, prewar);
    debug('Found transferrable AP with key: ' + key);    
    miscIndex := tranferredMiscCache.indexOf(key);

    if miscIndex > -1 then begin
        newMisc := ObjectToElement(tranferredMiscCache.objects[miscIndex]);
        trace('cached miscmod found: ' + editorId(newMisc));
        replaceReferences(misc, getId(newMisc));
        result := newMisc;
    end 
    else begin 
        tranferredMiscCache.addObject(key, misc);
        trace('cached miscmod: ' + editorId(misc));
        result := misc;
    end;

end;

//============================================================================  
function cleanPerkConditions(e: IInterface): String;
var
  conditions: IInterface;
  i: integer;
begin
  conditions := ElementByName(e, 'Conditions');
  if not assigned(conditions) then exit;

  for i := ElementCount(conditions)-1 downto 0 do begin 
    if getElementEditValues(ElementByIndex(conditions, i), 'CTDA\Perk') = '' then begin 
      //logg(2, 'Leaving non-perk condition on '+ getElementEditValues(e, 'EDID'));
    end
    else begin 
      remove(ElementByIndex(conditions, i));
    end;
  end;
end;

//============================================================================ 
function shouldDisableCraftingForAppr(appr: IINterface; preWar: boolean): boolean;
begin
    if preWar then result := prewar_disable_crafting_apprs.indexOf(editorId(appr)) > -1
    else result := improv_disable_crafting_apprs.indexOf(editorId(appr)) > -1;    
end;
//============================================================================ 
function isStandard(omod: IInterface): boolean;
begin
    if copy(getElementEditValues(omod, 'DESC'), 1, 8) = 'Standard' then result := true
    //else if containsText(getElementEditValues(omod, 'FULL'), 'standard') then result := true
    else result := false;
end;

//###
end.