unit log;
const
    log_level = 1;

//=====
procedure trace(msg: string);
begin
    if log_level < 1 then addMessage('          ' + msg);
end;
//=====
procedure debug(msg: string);
begin
    if log_level < 2 then addMessage('      ' + msg);
end;
procedure debugHeading(msg: string);
begin
    if log_level < 2 then addMessage(msg);
end;
//=====
procedure info(msg: string);
begin
    if log_level < 3 then addMessage('    ' + msg);
end;
//=====
procedure infoHeading(msg: string);
begin
    if log_level < 3 then addMessage(msg);
end;
//=====
procedure warn(msg: string);
begin
    if log_level < 4 then addMessage('  WARN: ' + msg);
end;


//#####
end.