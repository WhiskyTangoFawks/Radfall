unit crafting_disable;

//============================================================================  
procedure replaceReferences(oldRecord: IInterface; newRecordFormId: string);
var
  refBy: IInterface;
  i : integer;
begin
  info('Replacing references ' + editorId(oldRecord) + ' -> ' + newRecordFormId);
  for i := 0 to ReferencedByCount(oldRecord)-1 do begin
    refBy := ReferencedByIndex(oldRecord, i);
    if not isWinningOverride(refBy) then continue;
    refBy := copyOverrideToPatch(refBy);
    compareExchangeFormId(refBy, GetLoadOrderFormID(oldRecord), StrToInt('$' + newRecordFormId));
  end;
end;
//============================================================================  
procedure replaceWeapArmoReferences(oldRecord, newRecord: IInterface);
var
  refBy: IInterface;
  i : integer;
  sig : string;
begin
  info('Replacing Weap/Armo references ' + editorId(oldRecord) + ' -> ' + editorId(newRecord));
  for i := 0 to ReferencedByCount(oldRecord)-1 do begin
    refBy := ReferencedByIndex(oldRecord, i);
    if not isWinningOverride(refBy) then continue;
    sig := signature(refBy);
    if (sig = 'WEAP') OR (sig = 'ARMO') OR (sig = 'REFR') then begin
      refBy := copyOverrideToPatch(refBy);
      compareExchangeFormId(refBy, GetLoadOrderFormID(oldRecord), GetLoadOrderFormID(newRecord));
    end;
  end;
end;
//============================================================================  
procedure disableReferences(oldRecord: IInterface);
var
  i: integer;
  refby: IInterface;
  sig: string;
begin
  info('Disabling references ' + editorID(oldRecord));
  for i := 0 to ReferencedByCount(oldRecord)-1 do begin
    refBy := ReferencedByIndex(oldRecord, i);
    if not isWinningOverride(refBy) then continue;
    if (getElementEditValues(refBy, 'Record Header\record flags\Non-Playable') = '1') then continue;
    
    refBy := copyOverrideToPatch(refBy);
    sig := signature(refBy);
    if sig = 'FLST' then removeFlstReference(refBy, oldRecord)
    else if sig = 'LVLI' then removeLvliReference(refBy, oldRecord)
    else if sig = 'CONT' then removeContReference(refBy, oldRecord)
    else if sig = 'OMOD' then removeOmodReference(refBy, oldRecord)
    else if sig = 'REFR' then removeRefrReference(refBy, oldRecord)
    else if sig = 'COBJ' then removeCobjReference(refBy, oldRecord)
    else if sig = 'ARMO' then removeTemplateReference(refBy, oldRecord)
    else if sig = 'WEAP' then removeTemplateReference(refBy, oldRecord)
    //TODO: remove this later
    else if sig = 'CELL' then warn('Found cell ref while disabling ' + editorID(oldRecord) + ', skipping')
    else if sig = 'QUST' then warn('Found quest ref while disabling ' + editorID(oldRecord) + ', skipping')
    else if sig = 'SCOL' then warn('Found SCOL ref while disabling ' + editorID(oldRecord) + ', skipping')
    else if sig = 'NPC_' then warn('Found NPC_ ref while disabling ' + editorID(oldRecord) + ', skipping')
    else raise exception.create('Unexpected reference type: ' + signature(refBy));
    
  end;
end;
//===============
procedure removeFlstReference(flst, oldRecord: IInterface);
var
  i: integer;
  list: IInterface;
begin
  list := elementByPath(flst, 'FormIDs');
  for i := elementCount(list) downTo 0 do begin
    if GetLoadOrderFormID(LinksTo(elementByIndex(list, i))) = GetLoadOrderFormID(oldRecord) then removeByIndex(list, i, true);
  end;
end;
//===============
procedure removeLvliReference(lvli, oldRecord: IInterface);
var
  i: integer;
  list, entry: IInterface;

begin
  list := ElementByPath(lvli, 'Leveled List Entries');
  for i := ElementCount(list)-1 downto 0 do begin
    entry := LinksTo(ElementByPath(ElementByIndex(list, i), 'LVLO\Item'));
    if GetLoadOrderFormID(entry) = GetLoadOrderFormID(oldRecord) then removeByIndex(list, i, true);
  end;     
end;
//===============
procedure removeContReference(cont, oldRecord: IInterface);
var
  i: integer;
  list, entry: IInterface;

begin
  if containsText(editorId(cont), 'QA') then exit;
  
  list := ElementByPath(cont, 'Items');
  for i := ElementCount(list)-1 downto 0 do begin
    entry := LinksTo(ElementByPath(ElementByIndex(list, i), 'CNTO\Item'));
    if GetLoadOrderFormID(entry) = GetLoadOrderFormID(oldRecord) then removeByIndex(list, i, true);
  end;
end;
//===============
procedure removeOmodReference(omod, oldRecord: IInterface);
var
  i: integer;
  list, entry: IInterface;

begin
  if getElementEditValues(omod, 'Record Header\record flags\Mod Collection') = '1' then begin
    list := ElementByPath(omod, 'DATA\Includes');
    for i := ElementCount(list)-1 downto 0 do begin
      entry := LinksTo(ElementByPath(ElementByIndex(list, i), 'Mod'));
      if GetLoadOrderFormID(entry) = GetLoadOrderFormID(oldRecord) then removeByIndex(list, i, true);
    end;
  end;
  
  if GetLoadOrderFormID(linksTo(elementByPath(omod, 'LNAM'))) = GetLoadOrderFormID(oldRecord) then removeElement(omod, elementByPath(omod, 'LNAM'));
end;
//===============
procedure removeRefrReference(refr, oldRecord: IInterface);
begin
  if GetLoadOrderFormID(linksTo(elementByPath(refr, 'NAME'))) = GetLoadOrderFormID(oldRecord) then SetIsInitiallyDisabled(refr, true);
end;
//===============
procedure removeCobjReference(cobj, oldRecord: IInterface);
var
  i: integer;
  list, entry: IInterface;

begin
  if GetLoadOrderFormID(linksTo(elementByPath(cobj, 'CNAM'))) = GetLoadOrderFormID(oldRecord) then removeElement(cobj, ElementByPath(cobj, 'CNAM'))
  else begin
    list := ElementByPath(cobj, 'FVPA');
    for i := ElementCount(list)-1 downto 0 do begin
      entry := LinksTo(ElementByPath(ElementByIndex(list, i), 'Component'));
      if GetLoadOrderFormID(entry) = GetLoadOrderFormID(oldRecord) then removeByIndex(list, i, true);
    end;
  end;
end;
//===============
procedure removeTemplateReference(item, oldRecord: IInterface);
var
  i, j: integer;
  templateList, includesList, entry: IInterface;

begin
  templateList := ElementByPath(item, 'Object Template\Combinations');
  for i := ElementCount(templateList)-1 downto 0 do begin
    includesList := elementByPath(ElementByIndex(templateList, i), 'OBTS\Includes');
    for j := elementCount(includesList) downto 0 do begin
      entry := linksTo(elementByPath(elementByIndex(includesList, j), 'Mod'));
      if GetLoadOrderFormID(entry) = GetLoadOrderFormID(oldRecord) then removeByIndex(includesList, j, true);
    end;
  end;
end;


end.