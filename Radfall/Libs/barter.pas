unit Radfall_barter;

uses 'Radfall\Libs\util';

const 
    restockScriptTemplate = MainRecordByEditorID(GroupBySignature(fileByName('Radfall.esp'), 'CONT'), 'DynamicRestock_Template');
    NO_SALE_KYWD = '00022CE4';
    template_vendor_misc = RecordByFormID(FileByIndex(0), '00022CE5', false);
    
var
    keywordsToCheck, keywordsToCheckFormIds, allowWeapons, allowArmor, listHasKeywordCache: TStringList;
    barterMaster, keyword : IInterface;
    MiscValueThreshold: integer;
    enable_dynamic_restock, reduce_vendor_caps, retrict_vendor_buys: boolean;

procedure runBarter();
var
  i: integer;
begin
    if config.readBool('Barter', 'enable_barter', false) then addMessage('Running Barter Module')
    else begin
        addMessage('BARTER MODULE DISABLED BY CONFIGURATION: SKIPPING');
        exit;
    end;

    listHasKeywordCache := newSortedTStringList();

    addMessage('Init Barter');
    keywordsToCheck := getConfigList('Barter', 'vendor_category_kywds');
    keywordsToCheckFormIds := TStringList.create;
    for i := 0 to keywordsToCheck.count-1 do begin
      keyword := recordByFileAndEdid('KYWD', keywordsToCheck[i]);
      keywordsToCheckFormIds.add(getId(keyword));
    end;
    addMessage('  Keywords to Check: ' + keywordsToCheck.DelimitedText);

    allowArmor := getConfigList('Barter', 'override_armo');
    addMessage('  Override allow armor: ' + allowArmor.DelimitedText);

    allowWeapons := getConfigList('Barter', 'override_weap');
    addMessage('  Override allow weapons: ' + allowWeapons.DelimitedText);
    
    MiscValueThreshold := config.readInteger('Barter', 'min_sale_value', 0);
    addMessage('  Min salve value= ' + intToStr(MiscValueThreshold));

    enable_dynamic_restock := config.readBool('Barter', 'enable_dynamic_restock', false);
    if not enable_dynamic_restock then addMessage('  DYNAMIC RESTOCK DISABLED');
    reduce_vendor_caps := config.readBool('Barter', 'reduce_vendor_caps', false);
    if not reduce_vendor_caps then addMessage('  VENDOR CAP REDUCTION DISABLED');
    retrict_vendor_buys := config.readBool('Barter', 'retrict_vendor_buys', false);
    if not retrict_vendor_buys then addMessage('  RESTRICT VENDOR BUYS DISABLED');

    if MiscValueThreshold > 0 then begin
        loadRecordQueue('MISC');
        while recordQueueHasNext() do processMisc(getQueueNextRecord());
    end;

    loadRecordQueue('FACT');
    while recordQueueHasNext() do processVendorFaction(getQueueNextRecord());

    listHasKeywordCache.free();
    keywordsToCheck.free();
    keywordsToCheckFormIds.free();
    allowWeapons.free();
    allowArmor.free();

end;


//============================================================================  
function processVendorFaction(fact: IInterface): integer;
var
    i: integer;
    ref, cont: IInterface;  

begin
    ref := WinningOverride(LinksTo(ElementByPath(fact, 'VENC')));
    cont := WinningOverride(LinksTo(ElementByPath(ref, 'NAME - Base')));
            
    if (getElementEditValues(fact, 'Data - Flags\Flags\Vendor') = '0') then exit;
    if not assigned(ref) then exit;
    if not assigned(cont) then exit;
    
    AddMessage('----Processing FACT ' + EditorID(fact) + '------------------------------------------------------');
    
    //Get the vendor container
    fact := copyOverrideToPatch(fact);
    cont := copyOverrideToPatch(cont);
    
    if retrict_vendor_buys then restrictVendorsBuySell(fact, cont);
    
    //Assign dynamic restock script
    if enable_dynamic_restock then begin
        ElementAssign(cont, 1, ElementByPath(restockScriptTemplate, 'VMAD'), False);
        setElementEditValues(cont, 'DATA\Flags\Respawns', 0);
    end;
    
    if reduce_vendor_caps then replaceCaps(cont);

end;

//============================================================================  
function restrictVendorsBuySell(e, cont: IInterface): integer;
var
  i: integer;
  restrictedList, formIDs, entry: IInterface;
  hasUnrestricted: boolean;

begin
  addMessage('     Restricting vendor buy/sells');
  if getElementEditValues(e, 'VENV\Buy/Sell Everything Not In List?') = 'False' then begin
    addMessage('          Vendor already uses whitelist, skipping vendor restriction');
    exit;
  end;
    
  //Copy the restricted formlist as new, and assign it to the vendor
  restrictedList := copyRecordToFile(template_vendor_misc, patchFile, true);
  setElementEditValues(restrictedList, 'EDID', EditorID(e) + '_restricted');
  setElementEditValues(e, 'VEND', getId(restrictedList));
  setElementEditValues(e, 'VENV\Buy/Sell Everything Not In List?', 'True');
  formIDs := elementByPath(restrictedList, 'FormIDs');

  //For each keyword in the config, check if an item in the container has the keyword
  for i:=0 to keywordsToCheck.Count -1 do begin
    // if it's not sold by the merchant, then blacklist it
    if shouldOverrideVendorRestriction(EditorId(e), keywordsToCheck[i]) 
    OR containerHasKeywordItem(cont, keywordsToCheck[i]) then continue;
    
    //If it doesn't then add that keyword to the restricted list
    entry := ElementAssign(formIDs, HighInteger, nil, true);
    SetEditValue(entry, keywordsToCheckFormIds[i]);
  end;
  
end;

//============================================================================  
function replaceCaps(cont: IInterface): integer;
var
  i: integer;
  item, items, entry: IInterface;
begin
    addMessage('     Reducing vendor caps');

    items := ElementByPath(cont, 'Items');
    for i := ElementCount(items)-1 downto 0 do begin
      item := WinningOverride(LinksTo(ElementByPath(ElementByIndex(items, i), 'CNTO\Item')));
      if Signature(item) = 'LVLI' then begin
        if levelledListHasKeywordItemOrItem(item, 'Caps001') then RemovebyIndex(items, i, true);
      end
      else if containsText(EditorID(item), 'Caps001') then RemovebyIndex(items, i, true);
    end;
    
    entry := ElementAssign(items, HighInteger, nil, true);
    setElementEditValues(entry, 'CNTO - item\item', '000585A4');
    setElementEditValues(entry, 'CNTO - item\Count', 5);
end;



//============================================================================  
// Utility Functions
//============================================================================  

function shouldOverrideVendorRestriction(edid, kywd: string): Boolean;

begin
    result := false;
    if (kywd = 'ObjectTypeWeapon') and (allowWeapons.indexOf(edid) > -1) then result := true
    else if (kywd = 'ObjectTypeArmor') and (allowArmor.indexOf(edid) > -1) then result := true;
    if result then addMessage(          'Overriding vendor restriction on: ' + kywd)
end; 

//============================================================================  
function containerHasKeywordItem(cont: IInterface; keyword:String): Boolean;
var  
  i: integer;
  entries, entry: IInterface;
  
begin
    result := false;
    entries := ElementByPath(cont, 'Items');
    for i := ElementCount(entries)-1 downto 0 do begin
        entry := WinningOverride(LinksTo(ElementByPath(ElementByIndex(entries, i), 'CNTO\Item')));
        if (editorId(entry) = '') then raise exception.create('Failed to get leveled list entry ');

        if (Signature(entry) <> 'LVLI') then result := hasKeyword(entry, keyword)
        else result := levelledListHasKeywordItemOrItem(entry, keyword);
        
        if result then exit;
    end;

end;

//============================================================================  

function levelledListHasKeywordItemOrItem(lvli: IInterface; keyword:String): Boolean;
var  
  i: integer;
  entries, entry: IInterface;
  cacheKey : string;
begin
    //Use a cache to avoid reprocessing the same lists
    cacheKey := editorId(lvli) + ':' + keyword;
    i := listHasKeywordCache.indexOf(cacheKey);
    if i > -1 then begin
        result := IntToStr(listHasKeywordCache.objects[i]) = '1';
        exit;
    end;


    result := false;
    entries := ElementByPath(lvli, 'Leveled List Entries');
  
    for i := ElementCount(entries)-1 downto 0 do begin
        entry := WinningOverride(LinksTo(ElementByPath(ElementByIndex(entries, i), 'LVLO\Item')));
        //recurse for nested lists
        if (Signature(entry) = 'LVLI') then result := levelledListHasKeywordItemOrItem(entry, keyword)
        //required to check for caps, because caps checks for the item, and doesn't have a keyword
        else result := (hasKeyword(entry, keyword) or containsText(editorId(entry), keyword));
        if result then begin 
          listHasKeywordCache.addObject(cacheKey, 1);
          exit;
        end;
    end;

    listHasKeywordCache.addObject(cacheKey, 0);

end;

//============================================================================ 
function getConfigList(section, key: string): TStringList;
var
    raw: string;
begin
    raw := config.readString(section, key, '');
    result := TStringList.create;
    result.DelimitedText := raw;
end;
//=========
function recordByFileAndEdid(sig, fileAndEdid: String): IInterface;
var
    p: integer;
    filename, edid: string;

begin
    p := Pos('|', fileAndEdid);
    filename := Copy(fileAndEdid, 1, p-1);
    if filename = '' then fileName := 'Fallout4.esm'; //raise Exception.create('** ERROR ** missing file name for' + keyword);
    edid := Copy(fileAndEdid, P+1, Length(fileAndEdid));
    result := getRecord(fileName, sig, edid);
end;

//===========
end.
