unit util;

function hasKeyword(e: IInterface; edid: String): boolean;
var
    kwda :IInterface;
    i: integer;
begin
    Result := false;
    kwda := ElementByPath(e, 'Keywords\KWDA');
    for i := 0 to ElementCount(kwda) - 1 do if GetElementEditValues(LinksTo(ElementByIndex(kwda, i)), 'EDID') = edid then Result := true;
end;

//=========
procedure addKeywordByFormId(e: IInterface; formId: String);
var
    keywords, entry :IInterface;
    i: integer;
begin
    keywords := add(e, 'Keywords', true);
    if not assigned(keywords) then raise Exception.Create('**ERROR**  Failed to add "Keywords"');
    entry := ElementAssign(elementByPath(keywords, 'KWDA'), HighInteger, nil, true);
    if not assigned(entry) then raise Exception.Create('**ERROR**  Failed to add new entry to keyword list');
    SetEditValue(entry, formId);
end;
//=========
function replaceKeyword(e: IInterface; oldKeywordEdid, newKeywordFormId: String): boolean;
var
    keywords :IInterface;
    i: integer;
begin
    Result := false;
    keywords := ElementByPath(e, 'Keywords\KWDA');
    for i := 0 to ElementCount(keywords) - 1 do if GetElementEditValues(LinksTo(ElementByIndex(keywords, i)), 'EDID') = oldKeywordEdid then begin
        setEditValue(elementByIndex(keywords, i), newKeywordFormId);
        exit;
    end;
    //If the keyword to replace isn't present, then just add the new one
    addKeywordByFormId(e, newKeywordFormId);
end;
//============================================================================  
function getKeywordList(item: IInterface):TStringList;
var
  kwda: IInterface;
  n: integer;
begin
  
    kwda := ElementByPath(item, 'Keywords\KWDA');
    if not assigned(kwda) then begin
        AddMessage('WARNING: failed to get keywords from ' + editorId(item));
        exit;
    end;
  
    result := TStringList.create;
    result.Sorted := true;
    result.Duplicates := dupIgnore;
    result.CaseSensitive := true; 
    
    for n := 0 to ElementCount(kwda) - 1 do result.add(editorId(winningOverride(LinksTo(ElementByIndex(kwda, n)))));
end;

//=========
function getRecord(fileName, sig, edid: String): IInterface;
var
    f: file;
begin
    f := fileByName(filename);
    if not assigned(f) then raise exception.create('Unable to find file: ' + fileName);
    result := MainRecordByEditorID(GroupBySignature(f, sig), edid);
    if not assigned(result) then raise Exception.create('** ERROR ** unable to find sig=' + sig + ' edid=' + edid + ' in file=' + filename);
end;

//=========
function getId(e: IInterface): String;

begin
    result := intToHex(GetLoadOrderFormID(e), 8);
end;

//============================================================================  
function addToFormlist(v, flst: IInterface): int;
var
  newElement: IInterface;

begin
    newElement := ElementAssign(ElementByPath(flst, 'FormIDs'), HighInteger,  nil, false);
    setEditValue(newElement, IntToHex(GetLoadOrderFormID(v), 8));

end;
//=========
function winningRefByCount(e: IInterface): integer;
var
    i: integer;
    ref: IInterface;
begin
    result := 0;
    for i := 0 to ReferencedByCount(e)-1 do begin
        ref := ReferencedByIndex(e, i);
        if Copy(editorId(ref), 1, 2) = 'QA' then continue;
        if isWinningOverride(ref) then result := result + 1;
    end;
      
end;

// ==============================================
function searchLoadOrderForRecord(edid: String; sigs: TStringList): IInterface;
var
    i, j: integer;
begin
    //First, check radfall.esp
    for j := 0 to sigs.count-1 do begin
        result := MainRecordByEditorID(GroupBySignature(file_radfall, sigs[j]), edid);
        if assigned(result) then exit;
    end;
    //then, start searching at the beginning of the load order
    for i := 0 to fileCount-1 do begin
        for j := 0 to sigs.count-1 do begin
             result := MainRecordByEditorID(GroupBySignature(fileByIndex(i), sigs[j]), edid);
             if assigned(result) then exit;
        end;
    end;
end;

//============================================================================
function GetFilesInFolder(const folder: string; const mask: string): TStringList;
var
  sr: TSearchRec;
begin
  Result := TStringList.Create;
  
  if FindFirst(folder + '\' + mask, faAnyFile, sr) = 0 then
  begin
    repeat
      // skip "." and ".." entries
      if (sr.Name <> '.') and (sr.Name <> '..') then Result.Add(sr.Name);
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
end;
//==============================================
function newSortedTStringList(): TStringList;
begin
    result := TStringList.create;
    result.delimiter := ',';
    result.sorted := true;
    result.Duplicates := dupIgnore;
end;
//=========
function listOf(s: string): TStringList;
begin
    result := TStringList.create;
    //result.StrictDelimiter := True;
    result.Delimiter := ',';
    result.delimitedText := s;
end;

end.