unit Radfall_Furniture;
uses 'Radfall\Libs\util';

var
  famineBenchKywdFormId: String;

function initFurniture: Integer;

begin
    
end;

//============================================================================  
procedure runFurniture();
var
    edid: string;
begin
    AddMessage('Initializing Furniture Module');
    famineBenchKywdFormId := getId(getRecord('Radfall.esp', 'KYWD', 'WorkbenchFamine'));
    addMessage('Got keyword for famine cooking bench: ' + famineBenchKywdFormId);
    loadRecordQueue('FURN');
    while recordQueueHasNext() do processFurn(getQueueNextRecord());
    

end;

//============================================================================  
procedure processFurn(furn: IInterface);

begin
    if not hasKeyword(furn, 'WorkbenchCooking') then exit;
    if referencedByCount(furn) = 0 then exit;

    AddMessage('----Processing FURN ' + EditorID(furn) + '------------------------------------------------------');
    furn := copyOverrideToPatch(furn);
    replaceKeyword(furn, 'WorkbenchCooking', famineBenchKywdFormId);
    
end;

end.